const express = require('express');
const router = express.Router();
const Car = require('../models/Car');

// 1. Add a new car
router.post('/add', async (req, res) => {
    try {
        console.log("Incoming Car Data:", req.body); 
        const newCar = new Car(req.body);
        await newCar.save();
        res.status(201).json(newCar);
    } catch (err) {
        console.error("ADD CAR ERROR:", err.message);
        res.status(400).json({ message: err.message });
    }
});

// 2. Fetch all cars (Used by Customer Home)
// CRITICAL: We populate 'vendorId' so the frontend gets the User object
router.get('/', async (req, res) => {
    try {
        const cars = await Car.find()
            .populate('vendorId', 'name email') // This matches the field in your Car model
            .sort({ createdAt: -1 });
        res.json(cars);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 3. Fetch cars for a specific Vendor (Used by Vendor Dashboard)
router.get('/vendor/:vendorId', async (req, res) => {
    try {
        const { vendorId } = req.params;
        const cars = await Car.find({ vendorId: vendorId });
        res.json(cars);
    } catch (err) {
        console.error("FETCH VENDOR CARS ERROR:", err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;