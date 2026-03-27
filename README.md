# Leaves Management System

A full-stack Leave Management application built with **Flutter** (frontend) and **Laravel** (backend API).

---

## Features

- User registration and login (JWT authentication)
- Apply for leave (reason, start date, end date)
- View all submitted leave requests
- Delete leave requests (swipe to delete)
- Pull-to-refresh leave list
- Status badges (Pending / Approved / Rejected)
- Clean, consistent UI across all screens

---

## Project Structure

```
leaves/
├── lib/                    # Flutter frontend
│   ├── main.dart           # App entry point
│   ├── models/
│   │   └── leaves_model.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── leave_list_screen.dart
│   │   └── add_leaves_screen.dart
│   └── services/
│       └── api_service.dart
├── backend/                # Laravel API backend
│   ├── app/
│   │   ├── Http/Controllers/Api/
│   │   │   ├── AuthController.php
│   │   │   └── LeaveController.php
│   │   └── Models/
│   │       ├── User.php
│   │       └── Leave.php
│   ├── database/migrations/
│   ├── routes/api.php
│   └── ...
```

---

## Prerequisites

- **Flutter SDK** (3.x or later)
- **PHP** (8.1 or later)
- **Composer** (PHP dependency manager)
- **MySQL** (via XAMPP or standalone)

---

## Backend Setup (Laravel API)

### 1. Install PHP dependencies

```bash
cd backend
composer install
```

### 2. Configure environment

```bash
cp .env.example .env
```

Edit `backend/.env` and set your database credentials:

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=leaves
DB_USERNAME=root
DB_PASSWORD=
```

### 3. Generate keys

```bash
php artisan key:generate
php artisan jwt:secret
```

### 4. Create the database

Open **phpMyAdmin** (http://localhost/phpmyadmin) or MySQL CLI and create a database named `leaves`:

```sql
CREATE DATABASE leaves;
```

### 5. Run migrations

```bash
php artisan migrate
```

This creates the following tables: `users`, `leaves`, `cache`, `jobs`, `sessions`.

### 6. Start the server

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

> Use `--host=0.0.0.0` so the API is accessible from physical devices on the same network.

The API will be available at `http://<your-ip>:8000/api`.

---

## API Endpoints

| Method | Endpoint             | Description          | Auth Required |
|--------|----------------------|----------------------|---------------|
| POST   | `/api/register`      | Register a new user  | No            |
| POST   | `/api/login`         | Login & get JWT token| No            |
| GET    | `/api/leaves`        | List user's leaves   | Yes           |
| POST   | `/api/leaves`        | Create a new leave   | Yes           |
| PUT    | `/api/leaves/{id}`   | Update a leave       | Yes           |
| DELETE | `/api/leaves/{id}`   | Delete a leave       | Yes           |

### Request/Response Examples

**Register:**
```json
POST /api/register
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "0712345678",
  "password": "123456",
  "password_confirmation": "123456"
}
```

**Login:**
```json
POST /api/login
{
  "email": "john@example.com",
  "password": "123456"
}
```

**Create Leave:**
```json
POST /api/leaves
Authorization: Bearer <token>
{
  "reason": "Annual vacation",
  "start_date": "2026-04-01",
  "end_date": "2026-04-05"
}
```

---

## Frontend Setup (Flutter)

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure API URL

Edit `lib/services/api_service.dart` and set your machine's IP address:

```dart
static const String baseUrl = 'http://<YOUR-IP>:8000/api';
```

To find your IP:
- **Mac/Linux:** `ifconfig | grep inet`
- **Windows:** `ipconfig`

### 3. Run the app

```bash
flutter run
```

> For physical device testing, make sure your phone and computer are on the **same Wi-Fi network**.

---

## Usage

1. **Register** — Create a new account with name, email, phone, and password
2. **Login** — Sign in with your email and password
3. **View Leaves** — See all your leave requests with status badges
4. **Apply Leave** — Tap "Apply Leave" button, fill in reason and dates, submit
5. **Delete Leave** — Swipe a leave card left to delete it
6. **Logout** — Tap the logout icon in the top-right corner

---

## Tech Stack

| Layer    | Technology       |
|----------|------------------|
| Frontend | Flutter (Dart)   |
| Backend  | Laravel (PHP)    |
| Database | MySQL            |
| Auth     | JWT (tymon/jwt-auth) |
