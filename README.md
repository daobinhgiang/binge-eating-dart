# BED Support App

A Flutter web application designed to support patients with Binge Eating Disorder (BED) through education, resources, and tools for recovery.

## Features

### Current Features
- **Education Module**: Comprehensive articles about BED, coping strategies, nutrition, and recovery
- **User Authentication**: Secure login and registration using Firebase Auth
- **Responsive Design**: Optimized for web browsers with mobile-friendly layout
- **Article Categories**: Organized content by topic (Understanding BED, Coping Strategies, Nutrition, etc.)
- **Admin Panel**: Easy database population with sample content

### Planned Features
- Progress tracking and journaling
- Support group connections
- Professional resource directory
- Crisis intervention tools
- Mobile app versions

## Technology Stack

- **Frontend**: Flutter Web
- **Backend**: Firebase (Firestore, Authentication)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **UI Framework**: Material Design 3

## Getting Started

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Firebase project with Firestore and Authentication enabled
- Web browser for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bed_app_1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - The Firebase configuration is already set up in `lib/firebase_options.dart`
   - Ensure your Firebase project has Firestore and Authentication enabled
   - The app is configured for the project ID: `bed-app-ef8f8`

4. **Run the application**
   ```bash
   flutter run -d web-server --web-port 8080
   ```

5. **Access the app**
   - Open your browser and navigate to `http://localhost:8080`

### Initial Setup

1. **Populate Sample Data**
   - Navigate to the Admin Panel (click "Admin Panel" button on home screen)
   - Click "Populate Database" to add sample education content
   - This will add 6 sample articles covering various BED-related topics

2. **Create User Account**
   - Click "Login" in the top-right corner
   - Click "Sign Up" to create a new account
   - Use any valid email and password (minimum 6 characters)

## Project Structure

```
lib/
├── main.dart                 # App entry point and routing
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── article.dart         # Article model
│   └── user.dart            # User model
├── providers/               # State management
│   ├── auth_provider.dart   # Authentication logic
│   └── education_provider.dart # Education content management
├── screens/                 # UI screens
│   ├── home_screen.dart     # Main dashboard
│   ├── auth/                # Authentication screens
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── education/           # Education module
│   │   ├── education_screen.dart
│   │   └── article_detail_screen.dart
│   └── admin/               # Admin functionality
│       └── admin_screen.dart
└── utils/                   # Utility functions
    ├── sample_data.dart     # Sample education content
    └── populate_database.dart # Database population script
```

## Key Features Explained

### Education Module
- **Article Categories**: Content is organized into 6 categories:
  - Understanding BED
  - Coping Strategies
  - Nutrition & Eating
  - Mental Health
  - Recovery Journey
  - Support & Resources

- **Article Features**:
  - Rich content with proper formatting
  - Reading time estimates
  - Author information
  - Publication dates
  - Tags for better organization
  - Featured articles highlighting

### Authentication
- Secure user registration and login
- User profiles stored in Firestore
- Session management with automatic login persistence

### Responsive Design
- Mobile-first approach
- Adaptive layouts for different screen sizes
- Touch-friendly interface elements
- Optimized for web browsers

## Development

### Adding New Articles

1. **Via Admin Panel** (Recommended for testing):
   - Use the admin panel to populate sample data
   - Modify `lib/utils/sample_data.dart` to add new articles
   - Re-run the populate database function

2. **Via Firestore Console**:
   - Access Firebase Console
   - Navigate to Firestore Database
   - Add documents to the `articles` collection
   - Follow the Article model structure

### Customizing Content

- **Article Categories**: Modify `ArticleCategory` enum in `lib/models/article.dart`
- **Sample Content**: Edit `lib/utils/sample_data.dart`
- **UI Themes**: Customize colors and styling in `lib/main.dart`

### Database Schema

#### Articles Collection
```json
{
  "title": "string",
  "content": "string",
  "category": "string",
  "author": "string",
  "publishedAt": "timestamp",
  "imageUrl": "string (optional)",
  "tags": ["string array"],
  "readTimeMinutes": "number",
  "isFeatured": "boolean"
}
```

#### Users Collection
```json
{
  "email": "string",
  "displayName": "string (optional)",
  "photoUrl": "string (optional)",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp (optional)",
  "preferences": "object"
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions about this application, please contact the development team or create an issue in the repository.

## Disclaimer

This application is designed to provide educational content and support for individuals with Binge Eating Disorder. It is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of qualified health providers with questions about any medical condition.