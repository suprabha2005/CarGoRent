const mongoose = require('mongoose');

const carSchema = new mongoose.Schema({
    brand: { type: String, required: true },
    model: { type: String, required: true },
    pricePerDay: { type: Number, required: true },
    status: { type: String, enum: ['available', 'rented'], default: 'available' },
    imageURL: { type: String } // This links to your Image Storage cloud
}, { timestamps: true });

module.exports = mongoose.model('Car', carSchema);