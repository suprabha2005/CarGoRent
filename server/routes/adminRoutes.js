const express = require('express');
const router = express.Router();
const User = require('../models/User'); 
const Car = require('../models/Car');
const Booking = require('../models/Booking');

// --- GET ADMIN DASHBOARD STATS ---
router.get('/stats', async (req, res) => {
    try {
        const userCount = await User.countDocuments({ role: { $in: ['customer', 'vendor'] } });
        const carCount = await Car.countDocuments();
        const pendingApprovals = await User.countDocuments({ role: 'vendor', verificationStatus: 'pending' });

        const revenueData = await Booking.aggregate([
            { $match: { status: 'confirmed' } },
            { $group: { _id: null, total: { $sum: "$totalPrice" } } }
        ]);

        const totalRevenue = revenueData.length > 0 ? revenueData[0].total : 0;

        res.json({
            totalUsers: userCount,
            totalCars: carCount,
            pendingApprovals: pendingApprovals,
            totalRevenue: totalRevenue
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- GET LIST OF PENDING VENDORS (WITH DOC LINKS) ---
router.get('/pending-vendors', async (req, res) => {
    try {
        // EXPLICITLY SELECTing the fields to ensure they are sent to Flutter
        const vendors = await User.find({ 
            role: 'vendor', 
            verificationStatus: 'pending' 
        }).select('name email businessLicense idProofUrl'); 
        
        res.json(vendors);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- APPROVE A VENDOR ---
router.post('/approve-vendor', async (req, res) => {
    try {
        const { userId } = req.body;
        await User.findByIdAndUpdate(userId, { verificationStatus: 'verified' });
        res.json({ message: "Vendor approved successfully" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;