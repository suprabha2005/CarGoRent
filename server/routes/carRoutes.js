const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

// Define Car Schema
const CarSchema = new mongoose.Schema({
    brand: { type: String, required: true },
    name: { type: String, required: true },
    pricePerDay: { type: Number, required: true },
    type: { type: String, required: true },
    imageUrl: { type: String, required: true },
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    isAvailable: { type: Boolean, default: true }
});

const Car = mongoose.models.Car || mongoose.model('Car', CarSchema);

// --- ADD NEW CAR ---
// This matches: http://localhost:5000/api/cars/add
router.post('/add', async (req, res) => {
    try {
        const { brand, name, pricePerDay, type, imageUrl, vendorId } = req.body;
        
        // Basic validation check
        if (!brand || !name || !pricePerDay || !vendorId) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        const newCar = new Car({
            brand,
            name,
            pricePerDay,
            type,
            imageUrl,
            vendorId
        });

        await newCar.save();
        res.status(201).json({ message: "Car added successfully", car: newCar });
    } catch (err) {
        console.error("Error adding car:", err);
        res.status(500).json({ error: "Database error while adding car" });
    }
});

// --- GET ALL CARS (For Customers) ---
// This matches: http://localhost:5000/api/cars
router.get('/', async (req, res) => {
    try {
        const { type, search } = req.query;
        let query = {};
        
        if (type && type !== 'All') query.type = type;
        if (search) {
            query.$or = [
                { brand: new RegExp(search, 'i') },
                { name: new RegExp(search, 'i') }
            ];
        }

        const cars = await Car.find(query);
        res.json(cars);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- GET VENDOR SPECIFIC CARS ---
// This matches: http://localhost:5000/api/cars/vendor/:vendorId
router.get('/vendor/:vendorId', async (req, res) => {
    try {
        const cars = await Car.find({ vendorId: req.params.vendorId });
        res.json(cars);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;