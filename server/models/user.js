const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['admin', 'vendor', 'customer'], default: 'customer' },
    isVerified: { type: Boolean, default: false },
    verificationStatus: { type: String, default: 'unverified' },
    businessLicense: { type: String, default: "" },
    idProofUrl: { type: String, default: "" }
});

module.exports = mongoose.models.User || mongoose.model('User', UserSchema);