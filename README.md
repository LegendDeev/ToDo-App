# 🚀 Elite Todo - Master Your Goals

A beautiful, feature-rich **Flutter** todo and goal management application designed to help you stay organized, focused, and motivated. Track your daily tasks, set ambitious goals, and monitor your progress with intuitive statistics and reminders.

---

## 📱 App Features

### Core Features
- **Goal Management**: Create, update, and delete goals with custom titles and descriptions
- **Task Tracking**: Organize tasks within goals with detailed descriptions and deadlines
- **Priority Levels**: Set priority for goals (Low, Medium, High, Critical) to focus on what matters
- **Deadline Management**: Set specific deadlines for goals and receive timely reminders
- **Recurrence Options**: Configure goals to repeat (None, Daily, Weekly, Monthly)
- **Reminder Notifications**: Enable smart reminders with customizable time slots (Morning, Afternoon, Evening)

### Analytics Dashboard
- **Statistics Overview**: View at-a-glance metrics including:
  - Total Tasks count
  - Completed Tasks percentage
  - Success Rate visualization
  - Current Streak tracking
- **Task Filtering**: Filter tasks by status (All, Today, Pending, Completed)
- **Progress Monitoring**: Track completion rates and maintain motivation through visual feedback

### User Experience
- **Search Functionality**: Quickly find goals using the integrated search feature
- **Goal Status Indicators**: Visual indicators for task completion and due date status
- **Motivational Interface**: Encouraging messages and achievement badges to inspire consistent progress
- **Dark Mode Support**: Eye-friendly interface with dark theme optimization

---

## 📸 Screenshots

