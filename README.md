# CodeLevel 


**CodeLevel** is a comprehensive, AI-powered interactive learning platform built with Flutter that revolutionizes how developers learn programming through **immersive game-based learning**, **personalized educational pathways**, and **real-time code validation**. 

### Core Philosophy
CodeLevel moves beyond traditional coding tutorials by combining:
- **Gamified Learning**: 4 distinct language-specific games with 5 progressive levels each (20 total levels)
- **Intelligent Content Delivery**: AI-generated personalized learning paths, adaptive notes, and concept visualizations
- **Real-Time Code Validation**: Language-specific engines that parse and validate Python, JavaScript, SQL, and Java code without execution
- **Multi-Modal Learning**: Combines game-based practice, interactive mind maps, timed quizzes, and visual concept graphs
- **AWS-Powered Backend**: Scalable cloud infrastructure using Cognito for auth, API Gateway for content, and Lambda for dynamic content generation

## Core Features

### 🔐 Authentication & Onboarding
- **AWS Cognito Integration**: Sign up, OTP confirmation, and secure sign-in
- **User Pool Management**: Resend OTP, account verification, session management
- **Language Selection**: Choose your preferred programming language (Python, JavaScript, SQL, Java)

### 📚 Personalized Learning Roadmap
- **AI-Generated Roadmaps**: Basic, Intermediate, and Advanced learning paths
- **API-Powered Content**: Dynamic roadmap generation via AWS API Gateway
- **Adaptive Progression**: Topics unlock based on mastery thresholds

### 🎮 Four Interactive Code Games (Core Differentiator)

#### **1. Python RPG Game** 🐍
Navigate a knight through visual puzzles by writing Python movement commands
- **Levels**: 5 progressive challenges with auto-progression
- **Concepts**: Functions, parameters, control flow, logic puzzles
- **Gameplay**: Guide your character to the treasure chest using `move_right()`, `move_left()`, `turn_left()` commands
- **Engine**: Visual Flame game with real-time validation
- **Level Files**: `assets/levels/python/level_{1-5}.json`

#### **2. JavaScript Logic Game** 🧙
Master JavaScript fundamentals through logic-based challenges
- **Levels**: 5 progressive challenges
- **Concepts**: Variables, conditionals, loops, function calls
- **Gameplay**: Write valid JavaScript code to unlock doors and complete objectives
- **Validation**: Variable declaration, conditional logic, and loop structure recognition
- **Level Files**: `assets/levels/javascript/level_{1-5}.json`

#### **3. SQL Puzzle Game** 📦
Query databases and retrieve data using SQL
- **Levels**: 5 progressive challenges (SELECT → Columns → Filtering → Advanced filtering → Sorting/Limiting)
- **Concepts**: SELECT statements, WHERE clauses, column selection, filtering, sorting, limiting
- **Gameplay**: Write SQL queries to fetch the correct data from tables
- **Validation**: Query parsing, table validation, WHERE clause evaluation, result comparison
- **Level Files**: `assets/levels/sql/level_{1-5}.json`

#### **4. Java Game** ☕
Master Java fundamentals and object-oriented programming
- **Levels**: 5 progressive challenges
- **Concepts**: Classes, methods, variables, control structures
- **Gameplay**: Solve OOP-based coding challenges to progress through levels
- **Validation**: Syntax checking and execution validation
- **Level Files**: `assets/levels/java/level_{1-5}.json`

### 📖 Level & Topic Learning
- **Dynamic Content Overview**: Per-topic summaries and key concepts
- **Multiple Learning Modalities**:
  - Conceptual mind maps
  - Logical/flow diagrams
  - Official tutorials and references
- **Topic Task System**:
  - Notes generation and structured rendering
  - Timed MCQ assessments with instant scoring
  - Logic building via interactive concept graphs

### 📝 AI-Powered Learning Tools
- **AI Notes**: Structured, context-aware note generation via API
- **Assessment Quizzes**: Timed MCQ tests with real-time scoring and result analysis
- **Concept Visualization**: Interactive node-based graphs of programming concepts
- **AI Hints in Games**: Context-aware hints powered by Google Gemini API
- **AI Recommendations Dashboard**: Personalized learning suggestions and progress insights

### 📊 Analytics & Progress Tracking
- **Learner Dashboard**: Track game progress, assessment scores, and topic mastery
- **Performance Analytics**: Time-on-task analysis, accuracy trends, and completion rates
- **Profile Management**: User information, learning history, and preference management
- **Progress Cards**: Visual representation of completed and in-progress topics

