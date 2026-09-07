# Product Requirement Document (PRD)

# HabitFlow

## Offline-First Habit Tracker, Journal & Sleep Analytics Mobile Application

---

# Document Information

| Field            | Detail                             |
| ---------------- | ---------------------------------- |
| Product Name     | HabitFlow                          |
| Version          | 1.0                                |
| Platform         | Android & iOS                      |
| Framework        | Flutter                            |
| Architecture     | Clean Architecture + Offline First |
| Database         | SQLite / Drift                     |
| Development Type | Mobile Application                 |
| Document Type    | Product Requirement Document       |

---

# 1. Product Overview

## 1.1 Application Description

HabitFlow adalah aplikasi mobile berbasis Flutter yang dirancang sebagai **personal growth companion** untuk membantu pengguna membangun kebiasaan positif, melakukan refleksi diri, memantau kualitas tidur, dan memahami perkembangan dirinya melalui data.

Aplikasi ini menggabungkan beberapa sistem utama:

- Habit Tracker
- Daily Journal
- Sleep Tracker
- Progress Analytics
- Achievement System
- Behavioral Feedback System

Berbeda dengan aplikasi habit tracker biasa yang hanya berfungsi sebagai checklist aktivitas, HabitFlow memberikan pengalaman pengembangan diri yang lebih lengkap dengan menghubungkan:

- Aktivitas harian
- Konsistensi kebiasaan
- Kondisi emosional
- Pola tidur
- Perkembangan pengguna

Konsep utama aplikasi:

```
Plan
 ↓
Execute
 ↓
Reflect
 ↓
Analyze
 ↓
Improve
```

---

# 2. Background & Problem Statement

Banyak pengguna ingin membangun kebiasaan baru seperti:

- Olahraga rutin
- Membaca buku
- Belajar skill baru
- Meditasi
- Bangun pagi
- Tidur lebih teratur

Namun banyak dari mereka gagal mempertahankan kebiasaan tersebut karena:

1. Tidak memiliki sistem monitoring yang konsisten.
2. Tidak mengetahui penyebab kegagalan kebiasaan.
3. Tidak melakukan evaluasi diri.
4. Tidak melihat perkembangan secara visual.
5. Kehilangan motivasi karena progress tidak terasa.

Sebagian besar aplikasi habit tracker hanya menyediakan:

- Checklist habit
- Reminder
- Statistik sederhana

HabitFlow memberikan solusi dengan membuat sistem yang menggabungkan:

Habit Tracking + Reflection + Sleep Monitoring + Personal Analytics

---

# 3. Product Vision

Membangun aplikasi yang menjadi:

> "Personal Operating System untuk membantu pengguna membangun kehidupan yang lebih baik melalui kebiasaan kecil yang konsisten."

---

# 4. Product Mission

Membantu pengguna:

- Membentuk kebiasaan positif.
- Memahami pola dirinya sendiri.
- Meningkatkan kualitas hidup.
- Melihat perkembangan secara nyata.
- Termotivasi melalui feedback berbasis data.

---

# 5. Product Goals

## Primary Goals

### Goal 1

Menyediakan sistem habit tracking yang mudah digunakan.

### Goal 2

Membantu pengguna melakukan refleksi melalui journaling.

### Goal 3

Membantu pengguna memahami hubungan antara tidur, mood, dan produktivitas.

### Goal 4

Memberikan visualisasi perkembangan pengguna.

### Goal 5

Meningkatkan retention melalui sistem motivasi dan gamifikasi.

---

# 6. Target Users

## Persona 1 — Productivity Enthusiast

### Profile

- Mahasiswa
- Profesional muda
- Entrepreneur
- Freelancer

### Needs

- Mengatur rutinitas.
- Membentuk disiplin.
- Meningkatkan produktivitas.

---

## Persona 2 — Self Improvement User

### Profile

Pengguna yang sedang melakukan pengembangan diri.

### Needs

- Tracking progress.
- Journaling.
- Reflection.

---

## Persona 3 — Lifestyle Optimizer

### Profile

Pengguna yang ingin meningkatkan performa hidup.

### Needs

- Sleep tracking.
- Lifestyle analytics.
- Personal improvement.

---

# 7. Product Principles

## Simple

Aplikasi harus mudah dipahami tanpa tutorial panjang.

## Personal

Aplikasi harus terasa seperti personal assistant.

## Data Driven

Setiap aktivitas pengguna menghasilkan insight.

## Motivational

Progress harus memberikan rasa puas.

## Offline First