### 1. Goal Creation Screen
Create new goals with detailed information:
![Goal Creation](https://github.com/LegendDeev/ToDo-App/blob/main/assets/screenshots/Screenshot_2025-12-28-21-09-20-825_com.example.ego.jpg)

### 2. Loading Screen
Beautiful splash screen with app branding:
![Loading Screen](https://github.com/LegendDeev/ToDo-App/blob/main/assets/screenshots/Screenshot_2025-12-28-21-06-03-035_com.example.ego.jpg)

### 3. Main Dashboard
View all goals and tasks with statistics:
![Main Dashboard](https://github.com/LegendDeev/ToDo-App/blob/main/assets/screenshots/Screenshot_2025-12-28-21-09-05-899_com.example.ego.jpg)

### 4. Filtered Tasks (Pending View)
Track pending tasks and manage deadlines:
![Pending Tasks](https://github.com/LegendDeev/ToDo-App/blob/main/assets/screenshots/Screenshot_2025-12-28-21-09-09-910_com.example.ego.jpg)

### 5. Task Completion View
View completed goals and celebrate achievements:
![Completed Tasks](https://github.com/LegendDeev/ToDo-App/blob/main/assets/screenshots/Screenshot_2025-12-28-21-09-14-665_com.example.ego.jpg)

### 6. Task Actions
Manage tasks with delete and completion options:
![Task Actions](https://github.com/LegendDeev/ToDo-App/blob/main/assets/screenshots/Screenshot_2025-12-28-21-09-12-783_com.example.ego.jpg)

---

## 🏗️ Technical Stack

### Frontend
- **Framework**: [Flutter](https://flutter.dev/) - Cross-platform mobile development
- **Language**: [Dart](https://dart.dev/)
- **UI Components**: Material Design 3 with custom styling

### State Management
- **GetX**: Reactive state management and navigation
- **RxDart**: Reactive extensions for Dart

### Local Storage
- **SQLite**: Reliable local database for goal and task persistence
- **SharedPreferences**: Lightweight key-value storage for app settings

### Additional Libraries
- **Intl**: Internationalization and date formatting
- **UUID**: Unique identifier generation for goals and tasks

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.0 or higher)
- Dart SDK (v3.0 or higher)
- Android Studio / Xcode (for emulator/device testing)
- Git

### Installation

1. **Clone the repository**:
git clone https://github.com/LegendDeev/ToDo-App.git
cd ToDo-App

2. **Install dependencies**:
flutter pub get

3. **Run the app**:
flutter run

4. **Build for production**:
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

---

## 📁 Project Structure

```bash
ToDo-App/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models (Goal, Task)
│   ├── controllers/              # GetX controllers for state management
│   ├── screens/
│   │   ├── home_screen.dart     # Main dashboard
│   │   ├── goal_creation.dart   # Goal creation form
│   │   ├── task_detail.dart     # Individual task details
│   │   └── splash_screen.dart   # Loading/splash screen
│   ├── widgets/                  # Reusable UI components
│   ├── services/                 # Database and API services
│   ├── utils/                    # Helper functions and constants
│   └── styles/                   # Theme and styling
├── assets/
│   ├── images/                   # App icons and images
│   └── fonts/                    # Custom fonts
├── pubspec.yaml                  # Dependencies and project configuration
└── README.md                      # This file
```
---

## 🎯 Usage Guide

### Creating a Goal
1. Tap the **"ADD GOAL"** button on the home screen
2. Enter goal title (e.g., "Complete project documentation")
3. Add optional description with details
4. Set a deadline date and time
5. Choose recurrence pattern (None, Daily, Weekly, Monthly)
6. Select priority level (Low, Medium, High, Critical)
7. Enable reminders and choose preferred time slot
8. Tap **"CREATE GOAL"** to save

### Managing Tasks
- **View Tasks**: Navigate through All, Today, Pending, and Completed tabs
- **Complete Task**: Tap the checkbox to mark a task as completed
- **Delete Task**: Swipe left or tap the trash icon to remove a task
- **Search**: Use the search bar to quickly find specific goals

### Tracking Progress
- Monitor your **Success Rate** percentage
- Check your **Current Streak** count
- Review **Total Tasks** and **Completed** counts
- Track daily and weekly progress

### Notifications
- Reminders are sent at your chosen time (Morning, Afternoon, Evening)
- Notifications appear only for active goals with enabled reminders
- Configure notification preferences in goal settings

---

## 🔧 Configuration

### Environment Variables
If using environment-specific configurations:
# Create a .env file in the root directory
APP_NAME=Elite Todo
ENABLE_ANALYTICS=true

### Theme Customization

Modify `lib/styles/theme.dart` to customize colors, fonts, and spacing:

const primaryColor = Color(0xFF6366F1); // Indigo

const accentColor = Color(0xFF10B981);  // Emerald

const darkBg = Color(0xFF1F2125);       // Charcoal

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork the repository**: Click the "Fork" button on GitHub
2. **Create a feature branch**:
git checkout -b feature/your-feature-name

3. **Make your changes** and commit:
git commit -m "feat: Add new feature"

4. **Push to your fork**:
git push origin feature/your-feature-name

5. **Create a Pull Request** with a clear description of changes

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

---

## 🐛 Bug Reports & Features

Found a bug or have a feature request?
- **Issue Tracker**: [GitHub Issues](https://github.com/LegendDeev/ToDo-App/issues)
- **Submit Issue**: Include steps to reproduce, expected behavior, and device information

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 About Developer

Built with ❤️ by [LegendDeev](https://github.com/LegendDeev)

- **GitHub**: [@LegendDeev](https://github.com/LegendDeev)
- **Location**: Ghaziabad, Uttar Pradesh, India
- **Tech Stack**: Flutter, Dart, Java, JavaScript, React

---

## 🙏 Acknowledgments

- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design](https://material.io/) for UI guidelines
- [GetX Package](https://pub.dev/packages/get) for state management
- All contributors and users who support this project

---

## 📞 Support

If you encounter any issues or need assistance:
1. Check existing [GitHub Issues](https://github.com/LegendDeev/ToDo-App/issues)
2. Create a new issue with detailed information
3. Reach out on social media or contact directly

---

## 🎉 Changelog

### v1.0.0 (Current Release)
- ✅ Goal creation and management
- ✅ Task tracking with deadlines
- ✅ Priority levels system
- ✅ Recurring goals support
- ✅ Smart reminder notifications
- ✅ Analytics and progress tracking
- ✅ Search functionality
- ✅ Dark mode support

---

## 🔮 Future Roadmap

- [ ] Cloud synchronization (Firebase)
- [ ] Goal sharing and collaboration
- [ ] Advanced analytics with charts
- [ ] Habit tracking integration
- [ ] Multi-language support
- [ ] Widget support for home screen
- [ ] AI-powered goal suggestions
- [ ] Export goals to PDF/CSV

---

**Made with 💙 by LegendDeev** | Star this repo if you found it helpful! ⭐
