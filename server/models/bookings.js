const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
    user_id: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', // Links to the User table
        required: true 
    },
    car_id: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'Car', // Links to the Car table
        required: true 
    },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    totalAmount: { type: Number, required: true } // Calculated during the booking flow
}, { timestamps: true });

module.exports = mongoose.model('Booking', bookingSchema);