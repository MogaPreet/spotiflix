# Spotiflix

<p align="center">
<img src="assets/images/spotiflix_logo.png" alt="Spotiflix Logo" width="200"/>
</p>

Spotiflix is a cross-platform media streaming application that combines the best features of music and video streaming services. Built with Flutter and Appwrite, it offers a seamless experience for browsing, discovering, and enjoying your favorite media content.

## ✨ Features

- **User Authentication**: Secure login and registration system
- **Personalized Home Feed**: Customized content recommendations
- **Media Playback**: Integrated audio and video players
- **Content Discovery**: Browse through various categories of content
- **User Profiles**: Personalized user experience
- **Dark Mode**: Easy on the eyes with a sleek dark theme
- **Responsive Design**: Works on mobile, tablet, and web

## 🛠️ Tech Stack

- **Frontend**: Flutter
- **Backend**: Appwrite
- **State Management**: Provider
- **UI Components**:
- carousel_slider for image carousels
- shimmer for loading effects
- google_fonts for typography
- animated_text_kit for text animations
- **Media Playback**: youtube_player_flutter
- **Storage**: flutter_secure_storage, shared_preferences

## 🚀 Installation

1. **Prerequisites**:
- Flutter (latest stable version)
- Dart
- Git
- An Appwrite instance (for backend)

2. **Clone the repository**:
```bash
git clone https://github.com/MogaPreet/spotiflix.git
cd spotiflix
```

3. **Install dependencies**:
```bash
flutter pub get
```

4. **Configure Appwrite**:
- Create an Appwrite project
- Configure the environment variables (see `.env.example`)
- Set up the necessary collections and functions

5. **Run the app**:
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart           # Application entry point
├── models/             # Data models
├── providers/          # State management
├── screens/            # Application screens
├── services/           # API and backend services
├── utils/              # Utility functions
├── widgets/            # Reusable UI components
└── constants/          # App constants and theme data
```

<!-- ## 📸 Screenshots

<p align="center">
<img src="screenshots/home.png" alt="Home Screen" width="200"/>
<img src="screenshots/player.png" alt="Player Screen" width="200"/>
<img src="screenshots/profile.png" alt="Profile Screen" width="200"/>
</p> -->

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

Your Name - preetmoga777@gmail.com

Project Link: [https://github.com/MogaPreet/spotiflix](https://github.com/MogaPreet/spotiflix)
