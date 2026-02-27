const express = require('express');
const router = express.Router();
const Car = require('../models/car.js'); // Matching your file name from the image

// Get all cars with optional filters
router.get('/', async (req, res) => {
    try {
        const { search, type } = req.query;
        let query = {};

        // 1. If search text exists, look for matches in Name or Brand
        if (search && search.trim() !== "") {
            query.$or = [
                { name: { $regex: search, $options: 'i' } },
                { brand: { $regex: search, $options: 'i' } }
            ];
        }

        // 2. IMPORTANT: If type is "All", we don't add it to the query.
        // This ensures the database returns everything.
        if (type && type !== "All" && type.trim() !== "") {
            query.type = type;
        }

        console.log("Query constructed:", query); // Check your terminal to see what's being sent to DB

        const cars = await Car.find(query);
        res.status(200).json(cars);
    } catch (error) {
        console.error("Error fetching cars:", error);
        res.status(500).json({ message: "Server Error" });
    }
});

module.exports = router;