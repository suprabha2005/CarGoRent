const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs'); 
const jwt = require('jsonwebtoken'); 
const axios = require('axios'); 

// 1. Load Environment Variables
dotenv.config();

// 2. Import Models (ONLY ONCE)
const User = require('./models/User'); 
const Car = require('./models/Car');

/** * UPDATED: Pointing to 'Bookings.js' (Capital B, plural)
 * to match your actual filename exactly.
 */
const Booking = require('./models/Bookings'); 

// 3. Import Routes
const carRoutes = require('./routes/carRoutes');
const bookingRoutes = require('./routes/bookingRoutes');

const app = express();

// 4. Middleware
app.use(cors()); 
app.use(express.json());

// 5. Database Connection
mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/CarGoRent')
    .then(() => console.log('MongoDB Connected ✅'))
    .catch(err => console.log('DB connection error:', err));

// --- 6. IMAGE PROXY ROUTE ---
app.get('/api/proxy-image', async (req, res) => {
    try {
        const imageUrl = req.query.url;
        if (!imageUrl) return res.status(400).send("No URL provided");
        
        const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
        const contentType = response.headers['content-type'];
        res.set('Content-Type', contentType);
        res.send(response.data);
    } catch (error) {
        res.status(500).send('Error fetching image');
    }
});

// --- 7. AUTH ROUTES ---
app.post('/api/auth/register', async (req, res) => {
    try {
        const { name, email, password, role, adminCode } = req.body;
        const existingUser = await User.findOne({ email });
        if (existingUser) return res.status(400).json({ message: "Email taken" });

        if (role === 'admin' && adminCode !== "12345") return res.status(401).json({ message: "Invalid Admin Key" });

        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({
            name, email, password: hashedPassword, role,
            isVerified: role === 'customer',
            verificationStatus: role === 'customer' ? 'approved' : 'unverified'
        });
        await newUser.save();
        res.status(201).json({ message: "Success" });
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email });
        if (!user) return res.status(404).json({ message: "User not found" });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ message: "Invalid credentials" });

        const token = jwt.sign({ id: user._id, role: user.role }, 'secret_key_123', { expiresIn: '1d' });
        res.json({ 
            token, 
            user: { id: user._id, name: user.name, role: user.role, verificationStatus: user.verificationStatus } 
        });
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/auth/profile', async (req, res) => {
    try {
        const token = req.headers.authorization?.split(" ")[1];
        if (!token) return res.status(401).json({ message: "No token" });
        const decoded = jwt.verify(token, 'secret_key_123');
        const user = await User.findById(decoded.id).select('-password');
        res.json(user);
    } catch (err) { res.status(401).json({ message: "Unauthorized" }); }
});

app.post('/api/auth/submit-docs', async (req, res) => {
    try {
        const { userId, businessLicense, idProofUrl } = req.body;
        const user = await User.findByIdAndUpdate(userId, { 
            businessLicense, 
            idProofUrl, 
            verificationStatus: 'pending' 
        }, { new: true });
        res.json({ message: "Submitted", status: user.verificationStatus });
    } catch (err) { res.status(500).json({ error: err.message }); }
});

// --- 8. ADMIN ROUTES ---
app.get('/api/admin/pending-vendors', async (req, res) => {
    try {
        const vendors = await User.find({ role: 'vendor', verificationStatus: 'pending' });
        res.json(vendors);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/admin/approve-vendor', async (req, res) => {
    try {
        const { userId } = req.body;
        await User.findByIdAndUpdate(userId, { verificationStatus: 'approved', isVerified: true });
        res.json({ message: "Vendor Approved Successfully" });
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/admin/stats', async (req, res) => {
    try {
        const totalUsers = await User.countDocuments({ role: { $ne: 'admin' } });
        const pendingVendors = await User.countDocuments({ verificationStatus: 'pending' });
        const totalCars = await Car.countDocuments();
        
        // Revenue logic remains the same (sums confirmed bookings)
        const revenueData = await Booking.aggregate([
            { $match: { status: 'confirmed' } },
            { $group: { _id: null, total: { $sum: "$totalPrice" } } }
        ]);
        const totalRevenue = revenueData.length > 0 ? revenueData[0].total : 0;

        res.json({ totalUsers, pendingVendors, totalCars, totalRevenue });
    } catch (err) { res.status(500).json({ error: err.message }); }
});

// --- 9. ROUTE MIDDLEWARE ---
app.use('/api/cars', carRoutes);
app.use('/api/bookings', bookingRoutes);

// 10. Start Server
const PORT = 5000;
app.listen(PORT, () => console.log(`Server started on port ${PORT} ✅`));