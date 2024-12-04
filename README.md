# BallotBox 360

Welcome to **BallotBox 360**, an online voting system that enables secure, transparent, and user-friendly polling experiences. The app provides features like account creation, secure login, ballot selection, and result viewing with a modern and responsive user interface.

The project is currently hosted at:
[BallotBox 360 Web Version](https://ballot-box-360.vercel.app/)

---

## Features

- **User Authentication**: Sign up and log in securely using Firebase Authentication.
- **Dynamic Polling**: View available polls, participate, and track real-time results.
- **Responsive Design**: Optimized for web and mobile devices.
- **Firebase Integration**: Real-time database for managing polls and votes.

---

## Getting Started

### Prerequisites

Ensure you have the following installed:
- **Flutter SDK**: Version 3.24.5 or higher
- **Dart SDK**: Included with Flutter
- **Firebase CLI**: For Firebase configuration and deployment
- **Node.js**: For Firebase tools (optional, but recommended)

---

### Setting Up Firebase

1. Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Add a new Web App to the project and download the `google-services.json` and `firebase-config.js` files.

---

### Running the Project

1. Clone this repository:
   ```bash
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```bash
   cd BallotBox-360
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app in your browser:
   ```bash
   flutter run -d chrome
   ```

---

### Building the Web App

To generate the production build:
```bash
flutter build web
```
The build files will be available in the `build/web` directory.

---

### Deploying the Web App

You can deploy the app using Firebase Hosting, Vercel, or any other hosting platform.

#### Using Firebase Hosting:
1. Initialize Firebase Hosting:
   ```bash
   firebase init hosting
   ```
2. Set the `public` directory to `build/web`.
3. Deploy:
   ```bash
   firebase deploy
   ```

#### Using Vercel:
1. Install Vercel CLI:
   ```bash
   npm install -g vercel
   ```
2. Deploy:
   ```bash
   vercel --prod
   ```

---

## Contributing

Feel free to open issues or submit pull requests for any improvements or bug fixes. Your contributions are welcome!

---

## License

This project is licensed under the MIT License.

---

### Note

Ensure Firebase is set up correctly to access the database and manage authentication. Without Firebase configuration, the app will not function as expected.

---

