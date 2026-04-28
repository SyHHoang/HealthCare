# Online Medical Consultation System

A multi-platform system that allows patients to find doctors, book consultations, and communicate in real time.

## Overview

This project simulates a basic healthcare platform with multiple roles including patient, doctor, and admin. Users can search for doctors, book appointments, and chat directly. The system also includes content management for medical articles.

## Features

* Authentication and role-based authorization
* Search doctors by specialty
* Book online consultations
* Real-time chat between patient and doctor
* Patient profile and consultation history
* Doctor verification
* Admin management for medical content

## Tech Stack

* Web: Vue.js
* Mobile: Flutter
* Backend: Node.js, Express
* Database: MongoDB
* 
## Environment Variables

### Backend (.env)

Create a `.env` file inside the backend folder:

```env
PORT=5000
MONGO_URI=
retryWrites=
JWT_SECRET=
IMGBB_API_KEY=
GEMINI_API_KEY=

### Frontend Web (.env)

Create a `.env` file inside the frontend-web folder:
```env
VITE_BASE_URL=
VITE_IMGBB_API_KEY=
VITE_GEMINI_API_KEY=

### Mobile (Flutter)

Create a `.env` file or config file:
```env
BASE_URL=
IMGBB_API_KEY=

---

## Run

### Backend

cd backend
npm install
npm run dev

### Frontend (Web)

cd frontend-web
npm install
npm run dev

### Mobile

cd mobile-app
flutter pub get
flutter run

---

## Notes

This project was built to practice building a fullstack system with multiple roles and real-time features. It focuses on backend structure, authentication, and communication between different platforms.

Some parts can still be improved, especially performance, UI, and adding more real-world features like video call or notifications.
