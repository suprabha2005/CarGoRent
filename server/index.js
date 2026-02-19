const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors'); // Added this
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();

// Middleware
app.use(cors()); // This allows your Flutter Chrome app to connect
app.use(express.json());

// 1. Database Connection
// Your terminal confirmed this works
const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/CarGoRent';

mongoose.connect(mongoURI)
    .then(() => console.log('Local MongoDB Connected: localhost:27017 ✅'))
    .catch(err => console.error('MongoDB connection error:', err));

// 2. User Schema & Model
const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, default: 'customer' }
});

const User = mongoose.model('User', userSchema);

// 3. Registration Route
app.post('/api/auth/register', async (req, res) => {
    try {
        const { name, email, password, role } = req.body;
        
        // Check if user exists
        const existingUser = await User.findOne({ email });
        if (existingUser) return res.status(400).json({ message: 'User already exists' });

        const newUser = new User({ name, email, password, role });
        await newUser.save();

        res.status(201).json({ message: 'User created successfully!' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 4. Start the Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server started on port ${PORT} ✅`);
});