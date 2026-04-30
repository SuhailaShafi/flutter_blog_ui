# 📱 Flutter Blog App

A modern Flutter-based blog application built using **MVVM architecture**, **Supabase backend**, and **Provider state management**.

---

## 🚀 Features

### 🔐 Authentication

* Email & Password Signup/Login
* Supabase Authentication integration

### 📝 Blog Management

* Create blog posts
* View all blogs
* Edit blog posts
* Delete blogs

### 🗂️ Categories

* Categorize blogs
* Filter blogs by category

### 👤 User Profile

* View user details
* Logout functionality

---

## 🧱 Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture:

* **Model** → Data models (Blog, User, Category)
* **View** → UI Screens
* **ViewModel** → Business logic using Provider

---

## 🛠️ Tech Stack

* **Flutter**
* **Dart**
* **Supabase** (Backend & Auth)
* **Provider** (State Management)
* **Dio** (API handling)

---

## 📂 Project Structure

```
lib/
 ├── core/
 ├── models/
 ├── viewmodels/
 ├── views/
 ├── widgets/
 └── main.dart
```

---

## ⚙️ Setup Instructions

1. Clone the repository:

```
git clone https://github.com/YOUR_USERNAME/flutter-blog-ui.git
```

2. Navigate to project:

```
cd flutter-blog-ui
```

3. Install dependencies:

```
flutter pub get
```

4. Add your Supabase credentials:

Update:

```
lib/core/constants/app_constants.dart
```

```
supabaseUrl = YOUR_SUPABASE_URL
supabaseAnonKey = YOUR_SUPABASE_ANON_KEY
```

5. Run the app:

```
flutter run
```

---

## ⚠️ Issue Faced

### ❌ Supabase Host Lookup Error

**Error:**

```
Failed host lookup: your_project.supabase.co
```

**Cause:**

* Placeholder URL used instead of actual Supabase project URL

**Fix:**

* Replaced with correct Supabase URL
* Cleaned and rebuilt the project

---

## 📸 Screenshots

*(Add your app screenshots here)*

---

## 📈 Future Improvements

* Image upload for blogs
* Form validation
* Search functionality
* Pagination
* Improved UI animations

---

## 👤 Author

Parvin

---

## ⭐ If you like this project

Give it a ⭐ on GitHub!
