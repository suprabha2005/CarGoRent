const express = require('express');
const router = express.Router();
const Car = require('../models/car.js');
const jwt = require('jsonwebtoken');

const JWT_SECRET = 'secret_key_123';

// Middleware to verify token
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

// ============================
// 1️⃣ GET ALL CARS (with filters)
// ============================
router.get('/', async (req, res) => {
    try {
        const { search, type } = req.query;
        let query = {};

        if (search && search.trim() !== "") {
            query.$or = [
                { name: { $regex: search, $options: 'i' } },
                { brand: { $regex: search, $options: 'i' } }
            ];
        }

        if (type && type !== "All" && type.trim() !== "") {
            query.type = type;
        }

        const cars = await Car.find(query).populate('vendorId', 'name email');
        res.status(200).json(cars);
    } catch (error) {
        console.error("Error fetching cars:", error);
        res.status(500).json({ message: "Server Error" });
    }
});

// ============================
// 2️⃣ GET VENDOR'S OWN CARS
// ============================
router.get('/vendor/:userId', async (req, res) => {
    try {
        const cars = await Car.find({ vendorId: req.params.userId });
        res.status(200).json(cars);
    } catch (error) {
        res.status(500).json({ message: "Server Error" });
    }
});

// ============================
// 3️⃣ ADD A NEW CAR ✅ THIS WAS MISSING
// ============================
router.post('/', verifyToken, async (req, res) => {
    try {
        const { name, brand, type, pricePerDay, imageUrl, description } = req.body;

        // Validate required fields
        if (!name || !brand || !type || !pricePerDay || !imageUrl) {
            return res.status(400).json({ 
                message: "Missing required fields: name, brand, type, pricePerDay, imageUrl" 
            });
        }

        const newCar = new Car({
            name,
            brand,
            type,
            pricePerDay: Number(pricePerDay),
            imageUrl,
            description: description || '',
            vendorId: req.user.id, // ✅ taken from JWT, not body
            isAvailable: true,
        });

        await newCar.save();

        res.status(201).json({ 
            message: "Car listed successfully!", 
            car: newCar 
        });

    } catch (error) {
        console.error("Error adding car:", error);
        res.status(500).json({ message: error.message });
    }
});

// ============================
// 4️⃣ DELETE A CAR
// ============================
router.delete('/:carId', verifyToken, async (req, res) => {
    try {
        const car = await Car.findById(req.params.carId);
        if (!car) return res.status(404).json({ message: "Car not found." });

        // Only the vendor who owns it can delete
        if (car.vendorId.toString() !== req.user.id) {
            return res.status(403).json({ message: "Not authorized." });
        }

        await Car.findByIdAndDelete(req.params.carId);
        res.status(200).json({ message: "Car deleted successfully." });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;