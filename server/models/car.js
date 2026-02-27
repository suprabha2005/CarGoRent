const mongoose = require('mongoose');

const CarSchema = new mongoose.Schema({
    name: { type: String, required: true },
    brand: { type: String, required: true },
    type: { type: String, required: true },
    pricePerDay: { type: Number, required: true },
    imageUrl: { type: String, required: true },
    description: { type: String },
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    isAvailable: { type: Boolean, default: true },
    createdAt: { type: Date, default: Date.now }
}, { collection: 'cars' }); // Explicitly set collection name

module.exports = mongoose.models.Car || mongoose.model('Car', CarSchema);