const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/db'); 
const cors = require('cors'); // Add this for Flutter connection

// 1. Load Environment Variables
dotenv.config();

// 2. Initialize Express
const app = express();

// 3. Middleware
app.use(express.json()); // Essential for parsing JSON bodies
app.use(cors()); // Allows your Flutter app to access this API without being blocked

// 4. Connect to Database
// Ensure your .env has MONGO_URI=mongodb://localhost:27017/CarGoRent
connectDB();

// 5. Define Routes
// This links the logic in /routes/auth.js to the /api/auth path
const authRoutes = require('./routes/auth');
app.use('/api/auth', authRoutes);

// 6. Test/Root Route
app.get('/', (req, res) => {
    res.send("CarGoRent Server is Running locally! 🚗💨");
});

// 7. Start the Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server started on port ${PORT} ✅`);
    console.log(`Local MongoDB Connected: localhost:27017 ✅`);
});