## 📋 Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/                              # Core engine & interpreter logic
│   ├── engine/                        # Game engines for each language
│   ├── interpreter/                   # Code interpreters & validators
│   └── models/                        # Data models
├── games/                             # Game implementations
│   ├── python/                        # Python RPG game
│   ├── javascript/                    # JavaScript logic game
│   ├── sql/                           # SQL puzzle game
│   └── java/                          # Java game
├── screens/                           # UI screens
│   ├── login_screen.dart
│   ├── language_selection_screen.dart
│   ├── game_hub_screen.dart
│   ├── level_detail_screen.dart
│   ├── ai_recommendation_screen.dart
│   ├── analytics_screen.dart
│   └── ...                            # Other feature screens
├── services/                          # API and business logic services
├── models/                            # Data models
├── theme/                             # App theming
└── widgets/                           # Reusable UI components

assets/
├── images/                            # App images & icons
└── levels/                            # Level configurations
    ├── python/                        # Python level files (JSON)
    ├── javascript/                    # JavaScript level files
    ├── sql/                           # SQL level files
    └── java/                          # Java level files
```

## 🚀 Getting Started

### Prerequisites

- **Flutter**: Ensure Flutter 3.10.7+ is installed ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart**: Included with Flutter
- **Android/iOS Development**: 
  - For Android: Android Studio with Android SDK
  - For iOS: Xcode (macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd developer_productivity
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Cognito**
   - Update AWS Cognito credentials in `services/cognito_service.dart`
   - Set your app client ID, user pool ID, and region

4. **Run the app**
   ```bash
   flutter run
   ```

## 🎯 User Journey Flow

### Complete Learning Path
```
1. Authentication Phase
   ↓
   Login/Register → OTP Confirmation → Sign In (Cognito)
   
2. Onboarding Phase
   ↓
   Language Selection → Welcome Screen → Main Navigation
   
3. Learning Phase (Parallel Tracks)
   ├─ Roadmap Tab
   │  └─ Browse Roadmap (Basic/Intermediate/Advanced)
   │     └─ Select Level
   │        └─ Level Details (Overview + Topics/Maps)
   │
   ├─ Topic Task Screen
   │  ├─ Read AI-Generated Notes
   │  ├─ Take Timed MCQ Assessment
   │  │  └─ View Result & Feedback
   │  └─ Explore Interactive Concept Graphs
   │
   └─ Games Tab
      └─ Choose Language Game
         └─ Run Code in Editor
            └─ Engine Validates Solution
               └─ Win/Loss → Auto Progress to Next Level (Levels 1-5)
   
4. Dashboard Phase
   ↓
   Analytics Screen → View Progress Metrics
   AI Recommendations → Personalized Suggestions
   Profile Screen → Manage Account
```

### Key Entry Points
- **main.dart**: App initialization and theme
- **login_screen.dart**: Authentication UI (sign up, OTP, login)
- **language_selection_screen.dart**: Programming language selection
- **main_navigation_screen.dart**: Main app navigation with tabs
  - Home (Roadmap)
  - Games (Code GameHub)
  - Profile & Analytics

## ☁️ Cloud Architecture & AWS Services

### AWS Cognito User Pool
**Location**: `lib/services/cognito_service.dart`
- User registration and sign-up
- OTP verification and confirmation
- Secure sign-in and authentication
- Session management and token handling
- Multi-factor authentication support (optional)

### AWS API Gateway
**Base URL**: execute-api endpoints (Cognito-authenticated)

**Active Endpoints**:
1. **`/generate-roadmap`** → `roadmap_service.dart`, `ai_roadmap_service.dart`
   - Generates personalized learning paths (Basic/Intermediate/Advanced)
   - Returns topic hierarchy and progression recommendations

2. **`/notes`** → `notes_service.dart`
   - Fetches or generate structured learning notes
   - Returns content for `topic_notes_screen.dart`

3. **`/generate-assessment`** → `assessment_service.dart`, `assessment_screen.dart`
   - Generates MCQ assessment questions
   - Returns quiz metadata (time limit, scoring rules)

4. **`/generate-visualization`** → `api_service.dart`
   - Generates interactive concept graphs
   - Returns node/edge topology for `concept_graph_view.dart`

### Backend Services (Behind API Gateway)
Likely implementation (not in this repo):
- **AWS Lambda**: Serverless handlers for roadmap, notes, assessment, and visualization generation
- **DynamoDB or RDS**: Persistent storage for user progress, learning content, and analytics
- **S3**: Asset and content storage (level configurations, images)
- **CloudWatch**: Application logs and monitoring