Fitur utama harus dapat berjalan tanpa koneksi internet.

---

# 8. Core Features

---

# Feature 1 — User Profile

## Description

Sistem profil pengguna untuk personalisasi aplikasi.

## User Story

Sebagai pengguna, saya ingin memiliki profil agar aplikasi dapat memberikan pengalaman yang lebih personal.

## Functional Requirements

User dapat:

- Membuat profil.
- Mengubah nama.
- Mengubah avatar.
- Mengatur tema aplikasi.
- Mengatur preferensi.

## Data Model

```
User

id
name
avatar
themePreference
createdAt
```

---

# Feature 2 — Habit Management

## Description

Fitur utama untuk membuat dan mengelola kebiasaan.

## User Story

Sebagai pengguna, saya ingin membuat habit agar saya dapat memonitor aktivitas yang ingin saya bangun.

## Functional Requirements

User dapat:

- Membuat habit baru.
- Mengubah habit.
- Menghapus habit.
- Mengarsipkan habit.
- Menentukan kategori.
- Memilih icon.
- Memilih warna.
- Mengatur reminder.
- Mengatur frekuensi.

## Habit Data

```
Habit

id
title
description
category
frequency
target
reminderTime
icon
color
createdAt
status
```

---

# Feature 3 — Habit Completion Tracking

## Description

Sistem pencatatan penyelesaian habit.

## Functional Requirements

User dapat:

- Menandai habit selesai.
- Membatalkan completion.
- Melihat riwayat.
- Melihat tingkat keberhasilan.

Example:

```
Today's Progress

8 / 10 Completed

80%
```

---

# Feature 4 — Habit Streak System

## Description

Sistem streak untuk meningkatkan motivasi.

## System Calculation

Menghitung:

- Current streak.
- Longest streak.
- Weekly consistency.
- Monthly consistency.

Example:

```
🔥 30 Days Streak

Best Record:

45 Days
```

---

# Feature 5 — Daily Journal System

## Description

Fitur journaling yang terintegrasi dengan aktivitas harian.

Tujuan:

Memberikan ruang bagi pengguna untuk memahami:

- Perasaan.
- Perkembangan.
- Hambatan.
- Tujuan berikutnya.

## Functional Requirements

User dapat:

- Membuat journal.
- Mengedit journal.
- Menghapus journal.
- Melihat journal history.
- Mencari journal.

## Morning Journal Template

```
What do I want to achieve today?

My main priority:

Today's intention:
```

## Evening Journal Template

```
What went well today?

What can I improve?

What am I grateful for?
```

## Journal Data

```
Journal

id
date
content
mood
energyLevel
createdAt
```

---

# Feature 6 — Mood Tracking

## Description

Tracking kondisi emosional pengguna.

## Mood Scale

```
5 - Excellent

4 - Good

3 - Normal

2 - Bad

1 - Very Bad
```

## Data

```
Mood

id
date
score
emotion
```

---

# Feature 7 — Sleep Tracker

## Description

Sistem monitoring kebiasaan tidur.

## Functional Requirements

User dapat:

- Input waktu tidur.
- Input waktu bangun.
- Mengukur durasi tidur.
- Memberikan kualitas tidur.
- Melihat statistik.

## Sleep Data

```
SleepRecord

id
date
sleepStart
sleepEnd
duration
quality
```

---

# Feature 8 — Analytics Dashboard

## Description

Dashboard perkembangan pengguna.

## Dashboard Components

## Daily Overview

Menampilkan:

- Today's progress.
- Habit completion.
- Current streak.
- Daily score.

---

## Habit Analytics

Menampilkan:

- Weekly completion chart.
- Monthly completion chart.
- Habit performance.

---

## Sleep Analytics

Menampilkan:

- Average sleep duration.
- Sleep consistency.
- Sleep score.

---

## Personal Insight

Example:

```
Your habit completion improves
when your sleep duration is above 7 hours.
```

---

# Feature 9 — Gamification System

## Description

Sistem penghargaan untuk meningkatkan engagement.

## Achievement Example

```
🏆 First Habit Completed

🔥 30 Days Streak

📖 50 Journal Entries

🌙 Sleep Master
```

## XP System

```
Level 10

Consistency Builder

XP: 2000
```

---

# Feature 10 — Notification System

## Description

Reminder aktivitas pengguna.

## Notification Types

Habit Reminder:

```
Time to complete your habit.
```

Journal Reminder:

```
Reflect your day.
```

Sleep Reminder:

```
Prepare for better sleep.
```

---

