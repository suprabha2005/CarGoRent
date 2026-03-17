# 🚗 CarGoRent — Car Rental Platform

A full-stack multi-role car rental application built with **Flutter** and **Node.js**.

---

## 📱 Features

### Customer
- Browse and search available cars by name and type
- View car details with pricing breakdown
- Select rental dates with real-time availability checking
- Multi-step booking flow with add-ons (insurance, GPS, driver, child seat)
- View booking history and payment status

### Vendor
- Register and submit verification documents
- Manage car listings (add, view, update)
- View and approve/reject incoming booking requests
- Vendor approval workflow via admin

### Admin
- Dashboard with platform statistics
- Approve or reject vendor registrations
- Monitor all bookings and users

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| State Management | Provider + ChangeNotifier |
| Backend | Node.js + Express.js |
| Database | MongoDB (Mongoose) |
| Authentication | JWT + flutter_secure_storage |
| Payment | Razorpay Integration |
| Storage | Flutter Secure Storage |

---

## 📁 Project Structure
```
CarGoRent/
├── cargo_rent_app/          # Flutter frontend
│   └── lib/
│       ├── main.dart
│       ├── auth_guard.dart
│       ├── models/          # Dart data models
│       ├── providers/       # State management
│       ├── services/        # API service layer
│       └── screens/
│           ├── auth/        # Login, Register, Verification
│           ├── customer/    # Home, Booking, History
│           ├── vendor/      # Dashboard, Add Car
│           ├── admin/       # Admin Dashboard
│           └── shared/      # Profile, Splash
└── server/                  # Node.js backend
    ├── config/              # Database config
    ├── controllers/         # Business logic
    ├── middleware/          # Auth middleware
    ├── models/              # MongoDB schemas
    └── routes/              # API routes
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8+)
- Node.js (18+)
- MongoDB (local or Atlas)

### Backend Setup
```bash
cd server
npm install
```

Create a `.env` file in the `server/` folder:
```
PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret_key
```

Start the server:
```bash
node index.js
```

### Flutter Setup
```bash
cd cargo_rent_app
flutter pub get
flutter run
```

> **Note:** Make sure the backend server is running before launching the Flutter app.

---

## 🔐 User Roles

| Role | Access |
|------|--------|
| Customer | Browse cars, make bookings, view history |
| Vendor | List cars, manage bookings, requires admin approval |
| Admin | Full platform access, approve vendors |

---

## 📦 Key Packages
```yaml
provider: ^6.1.5          # State management
flutter_secure_storage: ^10.0.0  # Secure token storage
http: ^1.6.0              # API calls
razorpay_flutter: ^1.3.6  # Payment gateway
flutter_animate: ^4.0.0   # Animations
```

---

## 🏗️ Architecture

The app follows a **layered architecture**:

- **Screens** — UI only, no business logic
- **Providers** — State management and business logic
- **Services** — All API calls centralized in `ApiService`
- **Models** — Strongly typed data models

---

## 👨‍💻 Developer

**Suprabha** — Flutter Developer  
GitHub: [@suprabha2005](https://github.com/suprabha2005)