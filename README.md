# 📱 Chat App (Flutter + Firebase)

A simple chat application built with Flutter and Firebase that supports both private messaging and group chats.

## ✨ Features

🔑 User authentication (Firebase Auth – login & signup)

💬 One-to-one chat between users

👥 Group chat with the ability to create new groups

📨 Send & receive text messages in real-time (Firestore)

⏰ Show last message and timestamp in chat list

🔔 Show unread message count for each chat

🖼 Responsive UI using Flutter ScreenUtil

### 🛠 Tech Stack

Flutter

Firebase Authentication

Cloud Firestore

Provider
 for state management

Clean architecture (Model - ViewModel - Service)

## 📂 Folder Structure
lib/
 ┣ core/
 ┃ ┣ constants/        # Colors & styles
 ┃ ┣ models/           # Data models (User, Message, Group)
 ┃ ┣ services/         # Services (ChatService, AuthService)
 ┃ ┗ other/            # BaseViewModel & utilities
 ┣ ui/
 ┃ ┣ screens/          # Screens (Login, ChatList, ChatRoom, GroupInfo)
 ┃ ┗ widgets/          # Reusable widgets (ChatBubble, BottomField, etc.)

## 📌 Roadmap

 File & image sharing

 Push notifications (Firebase Cloud Messaging)

 Improved UI/UX (Dark mode, animations)

## ✍️ Built with ❤️ using Flutter & Firebase by Amir
