# 🗣️ Voice Task Manager (Flutter + BLoC + LLM)

A Flutter application that allows users to create, update, and delete tasks using **voice commands(using Gemini)** and also hadling it manualy with button option . This app integrates a Large Language Model (LLM) to process spoken instructions and uses **BLoC for state management**.

---

## 🚀 Features

- 🎙 Voice-controlled task management
- 🧠 LLM-based natural language command processing
- 📅 Create, update, delete, or bulk delete tasks by voice
- 🧱 BLoC pattern for scalable state management (choose because this is ai based app so it could be at large scale in future that is why i choose bloc )
- 📦 Local task persistence (via  local data source usinh Hive )

---

## 🧩 Architecture

- `Task`: Model class for each task
- `TaskBloc`: Handles all task events and states
- `llmService`: Processes natural language commands and converts them into structured JSON
- `TaskRepository`: Abstract interface to manage tasks
- `TaskLocalDataSource`: Simulated local storage

---

## 🧠 Voice Command Examples

| Command | Action |
|--------|--------|
| "Create a task titled buy groceries at 6 PM" | Creates a task |
| "Update the task meeting to client call at 3 PM" | Updates a task |
| "Delete the task grocery shopping at 7 PM" | Deletes a task |
| "Delete all tasks" | Deletes all tasks |

---


## 🔧 Setup Instructions

1. **Clone the repo:**
   ```bash
   git clone https://github.com/yourusername/voice-task-manager.git
   cd voice-task-manager
   flutter pub get
flutter run



🛠 Tech Stack
Flutter

BLoC (flutter_bloc)

Dart

Voice recognition (e.g., speech_to_text or similar)

LLM Integration (OpenAI API or local LLM)