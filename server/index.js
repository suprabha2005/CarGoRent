const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs'); 
const jwt = require('jsonwebtoken'); 

// IMPORT ROUTES
const carRoutes = require('./routes/carRoutes');
const bookingRoutes = require('./routes/bookingRoutes');

dotenv.config();

const app = express();

// Middleware
app.use(cors()); 
app.use(express.json());

// 1. Database Connection
const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/CarGoRent';

mongoose.connect(mongoURI)
    .then(() => console.log('Local MongoDB Connected: localhost:27017 ✅'))
    .catch(err => console.error('MongoDB connection error:', err));

// 2. User Schema & Model
const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['admin', 'vendor', 'customer'], default: 'customer' }
});

const User = mongoose.model('User', userSchema);

// --- HEALTH CHECK ROUTE ---
app.get('/', (req, res) => res.send('CarGoRent API is running... 🚗'));

// 3. Auth Routes
app.post('/api/auth/register', async (req, res) => {
    try {
        const { name, email, password, role } = req.body;
        const existingUser = await User.findOne({ email });
        if (existingUser) return res.status(400).json({ message: 'User already exists' });

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const newUser = new User({ 
            name, 
            email, 
            password: hashedPassword, 
            role 
        });
        
        await newUser.save();
        res.status(201).json({ message: 'User created successfully!' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ message: 'User not found' });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

        const token = jwt.sign(
            { id: user._id, role: user.role },
            process.env.JWT_SECRET || 'super_secret_key_123',
            { expiresIn: '1d' }
        );

        res.json({
            token,
            user: { id: user._id, name: user.name, email: user.email, role: user.role }
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 4. ROUTE MIDDLEWARE
app.use('/api/cars', carRoutes);
app.use('/api/bookings', bookingRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server started on port ${PORT} ✅`);
});