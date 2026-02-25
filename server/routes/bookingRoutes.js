const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

// Define the Booking Schema directly if not already in a separate models file
const bookingSchema = new mongoose.Schema({
    carId: { type: mongoose.Schema.Types.ObjectId, ref: 'Car', required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    totalPrice: { type: Number, required: true },
    status: { type: String, default: 'Confirmed' },
    createdAt: { type: Date, default: Date.now }
});

const Booking = mongoose.model('Booking', bookingSchema);

// POST: /api/bookings/create
router.post('/create', async (req, res) => {
    try {
        console.log("📥 Incoming Booking Request:", req.body); // Check terminal to see if data arrives

        const { carId, userId, startDate, endDate, totalPrice } = req.body;

        // 1. Validate that all fields exist
        if (!carId || !userId || !startDate || !endDate || !totalPrice) {
            console.log("❌ Validation Failed: Missing fields");
            return res.status(400).json({ message: "All fields are required" });
        }

        // 2. Create the booking document
        const newBooking = new Booking({
            carId,
            userId,
            startDate,
            endDate,
            totalPrice
        });

        const savedBooking = await newBooking.save();
        console.log("✅ Booking Saved Successfully:", savedBooking._id);
        
        res.status(201).json(savedBooking);
    } catch (err) {
        console.error("🔥 Server Error during booking:", err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;