# 9. UI/UX Requirement

# Design Direction

Style:

- Modern
- Minimal
- Premium
- Calm
- Mobile friendly

Reference:

- Apple Health
- Notion
- Headspace
- Linear

---

# Theme System

## Light Mode

Requirements:

- Clean background.
- Soft color.
- High readability.

## Dark Mode

Requirements:

- OLED friendly.
- Comfortable penggunaan malam.
- High contrast.

---

# Application Screens

## 1. Splash Screen

Contains:

- Logo.
- Animation.

---

## 2. Dashboard Screen

Contains:

- Greeting.
- Daily progress.
- Habit list.
- Sleep summary.
- Journal reminder.

---

## 3. Habit Screen

Contains:

- Habit cards.
- Completion button.
- Progress indicator.

---

## 4. Journal Screen

Contains:

- Writing editor.
- Mood selector.
- History.

---

## 5. Analytics Screen

Contains:

- Charts.
- Statistics.
- Achievement.

---

# 10. Technical Requirement

# Technology Stack

## Frontend

Flutter

## Programming Language

Dart

## Architecture

Clean Architecture

## State Management

Riverpod

## Local Database

Drift Database (SQLite)

---

# Project Structure

```
lib/

├── core/

│   ├── database

│   ├── theme

│   ├── utils


├── features/

│   ├── habit

│   ├── journal

│   ├── sleep

│   ├── analytics


└── shared/
```

---

# Required Packages

## Core

```
flutter_riverpod

go_router

drift

sqlite3_flutter_libs

path_provider
```

## UI

```
fl_chart

google_fonts

animations

lottie
```

## Notification

```
flutter_local_notifications
```

---

# 11. Database Design

## users

```
id
name
avatar
theme
created_at
```

---

## habits

```
id
title
description
category
frequency
created_at
```

---

## habit_logs

```
id
habit_id
date
completed
```

---

## journals

```
id
date
content
mood
energy
```

---

## sleep_records

```
id
date
sleep_time
wake_time
duration
quality
```

---

## achievements

```
id
name
unlock_date
```

---

# 12. Non Functional Requirements

## Performance

Application startup:

< 2 seconds

Database query:

< 100ms

---

## Offline Capability

Aplikasi tetap dapat digunakan tanpa:

- Internet.
- Server.
- Cloud.

---

## Security

Requirement:

- Local encrypted database.
- Private user data.
- Tidak mengirim data tanpa izin.

---

# 13. Development Roadmap

# Sprint 1 — Foundation

Duration:

2 Weeks

Tasks:

- Flutter setup.
- Clean architecture.
- Database.
- Theme system.

---

# Sprint 2 — Habit System

Duration:

3 Weeks

Tasks:

- Habit CRUD.
- Completion tracking.
- Streak.

---

# Sprint 3 — Journal System

Duration:

2 Weeks

Tasks:

- Journal editor.
- Mood tracking.

---

# Sprint 4 — Sleep Tracker

Duration:

2 Weeks

Tasks:

- Sleep input.
- Sleep calculation.
- Sleep statistics.

---

# Sprint 5 — Analytics

Duration:

3 Weeks

Tasks:

- Dashboard.
- Charts.
- Achievement.

---

# Sprint 6 — Optimization

Duration:

2 Weeks

Tasks:

- Testing.
- Performance improvement.
- UI polishing.

---

# 14. Success Metrics

## User Engagement

Target:

70% daily active usage.

---

## Habit Completion

Target:

60% average completion rate.

---

## Journal Engagement

Target:

3 journal entries per week.

---

## Retention

Target:

40% Day-30 retention.

---

# 15. Future Development

## Cloud Sync

Features:

- Account system.
- Backup.
- Multi device synchronization.

---

## AI Personal Coach

Features:

- Habit recommendation.
- Journal analysis.
- Personalized advice.

---

## Health Integration

Integration:

- Google Fit.
- Apple Health.
- Smart Watch.

---

# Final Product Statement

HabitFlow bukan hanya aplikasi habit tracker.

HabitFlow adalah sistem pengembangan diri digital yang membantu pengguna:

- Membentuk kebiasaan.
- Memahami diri sendiri.
- Mengoptimalkan gaya hidup.
- Mengukur perkembangan.

Core system:

```
Habit Tracking

+

Journaling

+

Sleep Monitoring

+

Analytics

+

Gamification
```

HabitFlow menjadi partner digital yang membantu pengguna berkembang sedikit demi sedikit setiap hari.

---

# END OF PRD

```

```
