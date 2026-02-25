const mongoose = require('mongoose');

const carSchema = new mongoose.Schema({
  name: { type: String, required: true },
  brand: { type: String, required: true },
  pricePerDay: { type: Number, required: true },
  imageUrl: { type: String, required: true },
  type: { type: String, required: true },
  vendor: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // Links car to the vendor who added it
  isAvailable: { type: Boolean, default: true }
});

module.exports = mongoose.model('Car', carSchema);