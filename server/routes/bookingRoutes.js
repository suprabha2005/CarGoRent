const express = require('express');
const router = express.Router();
const Booking = require('../models/Bookings');
const jwt = require('jsonwebtoken');

const JWT_SECRET = 'secret_key_123';

const verifyToken = (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(" ")[1];
        if (!token) return res.status(401).json({ message: "No token provided." });
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        return res.status(401).json({ message: "Invalid or expired token." });
    }
};

// ============================================================
// GET /api/bookings/booked-dates/:carId
// Returns all booked date ranges for a car (for frontend calendar)
// ============================================================
router.get('/booked-dates/:carId', async (req, res) => {
    try {
        const bookings = await Booking.find({
            carId: req.params.carId,
            status: { $in: ['pending', 'confirmed'] }
        }).select('startDate endDate status');

        const bookedRanges = bookings.map(b => ({
            startDate: b.startDate,
            endDate: b.endDate,
            status: b.status,
        }));

        res.status(200).json({ bookedRanges });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ============================================================
// POST /api/bookings/create
// ✅ Now checks for overlapping bookings before creating
// ============================================================
router.post('/create', verifyToken, async (req, res) => {
    try {
        const { carId, vendorId, startDate, endDate, totalPrice, addOns, paymentMethod, customerDetails } = req.body;

        if (!carId || !vendorId || !startDate || !endDate || !totalPrice) {
            return res.status(400).json({ message: "Missing required fields." });
        }

        const start = new Date(startDate);
        const end = new Date(endDate);

        if (start >= end) {
            return res.status(400).json({ message: "Start date must be before end date." });
        }

        // ✅ OVERLAP CHECK — find any confirmed/pending booking that overlaps
        const overlapping = await Booking.findOne({
            carId,
            status: { $in: ['pending', 'confirmed'] },
            $or: [
                // New booking starts inside an existing booking
                { startDate: { $lte: start }, endDate: { $gte: start } },
                // New booking ends inside an existing booking
                { startDate: { $lte: end }, endDate: { $gte: end } },
                // New booking completely contains an existing booking
                { startDate: { $gte: start }, endDate: { $lte: end } },
            ]
        });

        if (overlapping) {
            return res.status(409).json({
                message: `This car is already booked from ${new Date(overlapping.startDate).toDateString()} to ${new Date(overlapping.endDate).toDateString()}. Please choose different dates.`
            });
        }

        // ✅ No overlap — create booking
        const newBooking = new Booking({
            carId,
            vendorId,
            customerId: req.user.id,
            startDate: start,
            endDate: end,
            totalPrice,
            status: 'pending',
            addOns: addOns || {},
            paymentMethod: paymentMethod || 'cash',
            customerDetails: customerDetails || {},
        });

        await newBooking.save();

        res.status(201).json({
            message: "Booking request created successfully!",
            booking: newBooking,
        });

    } catch (err) {
        console.error("Booking error:", err);
        res.status(500).json({ message: err.message });
    }
});

// ============================================================
// GET /api/bookings/my-bookings
// Customer's own bookings
// ============================================================
router.get('/my-bookings', verifyToken, async (req, res) => {
    try {
        const bookings = await Booking.find({ customerId: req.user.id })
            .populate('carId', 'name brand imageUrl type pricePerDay')
            .populate('vendorId', 'name email')
            .sort({ createdAt: -1 });
        res.status(200).json(bookings);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ============================================================
// GET /api/bookings/vendor-requests
// Vendor's incoming booking requests
// ============================================================
router.get('/vendor-requests', verifyToken, async (req, res) => {
    try {
        const bookings = await Booking.find({ vendorId: req.user.id })
            .populate('carId', 'name brand imageUrl type pricePerDay')
            .populate('customerId', 'name email')
            .sort({ createdAt: -1 });
        res.status(200).json(bookings);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ============================================================
// POST /api/bookings/update-status
// Vendor approves or rejects
// ============================================================
router.post('/update-status', verifyToken, async (req, res) => {
    try {
        const { bookingId, status } = req.body;
        if (!['confirmed', 'cancelled', 'completed'].includes(status)) {
            return res.status(400).json({ message: "Invalid status." });
        }
        const booking = await Booking.findByIdAndUpdate(
            bookingId,
            { status },
            { new: true }
        );
        if (!booking) return res.status(404).json({ message: "Booking not found." });
        res.status(200).json({ message: "Status updated.", booking });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ============================================================
// GET /api/bookings/all-bookings  (Admin only)
// ============================================================
router.get('/all-bookings', async (req, res) => {
    try {
        const bookings = await Booking.find()
            .populate('carId', 'name brand imageUrl')
            .populate('customerId', 'name email')
            .populate('vendorId', 'name email')
            .sort({ createdAt: -1 });
        res.status(200).json(bookings);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;