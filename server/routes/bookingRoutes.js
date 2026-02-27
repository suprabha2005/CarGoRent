const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');

// --- 1. IMPORT THE MODEL ---
// We only import it. DO NOT define 'const BookingSchema' or 'mongoose.model' here.
const Booking = require('../models/Bookings');

// --- HELPER: VERIFY TOKEN ---
const verifyToken = (req) => {
    const token = req.headers.authorization?.split(" ")[1];
    if (!token) return null;
    try {
        return jwt.verify(token, 'secret_key_123');
    } catch (err) {
        return null;
    }
};

// --- 2. CREATE BOOKING ---
router.post('/create', async (req, res) => {
    try {
        const { carId, customerId, vendorId, startDate, endDate, totalPrice } = req.body;
        
        const newBooking = new Booking({
            carId,
            customerId,
            vendorId,
            startDate,
            endDate,
            totalPrice
        });

        await newBooking.save();
        res.status(201).json({ message: "Booking created successfully", booking: newBooking });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- 3. VENDOR: VIEW REQUESTS ---
router.get('/vendor-requests', async (req, res) => {
    try {
        const decoded = verifyToken(req);
        if (!decoded) return res.status(401).json({ message: "Unauthorized" });

        const requests = await Booking.find({ vendorId: decoded.id })
            .populate('carId')
            .populate('customerId', 'name email')
            .sort({ createdAt: -1 });
            
        res.json(requests);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- 4. VENDOR: UPDATE STATUS ---
router.post('/update-status', async (req, res) => {
    try {
        const { bookingId, status } = req.body;
        
        if (!['confirmed', 'cancelled'].includes(status)) {
            return res.status(400).json({ message: "Invalid status update" });
        }

        const updatedBooking = await Booking.findByIdAndUpdate(
            bookingId,
            { status: status },
            { new: true }
        );

        if (!updatedBooking) return res.status(404).json({ message: "Booking not found" });
        
        res.json({ message: `Booking marked as ${status}`, booking: updatedBooking });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- 5. CUSTOMER: VIEW MY BOOKINGS ---
router.get('/my-bookings', async (req, res) => {
    try {
        const decoded = verifyToken(req);
        if (!decoded) return res.status(401).json({ message: "Unauthorized" });

        const bookings = await Booking.find({ customerId: decoded.id })
            .populate('carId', 'name imageUrl brand pricePerDay')
            .sort({ createdAt: -1 });
            
        res.json(bookings);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;