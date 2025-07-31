# WATTMATES ⚡

A comprehensive Flutter mobile application for managing **electricity consumption and billing records** for tenants and landlords.  

---

## 📱 Features  

### Core Functionality  
- **Dashboard:** Visual overview of electricity consumption with interactive charts  
- **Records Management:** Add, edit, and delete electricity consumption records  
- **Advanced Search:** Search records by name, room, date, or values  
- **Reports & Analytics:** Detailed analytics with export capabilities  
- **History Tracking:** Monthly consumption history with filtering  
- **Settings:** Theme toggle and data management  

### Key Capabilities  
- 📊 **Visual Analytics:** Custom bar charts showing monthly consumption patterns  
- 🔍 **Smart Search:** Debounced search with real-time filtering  
- 🏠 **Room-based Tracking:** Organize consumption by rooms/units  
- 📅 **Date-based Filtering:** View records by specific months or periods  
- 💰 **Cost Calculations:** Automatic total price calculations based on kWh rates  
- 🌙 **Dark/Light Theme:** Toggle between themes with persistent settings  
- 📱 **Responsive Design:** Optimized for mobile devices  

---

## 🏗️ Architecture  

### Project Structure  


### Database Schema  
- SQLite local database for offline functionality  
- Automatic ID generation for records  
- Indexed columns for optimized queries  
- 12-month limit enforcement per client to manage storage  

---

## 🚀 Getting Started  

### Prerequisites  
- **Flutter SDK (>=3.0.0)**  
- **Dart SDK (>=3.0.0)**  
- Android Studio / VS Code  
- Android/iOS device or emulator  

### Dependencies  
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0              # Local SQLite database
  shared_preferences: ^2.2.2   # Theme persistence
  intl: ^0.18.1                # Date formatting
  path: ^1.8.3                 # File path utilities
