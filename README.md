# 📈 Indian Stocks App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web-lightgrey.svg)

**A modern, feature-rich Flutter application for tracking Indian stock market data with stunning glassmorphism UI and advanced charting capabilities.**

[Features](#-features) • [Installation](#-installation) • [Configuration](#-configuration) • [Screenshots](#-screenshots) • [Contributing](#-contributing)

</div>

---

## ✨ Features

### 📊 **Advanced Stock Market Data**
- 🔄 **Real-time stock quotes** from TwelveData API
- 🏢 **Popular Indian stocks** (NSE/BSE integration)
- 🔍 **Intelligent search** with auto-suggestions
- 📈 **Historical data** and market trends
- ⭐ **Watchlist management** for favorite stocks

### 📈 **Professional Charts & Analytics**
- **Syncfusion Charts Integration** with interactive features
- 📊 **Multiple chart types**: Line, Candlestick, Area, Column
- 🎯 **Interactive tools**: Zoom, pan, crosshair, tooltips
- 📱 **Responsive design** optimized for all screen sizes
- ⚡ **Real-time updates** with smooth animations

### 🎨 **Modern UI/UX Design**
- 🪟 **Glassmorphism design** with frosted glass effects
- 🌓 **Dark/Light theme** with instant switching
- 🎭 **Material 3** design system
- ✨ **Smooth animations** and micro-interactions
- 📱 **Responsive layout** for tablets and phones

### ⚙️ **Advanced Settings & Customization**
- 🔑 **Custom API key** management with validation
- 🎨 **Theme preferences** with system sync
- 🔔 **Notification settings** and price alerts
- 📤 **Share functionality** for app and individual stocks
- 🔄 **Settings backup** and reset options

### 🔐 **Production-Ready Features**
- 🛡️ **Secure environment** variable configuration
- 📝 **Comprehensive logging** and error handling
- ⚡ **Performance monitoring** and optimization
- 🔒 **Data encryption** for sensitive information
- � **CI/CD ready** with automated testing

---

## 🏗️ Architecture

The app follows **Clean Architecture** principles with a modular, scalable structure:

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── providers/          # Global state management
│   ├── services/           # Business logic services
│   └── theme/             # App theming system
├── features/
│   ├── dashboard/         # Home dashboard
│   ├── search/           # Stock search functionality
│   ├── stock_detail/     # Individual stock details
│   ├── watchlist/        # User's favorite stocks
│   ├── settings/         # App configuration
│   └── main/             # Navigation & main layout
└── shared/
    └── widgets/          # Reusable UI components
```

---

## 🚀 Installation

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio / VS Code
- Git

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/indian-stocks-app.git
   cd indian-stocks-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` with your configuration:
   ```env
   TWELVE_DATA_API_KEY=your_api_key_here
   APP_NAME=Indian Stocks
   APP_VERSION=1.0.0
   DEBUG_MODE=false
   ENABLE_LOGGING=false
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

---

## ⚙️ Configuration

### API Setup

1. **Get TwelveData API Key**
   - Visit [TwelveData](https://twelvedata.com/)
   - Sign up for a free account
   - Get your API key from the dashboard

2. **Configure API Key**
   - Add your key to `.env` file, OR
   - Use the in-app settings to enter a custom API key
   - The app includes a fallback demo key for testing

### Build Configuration

#### Debug Build
```bash
flutter run --debug
```

#### Release Build
```bash
flutter build apk --release
flutter build ios --release
```

---

## 📦 Key Dependencies

| Category | Package | Purpose |
|----------|---------|---------|
| **Charts** | `syncfusion_flutter_charts` | Professional charting library |
| **UI Design** | `glass_kit`, `glassmorphism` | Glassmorphism effects |
| **Animations** | `flutter_staggered_animations` | Smooth transitions |
| **State Management** | `provider` | Reactive state management |
| **Networking** | `http`, `dio` | API communication |
| **Storage** | `hive`, `shared_preferences` | Local data persistence |
| **Utils** | `intl`, `share_plus`, `url_launcher` | Internationalization & sharing |

---

## � Design System

### Color Palette
- **Primary**: Deep Blue (`#1E40AF`)
- **Secondary**: Cyan Gradient (`#0891B2`)
- **Success**: Green (`#10B981`)
- **Warning**: Amber (`#F59E0B`)
- **Error**: Red (`#EF4444`)

### Typography
- **Font Family**: Poppins
- **Weights**: Light (300), Regular (400), Medium (500), Semi-Bold (600), Bold (700)

### Components
- **Glass Containers**: Frosted glass effect with blur
- **Neumorphic Elements**: Soft, embossed design
- **Gradient Backgrounds**: Smooth color transitions
- **Interactive Charts**: Touch-responsive data visualization

---

## 🧪 Testing

Run the test suite:
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
```

---

## 🔧 Development

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` for static analysis
- Format code with `dart format`

### Git Workflow
1. Create feature branch: `git checkout -b feature/new-feature`
2. Commit changes: `git commit -m "Add new feature"`
3. Push branch: `git push origin feature/new-feature`
4. Create Pull Request

---

## 📱 Screenshots

<div align="center">

| Dashboard | Stock Details | Search | Settings |
|-----------|---------------|--------|----------|
| ![Dashboard](screenshots/dashboard.png) | ![Details](screenshots/details.png) | ![Search](screenshots/search.png) | ![Settings](screenshots/settings.png) |

*Modern glassmorphism design with dark/light theme support*

</div>

---

## 🗺️ Roadmap

- [ ] **Portfolio Tracking** - Personal investment portfolio
- [ ] **News Integration** - Financial news and analysis
- [ ] **Price Alerts** - Push notifications for price changes
- [ ] **Technical Indicators** - RSI, MACD, Bollinger Bands
- [ ] **Options Data** - Options chain and analytics
- [ ] **Social Features** - Community discussions and insights

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### How to Contribute
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

### Contributors
- **[Your Name]** - *Initial work and main development*

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **TwelveData** - For providing reliable financial data API
- **Syncfusion** - For excellent charting components
- **Flutter Community** - For amazing packages and support
- **Material Design** - For design inspiration and guidelines

---

## � Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/indian-stocks-app/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/indian-stocks-app/discussions)
- **Email**: your.email@example.com

---

<div align="center">

**Made with ❤️ and Flutter**

[⭐ Star this repository](https://github.com/yourusername/indian-stocks-app) if you found it helpful!

</div>
