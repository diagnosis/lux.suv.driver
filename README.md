# LuxSUV Driver App - React Native

A premium transportation driver application built with React Native and Expo.

## Features

- **Authentication**: Secure login with JWT token storage
- **Dashboard**: Overview of rides, status, and quick actions
- **Ride Management**: View, update, and manage ride requests
- **Calendar View**: Schedule visualization with ride details
- **Profile Management**: Driver profile and settings

## Tech Stack

- **React Native** with Expo
- **React Navigation** for navigation
- **Expo SecureStore** for secure token storage
- **React Native Calendars** for calendar functionality
- **Expo Linear Gradient** for beautiful gradients
- **Vector Icons** for consistent iconography

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- Expo CLI (`npm install -g @expo/cli`)
- iOS Simulator or Android Emulator (or physical device with Expo Go)

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd luxsuv-driver-app
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm start
```

4. Run on your preferred platform:
```bash
npm run ios     # iOS Simulator
npm run android # Android Emulator
npm run web     # Web browser
```

## Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── RideDetailModal.js
│   └── RideUpdateModal.js
├── context/            # React Context providers
│   ├── AuthContext.js
│   └── RideContext.js
├── navigation/         # Navigation configuration
│   ├── AppNavigator.js
│   └── TabNavigator.js
├── screens/           # Screen components
│   ├── DashboardScreen.js
│   ├── LoginScreen.js
│   ├── RidesListScreen.js
│   ├── CalendarScreen.js
│   ├── ProfileScreen.js
│   └── LoadingScreen.js
└── utils/             # Utility functions
```

## API Integration

The app connects to the LuxSUV backend API:
- **Base URL**: `https://luxsuv-backend.fly.dev`
- **Authentication**: JWT Bearer tokens
- **Endpoints**:
  - `POST /driver/login` - Driver authentication
  - `GET /driver/book-rides` - Fetch ride requests
  - `PUT /driver/book-ride/:id` - Update ride status
  - `DELETE /driver/book-ride/:id` - Cancel ride

## Key Features

### Authentication
- Secure login with username/password
- JWT token storage using Expo SecureStore
- Automatic token validation and logout

### Dashboard
- Welcome message with driver name
- Current status indicator
- Today's ride count
- Upcoming rides preview
- Quick action buttons

### Ride Management
- Complete ride list with status indicators
- Detailed ride information modal
- Status updates (requested → accepted → in progress → completed)
- Customer contact information with call/email links
- Ride cancellation functionality

### Calendar Integration
- Monthly calendar view with ride indicators
- Date selection to view daily rides
- Compact ride cards for quick overview

### Profile Management
- Driver information display
- Settings and preferences (coming soon)
- Secure logout functionality

## Styling

The app uses a premium dark theme with:
- **Primary Colors**: Dark navy (#0D0D1A, #1A1A33)
- **Accent Color**: Gold (#CDB649, #E6CC52)
- **Status Colors**: Blue, Green, Orange, Red, Gray
- **Typography**: System fonts with proper weight hierarchy
- **Components**: Glassmorphism cards with subtle borders

## Development

### Adding New Features

1. Create new components in `src/components/`
2. Add new screens in `src/screens/`
3. Update navigation in `src/navigation/`
4. Add API calls to context providers
5. Update styling to match the design system

### Testing

- Test on both iOS and Android platforms
- Verify API integration with backend
- Test authentication flow
- Validate ride management functionality

## Deployment

### iOS (App Store)

1. Build for production:
```bash
expo build:ios
```

2. Follow Expo's iOS deployment guide

### Android (Google Play)

1. Build for production:
```bash
expo build:android
```

2. Follow Expo's Android deployment guide

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is proprietary software for LuxSUV Transportation Services.