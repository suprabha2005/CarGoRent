const express = require('express');
const router = express.Router();
const Booking = require('../models/Bookings');
const jwt = require('jsonwebtoken');

const JWT_SECRET = 'secret_key_123';

// ============================
// 1️⃣ CREATE BOOKING (WITH OVERLAP CHECK)
// ============================

router.post('/create', async (req, res) => {
    try {
        const { carId, vendorId, customerId, startDate, endDate, totalPrice } = req.body;

        if (!carId || !vendorId || !customerId || !startDate || !endDate || !totalPrice) {
            return res.status(400).json({ message: "Missing required booking information." });
        }

        const start = new Date(startDate);
        const end = new Date(endDate);

        if (start >= end) {
            return res.status(400).json({ message: "End date must be after start date." });
        }

        // 🔥 Check overlapping bookings
        const overlappingBooking = await Booking.findOne({
            carId,
            status: { $in: ['pending', 'confirmed'] },
            startDate: { $lte: end },
            endDate: { $gte: start }
        });

        if (overlappingBooking) {
            return res.status(400).json({
                message: "Car is already booked for selected dates."
            });
        }

        const newBooking = new Booking({
            carId,
            vendorId,
            customerId,
            startDate: start,
            endDate: end,
            totalPrice,
            status: 'pending'
        });

        await newBooking.save();

        res.status(201).json({
            message: "Booking request created successfully!",
            booking: newBooking
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


// ============================
// 2️⃣ CUSTOMER BOOKING HISTORY
// ============================

router.get('/my-bookings', async (req, res) => {
    try {
        const token = req.headers.authorization?.split(" ")[1];
        const decoded = jwt.verify(token, JWT_SECRET);

        const bookings = await Booking.find({ customerId: decoded.id })
            .populate('carId')
            .populate('vendorId', 'name email')
            .sort({ createdAt: -1 });

        res.json(bookings);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


// ============================
// 3️⃣ VENDOR BOOKING REQUESTS
// ============================

router.get('/vendor-requests', async (req, res) => {
    try {
        const token = req.headers.authorization?.split(" ")[1];
        const decoded = jwt.verify(token, JWT_SECRET);

        const requests = await Booking.find({ vendorId: decoded.id })
            .populate('carId', 'name brand imageUrl')
            .populate('customerId', 'name email')
            .sort({ createdAt: -1 });

        res.json(requests);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


// ============================
// 4️⃣ UPDATE BOOKING STATUS
// ============================

router.post('/update-status', async (req, res) => {
    try {
        const { bookingId, status } = req.body;

        const allowedStatuses = ['confirmed', 'cancelled', 'completed'];

        if (!allowedStatuses.includes(status)) {
            return res.status(400).json({ message: "Invalid status update." });
        }

        const updatedBooking = await Booking.findByIdAndUpdate(
            bookingId,
            { status },
            { new: true }
        );

        if (!updatedBooking) {
            return res.status(404).json({ message: "Booking not found." });
        }

        res.json({
            message: `Booking status updated to ${status}`,
            booking: updatedBooking
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;