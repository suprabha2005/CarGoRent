const router = require('express').Router();
const Car = require('../models/car');
const authMiddleware = require('../middleware/auth'); // We need this to verify the vendor

// POST: Add a new car (Protected - Only for logged-in users)
router.post('/add', authMiddleware, async (req, res) => {
  try {
    const { name, brand, pricePerDay, imageUrl, type } = req.body;
    
    const newCar = new Car({
      name,
      brand,
      pricePerDay,
      imageUrl,
      type,
      vendor: req.user.id // Taken from the JWT token via middleware
    });

    const savedCar = await newCar.save();
    res.status(201).json(savedCar);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET: Fetch all available cars
router.get('/all', async (req, res) => {
  try {
    const cars = await Car.find({ isAvailable: true });
    res.json(cars);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;