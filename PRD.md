# Product Requirements Document

# Prokopa: Habits and Jurnaling

**Document Version:** 2.0 Draft Part 2
**Scope:** Sections 6–10
**Depends On:** `PRD_REBUILD_PART_01.md`
**Brand Name:** `Prokopa: Habits and Jurnaling`
**Product Type:** Offline-native personal habit, journaling, sleep, mood, progress, and self-reflection application
**Authentication:** None
**Backend:** None
**Cloud Sync:** None
**Internet Dependency:** None for core application behavior
**Storage Model:** Local device storage
**Primary Brand Color:** `#3949AB`
---

# 1. Document Purpose and Product Definition

## 1.1 Purpose

Dokumen ini adalah sumber kebenaran utama untuk pengembangan HabitFlow. Dokumen mendefinisikan tujuan produk, batas sistem, perilaku yang harus didukung, aturan bisnis, pengalaman pengguna, prinsip desain, requirement fungsional, requirement non-fungsional, struktur data, dan acceptance criteria.

Dokumen ini ditulis untuk dua kebutuhan utama:

1. menjadi acuan product dan design agar keputusan tidak berubah-ubah;
2. menjadi acuan AI coding agent agar implementasi tidak menebak requirement, membuat fitur fiktif, atau menambah kompleksitas yang tidak diperlukan.

Setiap implementasi harus dapat ditelusuri kembali ke requirement yang jelas dalam dokumen ini.

## 1.2 Status Dokumen

Dokumen ini menggantikan PRD lama secara konseptual. Struktur final akan disusun bertahap untuk menghindari requirement yang saling bertentangan.

Urutan prioritas sumber keputusan adalah:

1. requirement eksplisit dalam PRD final;
2. aturan arsitektur dan engineering dalam `AGENTS.md`;
3. design direction dan brand asset yang disediakan;
4. psychology design system;
5. implementasi repository yang sudah ada, hanya jika tidak bertentangan dengan requirement baru.

Implementasi lama tidak dianggap sebagai sumber kebenaran ketika behavior-nya berbeda dengan PRD baru.

## 1.3 Product Definition

HabitFlow adalah aplikasi personal yang membantu pengguna:

- membangun dan menjalankan kebiasaan;
- memahami konteks yang membantu kebiasaan dilakukan;
- mencatat jurnal dan refleksi;
- mencatat kondisi mood;
- mencatat tidur secara manual;
- melihat progress dan pola pribadi;
- melakukan review mingguan dan bulanan;
- kembali setelah jeda tanpa kehilangan historical progress;
- menyimpan dan memulihkan seluruh data secara lokal.

HabitFlow bukan aplikasi media sosial, bukan aplikasi terapi, bukan layanan kesehatan, bukan game kompetitif, dan bukan platform berbasis akun daring.

## 1.4 Product Character

HabitFlow harus terasa:

- tenang;
- jelas;
- dewasa;
- personal;
- ringan;
- cepat;
- dapat dipercaya;
- tidak menghakimi;
- tidak ramai;
- tidak memaksa pengguna terus membuka aplikasi.

Karakter tersebut selaras dengan psychology design system yang menetapkan pendekatan calm, warm, focused, low-pressure, reflective, dan quietly rewarding.

## 1.5 Product Promise

HabitFlow membantu pengguna memahami empat hal sederhana:

```text
Apa yang ingin saya lakukan?
Kapan dan dalam konteks apa saya melakukannya?
Apa yang terjadi dari waktu ke waktu?
Apa yang ingin saya ubah berikutnya?
```

## 1.6 Product Outcome

Keberhasilan produk tidak didefinisikan oleh lamanya pengguna berada di aplikasi.

Keberhasilan produk didefinisikan oleh kemampuan pengguna untuk:

- melakukan tindakan yang mereka pilih;
- melihat progress yang bermakna;
- memahami pola pribadinya;
- melakukan penyesuaian;
- kembali setelah lapse;
- menggunakan aplikasi seperlunya.

Psychology design system secara eksplisit menempatkan autonomy, consistency, reflection, recovery, progress, dan trust di atas engagement maximization.

## 1.7 Source-of-Truth Rule

AI coding agent tidak boleh menambahkan behavior hanya karena fitur tersebut umum pada aplikasi sejenis.

Contoh larangan:

- tidak menambahkan login karena aplikasi habit tracker lain memilikinya;
- tidak menambahkan cloud sync karena ada fitur export/import;
- tidak menambahkan AI cloud karena ada fitur insights;
- tidak menambahkan social feed karena ada achievement;
- tidak menambahkan leaderboard karena ada gamification;
- tidak menambahkan subscription atau paywall tanpa requirement eksplisit.

Ketika requirement belum didefinisikan, implementasi harus dihentikan pada area tersebut dan ambiguity harus disebutkan.

## 1.8 Engineering Alignment

Aturan proyek menekankan assumption disclosure, simplicity first, surgical changes, dan success criteria yang dapat diverifikasi. Karena itu PRD ini harus menghasilkan requirement yang kecil, jelas, dapat diuji, dan tidak membuka ruang untuk abstraksi atau fitur spekulatif.

---

# 2. Product Vision, Mission, and Experience Model

## 2.1 Vision

Menjadikan HabitFlow sebagai ruang pribadi yang ringan untuk membantu pengguna membangun kebiasaan, memahami dirinya, dan menyesuaikan rutinitas berdasarkan data yang mereka pilih sendiri.

## 2.2 Mission

HabitFlow membantu pengguna bergerak dari niat menuju tindakan, dari tindakan menuju pengamatan, dan dari pengamatan menuju penyesuaian tanpa tekanan psikologis yang tidak perlu.

Model inti produk:

```text
INTENTION
    ↓
ACTION
    ↓
REPETITION
    ↓
CONTEXT ASSOCIATION
    ↓
REFLECTION
    ↓
ADAPTATION
    ↓
RECOVERY
    ↓
ACTION
```

Psychology design system menggunakan rangkaian intention, action, repetition, context association, automaticity, reflection, dan adaptation sebagai arah desain, bukan rangkaian notification, app open, streak, reward, dan repeated app open.

## 2.3 Product Mental Model

HabitFlow dibagi menjadi tiga mental mode utama:

```text
DO
Menyelesaikan tindakan.

REFLECT
Mencatat dan memahami pengalaman.

REVIEW
Melihat pola dan menentukan penyesuaian.
```

Ketiga mode tidak boleh dicampur secara berlebihan pada layar yang sama.

## 2.4 North Star Experience

Pengalaman utama harus sesingkat mungkin:

```text
OPEN
↓
UNDERSTAND TODAY
↓
ACT
↓
CONFIRM
↓
REFLECT
↓
LEAVE
```

Aplikasi tidak membutuhkan pengguna untuk tinggal lama agar dianggap berhasil.

## 2.5 Core Product Loop

```text
Plan
  ↓
Do
  ↓
Track
  ↓
See
  ↓
Reflect
  ↓
Adjust
  ↓
Repeat
```

## 2.6 Core Value Areas

### Habit

Memudahkan pengguna menentukan tindakan, konteks, jadwal, versi minimum, dan menyelesaikan tindakan tanpa banyak friction.

### Journal

Menyediakan tempat menulis yang tenang, cepat, dan tidak memaksa prompt atau metadata.

### Mood

Membantu pengguna memberi label pada kondisi emosinya dan menambahkan konteks secara opsional. Mood adalah self-report dan bukan diagnosis.

### Sleep

Memudahkan pencatatan tidur dan membantu pengguna melihat pola durasi serta kualitas tidur dari waktu ke waktu.

### Progress

Mengubah data menjadi representasi progress yang dapat dipahami tanpa bergantung pada streak sebagai satu-satunya metric.

### Review

Mengubah data menjadi pemahaman dan keputusan praktis melalui weekly review dan monthly review. Weekly review berfungsi sebagai jembatan dari data menuju meaning dan adjustment.

### Insights

Menyajikan pola yang dapat dijelaskan, cukup didukung data, tidak membuat klaim sebab-akibat tanpa dasar, dan memiliki nilai tindakan.

---

# 3. Problem Statement and Product Opportunity

## 3.1 Problem Utama

Pengguna sering mengetahui kebiasaan apa yang ingin dilakukan tetapi kesulitan mempertahankan perilaku tersebut dalam rutinitas nyata.

Masalah produk yang hendak diselesaikan adalah kombinasi dari:

| Problem | Dampak | Kebutuhan Produk |
|---|---|---|
| Pengguna lupa tindakan | habit tidak dilakukan | cue dan reminder yang terkontrol |
| Target terlalu besar | mudah menyerah | minimum version |
| Jadwal tidak sesuai real life | habit cepat ditinggalkan | flexible scheduling |
| Data hanya menjadi checklist | pengguna tidak belajar dari data | reflection dan review |
| Missed day dianggap kegagalan | pengguna enggan kembali | recovery-first UX |
| Streak terlalu dominan | progress terasa binary | multiple progress metrics |
| Terlalu banyak notifikasi | attention fatigue | notification control |
| Jurnal membutuhkan privasi | pengguna menahan diri | local-only storage dan privacy control |
| Data hilang saat ganti perangkat | kehilangan historical record | export dan import |
| Aplikasi terasa berat | friction meningkat | performance-first implementation |

Psychology design system menekankan bahwa tracking seharusnya tidak berhenti pada collection, tetapi bergerak menuju reflection dan action.

## 3.2 Problem yang Tidak Diselesaikan

HabitFlow tidak ditujukan untuk:

- mendiagnosis kondisi kesehatan mental;
- memberikan diagnosis medis;
- memberikan terapi;
- menggantikan tenaga profesional;
- memverifikasi kebenaran self-report pengguna;
- menentukan apa yang seharusnya menjadi tujuan hidup pengguna;
- membuat keputusan kesehatan berisiko tinggi secara otomatis.

## 3.3 Product Opportunity

Peluang utama HabitFlow adalah menggabungkan tiga pengalaman yang biasanya dipisahkan:

```text
HABIT EXECUTION
+
SELF REFLECTION
+
PERSONAL REVIEW
```

Penggabungan ini harus tetap sederhana pada level UI. Kompleksitas berada pada data model dan business logic, bukan pada kepadatan layar.

## 3.4 Design Opportunity

Visual reference yang diberikan menunjukkan arah visual mobile yang:

- bersih;
- rounded secara terkontrol;
- banyak whitespace;
- menggunakan illustration sebagai pendukung konteks;
- menggunakan card untuk grouping;
- memiliki bottom navigation;
- memiliki light dan dark theme;
- menggunakan interaction yang jelas dan singkat.

Versi final harus diselaraskan dengan brand logo, bukan menyalin palette hijau dari mockup secara mentah.

## 3.5 Brand Direction

Logo utama menggunakan warna brand:

```text
Brand Primary
#3949AB
```

Konsekuensi desain:

- indigo menjadi warna brand utama;
- warna hijau dapat digunakan sebagai semantic success, bukan sebagai brand primary;
- warna accent digunakan terbatas pada titik perhatian penting;
- background dan surface harus tetap netral agar brand color tidak menjadi berisik;
- dark mode menggunakan brand indigo yang disesuaikan untuk kontras, bukan mengganti identitas brand.

## 3.6 UX Opportunity

Mental model aplikasi harus membantu pengguna menjawab:

```text
Hari ini saya harus melakukan apa?

Apa yang terjadi pada kebiasaan saya?

Apa yang saya rasakan?

Apa yang bisa saya pelajari?

Apa yang ingin saya ubah?
```

Information architecture yang direkomendasikan oleh design system adalah Today, Journal, Progress, Insights, dan Profile.

---

# 4. Product Principles and Non-Negotiable Design Rules

## 4.1 Simplicity First

Setiap fitur harus memiliki alasan yang jelas.

Tidak boleh ada:

- section filler;
- screen yang hanya ada karena aplikasi sejenis memilikinya;
- visual yang tidak memberikan informasi atau feedback;
- abstraksi kode yang tidak diperlukan;
- konfigurasi tambahan yang tidak digunakan;
- state buatan yang tidak berasal dari domain nyata.

## 4.2 Local-Only by Default

HabitFlow adalah aplikasi local-only.

Semua fungsi inti harus berjalan tanpa internet.

Tidak ada dependency terhadap:

- API server;
- remote database;
- cloud authentication;
- remote analytics untuk core behavior;
- cloud sync;
- remote AI service.

## 4.3 No Login, No Signup

HabitFlow tidak memiliki authentication flow.

Tidak ada:

```text
Sign In
Sign Up
Log In
Log Out
Forgot Password
Reset Password
Google Login
Apple Login
Email Verification
```

Pengguna langsung menggunakan aplikasi setelah onboarding.

Profile yang tersimpan adalah local profile, bukan online account.

## 4.4 Local Profile

Local profile minimal berisi:

```text
id
name
avatar
selectedTheme
createdAt
```

Field tambahan hanya boleh ditambahkan jika digunakan oleh behavior nyata.

Tidak ada email atau password pada local profile.

## 4.5 Privacy by Architecture

Data sensitif seperti journal, mood, dan sleep harus tetap berada di perangkat kecuali pengguna secara eksplisit melakukan export.

Privacy bukan sekadar copy pada UI. Privacy harus tercermin dalam arsitektur.

Design system merekomendasikan private-by-default, app lock, notification privacy, export, dan delete controls.

## 4.6 Recovery Over Punishment

Missed habit bukan identitas pengguna dan bukan alasan untuk menghapus historical progress.

State minimal yang harus dibedakan:

```text
COMPLETED
SKIPPED
MISSED
PAUSED
```

Recovery harus menjadi bagian dari domain, bukan sekadar copy pada screen.

Design system menyediakan state model CREATED, ACTIVE, COMPLETED, SKIPPED, MISSED, PAUSED, dan RESUMED.

## 4.7 Progress Over Streak Dependency

Streak adalah salah satu representation, bukan definisi keberhasilan.

Progress harus dapat direpresentasikan melalui:

- completion rate;
- repetitions;
- weekly consistency;
- monthly rhythm;
- best streak;
- recovery count;
- adjustment history bila relevan.

Design system secara eksplisit mendorong multiple progress representations.

## 4.8 Context Over Motivation

Habit setup harus memprioritaskan context dan cue.

Struktur ideal:

```text
WHEN
WHERE
ACTION
MINIMUM VERSION
```

Dokumen psychology design system menyarankan cue builder dan implementation intention berbasis pola "ketika X, lakukan Y".

## 4.9 Autonomy Over Coercion

Pengguna harus dapat menentukan:

- goal;
- frequency;
- cue;
- reminder;
- target;
- pause;
- skip;
- privacy settings;
- gamification visibility jika fitur tersedia.

Aplikasi tidak boleh menggunakan guilt, shame, fake urgency, atau streak hostage.

## 4.10 No Toxic Positivity

Copy harus neutral-positive dan non-judgmental.

Dilarang:

```text
You failed.
You're falling behind.
Don't break your streak.
You must stay consistent.
```

Gunakan:

```text
Kemarin terlewat.
Mau lanjut hari ini?

Tidak perlu mengejar hari yang terlewat.
Mulai dari hari ini.
```

Guideline ini konsisten dengan prinsip recovery-first dan self-compassion.

## 4.11 Data Must Lead to Action

Chart tidak boleh dibuat hanya untuk mengisi ruang.

Setiap visual analytics harus memiliki pertanyaan yang dijawab.

Contoh:

```text
Pertanyaan:
Kapan habit membaca paling sering berhasil?

Output:
Completion berdasarkan waktu cue.
```

Jika kalimat sederhana lebih mudah dipahami daripada chart, gunakan kalimat.

## 4.12 Explainable Insights

Insight harus:

1. berdasarkan data nyata;
2. memiliki jumlah observasi yang cukup untuk metric yang dipakai;
3. dapat dijelaskan sumber perhitungannya;
4. tidak mengklaim sebab-akibat sederhana;
5. tidak memberikan diagnosis;
6. tidak menyimpulkan identitas pengguna;
7. memiliki tindakan lanjutan bila tindakan tersebut relevan.

Contoh yang diterima:

```text
Dalam 4 minggu terakhir, habit membaca lebih sering selesai ketika dijadwalkan sebelum pukul 21.00.
```

Contoh yang tidak diterima:

```text
You are a night person.
```

Insight design system juga menetapkan insight harus explainable, data-supported, non-overclaiming, dan actionable.

## 4.13 Notification as Support

Notification hanya digunakan untuk mendukung memory.

Prioritas:

```text
Essential
User explicitly scheduled.

Helpful
Weekly review.

Optional
Motivational message.
```

Tidak ada spam notification per habit secara default. Design system mendorong batching atau summary bila relevan.

## 4.14 No Fake or Invented Data

Development dan demo UI tidak boleh menyamarkan data fiktif sebagai data pengguna nyata.

Aturan:

- empty state harus benar-benar empty;
- metric harus berasal dari database;
- historical chart harus berasal dari record nyata;
- jika sample data diperlukan untuk test, data harus dibuat oleh fixture atau seed khusus testing;
- sample data tidak boleh ikut terpasang sebagai data user production.

## 4.15 No Emoji in Repository

Repository tidak boleh berisi emoji.

Aturan berlaku untuk:

- Dart source;
- string UI;
- markdown;
- README;
- PRD;
- commit-oriented documentation yang berada di repository;
- test fixtures;
- sample data;
- notification text;
- accessibility labels;
- empty state;
- achievement copy.

Icon visual harus berasal dari icon system atau asset desain, bukan karakter emoji.

## 4.16 Clean Code

Source code harus:

- sederhana;
- eksplisit;
- modular;
- dapat diuji;
- tidak memiliki dead code baru;
- tidak memiliki duplicated business rules;
- tidak memiliki speculative abstraction;
- tidak memiliki magic behavior yang tidak terdokumentasi melalui struktur atau naming.

## 4.17 No Code Comments

Production source code tidak boleh menggunakan comment sebagai penjelasan biasa.

Requirement harus tercermin melalui:

- naming;
- struktur module;
- type;
- test;
- architecture.

Tidak boleh menambahkan comment generik seperti:

```text
This function does...
Handle error...
Update state...
```

## 4.18 Real Interactions Only

Tidak boleh ada control yang hanya terlihat interaktif.

Setiap:

- button;
- toggle;
- checkbox;
- segmented control;
- navigation item;
- menu item;
- input;

harus mempunyai behavior nyata atau tidak ditampilkan.

## 4.19 Lightweight and Fast

Performance adalah product requirement, bukan pekerjaan optimasi belakangan.

Prinsip:

- local query yang efisien;
- reactive data hanya pada scope yang diperlukan;
- list memakai builder dan lazy rendering;
- tidak melakukan query database berulang di build phase;
- tidak melakukan kalkulasi berat pada UI thread tanpa kebutuhan;
- tidak memuat asset besar jika versi ringan tersedia;
- tidak menggunakan animation yang tidak memiliki tujuan;
- tidak menggunakan network untuk fungsi lokal;
- tidak memasang dependency besar tanpa kebutuhan yang jelas.

## 4.20 Interaction Quality

UI harus terasa responsif.

Target pengalaman:

```text
Tap
↓
Immediate visual state change
↓
Persist locally
↓
Related UI updates reactively
```

Completion habit harus dapat dilakukan dalam satu interaksi utama. Design system juga menekankan low-friction completion dan feedback yang ringan.

## 4.21 Accessibility by Default

Requirement minimum:

- semantic label untuk kontrol penting;
- status tidak hanya dibedakan dengan warna;
- touch target utama sekitar 44–48 px;
- text scaling tetap usable;
- reduced motion diperhatikan;
- contrast memadai.

Design system menetapkan practical baseline 44–48 px untuk kontrol mobile dan menegaskan bahwa mood/status/completion tidak boleh color-only.

## 4.22 Visual Restraint

Jangan menggunakan seluruh teknik visual secara bersamaan.

Dilarang menjadikan:

- gradient penuh halaman;
- glassmorphism penuh halaman;
- glow berlebihan;
- shadow berlebihan;
- badge berlebihan;
- card berulang tanpa hirarki;
- illustration dekoratif tanpa fungsi;
- animasi looping;

sebagai default visual.

Visual harus menjelaskan hierarchy, state, atau context.

---

# 5. Product Scope and System Boundaries

## 5.1 In Scope

### A. Local Onboarding

- welcome screen;
- product introduction singkat;
- intent selection;
- focus selection;
- local profile setup;
- first habit setup;
- onboarding completion;
- skip onboarding bila user memilih.

### B. Local Profile

- nama;
- avatar pilihan dari asset lokal;
- appearance;
- notification preferences;
- privacy and security settings;
- data management.

### C. Habit Management

- create habit;
- view habits;
- edit habit;
- archive habit;
- restore archived habit bila diperlukan;
- delete habit dengan konfirmasi;
- category;
- icon;
- color;
- frequency;
- specific days;
- weekly target;
- cue;
- minimum version;
- optional reminder;
- start date;
- pause;
- resume;
- skip;
- completion;
- notes.

### D. Journal

- journal list;
- free journal;
- guided journal;
- edit entry;
- delete entry;
- search;
- optional mood;
- optional tags;
- local persistence;
- local draft handling;
- saved state feedback.

### E. Mood Tracking

- mood check-in;
- emotion label;
- optional energy level;
- optional context tags;
- mood history;
- mood trend.

### F. Sleep Tracking

- sleep start;
- sleep end;
- calculated duration;
- quality;
- sleep history;
- average duration;
- average quality;
- sleep consistency;
- sleep detail.

### G. Progress

- daily progress;
- weekly progress;
- monthly progress;
- habit-specific progress;
- completion rate;
- repetition count;
- weekly consistency;
- streak;
- calendar;
- heatmap;
- recovery history where applicable.

### H. Weekly Review

- completed versus planned;
- most consistent habit;
- hardest habit;
- mood summary;
- sleep summary;
- journal summary;
- what helped;
- what was difficult;
- what to keep;
- what to adjust;
- what to pause.

### I. Monthly Review

- monthly rhythm;
- habit progress;
- sleep pattern;
- mood pattern;
- journal activity;
- highlights;
- adjustments.

### J. Personal Insights

- habit timing patterns;
- consistency patterns;
- sleep patterns;
- mood patterns;
- journal frequency patterns;
- explainable relationship summaries;
- actionable recommendations yang tidak bersifat diagnosis.

### K. Gamification

- optional achievements;
- milestone progress;
- XP hanya jika rule-nya jelas;
- level hanya jika konsisten secara matematis;
- no competitive leaderboard;
- no social comparison.

### L. Local Notifications

- habit reminders;
- journal reminders;
- sleep reminders;
- weekly review reminder;
- notification preferences;
- quiet period;
- local scheduling;
- lock-screen privacy.

### M. Data Backup and Recovery

- export all local data;
- export selected categories bila feasible;
- import backup;
- validate backup before import;
- backup schema version;
- import preview;
- replace local data with explicit confirmation;
- merge strategy hanya jika benar-benar dibutuhkan dan didefinisikan;
- backup integrity validation;
- no cloud backup by default.

### N. App Security

- optional app lock;
- PIN or biometric support bila platform capability tersedia;
- hide sensitive notification preview;
- delete all local data;
- explicit destructive confirmation.

## 5.2 Out of Scope

Fitur berikut tidak boleh dibuat pada versi produk ini tanpa perubahan PRD resmi:

- online account;
- registration;
- login;
- password authentication;
- OAuth;
- Google authentication;
- Apple authentication;
- backend API;
- cloud database;
- automatic cloud synchronization;
- social profile;
- public profile;
- follower/following;
- public journal;
- community;
- leaderboard;
- chat;
- ads;
- in-app purchases;
- subscription;
- remote AI analysis;
- server-side journal processing;
- continuous location tracking;
- wearable integration;
- automatic sleep detection tanpa device integration requirement;
- medical diagnosis;
- clinical recommendation.

## 5.3 Internet Boundary

Internet bukan dependency untuk penggunaan inti.

Aplikasi harus tetap dapat:

- dibuka;
- membaca data;
- membuat data;
- mengubah data;
- menghapus data;
- menghitung progress;
- menampilkan analytics;
- menampilkan insights berbasis data lokal;
- menjadwalkan local notification;
- export data;
- import data;

tanpa koneksi internet.

Tidak ada layar inti yang menampilkan error "No Internet Connection" sebagai blocker untuk data lokal.

## 5.4 Backup Boundary

Export dan import bukan cloud sync.

Modelnya:

```text
User
 ↓
Export
 ↓
Backup File

Backup File
 ↓
Import
 ↓
Local Database
```

Backup hanya terjadi ketika user memilihnya.

## 5.5 AI Boundary

Versi core HabitFlow tidak mengirim journal, mood, atau data personal ke model cloud.

Personal insights harus dapat dihitung secara lokal dengan rule atau statistik deterministik.

Model AI on-device hanya dapat ditambahkan melalui requirement terpisah yang mendefinisikan:

- model;
- ukuran;
- memory budget;
- input;
- output;
- privacy behavior;
- fallback;
- performance impact.

Tanpa requirement tersebut, AI tidak boleh ditambahkan.

## 5.6 Data Ownership Boundary

Data adalah milik pengguna.

Pengguna harus memiliki kemampuan untuk:

- melihat data yang tersimpan;
- export data;
- import data;
- menghapus data tertentu;
- menghapus seluruh data.

## 5.7 Feature Completion Rule

Fitur hanya dianggap selesai apabila:

1. UI tersedia;
2. state tersedia;
3. persistence tersedia bila membutuhkan data;
4. business rule tersedia;
5. error state tersedia;
6. empty state relevan;
7. interaction nyata;
8. test utama tersedia;
9. tidak ada placeholder behavior yang disamarkan sebagai fitur selesai.

## 5.8 Requirement Change Rule

Perubahan product behavior harus dilakukan melalui perubahan PRD lebih dahulu.

Contoh perubahan yang membutuhkan update PRD:

- menambah login;
- menambah cloud sync;
- mengubah struktur bottom navigation;
- menambah AI cloud;
- menambah social feature;
- mengubah model reminder;
- mengubah definisi streak;
- mengubah export/import behavior.

Tidak boleh melakukan perubahan tersebut hanya berdasarkan asumsi implementer.



# 6. Target Users and Personas

## 6.1 Primary User

Prokopa is designed for an individual who wants a lightweight private tool for building habits, tracking routines, journaling, understanding personal patterns, and reviewing progress without requiring an online account.

The primary user is expected to use the application on a personal mobile device and may have inconsistent routines, limited time, changing priorities, and periods of inactivity.

The product must support ordinary variation in behavior rather than assuming perfect daily consistency.

## 6.2 Core User Characteristics

The product should accommodate users who:

- want to start one or several small habits;
- want to maintain an existing routine;
- want to reflect through free writing;
- want help when they do not know what to write;
- want to record mood without treating the data as a diagnosis;
- want to track sleep manually;
- want to review trends across days, weeks, and months;
- want understandable personal insights from locally stored data;
- prefer privacy and local ownership of personal data;
- do not want account creation before using the application;
- may stop using the application temporarily and return later.

## 6.3 Persona A — Habit Builder

**Need:** Build one to three meaningful habits without feeling overwhelmed.

**Primary jobs:**

- create a realistic habit;
- choose a useful cue;
- define frequency;
- define a minimum version;
- complete the habit with minimal interaction;
- see progress without excessive gamification;
- recover after a missed period.

**Primary success signal:** The user can reliably act on the selected habit with low logging friction.

## 6.4 Persona B — Reflective User

**Need:** Capture thoughts and emotions privately with little interruption.

**Primary jobs:**

- write a free journal entry;
- use guided prompts when useful;
- record optional mood and context;
- return to previous entries;
- search and review past reflections;
- maintain trust that the journal remains local.

**Primary success signal:** The user can capture and review reflections without unnecessary friction.

## 6.5 Persona C — Pattern Seeker

**Need:** Understand personal patterns from tracked data.

**Primary jobs:**

- review habit consistency;
- compare planned and completed activity;
- examine mood and sleep patterns;
- inspect calendar and heatmap history;
- read explainable insights;
- use reviews to adjust future behavior.

**Primary success signal:** The user can identify at least one useful pattern or adjustment from their own data.

## 6.6 Persona D — Returning User

**Need:** Resume the system after a lapse without rebuilding everything.

**Primary jobs:**

- open the application after several inactive days;
- understand what remains active;
- see that historical progress is preserved;
- decide whether to continue, reduce, change the cue, or pause;
- resume without guilt-oriented messaging.

**Primary success signal:** The user can resume a useful action quickly after an absence.

## 6.7 Non-Target Users

The following are not primary product targets:

- organizations managing employee behavior;
- teams requiring shared habit plans;
- social communities requiring public profiles;
- users requiring clinical monitoring or diagnosis;
- users requiring online account synchronization across multiple services;
- administrators managing multiple users.

These scenarios are outside the product scope unless a later PRD revision explicitly changes the system boundary.

## 6.8 User Context Assumptions

The product should assume:

- the device may have no internet connection;
- the user may use the device in short sessions;
- the user may be interrupted while entering data;
- the user may have several active habits with different schedules;
- the user may need large touch targets;
- the user may use system-level text scaling;
- the user may prefer light or dark appearance;
- the user may disable notifications;
- the user may need to export and restore their local data.

## 6.9 User Ownership Principle

The user owns the local experience and controls:

- what to track;
- how often to track it;
- whether reminders are enabled;
- whether gamification is visible;
- what data is exported;
- what data is imported;
- what data is deleted;
- whether app locking is enabled;
- whether the local profile is reset.

No mandatory online account is allowed.

## 6.10 User Success Definition

The product is successful when users can:

1. start a meaningful habit quickly;
2. record an action without friction;
3. understand their progress;
4. reflect privately;
5. identify useful patterns;
6. adjust their routines;
7. recover after interruption;
8. retain control over their data;
9. continue using the application without needing an internet connection.

The application must not define success only through daily active usage, session duration, notification opens, or streak length.

---

# 7. Jobs To Be Done and User Goals

## 7.1 Primary Job To Be Done

> When I want to improve a routine or understand my personal patterns, I want a private and simple place to plan, record, reflect, and review so I can make practical adjustments without unnecessary pressure.

## 7.2 Habit Jobs

### JTBD-H01 — Start a Habit

When I decide to improve something, I want to create a small and realistic habit with a clear schedule and cue so I know exactly what to do and when to do it.

### JTBD-H02 — Complete a Habit

When a habit is due, I want to mark it complete in one simple interaction so recording does not become another task.

### JTBD-H03 — Handle a Difficult Day

When I cannot perform the full habit, I want a lower-effort option where appropriate so a difficult day does not automatically become a complete failure.

### JTBD-H04 — Miss a Habit

When I miss a planned action, I want the application to preserve my history and help me decide what to do next.

### JTBD-H05 — Adjust a Habit

When a habit is not working, I want to change its schedule, cue, target, or minimum version without recreating the entire history.

### JTBD-H06 — Pause a Habit

When my circumstances change, I want to pause a habit without losing historical information.

## 7.3 Journal Jobs

### JTBD-J01 — Capture Quickly

When I have something on my mind, I want to write immediately without completing a long form.

### JTBD-J02 — Write With Guidance

When I do not know what to write, I want a short guided sequence that helps me reflect one step at a time.

### JTBD-J03 — Record Emotion

When I want to understand how I feel, I want to label a mood and optionally record context without turning the entry into a clinical assessment.

### JTBD-J04 — Review Past Writing

When I want to remember what happened before, I want to browse, search, and review my previous entries locally.

## 7.4 Sleep Jobs

### JTBD-S01 — Record Sleep

When I wake up or prepare to review sleep, I want to record sleep start, sleep end, duration, and quality with minimal effort.

### JTBD-S02 — Understand Sleep Patterns

When I review sleep, I want to see understandable trends and averages from my own recorded data.

## 7.5 Progress Jobs

### JTBD-P01 — Understand Current Progress

When I want a quick status, I want to know what I completed, what remains, and how consistent I have been.

### JTBD-P02 — Compare Time Periods

When I want context, I want to compare relevant trends across week and month views.

### JTBD-P03 — Understand Consistency Without Streak Dependency

When I assess progress, I want multiple meaningful measures rather than a single streak number.

## 7.6 Review Jobs

### JTBD-R01 — Weekly Review

When a week ends, I want to understand what helped, what was difficult, and what I should keep or change.

### JTBD-R02 — Monthly Review

When I review a longer period, I want to see broader trends without being reduced to a score that implies personal worth.

## 7.7 Privacy Jobs

### JTBD-V01 — Keep Data Local

When I record private information, I want the data to remain on my device and not require an online account.

### JTBD-V02 — Control Backup

When I need a backup, I want to export my own data into a file I control.

### JTBD-V03 — Restore Local Data

When I change devices or reinstall the application, I want to restore a compatible backup manually.

### JTBD-V04 — Delete Data

When I no longer want a record or the complete local dataset, I want to remove it explicitly.

## 7.8 User Goal Hierarchy

The product goal hierarchy is:

```text
Meaningful behavior
        ↓
Low-friction action
        ↓
Reliable tracking
        ↓
Understandable feedback
        ↓
Reflection
        ↓
Adjustment
        ↓
Sustainable routine
```

The hierarchy must not be inverted into:

```text
App engagement
        ↓
Notification volume
        ↓
Streak preservation
        ↓
Reward collection
```

## 7.9 Goal Conflicts

When requirements conflict, resolve them in this order:

1. Data correctness
2. User control
3. Core task completion
4. Privacy
5. Clarity
6. Performance
7. Visual polish
8. Gamification

A decorative or engagement feature must never compromise local data integrity or core task usability.

---

# 8. Information Architecture

## 8.1 IA Objective

The information architecture must separate three primary mental modes:

- DO: complete and manage habits;
- REFLECT: journal, mood, and sleep capture;
- REVIEW: progress, calendar, reviews, and insights.

This separation follows the psychology design system requirement to avoid mixing all mental modes aggressively on one screen. fileciteturn1file0L91-L107

## 8.2 Primary Navigation

The canonical mobile navigation is:

```text
Home
Journal
Progress
Insights
Profile
```

Settings are accessed through Profile.

## 8.3 Navigation Responsibilities

### Home

Purpose:

```text
What is relevant now?
```

Primary content:

- current date;
- greeting;
- today's progress;
- today's planned habits;
- quick mood check-in;
- quick journal entry access;
- relevant recovery state when applicable.

Home is an action-oriented screen and must not become the full analytics dashboard.

### Journal

Purpose:

```text
What happened and what am I experiencing?
```

Primary content:

- recent entries;
- free journal entry;
- guided journal entry;
- optional mood;
- search;
- filters.

### Progress

Purpose:

```text
How consistent have I been?
```

Primary content:

- completion;
- consistency;
- repetitions;
- streak;
- calendar;
- heatmap;
- time period selection;
- recovery and return indicators.

### Insights

Purpose:

```text
What can I learn from my data?
```

Primary content:

- explainable patterns;
- habit patterns;
- sleep patterns;
- mood patterns;
- weekly reflection recommendations;
- actionable adjustments.

### Profile

Purpose:

```text
How is my local experience configured?
```

Primary content:

- local profile;
- appearance;
- notifications;
- privacy and security;
- data and backup;
- help and about.

The IA structure is aligned with the source design system, which recommends Today, Journal, Progress, Insights, and Profile as the primary mobile structure. fileciteturn1file0L111-L167

## 8.4 Secondary Navigation

Secondary screens may be opened from the primary sections.

```text
Home
├── Habit Detail
├── Mood Check-in
├── Quick Journal
└── Recovery

Journal
├── Free Journal Editor
├── Guided Journal
├── Journal Entry Detail
└── Journal Search

Progress
├── Habit Progress
├── Calendar
├── Heatmap
├── Weekly Review
└── Monthly Review

Insights
├── Habit Patterns
├── Mood Patterns
└── Sleep Patterns

Profile
├── Local Profile
├── Appearance
├── Notifications
├── Privacy & Security
├── Data & Backup
└── About
```

## 8.5 Global Add Action

A single global creation affordance may be available where appropriate.

Allowed creation targets:

- habit;
- journal entry;
- sleep record;
- mood check-in.

The action must not create a large generic action menu when the current context already provides a clear primary action.

## 8.6 Information Density Rules

Home:

- low density;
- action focused;
- one primary task per visible group.

Journal:

- low to medium density;
- writing area receives visual priority;
- metadata remains secondary.

Progress:

- medium density;
- numbers and charts may be displayed together;
- explanatory labels remain visible.

Insights:

- medium density;
- each insight includes evidence context and a possible action where available.

Profile:

- list based;
- grouped settings;
- no unnecessary dashboards.

## 8.7 Navigation Rules

1. Back navigation must preserve unsaved data state.
2. Returning from a secondary screen must refresh affected local data.
3. A successful creation action must return the user to the context in which the item was created unless a deliberate continuation flow is defined.
4. Destructive actions require explicit confirmation.
5. Navigation must not require network availability.
6. No screen may display an unavailable action as though it were functional.
7. No authentication gate may appear in the navigation tree.

## 8.8 Deep-Link Requirement

Deep linking is optional for the initial offline release.

If implemented, links must resolve only to local application destinations and must not require a network service.

## 8.9 Navigation State Persistence

The application should restore reasonable navigation context after transient interruption where practical.

It must never discard unsaved journal input because of ordinary navigation or lifecycle events.

## 8.10 Empty State Navigation

Empty states must provide the next useful action.

Example:

```text
No active habits yet.
Start with one small habit.

[ Add Habit ]
```

The state must not contain decorative filler copy that does not help the user proceed.

---

# 9. Navigation Architecture

## 9.1 Canonical Route Tree

The route tree should follow this conceptual structure:

```text
/
├── home
├── journal
├── progress
├── insights
└── profile
```

Secondary routes:

```text
/home/habit/:id
/home/recovery/:id
/journal/new
/journal/guided
/journal/:id
/journal/search
/progress/habit/:id
/progress/calendar
/progress/weekly-review
/progress/monthly-review
/insights/habits
/insights/mood
/insights/sleep
/profile/local-profile
/profile/appearance
/profile/notifications
/profile/privacy
/profile/data-backup
/profile/about
```

The exact routing syntax may differ in implementation, but the conceptual hierarchy must remain stable unless the PRD is changed.

## 9.2 Bottom Navigation Contract

Bottom navigation contains exactly five primary destinations:

```text
1. Home
2. Journal
3. Progress
4. Insights
5. Profile
```

No authentication destination exists.

No separate Sleep destination is required in the primary navigation.

Sleep is accessible from Home, Progress, and relevant quick actions.

## 9.3 Route Ownership

Each route has one clear responsibility.

### Home

Owns:

- today state;
- action completion;
- lightweight reflection access;
- recovery entry point.

Does not own:

- full analytics;
- all settings;
- long journal history;
- achievement catalog.

### Journal

Owns:

- journal list;
- journal creation;
- journal search;
- journal filters.

Does not own:

- full habit analytics;
- sleep history beyond relevant context.

### Progress

Owns:

- progress metrics;
- time-period review;
- calendar;
- heatmap;
- weekly review;
- monthly review.

### Insights

Owns:

- calculated patterns;
- explainability context;
- suggested adjustments.

### Profile

Owns:

- local identity representation;
- app preferences;
- privacy;
- backup and restore;
- security controls;
- notification preferences.

## 9.4 Route Parameters

Entity detail screens use stable local identifiers.

Example:

```text
HabitDetail(habitId)
JournalDetail(journalId)
```

Identifiers must not contain business meaning encoded into presentation strings.

## 9.5 Route Guard Rules

There are no login guards.

There are no online session checks.

The only allowed navigation guards are local state requirements, such as:

- app lock authentication;
- confirmation before destructive data operations;
- unsaved journal draft protection.

## 9.6 Onboarding Routing

On first installation:

```text
Launch
 ↓
First-run check
 ↓
Onboarding if not completed
 ↓
Home
```

If onboarding is already completed:

```text
Launch
 ↓
App lock check if enabled
 ↓
Home
```

The first-run check must be local.

## 9.7 Onboarding Completion State

The application stores a local boolean or equivalent local state indicating whether onboarding has been completed.

The state must not depend on a remote user account.

## 9.8 Local Profile Routing

The local profile may be created during onboarding or edited later from Profile.

It is not an authentication identity.

The system must not interpret the local profile as proof of server ownership or external identity.

## 9.9 Modal and Bottom Sheet Usage

Use bottom sheets for short contextual actions such as:

- habit actions;
- skip reason;
- pause configuration;
- time selection;
- quick filters;
- non-destructive contextual options.

Use dialogs for:

- destructive confirmation;
- irreversible reset;
- import validation failure;
- app-level security confirmation.

Do not use dialogs for ordinary completion actions.

## 9.10 Navigation and Offline Reliability

All navigational actions must remain available offline.

Network checks must never block navigation to locally supported screens.

No loading screen may exist solely because the application is checking internet connectivity when local data is sufficient.

## 9.11 Unsaved Data Navigation Rule

Journal editing is the main workflow requiring draft protection.

When the user leaves a journal editor with unsaved input:

```text
Save locally
Cancel
Discard
```

The system must prevent accidental data loss.

If autosave is implemented, navigation should normally preserve the latest local draft without requiring a blocking confirmation.

## 9.12 Navigation Animation

Transitions should be short and purposeful.

Recommended baseline:

```text
instant: 80ms
micro: 120ms
fast: 160ms
normal: 220ms
slow: 300ms
```

Long transitions should be avoided for frequent navigation.

These values follow the existing design-system baseline. fileciteturn1file6L1123-L1168

## 9.13 Navigation Accessibility

Every primary destination must:

- have a text label;
- have a distinguishable selected state;
- not depend on color alone;
- maintain a practical touch target;
- remain usable under text scaling.

The source design system recommends practical mobile targets around 44–48px. fileciteturn2file1L296-L344

---

# 10. End-to-End User Journeys

## 10.1 Journey Model

The primary product journey is:

```text
Discover
 ↓
Understand
 ↓
Choose
 ↓
Configure
 ↓
Act
 ↓
Record
 ↓
Reflect
 ↓
Review
 ↓
Adjust
 ↓
Continue
```

The journey must work entirely on the device.

## 10.2 First Launch Journey

```text
Launch
 ↓
Splash
 ↓
Welcome
 ↓
Understand product value
 ↓
Select personal focus
 ↓
Create local profile
 ↓
Create first habit or continue without one
 ↓
Complete onboarding
 ↓
Home
```

## 10.3 First Launch With No Habit

A user may skip initial habit creation.

Flow:

```text
Onboarding
 ↓
No habit created
 ↓
Home
 ↓
Empty habit state
 ↓
Add Habit
```

The application must remain useful without forcing the user to create multiple habits.

The psychology document recommends starting with one to three habits rather than encouraging overcommitment. fileciteturn1file1L361-L372

## 10.4 First Habit Creation Journey

```text
Home
 ↓
Add Habit
 ↓
Name
 ↓
Why
 ↓
Frequency
 ↓
Cue
 ↓
Minimum Version
 ↓
Reminder optional
 ↓
Start date
 ↓
Create
 ↓
Habit Detail or Home
```

The order follows the psychology design specification for habit creation. fileciteturn1file1L377-L433

## 10.5 Daily Habit Completion Journey

```text
Open App
 ↓
Home
 ↓
See today's habits
 ↓
Tap completion control
 ↓
Local write
 ↓
Immediate UI update
 ↓
Light feedback
 ↓
Continue or leave
```

The interaction should not require a separate completion screen.

## 10.6 Multi-Habit Daily Journey

When multiple habits are scheduled:

```text
Home
 ↓
Today's Habits
 ↓
Complete one or more
 ↓
Progress updates after each completion
 ↓
Completed items become visually less prominent
 ↓
Remaining items stay obvious
```

The user should never need to open every habit detail merely to mark completion.

## 10.7 Habit Detail Journey

```text
Home
 ↓
Tap Habit
 ↓
Habit Detail
 ↓
View:
- purpose
- cue
- schedule
- current period progress
- history
- notes
 ↓
Choose:
- complete
- edit
- skip
- pause
- archive
```

## 10.8 Habit Adjustment Journey

When a habit repeatedly fails to fit the user's routine:

```text
Habit Detail
 ↓
Adjust Habit
 ↓
Change frequency or days
Change cue
Change target
Change minimum version
Change reminder
 ↓
Save
 ↓
Future schedule uses new configuration
 ↓
Historical records remain intact
```

Historical data must not be rewritten merely because future configuration changes.

## 10.9 Skip Journey

When the user intentionally does not want to perform today's habit:

```text
Today's Habit
 ↓
More Actions
 ↓
Skip Today
 ↓
Optional Reason
 ↓
Save
 ↓
Today's instance = SKIPPED
```

Allowed reasons include:

```text
Sick
Travel
Rest
Schedule changed
Other
```

Skip is not equivalent to missed.

The source design system explicitly requires this distinction. fileciteturn5file7L913-L937

## 10.10 Pause Journey

```text
Habit Detail
 ↓
Pause Habit
 ↓
Select end condition
 ↓
Confirm
 ↓
Habit state = PAUSED
 ↓
No new planned instances during pause
 ↓
Historical progress preserved
```

Pause is not a failure state.

## 10.11 Missed Habit Journey

If a scheduled habit is not completed and is not intentionally skipped:

```text
Scheduled
 ↓
Due
 ↓
No completion before period ends
 ↓
MISSED
```

The UI should use neutral visual treatment.

The user should not receive punitive copy.

## 10.12 Recovery Journey

After a meaningful period of inactivity:

```text
Open App
 ↓
Welcome Back
 ↓
Historical progress remains
 ↓
Show active habits only
 ↓
Offer:
Continue
Reduce Target
Change Cue
Pause
 ↓
Return to Home
```

The recovery model follows:

```text
Acknowledge
 ↓
Normalize
 ↓
Reduce Friction
 ↓
Restart
```

This is a core psychology requirement. fileciteturn2file3L952-L994

## 10.13 Free Journal Journey

```text
Journal
 ↓
New Entry
 ↓
Date
 ↓
Optional Mood
 ↓
Optional Title
 ↓
Write Body
 ↓
Optional Tags
 ↓
Autosave locally
 ↓
Saved Locally
 ↓
Close
```

The journal body receives primary visual priority.

## 10.14 Guided Journal Journey

```text
Journal
 ↓
Guided
 ↓
Prompt 1
 ↓
Write
 ↓
Next
 ↓
Prompt 2
 ↓
Write
 ↓
Next
 ↓
Prompt 3
 ↓
Save Locally
```

Prompts must be progressive and optional rather than presenting a long questionnaire.

## 10.15 Mood Check-in Journey

```text
Home or Journal
 ↓
Mood Check-in
 ↓
Select emotion label
 ↓
Optional context
 ↓
Save locally
 ↓
Return to originating screen
```

Mood tracking must remain self-report and non-diagnostic. The source design system specifically frames mood as an observed moment rather than an identity label. fileciteturn4file5L889-L946

## 10.16 Sleep Recording Journey

```text
Home
 ↓
Sleep
 ↓
Add Sleep
 ↓
Sleep Start
 ↓
Sleep End
 ↓
Quality
 ↓
Duration calculated
 ↓
Save locally
 ↓
Sleep summary updated
```

## 10.17 Progress Review Journey

```text
Progress
 ↓
Select period
 ↓
View completion
 ↓
View consistency
 ↓
View repetitions
 ↓
View streak where relevant
 ↓
View calendar
 ↓
Inspect habit detail
```

Progress must expose more than streak.

The source design system recommends completion rate, repetitions, weekly consistency, monthly rhythm, and recovery count as complementary progress representations. fileciteturn2file3L908-L948

## 10.18 Weekly Review Journey

```text
Progress
 ↓
Weekly Review
 ↓
What happened
 ↓
What helped
 ↓
What was difficult
 ↓
What will change
 ↓
Keep / Change / Reduce / Pause
 ↓
Save Review
```

Weekly review is a bridge from data to meaning and should produce an optional future adjustment. fileciteturn5file3L370-L410

## 10.19 Monthly Review Journey

```text
Progress
 ↓
Monthly Review
 ↓
Habit trend
 ↓
Sleep trend
 ↓
Mood pattern
 ↓
Journal frequency
 ↓
Meaningful highlights
 ↓
Optional reflection
```

It must not behave like a moral scorecard.

## 10.20 Insight Journey

```text
Insights
 ↓
Select category
 ↓
Read pattern
 ↓
View evidence period
 ↓
Understand limitation
 ↓
Choose action if useful
```

Each generated insight must answer:

```text
What was observed?
When was it observed?
How much data supports it?
What should the user consider doing?
```

The source design system requires insights to be explainable, sufficiently supported, non-overclaiming, and actionable. fileciteturn5file3L472-L495

## 10.21 Achievement Journey

```text
Profile
 ↓
Achievements
 ↓
Achievement Detail
 ↓
View criteria
 ↓
View earned date
 ↓
View reward or recognition
```

Achievement descriptions must exactly match achievement evaluation logic.

No hidden or approximate criteria are allowed.

## 10.22 Reminder Journey

```text
Habit Detail
 ↓
Enable Reminder
 ↓
Select time
 ↓
Explain local reminder behavior
 ↓
Request platform permission if needed
 ↓
Schedule local notification
 ↓
Save reminder configuration
```

The notification design system recommends requesting permission only after the user understands the value and has chosen a reminder. fileciteturn5file7L978-L1031

## 10.23 Data Export Journey

```text
Profile
 ↓
Data & Backup
 ↓
Export Data
 ↓
Validate local dataset
 ↓
Generate backup file
 ↓
Open system share/save interface
 ↓
Success
```

Export must be initiated by the user or by an explicit local backup action.

## 10.24 Data Import Journey

```text
Profile
 ↓
Data & Backup
 ↓
Import Backup
 ↓
System file picker
 ↓
Select compatible backup
 ↓
Validate format
 ↓
Preview import summary
 ↓
Confirm
 ↓
Create safety snapshot of current local data if supported
 ↓
Import
 ↓
Rebuild local derived data
 ↓
Show result
```

The import process must never silently overwrite incompatible data.

## 10.25 Data Reset Journey

```text
Profile
 ↓
Data & Backup
 ↓
Delete All Data
 ↓
Explain consequence
 ↓
Optional export reminder
 ↓
Explicit confirmation
 ↓
Delete local dataset
 ↓
Reset local profile
 ↓
Return to first-run state
```

The user must explicitly confirm irreversible deletion.

## 10.26 App Lock Journey

When app lock is enabled:

```text
Launch
 ↓
Local lock screen
 ↓
PIN or biometric
 ↓
Success
 ↓
Home
```

App lock is local privacy protection and not an online login mechanism.

## 10.27 Offline Journey

The application is always considered capable of offline operation.

There is no blocking offline screen.

If an external capability is unavailable, only that capability should be unavailable.

Core local operations remain available:

```text
Read data
Create habit
Complete habit
Write journal
Record mood
Record sleep
View progress
View insights
Export data
```

The psychology design system warns that an offline label should only imply synchronization when synchronization actually exists. fileciteturn1file9L1454-L1469

For the final local-only product, the preferred wording is:

```text
Saved locally
```

not:

```text
Syncing
Synced
Sync failed
```

## 10.28 Full Product Loop

The final product loop is:

```text
INTENTION
   ↓
PLAN
   ↓
CUE
   ↓
ACTION
   ↓
RECORD
   ↓
FEEDBACK
   ↓
REFLECTION
   ↓
REVIEW
   ↓
ADJUST
   ↓
RECOVERY WHEN NEEDED
   ↓
ACTION
```

The loop must remain lightweight enough that users can complete a normal habit interaction and leave the application immediately.

## 10.29 Journey Quality Criteria

Every primary journey must satisfy:

- no network requirement;
- clear primary action;
- no unnecessary form fields;
- no hidden state changes;
- immediate local persistence;
- recoverable failure state;
- predictable navigation;
- accessible touch targets;
- no shame-oriented wording;
- no emoji in product copy;
- no fabricated data;
- no unavailable action presented as available.

## 10.30 Journey-to-Requirement Traceability

Each later feature section must map back to one or more journeys in this section.

When implementing a feature, the coding agent must be able to answer:

```text
Which user journey does this implement?
Which requirement does it satisfy?
What local data does it read?
What local data does it write?
What states can occur?
What happens when the user cancels?
What happens when local persistence fails?
```

If these questions cannot be answered from the PRD, implementation must stop and the requirement must be clarified before code is added.

---

# Part 2 Completion Rules

The following rules apply specifically to Sections 6–10:

1. No online account flow may be introduced through persona, journey, or navigation design.
2. Local profile terminology must not be replaced with account terminology.
3. Navigation must remain limited to the five canonical primary destinations.
4. Sleep remains a feature area, not a mandatory bottom-navigation destination.
5. Home remains action-oriented and lightweight.
6. Progress and Insights remain separate mental modes.
7. Recovery is a first-class user journey.
8. Skip and Missed remain distinct states.
9. Pause is never represented as failure.
10. Journal and mood remain private local features.
11. Export and import remain user-controlled local data operations.
12. No sync terminology may be introduced into a local-only journey.
13. No emoji may be introduced anywhere in the product copy defined by this document.
14. Every new screen introduced in later sections must have a clear owner, purpose, entry point, exit path, and state model.
15. Any requirement that conflicts with this part must be resolved by updating the PRD before implementation.




# 11. Onboarding and First-Run Experience

## 11.1 Purpose

The onboarding flow introduces Prokopa, establishes a local profile, captures the user's initial focus, optionally helps create the first habit, and transitions the user into the Today experience.

The onboarding must not require account creation, login, password entry, email verification, network access, or external authentication.

The onboarding must remain useful when the user has no internet connection.

The onboarding must create a small commitment rather than collecting unnecessary profile data.

The onboarding must follow the psychology design system's principles of meaning, agency, and small commitment.

## 11.2 First-Run Definition

A device is considered in first-run state when no initialized Prokopa local profile exists in the local database.

First-run state is local to the device.

First-run state is not associated with an online account.

The application must persist the completion of onboarding locally.

Once onboarding is completed, normal application startup must open the primary application shell rather than restarting onboarding.

## 11.3 Onboarding Goals

Onboarding must accomplish the following goals:

1. Explain the product in one concise screen.
2. Establish the user's local display name.
3. Allow the user to choose a general growth focus.
4. Encourage creation of one realistic first habit.
5. Offer an optional reminder configuration only when a reminder is relevant.
6. Avoid overwhelming the user with settings.
7. End with a clear transition to Today.

## 11.4 Onboarding Must Not Include

The following are prohibited in onboarding:

- login form;
- signup form;
- email address requirement;
- password requirement;
- password confirmation;
- Google authentication;
- Apple authentication;
- social authentication;
- cloud account creation;
- mandatory notification permission request at launch;
- mandatory avatar selection;
- mandatory biography;
- mandatory long-form explanation;
- mandatory creation of multiple habits;
- mandatory journal entry;
- mandatory mood entry;
- mandatory sleep entry;
- marketing content;
- advertisements;
- subscription prompts.

## 11.5 Onboarding Screen Sequence

The preferred default sequence is:

```text
Welcome
  -> Focus
  -> Local Profile
  -> First Habit
  -> Ready
  -> Today
```

The application may skip the First Habit screen when the user explicitly chooses to finish setup without creating a habit.

The application must not add additional onboarding screens solely to increase session duration.

## 11.6 Welcome Screen

The Welcome screen must communicate the brand and core purpose with minimal text.

Required elements:

- Prokopa logo;
- Prokopa brand name;
- short product statement;
- primary action;
- secondary skip or continue path only when applicable.

Recommended visual hierarchy:

```text
Logo
Brand name
Short statement
Primary action
Secondary action
```

The primary action label should be concise and action-oriented.

Example copy structure:

```text
Prokopa: Habits and Jurnaling

Small steps. Clear progress.

[Get Started]
```

The exact copy is subject to the UX writing system, but the meaning must remain equivalent.

No emoji may appear anywhere on the Welcome screen.

## 11.7 Focus Selection

The Focus screen asks why the user is opening Prokopa.

Supported focus options should be limited to a small controlled set.

Recommended categories:

- Health
- Productivity
- Mind
- Sleep
- Balance
- Personal Growth

The user may select one or several focus areas.

Focus selection is not a permanent classification of the user.

Focus is used for local personalization of suggestions and initial content.

Focus selection must not block access to any feature.

If the user skips focus selection, the profile remains valid.

## 11.8 Local Profile Setup

The profile setup creates a local user profile only.

Required field:

- display name.

Optional fields may include:

- avatar selection from bundled local assets;
- short personal statement;
- focus areas.

No remote identity data may be requested.

The display name must be stored locally.

The local profile must be available to the rest of the application through a single profile state source.

## 11.9 Display Name Validation

The display name must:

- trim leading and trailing whitespace;
- reject an empty value;
- accept ordinary Unicode letters;
- support spaces within names;
- reject values that contain only whitespace;
- preserve the user's intended casing;
- have a defined maximum length.

Recommended maximum display name length: 40 characters.

The application should provide concise inline validation rather than a long explanatory message.

## 11.10 Focus Persistence

After focus selection, the selected values must be written to the local database.

If the user terminates the application during onboarding, previously confirmed steps must not be silently discarded.

The application may persist onboarding progress or may safely restart the current step, but it must not create duplicate profiles or duplicate initial habits.

## 11.11 First Habit Invitation

The first habit flow is intended to reduce setup friction while still introducing the application's core behavior model.

The flow should encourage one meaningful habit rather than multiple simultaneous habits.

The first habit flow must support:

- habit name;
- why the habit matters;
- frequency;
- cue;
- minimum version;
- optional reminder;
- start date.

These fields are aligned with the psychology design system's recommended habit creation flow.

The user may skip first habit creation.

## 11.12 First Habit Name

The habit name should be action-oriented.

Preferred:

```text
Read 5 pages
```

Avoid:

```text
Reading
```

The application should not invent or silently modify the user's habit name.

The application may provide local suggestions, but suggestions must remain optional.

## 11.13 Meaning Field

The optional Why field captures the user's personal reason for the habit.

Example:

```text
Why is this important?

I want to read more consistently.
```

The Why value is private local data.

The Why field must not be presented as a public social profile attribute.

The Why field must not be required to save a habit.

## 11.14 Minimum Version

The user may define a minimum version of a habit.

Example:

```text
Target: 30 minutes of exercise
Minimum: 5 minutes of stretching
```

The minimum version is intended to reduce all-or-nothing behavior.

The system must distinguish the planned target from the minimum version.

If a habit does not require a measurable minimum version, the field may remain empty.

## 11.15 Cue Selection

The onboarding habit flow should introduce the concept of stable cues.

A cue may be:

- after an existing activity;
- at a time;
- at a place;
- a combination of supported local context fields.

The simplest supported form is:

```text
After [existing activity]
At [place]
```

A cue is stored as structured data rather than only a display string whenever possible.

## 11.16 Reminder Choice

Reminder setup must be optional.

The user must be able to:

- enable a reminder;
- configure a reminder time;
- skip reminder setup.

Notification permission should be requested only after the user has chosen a feature that needs notifications and after the value of that permission has been communicated.

This follows the psychology design system's reminder flow.

## 11.17 Ready Screen

The final onboarding screen confirms that the user's local workspace is ready.

The screen should communicate:

- profile created locally;
- selected habit if any;
- next action;
- transition to Today.

The screen must not claim server synchronization, account activation, or cloud backup.

## 11.18 Onboarding Skip Behavior

Users must be able to skip optional personalization steps.

Skipping must not produce a warning implying that the user is making a bad choice.

Skip should mean:

```text
continue with a valid default configuration
```

not:

```text
continue with a broken or incomplete application
```

## 11.19 Onboarding Completion

Onboarding is complete only after a valid local profile exists and the local onboarding completion state has been persisted.

The application must not rely only on in-memory state to determine whether onboarding has been completed.

## 11.20 Existing Local Data

If valid local application data already exists, the application must not display first-run onboarding as if the device were new.

After a restore/import operation, the application must use the restored onboarding/profile state when the imported dataset contains a valid local profile.

## 11.21 Re-Onboarding

The application must not expose a normal user flow that repeatedly restarts onboarding.

A destructive reset of local data may return the application to first-run state.

Reset must require explicit confirmation.

## 11.22 Onboarding Navigation Rules

The user must be able to navigate backward through completed steps where doing so does not invalidate confirmed data.

Forward navigation requires the current step's mandatory fields to be valid.

Navigating back must not duplicate records.

## 11.23 Onboarding Accessibility

All controls must have semantic labels.

All primary controls must use practical touch targets of approximately 44–48 logical pixels where feasible.

Text must remain usable at increased system font sizes.

The application must not communicate state through color alone.

No emoji is allowed as the sole label for any control.

## 11.24 Onboarding Performance

Each onboarding screen must render without noticeable delay under normal local conditions.

Database writes must be asynchronous.

Onboarding should avoid unnecessary queries and repeated initialization work.

Static visual assets should be bundled efficiently.

## 11.25 Onboarding Acceptance Criteria

The following must be true:

```text
Given a fresh installation
When the application starts
Then the Welcome screen is displayed.
```

```text
Given the Welcome screen
When the user proceeds
Then no login or account creation is requested.
```

```text
Given the Local Profile step
When the user enters a valid display name
Then a local profile can be created without internet access.
```

```text
Given the user skips focus selection
When onboarding continues
Then the profile remains valid.
```

```text
Given the user skips first habit creation
When onboarding finishes
Then Today opens with an empty-habit state.
```

```text
Given the user creates a first habit
When onboarding completes
Then exactly one corresponding habit exists locally.
```

```text
Given the device has no internet connection
When onboarding is completed
Then the application remains fully usable.
```

---

# 12. Local Profile

## 12.1 Definition

The Prokopa profile is a local identity used only to personalize the application on the current device.

It is not an authentication account.

It is not transferable through login.

It does not require a remote identifier.

## 12.2 Profile Scope

The profile may contain:

- internal local identifier;
- display name;
- avatar identifier;
- short bio or personal statement if implemented;
- focus areas;
- created date;
- theme preference;
- locale preference if supported;
- notification preference;
- app lock preference metadata;
- onboarding completion state.

Sensitive fields must not be stored unless explicitly required by a feature.

## 12.3 Single Local Profile Model

The default product model is one active local profile per device workspace.

The application must not implement multi-account switching unless a later PRD section explicitly adds this requirement.

## 12.4 Profile Creation

Profile creation occurs during first-run onboarding.

The application must create the profile transactionally with required initial setup state.

If profile creation fails, the user must receive a concise recovery path.

A failed profile creation must not leave a partially initialized profile that causes the application to bypass onboarding incorrectly.

## 12.5 Profile Editing

The user must be able to edit the display name.

Avatar selection may be changed at any time.

Focus preferences may be changed at any time.

Profile changes must be saved locally immediately after valid confirmation.

The interface should avoid requiring a full-screen account workflow for simple profile edits.

## 12.6 Local Avatar

Avatars must be selected from bundled or locally stored assets.

Remote avatar URLs must not be required.

If a custom photo avatar is later supported, the photo must remain local unless the user explicitly exports it.

The profile must remain valid when no avatar is selected.

## 12.7 Profile Statistics

Profile may display meaningful local statistics such as:

- total active habits;
- total journal entries;
- total sleep records;
- current level;
- earned achievements;
- total tracked days.

Statistics must use precise labels.

The system must not label days-since-profile-creation as active days unless actual activity is being measured.

## 12.8 Activity Day Definition

A tracked activity day is a local calendar day on which the user performs at least one supported meaningful action.

Supported activity events may include:

- completing a planned habit;
- saving a journal entry;
- recording mood;
- recording sleep;
- completing a review;
- adjusting or recovering a habit when the product explicitly counts such an event.

The exact metric must be documented in the analytics specification and must not be inferred from profile creation date.

## 12.9 Theme Preference

Supported appearance modes should be:

- Light;
- Dark;
- System.

The selected appearance mode must persist locally.

On application restart, the theme provider must hydrate from the stored preference before presenting the final application state where practical.

The application must not reset a stored theme to System on every startup.

## 12.10 Local Profile Privacy

The profile must never expose journal content by default.

The profile screen may show aggregate journal counts but must not display private journal text unless the user navigates to it intentionally.

## 12.11 Profile Deletion

Deleting the local profile is a destructive operation.

The application must distinguish:

```text
Edit profile
```

from:

```text
Delete all local data
```

Deleting the profile must not silently leave associated personal data behind unless the user explicitly chooses a partial deletion mode.

## 12.12 Profile Reset

A complete local reset must remove all application-owned user data and return the product to first-run state.

The reset flow must:

1. explain the consequence concisely;
2. require explicit confirmation;
3. perform the deletion transactionally where possible;
4. close or refresh stale providers;
5. return the application to a clean first-run state.

## 12.13 Import Interaction

If imported backup data contains a profile, the imported profile may replace the current profile only after explicit confirmation.

The application must not overwrite existing data silently.

If imported data is invalid, existing local data must remain untouched.

## 12.14 Export Interaction

Profile data is part of the user's local dataset and should be included in a complete export unless the user explicitly chooses a reduced export scope.

## 12.15 Profile Acceptance Criteria

```text
Given a fresh application
When onboarding is completed
Then exactly one valid local profile exists.
```

```text
Given an existing local profile
When the user edits the display name
Then the updated value persists after application restart.
```

```text
Given the user selects Dark appearance
When the application is restarted
Then Dark remains selected.
```

```text
Given the user chooses to reset all data
When the destructive confirmation is accepted
Then local application data is removed and first-run state is restored.
```

---

# 13. Habit Management

## 13.1 Purpose

Habit Management covers creation, viewing, editing, archiving, pausing, resuming, deleting, and organizing habits.

The design must prioritize action clarity, low friction, realistic commitment, stable cues, meaningful progress, and recovery.

## 13.2 Habit Definition

A habit is a user-defined behavior plan with an intended action, schedule, optional context cue, optional target, optional minimum version, and optional reminder.

A habit is not identical to its streak.

A streak is an output derived from valid habit performance history.

## 13.3 Required Habit Fields

A valid habit must contain:

- local habit identifier;
- title;
- schedule definition;
- created date;
- active status.

## 13.4 Optional Habit Fields

A habit may contain:

- description;
- why;
- category;
- icon;
- accent color;
- cue;
- minimum version;
- quantitative target;
- reminder configuration;
- start date;
- end date;
- pause information.

## 13.5 Habit Title Validation

The title must:

- be non-empty;
- be trimmed;
- have a defined maximum length;
- remain readable in a habit card;
- support ordinary Unicode text;
- not be silently rewritten into another action.

Recommended maximum: 80 characters.

The UI should encourage concise action-oriented titles.

## 13.6 Habit Description

Description is optional.

It may provide additional context without becoming the primary title.

Description should not be necessary to complete a habit.

## 13.7 Habit Why

Why is optional and private.

It should be presented as a personal meaning field rather than a motivational slogan.

The application must not use the Why text as a basis for psychological diagnosis.

## 13.8 Category

Categories provide organization and filtering.

Recommended default categories:

- Health;
- Learning;
- Productivity;
- Mind;
- Lifestyle;
- Personal;
- Sleep;
- Other.

The category model should remain small and stable.

The application must not create uncontrolled category proliferation.

## 13.9 Icon

The user may select an icon from a predefined local icon set.

Icons must remain visually consistent with the design system.

The icon is decorative/supportive and must not be the only semantic indication of the habit.

The habit title remains the primary semantic label.

## 13.10 Color

The user may choose an accent color for a habit from a controlled palette.

Habit colors are user customization, not status encoding.

Completion state must not depend solely on the chosen habit color.

Semantic colors must remain separate from user-selected decorative colors.

## 13.11 Create Habit

The Create Habit flow must support a simple path and an expanded path.

Simple path must allow the user to create a valid habit without filling optional fields.

Expanded path exposes additional structure such as Why, Cue, Minimum version, target, and reminder.

The UI must not force the user through unnecessary configuration before the first useful action.

## 13.12 Habit Editing

The user can modify editable habit properties without deleting historical completion records.

Editable fields may include:

- title;
- description;
- why;
- category;
- icon;
- color;
- schedule;
- cue;
- minimum version;
- target;
- reminder.

Editing a schedule must not retroactively rewrite historical completion events.

Historical records represent what happened under the conditions at that time.

## 13.13 Schedule Change Rule

When a user changes a habit schedule, the application must preserve historical logs.

Future planned instances should be evaluated using the new schedule from the effective date forward.

The system should store enough information to determine when a schedule change becomes effective if the feature supports future-dated changes.

## 13.14 Habit Archive

Archive is the default non-destructive way to remove a habit from active use.

Archived habits should not appear in the default active habit list.

Historical logs must remain available.

Archived habits may remain visible in history and analytics where appropriate.

Archiving must not delete progress.

## 13.15 Habit Delete

Delete is destructive and should be used for intentional removal of habit data.

The application should prefer archive for routine deactivation.

If delete is supported, the confirmation must explain that historical data will also be affected.

The application must not use delete as the default response to inactivity.

## 13.16 Habit Pause

Pause is a first-class state.

Pausing means the user intentionally suspends planned habit instances for a period or until resumed.

Pause must not be represented as failure.

During a paused period, the system must not count planned dates as missed.

Historical progress remains intact.

The user may optionally specify a resume date.

## 13.17 Habit Resume

Resume returns the habit to active scheduling.

Resuming must calculate future due instances from the resume point.

The application must not create retroactive missed states for the pause period.

## 13.18 Habit States

The high-level habit lifecycle is:

```text
CREATED
  -> ACTIVE
  -> PAUSED
  -> ACTIVE
  -> ARCHIVED
```

A habit may move from Active to Archived without entering Paused.

A habit that has been archived should not be automatically resumed by a background task.

## 13.19 Habit Instance States

For scheduled instances, supported states are:

```text
UPCOMING
DUE
COMPLETED
SKIPPED
MISSED
```

Not every calendar date creates an instance.

A date outside the habit schedule is a `NO_PLAN` condition rather than a missed instance.

## 13.20 No-Plan Rule

A non-scheduled date must not count as a missed habit day.

Example:

```text
Schedule: Monday, Wednesday, Friday
Tuesday: NO_PLAN
```

Tuesday must not negatively affect consistency calculations.

## 13.21 Habit Card Information Hierarchy

The preferred information hierarchy is:

1. action;
2. cue;
3. status/progress;
4. primary action;
5. secondary metadata.

This follows the psychology design system's habit card hierarchy.

## 13.22 Habit Card Content

A typical habit card should show:

```text
[Icon] Read 5 pages
        After dinner
        4 / 5 this week
        [Complete]
```

The exact content may vary by schedule type.

## 13.23 Daily Habit Card

For daily habits, the card should prioritize today's state.

Example structure:

```text
Read 5 pages
After dinner
Today
[Complete]
```

A supporting weekly consistency value may appear below the primary action.

## 13.24 Weekly Target Habit Card

For habits based on occurrences per week, the card should prioritize period progress.

Example:

```text
Exercise
3 times this week
2 / 3 completed
[Log today]
```

The UI must not force a daily streak representation onto a weekly-target habit.

## 13.25 Specific Day Habit Card

For specific-day schedules, the card should communicate whether the habit is planned today.

If today is not scheduled:

```text
No plan today
Next: Wednesday
```

No missed state should be shown when no instance exists.

## 13.26 Habit List Filters

The habit list should support simple filters such as:

- All;
- Active;
- Paused;
- Archived.

Schedule-based filters such as Daily and Weekly may be provided if they remain simple and useful.

Filters must not become a multi-control dashboard.

## 13.27 Habit Search

Habit search is optional for small datasets.

If implemented, search should operate on title and optionally description.

Search must remain local and immediate.

## 13.28 Habit Ordering

The default active habit ordering should prioritize what is actionable today.

Recommended order:

1. Due habits;
2. Upcoming habits;
3. Completed habits;
4. Paused or inactive content only when explicitly requested.

The exact ordering must remain deterministic.

## 13.29 Completed Habit Presentation

Completed habits should remain visible enough to communicate progress but should have reduced visual emphasis compared with unfinished due actions.

Completion should not require navigating away from the list.

## 13.30 Overdue Habit Presentation

The application must not use alarmist language for overdue or missed habits.

Avoid:

```text
You are falling behind.
```

Use neutral state language such as:

```text
Not completed
```

or:

```text
Missed
```

## 13.31 Recovery Entry Point

After a meaningful lapse, the user should be able to access recovery actions from the habit context.

The available actions are:

- Continue;
- Reduce target;
- Change cue;
- Pause habit.

The exact threshold for showing a dedicated recovery surface must be deterministic and documented in the state/behavior specification.

## 13.32 Habit Notes

A completion may optionally carry a short note.

The note is attached to the completion event, not to the habit definition itself.

Habit-level notes should remain separate from event-level notes.

## 13.33 Quantitative Targets

A habit may define a quantitative target when the action naturally supports measurement.

Examples:

```text
Drink water: 8 glasses
Read: 5 pages
Exercise: 30 minutes
```

The system must distinguish:

```text
target value
```

from:

```text
binary completion
```

If quantitative logging is not implemented for a habit type, the target field must not be presented as if it changes completion logic.

## 13.34 Habit Completion Mode

Each habit should have one defined completion model:

- binary;
- quantitative;
- duration-based;
- minimum-target based where explicitly supported.

The product must not silently mix incompatible completion models.

## 13.35 Habit Default Values

Defaults should minimize setup friction.

Recommended defaults:

- status: Active;
- start date: Today;
- reminder: Off;
- optional fields: Empty;
- minimum version: Empty unless inferred from a structured template;
- category: user-selected or Other;
- color: default brand-compatible accent.

Defaults must not create deceptive behavior.

## 13.36 Habit Creation Duplicate Prevention

Creating a habit must not create duplicate records because of repeated button taps.

The primary action should be protected against duplicate submission while a save is in progress.

The database operation should be atomic.

## 13.37 Habit Editing Duplicate Prevention

Saving an edit must update the existing local record rather than creating another habit.

Repeated save taps must not generate duplicates.

## 13.38 Habit Historical Integrity

Historical completion records must remain associated with the original habit identifier.

Changing the title or icon must not create a new habit identity unless the product explicitly supports cloning.

## 13.39 Habit Clone

Habit cloning is optional and out of the minimum feature set.

If added later, the clone must receive a new identifier and must not copy historical logs as completed events.

## 13.40 Habit Limits

The application should avoid arbitrary low limits that block legitimate personal use.

The product may establish safe engineering limits for extreme cases, but those limits must not be used as a motivational mechanism.

## 13.41 Habit Acceptance Criteria

```text
Given no existing habits
When the user creates a valid habit
Then one active habit is stored locally.
```

```text
Given an existing habit
When the user edits its title
Then the same habit identity remains and historical logs are preserved.
```

```text
Given a habit scheduled only on Monday, Wednesday, and Friday
When the current date is Tuesday
Then the habit instance is NO_PLAN rather than MISSED.
```

```text
Given an active habit
When the user pauses it
Then no planned instances during the pause period become missed.
```

```text
Given an archived habit
When the user views active habits
Then the archived habit is not shown in the default active list.
```

```text
Given repeated taps on Create Habit
When the first save is still processing
Then only one habit record is created.
```

---

# 14. Habit Scheduling and Cue Model

## 14.1 Purpose

Scheduling defines when a habit is planned.

Cue modeling defines contextual information intended to help the user associate the behavior with a stable routine.

Scheduling and cue information must be represented as distinct concepts.

## 14.2 Schedule Requirements

The schedule model must support non-daily behavior.

At minimum, supported schedule types should include:

- Daily;
- Specific Days;
- Times Per Week.

Interval and Custom schedules may be added when their business rules are fully specified.

The system must not expose a schedule type that has no corresponding calculation logic.

## 14.3 Daily Schedule

Daily means the habit is planned on each calendar day within its effective active period.

The application must account for the user's local calendar date.

## 14.4 Specific Days Schedule

Specific Days allows selection of one or more weekdays.

Example:

```text
Monday
Wednesday
Friday
```

Only selected weekdays generate planned instances.

## 14.5 Times Per Week Schedule

Times Per Week defines a target number of completed occurrences within a local calendar week.

Example:

```text
Exercise
3 times per week
```

A successful week is determined by meeting the configured target.

The UI should show:

```text
2 / 3 this week
```

rather than a daily streak when the behavior is period-target based.

## 14.6 Week Boundary

The application must define one local week boundary consistently across all features.

The preferred default should follow the device locale or a single application setting if configurable.

All weekly analytics, weekly targets, weekly reviews, and weekly achievements must use the same week definition.

## 14.7 Start Date

Every habit must have an effective start date.

Dates before the effective start date are `NO_PLAN` for that habit.

They must not count as missed.

## 14.8 End Date

An optional end date may define the final planned date.

Dates after the end date are `NO_PLAN`.

The application must not mark post-end dates as missed.

## 14.9 Pause Interval

A pause interval temporarily suspends planned instances.

Pause periods are not missed periods.

The application should support:

```text
Pause until [date]
```

and, where practical:

```text
Pause indefinitely
```

An indefinite pause remains paused until explicitly resumed.

## 14.10 Multiple Pause Periods

If multiple pause periods are supported, they must not overlap in a way that creates contradictory state.

The system must normalize or reject overlapping intervals deterministically.

## 14.11 Effective Schedule

At any date, the schedule evaluator must determine exactly one of:

```text
NO_PLAN
PLANNED
PAUSED
```

The instance engine then determines whether the planned instance is:

```text
UPCOMING
DUE
COMPLETED
SKIPPED
MISSED
```

## 14.12 Schedule Evaluation Order

The evaluator should apply rules in this conceptual order:

```text
Habit exists
  -> Effective date range
  -> Pause intervals
  -> Schedule pattern
  -> Planned instance
  -> Instance state
```

A paused date must not be evaluated as a missed planned date.

A non-scheduled date must not be evaluated as missed.

## 14.13 Time Zone

All date-based habit logic must use the user's device local date context.

The system should avoid converting a local habit date through UTC in a way that changes the visible calendar day.

Stored timestamps should use a consistent internal representation.

Calendar-date fields must be treated as date concepts rather than arbitrary timestamps where possible.

## 14.14 Reminder Time

Reminder time is separate from habit schedule.

A habit may be scheduled without a reminder.

A reminder may exist for a scheduled habit, but the existence of a reminder does not make the habit planned.

## 14.15 Cue Model

A cue should be represented using structured fields when possible.

Suggested model:

```text
cueType
cueActivity
cueTime
cuePlace
cueText
```

Only fields relevant to the selected cue type should be populated.

## 14.16 Routine Cue

Routine cues may refer to an existing activity such as:

```text
After breakfast
After brushing teeth
After opening my laptop
After dinner
```

The application should present cue suggestions from a controlled local list.

Users must be able to enter custom cue text.

## 14.17 Time Cue

A time cue may specify a local time.

Example:

```text
08:00
```

Time cue is useful for planning and reminder support but must not be represented as the only possible habit context.

## 14.18 Place Cue

A place cue may be a manually entered place label.

The initial offline-only product should not require continuous location tracking.

Location-aware automation is out of scope unless explicitly added later with a complete local privacy design.

This avoids unnecessary surveillance and remains aligned with the psychology design system's preference for routine over continuous location collection.

## 14.19 Combined Cue

A habit may use multiple cue components.

Example:

```text
After dinner
At home
```

The UI should still display this information concisely.

## 14.20 Cue Editing

Editing a cue affects future interpretation and guidance.

Changing a cue must not modify historical completion events.

Historical analytics may continue to show the current habit definition with appropriate labeling or may require versioned history if the product later needs historical schedule reconstruction.

## 14.21 Cue Display

A habit card should display a cue only when one exists.

If no cue exists, the card should not show an empty placeholder such as:

```text
No cue available
```

unless the user is in a configuration or coaching context.

## 14.22 Minimum Version Interaction

For habits with a minimum version, the system should allow the user to complete using the minimum route where that behavior is explicitly supported.

Example:

```text
Target: Exercise 30 minutes
Minimum: Stretch 5 minutes
```

The completion model must document whether the minimum version counts as:

- full completion;
- partial completion;
- a separate recovery completion.

The application must not imply a scoring rule that is not implemented.

## 14.23 Partial Completion

Partial completion is optional and should only be enabled when the habit has a measurable structure that supports it.

Binary habits should not display a false partial percentage.

When partial completion is supported, the system must define:

- entered value;
- target value;
- completion threshold;
- display format;
- analytics treatment.

## 14.24 Frequency Change

Changing from Daily to Times Per Week must affect future scheduling only.

Historical logs remain historical facts.

The system must recalculate future planned instances using the new schedule.

## 14.25 Weekly Target Calculation

For Times Per Week habits:

```text
weeklyProgress = completedOccurrencesWithinCurrentWeek
weeklyTarget = configuredTarget
```

The progress display must be bounded or normalized to the configured target according to the product's explicit UX rule.

A user who completes 4 of 3 planned occurrences should not produce an invalid negative or overfilled state.

Recommended display:

```text
3 / 3
Target reached
```

while retaining raw repetition count separately if useful.

## 14.26 Weekly Target Success

A week is considered successful when:

```text
completedOccurrences >= weeklyTarget
```

for the active portion of the schedule.

The system must define how a habit that starts or pauses mid-week is treated.

The preferred rule is to evaluate only the eligible planned period, rather than penalizing a partial week with impossible expectations.

## 14.27 Specific-Day Consistency

For specific-day schedules, consistency is calculated against planned days only.

Example:

```text
Monday planned: completed
Wednesday planned: completed
Friday planned: missed
```

Consistency:

```text
2 / 3
```

Tuesday and Thursday are no-plan days.

## 14.28 Daily Streak

Daily streak is valid only for schedules whose intended successful unit is a day.

The daily streak algorithm must not be applied to weekly-target habits.

## 14.29 Weekly Streak

For Times Per Week habits, the streak unit should be a successful week rather than a day.

Example:

```text
Week 1: 3 / 3
Week 2: 4 / 3
Week 3: 3 / 3
```

Weekly streak:

```text
3 successful weeks
```

## 14.30 Schedule and Reminder Relationship

Changing a schedule may require updating future local notifications.

Changing only a cue does not automatically create notifications unless a reminder is configured.

Turning a reminder off must cancel future reminder instances without changing habit completion history.

## 14.31 Local Notification Scheduling

Notification scheduling must be entirely local.

A scheduled notification must not depend on a server.

If the operating system cannot guarantee a scheduled notification, the UI must not claim server-level guarantees.

The application must handle local permission denial gracefully.

## 14.32 Notification Privacy

Notification text must avoid exposing sensitive journal or mood content by default.

Preferred:

```text
Time for your check-in.
```

Avoid:

```text
Do not forget to write about your anxiety.
```

This follows the privacy and notification guidance in the psychology design system.

## 14.33 Notification Batching

The product should avoid creating one aggressive notification for every habit by default.

The preferred model is user-controlled reminders with reasonable limits and optional summary behavior.

The application must not introduce artificial urgency to create more opens.

## 14.34 Schedule Validation

The schedule editor must prevent impossible configurations.

Examples:

- Times Per Week target must be positive;
- Specific Days requires at least one selected day;
- end date cannot precede start date;
- reminder time must be valid;
- pause end date cannot precede pause start date.

Validation errors should be inline and concise.

## 14.35 Schedule Preview

When schedule configuration becomes complex, the UI should show a concise preview.

Example:

```text
You plan to exercise 3 times each week.
```

or:

```text
Planned: Monday, Wednesday, Friday
```

The preview must use the same calculation logic as the actual schedule engine.

## 14.36 Schedule Acceptance Criteria

```text
Given a Daily habit
When the current date is within its active period
Then a planned instance exists for today.
```

```text
Given a Specific Days habit configured for Monday, Wednesday, and Friday
When today is Tuesday
Then no habit instance is considered planned for today.
```

```text
Given a Times Per Week habit with target 3
When the user completes it twice this week
Then the progress displays 2 / 3.
```

```text
Given a Times Per Week habit with target 3
When the user completes it three times this week
Then the week is successful.
```

```text
Given a paused habit
When a date falls inside the pause interval
Then the date is not missed.
```

```text
Given a reminder configured for a local time
When notification permission is denied
Then the habit remains usable and the application clearly communicates that reminders are unavailable.
```

---

# 15. Habit Completion and State Model

## 15.1 Purpose

Habit completion records what the user actually did for a planned habit instance.

Completion must be quick, reliable, locally persisted, and reversible where the business rule permits.

## 15.2 Core Principle

The completion interaction should be the lowest-friction habit interaction in the product.

The user should be able to complete a simple habit in one primary interaction.

The completion action must not require a modal confirmation for normal use.

## 15.3 Completion Record

A completion record should contain enough information to identify:

- habit;
- local calendar date;
- completion state;
- optional recorded value;
- optional note;
- creation/update timestamp.

## 15.4 One Habit Per Date Rule

For binary daily-style habit instances, the system should enforce one authoritative completion state per habit and planned date.

The preferred database invariant is equivalent to:

```text
UNIQUE(habitId, date)
```

when the domain model supports one event per date.

If quantitative logging allows multiple entries per date, the data model must explicitly use a separate event model rather than silently allowing duplicates.

## 15.5 Completion Toggle

For binary habit completion:

```text
Not completed
  -> Completed

Completed
  -> Not completed
```

Undo should be available when the date and business rules permit it.

Undo must update the authoritative local record rather than inserting a second contradictory completion record.

## 15.6 Completion Idempotency

Repeated completion requests for the same habit/date must result in one consistent final state.

Double tapping the completion control must not create duplicate log rows.

The data layer should enforce or safely handle uniqueness.

## 15.7 Completion Feedback

After completion, the UI should provide immediate feedback through:

- visual state change;
- progress update;
- optional subtle haptic feedback.

The application should not show a full-screen celebration for every normal completion.

The psychology design system explicitly recommends low-friction completion with small feedback and avoiding frequent interruption.

## 15.8 Completion Date

A completion event is associated with the intended local calendar date.

Cross-midnight behavior must be deterministic.

If the user records a habit shortly after midnight that belongs to the previous day's routine, the product should provide an explicit mechanism if retroactive logging is supported.

The application must not guess silently across date boundaries.

## 15.9 Retroactive Completion

The product may allow users to record a past completion.

If enabled, the UI must clearly identify the date being edited.

Retroactive completion must not bypass schedule rules without explicit product policy.

If a date was not planned, the application may allow a historical note or optional unscheduled record only if the data model supports it, but it must not silently turn a no-plan day into a planned day.

## 15.10 Future Completion

Future completion must not be allowed through the normal one-tap completion flow.

Future planning belongs to schedule configuration, not completion history.

## 15.11 Skip State

Skip is an intentional user decision to not perform a planned instance without treating the instance as a failure.

Skip must be distinct from Missed.

Example:

```text
Planned
  -> Skipped
```

The historical record must preserve that the user intentionally skipped the instance.

## 15.12 Skip Reasons

Optional reasons may include:

- Sick;
- Travel;
- Rest;
- Schedule changed;
- Other.

Reasons must be optional.

The application must not require a justification to grant the skip state.

## 15.13 Missed State

Missed means a planned instance reached its evaluation boundary without a completion or explicit skip.

Missed is a neutral data state.

It must not be rendered as punishment.

## 15.14 No-Plan State

No-plan means no habit instance was scheduled for that date.

No-plan is not a failure state.

No-plan must be distinguishable from Missed in analytics and calendar views.

## 15.15 Paused State

Paused is associated with the habit schedule rather than a failed habit instance.

A paused date must not create a missed record.

## 15.16 Due State

Due indicates the planned instance is currently actionable.

The Due state should be used to prioritize actions in Today.

## 15.17 Upcoming State

Upcoming indicates that the habit is planned later in the relevant local day or period but is not currently due under the configured schedule logic.

The product must define the exact due threshold consistently.

## 15.18 Instance State Transition

The preferred instance state model is:

```text
UPCOMING
   -> DUE
   -> COMPLETED

DUE
   -> SKIPPED

DUE
   -> MISSED
```

Undo is a controlled reversal of completion, subject to supported editing rules.

## 15.19 Completed to Undo

If the user unchecks a completed habit for the current date:

```text
COMPLETED
   -> DUE
```

The application should not automatically produce a Missed state merely because completion was removed.

## 15.20 Skip Undo

If skip can be undone:

```text
SKIPPED
   -> DUE
```

The UI must clearly indicate that the user is changing today's state.

## 15.21 Historical Completion Editing

Historical completion records may be editable when the user intentionally reviews a past date.

The application must make the selected date obvious.

Historical editing must update the authoritative record instead of creating duplicate records.

## 15.22 Completion and Streak Calculation

Streak calculations must use valid completion states only.

The calculation must also respect the habit schedule type.

The following must not count as completed:

- missed;
- skipped;
- no-plan;
- paused.

A partial completion rule, if implemented, must be defined explicitly before being included in streak calculations.

## 15.23 Completion and Consistency Calculation

Consistency is calculated against eligible planned instances, not all calendar days.

Conceptually:

```text
consistency = completedEligibleInstances / eligiblePlannedInstances
```

The UI should present the result in a human-readable form.

## 15.24 Completion and Weekly Review

Weekly review must use the same underlying completion facts as Today, Progress, and Analytics.

There must be one source of truth for completion data.

Weekly review must not use independently maintained counters that can diverge from the underlying logs.

## 15.25 Completion and Achievements

Achievements should be triggered from authoritative state changes or deterministic recalculation.

Achievement evaluation must not depend on whether a particular screen happened to be open when completion occurred.

This avoids missed achievement triggers caused by navigation timing.

## 15.26 Completion and XP

If XP is awarded for completion, the business rule must be deterministic.

The same completion must not repeatedly award XP because of repeated screen refreshes.

The final gamification specification will define whether completion XP exists and exactly how idempotency is enforced.

## 15.27 Completion Note

The user may optionally add a short note after completion.

The note should not interrupt the core completion action.

The preferred interaction is:

```text
Complete
  -> optional Add note
```

not:

```text
Complete
  -> mandatory form
  -> save
```

## 15.28 Completion Mood

The user may optionally associate a mood with a completion when the mood feature is available.

Mood must remain optional.

The habit completion flow must not require mood tracking for every habit.

## 15.29 Completion Duration

Duration may be optionally recorded for duration-based habits.

If duration is not part of the selected habit model, the completion UI should not display an unnecessary duration field.

## 15.30 Minimum Version Completion

When a minimum version exists, the product must define how it is recorded.

Possible semantics are:

```text
FULL
MINIMUM
```

or:

```text
PARTIAL
```

The final implementation must use one explicit model.

The UI must not label a minimum action as full completion if analytics treat it differently.

## 15.31 Recovery Completion

A recovery action may intentionally use a minimum version to reduce restart friction.

Recovery completion must preserve the user's historical progress.

The product should avoid presenting recovery as a score reset.

## 15.32 Missed-Day UX

When a habit was missed, the default language should remain neutral.

Recommended:

```text
Yesterday was missed.
Continue today?
```

or:

```text
Not completed.
```

Avoid:

```text
You failed.
```

This follows the recovery-first and self-compassion principles in the psychology design system.

## 15.33 Long Absence UX

After a meaningful period without interaction, the user should see a welcome-back experience rather than a punitive streak-loss message.

Preferred structure:

```text
Welcome back.

Your previous progress is still here.

Continue with the same plan
or make it lighter?
```

Available actions:

```text
Continue
Reduce target
Change cue
Pause habit
```

The exact absence threshold must be specified in a later behavioral configuration section rather than hard-coded in multiple screens.

## 15.34 Completion Accessibility

The entire habit card or an appropriately sized interaction region may be clickable when it does not create conflicting actions.

Primary completion control should have a large enough touch target.

The completion state must include semantic text for assistive technologies.

Example semantic state:

```text
Read 5 pages, completed today
```

No screen reader should receive a meaningless icon-only label.

## 15.35 Completion Motion

Completion animation should be brief and state-oriented.

Recommended baseline:

```text
80ms–180ms
```

The motion should communicate:

```text
incomplete -> complete
```

It must not block interaction.

Reduced-motion preferences must be respected.

## 15.36 Offline Persistence

Completion must be written to local storage before the UI is allowed to claim the state is durably saved, subject to normal asynchronous UI behavior.

If a local write fails, the UI must not permanently present the record as saved.

The application should provide an actionable local error state.

## 15.37 Local Save Failure

A local save failure must not trigger a fake sync state.

The product is local-only.

Preferred error language:

```text
Could not save this change.
Try again.
```

Avoid:

```text
Sync failed.
```

because no cloud synchronization exists.

## 15.38 Completion Race Conditions

If multiple UI events attempt to update the same habit/date at nearly the same time, the data layer must produce one deterministic result.

The provider layer must refresh from authoritative storage rather than assuming the optimistic state is final.

## 15.39 Completion Transaction Boundary

The state update and any required dependent local writes should be completed transactionally when the database model requires atomicity.

Example dependent operations may include:

- completion record update;
- achievement evaluation trigger state;
- local aggregate refresh.

The implementation must avoid leaving a half-applied completion state.

## 15.40 Completion State Source of Truth

There must be one authoritative persistence source for habit completion.

Derived values such as:

- streak;
- consistency;
- weekly progress;
- completion percentage;
- achievement eligibility;

must be calculated from authoritative records or from reliably synchronized derived data.

UI-local counters must not become a second source of truth.

## 15.41 Completion List Refresh

After completion, all visible components that depend on the changed data should update without requiring an application restart.

At minimum:

- habit card;
- Today progress;
- habit detail statistics;
- relevant streak value;
- relevant weekly progress.

The update should be reactive where practical.

## 15.42 Completion Acceptance Criteria

```text
Given an active due binary habit
When the user taps Complete
Then the habit becomes Completed for that planned date.
```

```text
Given a completed habit
When the user taps the completion control again
Then the current completion can be undone according to the supported editing policy.
```

```text
Given a habit scheduled only for Monday, Wednesday, and Friday
When Tuesday is displayed
Then Tuesday is not counted as a missed instance.
```

```text
Given a planned instance
When the user selects Skip
Then the state becomes Skipped rather than Completed or Missed.
```

```text
Given a planned instance with no completion or skip by the evaluation boundary
Then the state can become Missed.
```

```text
Given a paused habit
When a date falls within the pause period
Then no Missed completion record is created for that date.
```

```text
Given repeated taps on Complete
When the action is processed
Then duplicate completion records are not created.
```

```text
Given a local database write failure
When the completion cannot be persisted
Then the UI does not permanently represent the change as saved and provides a retry path.
```

```text
Given the application is offline
When the user completes a habit
Then completion works without internet access.
```

```text
Given the user returns after a lapse
When the recovery surface is shown
Then historical progress remains available and the user is offered a constructive continuation path.
```

---

# End of Part 3

Part 4 must continue from Section 16 without renumbering or duplicating requirements already defined here.

Recommended next scope:

```text
16. Streak, Consistency, Progress, and Recovery
17. Journal
18. Guided Journal
19. Mood Tracking
20. Sleep Tracking
```


# 16. Streak, Consistency, Progress, and Recovery

## 16.1 Purpose

Section ini mendefinisikan seluruh aturan bisnis untuk pengukuran perkembangan habit.

Streak bukan definisi utama keberhasilan habit.

Sistem harus dapat membedakan:

- repetition
- completion rate
- consistency
- current streak
- longest streak
- weekly progress
- monthly rhythm
- recovery
- missed
- skipped
- paused
- no-plan

Design system menetapkan bahwa streak hanya merupakan representasi momentum, sedangkan habit merupakan hubungan antara konteks dan respons. Progress harus tersedia dalam beberapa bentuk dan tidak boleh membuat pengguna bergantung pada perfect streak. fileciteturn4file3L635-L649 fileciteturn2file3L908-L948

## 16.2 Terminology

### 16.2.1 Completion

Satu instance habit yang diselesaikan sesuai jadwal.

### 16.2.2 Repetition

Jumlah penyelesaian habit yang valid sepanjang periode.

### 16.2.3 Planned Instance

Occurrence yang memang dijadwalkan untuk tanggal tersebut.

### 16.2.4 No-Plan

Tanggal yang tidak termasuk jadwal habit.

No-plan bukan missed.

### 16.2.5 Missed

Planned instance yang berakhir tanpa completion atau skip.

### 16.2.6 Skipped

Planned instance yang secara eksplisit dilewati oleh pengguna.

Skip bukan completion dan bukan missed.

### 16.2.7 Paused

Habit sementara tidak menghasilkan planned instance sampai tanggal resume.

Pause bukan failure.

### 16.2.8 Recovery

Perilaku pengguna kembali melakukan habit setelah lapse atau interruption.

## 16.3 Progress Principles

Sistem harus menyediakan setidaknya:

1. Completion rate
2. Repetition count
3. Current streak
4. Longest streak
5. Period consistency
6. Calendar history
7. Recovery count

Sistem tidak boleh menjadikan current streak sebagai satu-satunya metric.

## 16.4 Daily Habit Streak

Daily streak dihitung berdasarkan planned daily instances.

Aturan:

1. Hanya instance dengan status completed yang dapat memperpanjang streak.
2. No-plan tidak boleh memutus streak karena no-plan tidak pernah menjadi obligation.
3. Skipped tidak dihitung sebagai completion.
4. Missed memutus consecutive completion streak.
5. Paused period tidak dihitung sebagai missed.
6. Historical data sebelum lapse tetap dipertahankan.
7. Current streak dihitung dari completion terbaru yang relevan terhadap hari berjalan.
8. Longest streak dihitung dari rangkaian completion terpanjang dalam historical data.

## 16.5 Weekly Frequency Streak

Habit dengan target X times per week tidak menggunakan daily streak.

Contoh:

Habit:
Read 3 times per week

Week A:
3/3 completed

Week B:
3/3 completed

Week C:
2/3 completed

Maka weekly streak berhenti pada Week B.

UI harus menampilkan:

`2 / 3 this week`

bukan:

`0-day streak`

Aturan ini merupakan bagian eksplisit dari design system. fileciteturn2file2L716-L759

## 16.6 Specific-Day Habit

Habit yang dijadwalkan pada hari tertentu hanya menghasilkan planned instance pada hari tersebut.

Contoh:

Monday, Wednesday, Friday.

Tuesday:

`No plan`

bukan:

`Missed`

## 16.7 Completion Rate

Formula dasar:

`completed planned instances / total planned instances`

Periode statistik harus dibatasi ke planned instances yang berada dalam periode evaluasi.

Habit yang baru dibuat tidak boleh mendapatkan denominator dari hari sebelum creation date.

Paused period tidak masuk denominator.

No-plan tidak masuk denominator.

## 16.8 Repetition Count

Repetition count adalah jumlah completion yang valid.

Contoh:

`42 repetitions`

Angka ini bersifat historical dan tidak berkurang karena streak putus.

## 16.9 Recovery Count

Recovery count bertambah ketika:

1. habit memiliki interruption atau lapse,
2. pengguna kemudian melakukan completion setelah interruption tersebut.

Recovery count tidak boleh bertambah dari dua completion berturut-turut tanpa interruption.

Recovery merupakan metric positif yang menunjukkan kemampuan kembali, bukan indikator kegagalan.

## 16.10 Historical Integrity

Lapse tidak boleh:

- menghapus completion lama,
- mengubah longest streak historical,
- mengurangi repetition count,
- menghapus weekly review,
- menghapus journal,
- menghapus sleep data.

Sistem hanya mengubah current state dan metrics yang memang bergantung terhadap current continuity.

Design system secara eksplisit menetapkan bahwa lapse tidak menghapus historical progress. fileciteturn4file0L169-L183

## 16.11 Missed Day Presentation

Missed state harus netral.

Gunakan:

- `Missed`
- `Not completed`

Jangan menggunakan copy yang menyalahkan pengguna.

Design system melarang visual missed yang punitive dan menekankan state netral. fileciteturn2file3L952-L994

## 16.12 Recovery UX

Ketika pengguna kembali setelah lapse:

Header:

`Welcome back`

Subtext:

`Mau melanjutkan target yang sama atau membuatnya lebih ringan?`

Action:

- Continue
- Reduce target
- Change cue
- Pause habit

Recovery screen tidak boleh:

- menampilkan rasa bersalah,
- memaksa pengguna menjelaskan alasan,
- menghapus historical data,
- menggunakan warning agresif.

## 16.13 Pause Semantics

Pause memiliki:

- start datetime
- optional end datetime

Selama pause:

- habit tidak menghasilkan planned instance,
- tidak dihitung missed,
- tidak mengurangi completion rate,
- tidak memutus continuity berdasarkan obligation,
- historical completion tetap tersedia.

Setelah resume, scheduling kembali berlaku mulai dari resume date.

Design system menetapkan bahwa pause bukan failure. fileciteturn5file7L931-L937

## 16.14 Skip Semantics

Skip hanya berlaku untuk planned instance.

Alasan opsional:

- Sick
- Travel
- Rest
- Schedule changed
- Other

Skip tidak memberi completion credit.

Skip juga tidak diperlakukan sebagai failure moral.

## 16.15 Progress UI

Progress screen harus dapat memperlihatkan:

```text
This Week
18 / 21

Completion
86%

Repetitions
42

Current Streak
7 days

Longest Streak
21 days

Recoveries
4
```

Streak boleh dipromosikan secara visual, tetapi tidak boleh menghilangkan metric lain.

## 16.16 Calendar Semantics

Calendar harus dapat membedakan:

- Completed
- Partial
- Skipped
- No plan
- Missed
- Paused

Semua state harus dapat dipahami tanpa warna saja.

Design system menetapkan bahwa no-plan harus berbeda dari missed. fileciteturn5file3L440-L470

## 16.17 Weekly Review Metrics

Weekly review minimal menampilkan:

- planned
- completed
- completion rate
- most consistent habit
- hardest habit
- mood summary
- sleep summary
- journal count
- recovery count

Weekly review harus menghubungkan:

`data -> meaning -> adjustment`

Design system mendefinisikan weekly review sebagai jembatan dari data ke meaning dan menyediakan tindakan `Keep`, `Change schedule`, dan `Reduce target`. fileciteturn5file3L370-L410

## 16.18 Acceptance Criteria

### AC-16-01
Given a daily habit with five consecutive completions, current streak equals five.

### AC-16-02
Given a daily habit with a missed planned day, current streak resets but longest streak remains unchanged.

### AC-16-03
Given a Tuesday that is not part of a Monday-Wednesday-Friday schedule, Tuesday is `No plan`.

### AC-16-04
Given a weekly habit with target three and two completions this week, UI displays `2 / 3 this week`.

### AC-16-05
A weekly habit does not calculate a daily streak.

### AC-16-06
Pause period does not create missed instances.

### AC-16-07
Skip does not increase completion count.

### AC-16-08
Completion after an interruption increases recovery count.

### AC-16-09
Historical repetitions remain unchanged after a broken streak.

### AC-16-10
All calendar states remain distinguishable without relying on color alone.

---

# 17. Journal

## 17.1 Purpose

Journal merupakan ruang refleksi personal yang mendukung dua kebutuhan:

1. low-friction capture
2. deeper reflection

Design system menetapkan bahwa body harus menjadi fokus utama, title dan mood bersifat optional, dan journaling harus meminimalkan distraction. fileciteturn4file1L324-L388

## 17.2 Journal Modes

Sistem mendukung:

- Free Journal
- Guided Journal

Free Journal adalah default untuk pengguna yang ingin langsung menulis.

Guided Journal membantu pengguna yang membutuhkan struktur.

## 17.3 Free Journal

Free Journal tidak boleh memaksa:

- prompt
- mood
- title
- tags
- word count
- score

Struktur:

```text
Date

Title optional

Mood optional

Body

Tags optional
```

Design system secara eksplisit menetapkan bahwa free journal harus benar-benar bebas. fileciteturn1file4L787-L812

## 17.4 Journal Entry Fields

Minimum field:

- id
- createdAt
- updatedAt
- date
- type
- body

Optional:

- title
- mood
- energy
- tags

## 17.5 Journal Type

Supported types:

- free
- guided

Guided entry menyimpan metadata prompt flow agar entry dapat ditampilkan kembali sebagai hasil refleksi terstruktur.

## 17.6 Journal Editor

Editor hierarchy:

1. Date
2. Save status
3. Title
4. Body
5. Mood
6. Tags

Body harus memperoleh visual area terbesar.

Toolbar harus minimal.

## 17.7 Autosave

Autosave wajib.

State:

```text
Draft
Saving
Saved locally
Save failed
```

Karena sistem local-only, tidak ada:

```text
Syncing
Synced
Sync failed
```

Save status harus terlihat tanpa mengambil perhatian berlebihan.

Design system menempatkan autosave sebagai elemen trust. fileciteturn4file1L348-L360

## 17.8 Draft Recovery

Jika aplikasi ditutup ketika editor memiliki perubahan:

1. draft lokal dipertahankan,
2. pada pembukaan ulang editor menawarkan draft terakhir,
3. user dapat continue,
4. user dapat discard.

Sistem tidak boleh kehilangan draft karena lifecycle aplikasi.

## 17.9 Journal Date

Tanggal entry dapat dipilih.

Default adalah tanggal saat entry dibuat.

Tanggal tidak boleh otomatis berubah hanya karena user membuka entry pada hari berikutnya.

## 17.10 Editing

User dapat:

- membuka entry,
- mengubah title,
- mengubah body,
- mengubah mood,
- mengubah tags,
- menyimpan perubahan,
- menghapus entry.

`updatedAt` diperbarui setiap perubahan yang berhasil disimpan.

## 17.11 Delete

Delete harus meminta konfirmasi karena journal merupakan data personal.

Konfirmasi harus menjelaskan bahwa entry akan dihapus dari perangkat.

Tidak boleh menggunakan bahasa menakutkan yang berlebihan.

## 17.12 Search

Search minimal mendukung pencarian pada:

- title
- body
- tags

Search bersifat local.

Tidak membutuhkan internet.

## 17.13 Filter

Filter minimal:

- All
- Free
- Guided
- Mood
- Date range
- Tag

## 17.14 Guided Journal

Guided Journal menggunakan progressive prompting.

Contoh sequence:

```text
Apa yang paling menonjol hari ini?
```

kemudian:

```text
Apa yang kamu rasakan?
```

kemudian:

```text
Apa yang ingin kamu bawa ke besok?
```

Tidak boleh menampilkan terlalu banyak prompt sekaligus. fileciteturn5file5L816-L845

## 17.15 Guided Journal Categories

Supported categories:

- Daily reflection
- Gratitude
- Problem solving
- Planning
- Emotion
- Wins
- Learning
- Relationships

Kategori bersifat navigational dan tidak menentukan kondisi psikologis user. fileciteturn5file5L816-L845

## 17.16 Prompt Rules

Prompt harus:

- specific
- optional
- non-judgmental
- open enough
- tidak memaksakan positivity

Contoh valid:

`Apa yang paling kamu ingat dari hari ini?`

Contoh tidak valid:

`Kenapa hari ini luar biasa?`

Design system menetapkan aturan tersebut. fileciteturn5file5L849-L885

## 17.17 Reflection Capture Model

Journal dapat mendukung tiga mode konseptual:

```text
Capture
Understand
Adjust
```

Capture:
`Apa yang terjadi?`

Understand:
`Apa yang kamu rasakan?`
`Apa yang memengaruhinya?`

Adjust:
`Apa yang ingin kamu lakukan berikutnya?`

fileciteturn5file0L10-L35

## 17.18 Mood Association

Mood pada journal adalah optional metadata.

Journal tanpa mood tetap valid.

Mood tidak boleh memblokir save.

## 17.19 Tags

Tags bersifat optional.

User dapat:

- memilih existing tag,
- membuat tag baru,
- menghapus tag sebelum save.

Tags harus disimpan sebagai data terstruktur dan bukan hanya teks presentasi.

## 17.20 Journal Detail

Journal Detail menampilkan:

```text
Date
Title
Body
Mood
Tags
Updated time
```

Untuk guided entry, prompt yang relevan dapat ditampilkan sebagai metadata sekunder.

## 17.21 Privacy

Journal harus diperlakukan sebagai private-by-default.

Sistem tidak mengirim isi journal keluar dari perangkat dalam core architecture.

Tidak ada analytics yang mengirim body journal ke service eksternal.

## 17.22 Export

Export journal harus tersedia sebagai bagian dari general data export.

Format export ditentukan pada section backup dan data contract.

## 17.23 Acceptance Criteria

### AC-17-01
User can create an empty-title journal with body only.

### AC-17-02
User can save journal without selecting mood.

### AC-17-03
Journal body is the primary visual editing area.

### AC-17-04
Draft survives app restart.

### AC-17-05
Saved journal is stored locally and remains available without internet.

### AC-17-06
User can search local journal entries by title, body, or tag.

### AC-17-07
Guided Journal presents prompts sequentially.

### AC-17-08
User can skip optional prompts.

### AC-17-09
Deleting a journal removes it from local journal queries after successful deletion.

### AC-17-10
No journal content is sent to any remote service by core functionality.

---

# 18. Guided Journal

## 18.1 Purpose

Guided Journal merupakan mode journaling terstruktur untuk membantu pengguna melakukan reflection ketika tidak tahu harus mulai dari mana.

Guided Journal bukan assessment psikologis.

Guided Journal bukan diagnosis.

Guided Journal bukan terapi.

## 18.2 User Flow

```text
Open Guided Journal
        ↓
Choose prompt set
        ↓
Prompt 1
        ↓
Write
        ↓
Next
        ↓
Prompt 2
        ↓
Write
        ↓
Next
        ↓
Prompt 3
        ↓
Review
        ↓
Save
```

## 18.3 Prompt Set Definition

Setiap prompt set memiliki:

- id
- title
- category
- ordered prompts
- optional description

Prompt harus dapat disimpan secara statis di aplikasi sehingga tidak membutuhkan network.

## 18.4 Prompt Count

Default guided session menggunakan jumlah prompt yang kecil.

Jangan menampilkan sepuluh atau lebih pertanyaan sekaligus.

## 18.5 Navigation

User dapat:

- Next
- Back
- Skip
- Exit

Exit dengan unsaved text harus memicu draft preservation.

## 18.6 Save Behavior

Setiap guided session menghasilkan satu Journal Entry.

Prompt response disimpan bersama struktur entry sehingga dapat direproduksi saat detail dibuka.

## 18.7 Prompt Types

Supported:

- open text
- optional mood
- optional action selection
- optional single-choice reflection

Core version tidak membutuhkan form yang rumit.

## 18.8 Recovery Prompt Set

Guided Journal dapat memiliki prompt khusus recovery:

```text
Apa yang membuat rutinitas ini terhenti?
```

```text
Apa versi yang lebih ringan untuk sekarang?
```

```text
Apa yang ingin kamu coba berikutnya?
```

Prompt tidak boleh menyalahkan.

## 18.9 Habit Reflection Prompt Set

Prompt:

```text
Apa yang membuat habit ini lebih mudah?
```

```text
Apakah cue saat ini masih cocok?
```

```text
Apa versi minimum yang realistis pada hari sibuk?
```

```text
Adakah friction yang bisa kamu kurangi?
```

Prompt library tersebut selaras dengan design system. fileciteturn2file5L1423-L1439

## 18.10 Acceptance Criteria

### AC-18-01
Guided Journal can be started without network.

### AC-18-02
Prompts appear sequentially.

### AC-18-03
Skipping an optional prompt does not prevent completion.

### AC-18-04
Leaving the session preserves unsaved draft content.

### AC-18-05
Completed session creates one local journal entry.

### AC-18-06
Prompt order is stable between creation and detail view.

---

# 19. Mood Tracking

## 19.1 Purpose

Mood tracking digunakan untuk self-report sederhana mengenai keadaan yang dirasakan pengguna pada suatu waktu.

Mood bukan diagnosis.

Mood adalah self-report sesaat dan tidak boleh digunakan untuk memberi label identitas pengguna. fileciteturn4file5L889-L945

## 19.2 Mood Model

Mood record memiliki:

- id
- date
- createdAt
- valence
- optional energy
- optional emotion label
- optional context tags
- optional note

## 19.3 Valence

Minimum scale:

```text
Very Low
Low
Neutral
Good
Very Good
```

UI boleh menggunakan label yang lebih natural selama semantic mapping konsisten.

## 19.4 Energy

Energy optional:

```text
Low
Medium
High
```

Energy tidak sama dengan valence.

User dapat merasa:

- good + low energy
- bad + high energy
- neutral + medium energy

## 19.5 Emotion Labels

Supported emotion labels dapat mencakup:

- Calm
- Happy
- Tired
- Anxious
- Frustrated
- Sad
- Other

Design system memang merekomendasikan emotion labeling daripada hanya menampilkan emoji atau valence saja. fileciteturn5file0L39-L76

## 19.6 Context Tags

Optional tags:

- Work
- Sleep
- Family
- Health
- Social
- Weather
- Exercise

Tags tidak boleh dianggap sebagai penyebab mood.

## 19.7 Mood Check-in Flow

```text
How are you feeling?

Select mood
    ↓
Optional emotion
    ↓
Optional energy
    ↓
Optional context
    ↓
Save
```

Flow harus cepat.

User tidak dipaksa menulis journal ketika hanya ingin melakukan mood check-in.

## 19.8 Mood History

Mood History dapat menampilkan:

- recent entries
- average valence
- valence trend
- emotion distribution
- optional energy trend
- calendar

## 19.9 Mood Calendar

Calendar harus membedakan mood entries berdasarkan semantic state tanpa mengandalkan color-only meaning.

## 19.10 Causal Interpretation

Sistem tidak boleh menghasilkan kalimat seperti:

`Coffee caused your anxiety.`

Sistem dapat menghasilkan:

`On days when you logged afternoon coffee, anxious mood was also recorded more often. This is only a pattern in your self-reported data.`

Design system secara eksplisit melarang causal overclaim. fileciteturn4file5L932-L948

## 19.11 Mood and Journal Relationship

Mood dapat:

- berdiri sendiri,
- terhubung ke journal,
- ditampilkan pada journal detail.

Mood tidak wajib untuk journal.

## 19.12 Mood Edit

User dapat mengubah mood record yang sebelumnya dibuat.

History harus diperbarui setelah perubahan.

## 19.13 Mood Delete

User dapat menghapus mood record.

Penghapusan tidak menghapus journal yang terkait kecuali user memang menghapus journal tersebut secara terpisah.

## 19.14 Acceptance Criteria

### AC-19-01
User can save mood without writing a journal.

### AC-19-02
Mood can be recorded without internet.

### AC-19-03
Valence and energy are stored independently.

### AC-19-04
Mood cannot be represented only by color.

### AC-19-05
User can edit and delete mood history.

### AC-19-06
Insights do not claim causation from simple mood correlations.

---

# 20. Sleep Tracking

## 20.1 Purpose

Sleep Tracking digunakan untuk mencatat pola tidur pengguna secara manual dan membantu melihat pola historical sleep.

Sleep Tracking bukan perangkat medis dan bukan diagnosis.

## 20.2 Sleep Record

Field minimum:

- id
- date
- bedtime
- wakeTime
- duration
- quality
- createdAt
- updatedAt

Optional:

- note
- sleep interruptions
- subjective energy after waking

## 20.3 Date Semantics

`date` merepresentasikan tanggal wake-up atau tanggal sleep record yang dipilih user.

Definisi ini harus konsisten di seluruh application layer.

Default UI harus menjelaskan tanggal dengan jelas.

## 20.4 Time Input

User memasukkan:

- bedtime
- wake time

System menghitung duration.

Duration tidak boleh diinput bebas jika bedtime dan wake time sudah tersedia.

## 20.5 Cross-Midnight Sleep

Contoh:

```text
Bedtime: 23:00
Wake time: 06:30
```

Duration:

`7h 30m`

System harus mendukung sleep interval yang melewati midnight.

## 20.6 Invalid Duration

Input harus ditolak jika:

- wake time sama dengan bedtime tanpa konfigurasi durasi overnight,
- durasi nol,
- durasi negatif,
- duration melebihi batas maksimum yang ditetapkan domain.

Validation tidak boleh membuat user terjebak dalam form.

## 20.7 Sleep Quality

Minimum:

```text
Poor
Fair
Good
Excellent
```

Quality merupakan subjective self-report.

## 20.8 Sleep Entry Flow

```text
Sleep

Last night
or selected date

Bedtime
Wake time

Duration calculated automatically

Sleep quality

Optional note

Save
```

## 20.9 Edit Sleep

User dapat membuka historical sleep record dan mengubah:

- bedtime
- wake time
- quality
- note

Duration dihitung ulang.

## 20.10 Delete Sleep

User dapat menghapus sleep record tertentu.

Deletion membutuhkan konfirmasi.

## 20.11 Sleep History

History menyediakan:

- day
- week
- month

Minimum metrics:

- average duration
- average quality
- bedtime trend
- wake-time trend
- consistency
- longest available period

## 20.12 Sleep Consistency

Consistency harus dihitung berdasarkan unique planned/recorded sleep dates sesuai definisi metric.

Duplicate records pada tanggal yang sama tidak boleh secara otomatis dihitung sebagai dua sleep days.

## 20.13 Sleep Insights

Insight lokal dapat menampilkan:

`Your average sleep this week is 7h 32m.`

atau:

`You recorded longer sleep on 4 of the last 7 days.`

Sistem tidak boleh menyatakan:

`This proves better sleep caused better productivity.`

## 20.14 Sleep and Habit Correlation

Jika sistem membandingkan sleep dengan habit completion, output harus menggunakan bahasa observasional.

Valid:

`Habit completion was higher on days with at least 7 hours of logged sleep.`

Tidak valid:

`Sleeping 7 hours makes you complete more habits.`

## 20.15 Sleep Calendar

Calendar dapat menggunakan state:

- recorded
- no record

Bukan:

- good
- bad

kecuali user membuka detail metric yang dijelaskan.

## 20.16 Sleep Reminder

Sleep reminder merupakan local notification.

Reminder tidak boleh mengirim detail sensitif pada lock screen secara default.

Copy:

`Waktunya check-in.`

bukan isi data pribadi.

Design system menekankan notification privacy. fileciteturn5file8L1125-L1159

## 20.17 Sleep Goal

Sleep goal bersifat optional.

Default application tidak boleh menganggap semua user harus mencapai angka tertentu.

Jika user menetapkan target:

```text
Target: 7h 30m
```

progress dibandingkan terhadap target personal tersebut.

Target tidak dipakai untuk diagnosis.

## 20.18 Sleep Detail

```text
Sleep

7h 45m

Bedtime
11:00 PM

Wake
6:45 AM

Quality
Good

Recent pattern
```

Detail harus cepat dipahami.

## 20.19 Acceptance Criteria

### AC-20-01
User can create a sleep record without internet.

### AC-20-02
Duration is calculated consistently from bedtime and wake time.

### AC-20-03
Cross-midnight sleep is supported.

### AC-20-04
Editing bedtime or wake time recalculates duration.

### AC-20-05
Duplicate records for the same logical sleep date are prevented or explicitly reconciled.

### AC-20-06
Deleting a sleep record removes it from sleep history and derived local metrics.

### AC-20-07
Sleep insights use observational language and do not claim causality.

### AC-20-08
Lock-screen notification does not reveal sensitive journal or mood content by default.

---

# 20.20 Cross-Feature Data Relationship

Core personal tracking data memiliki hubungan:

```text
Habit
  |
  +-- Habit Log
  |
  +-- Progress
  |
  +-- Weekly Review
  |
  +-- Insights

Journal
  |
  +-- Mood
  |
  +-- Reflection
  |
  +-- Weekly Review
  |
  +-- Insights

Sleep
  |
  +-- Sleep History
  |
  +-- Weekly Review
  |
  +-- Insights
```

Sistem boleh melakukan correlation analysis lokal apabila data cukup.

Sistem tidak boleh menganggap correlation sebagai causation.

## 20.21 Cross-Feature Privacy Boundary

Core data tetap berada pada local storage.

Tidak ada requirement core untuk:

- upload journal,
- upload mood,
- upload sleep,
- remote analytics,
- remote personalization.

## 20.22 Cross-Feature Performance

Local calculations harus tetap ringan.

History query harus menggunakan query database yang terfilter berdasarkan periode bila memungkinkan.

Jangan memuat seluruh historical journal atau habit log ke memory untuk menghitung satu metric jika query agregasi database dapat digunakan.

## 20.23 Cross-Feature Empty States

Empty states harus memberi satu next action.

Journal kosong:

`Belum ada entry.`

`Mulai dengan apa pun yang sedang ada di pikiranmu.`

Habits kosong:

`Belum ada habit aktif.`

`Mulai dengan satu hal kecil.`

Pesan empty state harus singkat dan non-judgmental. fileciteturn2file0L78-L112

## 20.24 Cross-Feature Save Guarantees

Semua core creation/edit operation harus:

1. validasi input,
2. simpan ke local database,
3. memperbarui derived state,
4. memberikan feedback,
5. tetap tersedia setelah app restart.

## 20.25 Cross-Feature No-Internet Requirement

Mematikan Wi-Fi dan mobile data tidak boleh mencegah:

- membuat habit,
- menyelesaikan habit,
- menulis journal,
- menyimpan mood,
- menyimpan sleep,
- membuka history,
- melihat progress,
- membuka insights yang berbasis data lokal,
- membuka achievements,
- mengubah settings,
- melakukan export,
- melakukan import.

Internet tidak merupakan dependency untuk core functionality.

## 20.26 Cross-Feature Data Consistency

Mutation harus atomic pada level operasi domain bila satu action memengaruhi lebih dari satu tabel.

Contoh completion:

```text
User completes habit
        ↓
Create/update habit log
        ↓
Update derived progress
        ↓
Evaluate achievements
```

Jika operasi gagal, aplikasi tidak boleh menampilkan success state yang tidak didukung oleh persistent data.

## 20.27 Cross-Feature Requirement Rule

Setiap feature requirement berikutnya harus memiliki:

- purpose
- scope
- data inputs
- data outputs
- user interaction
- state behavior
- validation
- edge cases
- privacy implications
- performance implications
- acceptance criteria

Feature tidak dianggap terdefinisi hanya karena memiliki screen.

## 20.28 Engineering Constraint

Implementasi tidak boleh menambahkan remote dependency hanya untuk memenuhi kebutuhan UI yang sebenarnya dapat dihitung dari local database.




# 21. Weekly Review

## 21.1 Purpose

Weekly Review mengubah data tracking menjadi pemahaman dan keputusan sederhana untuk minggu berikutnya.

Weekly Review bukan halaman laporan formal.

Tujuannya adalah:

`Data -> Meaning -> Adjustment`

Design system menetapkan weekly review sebagai jembatan dari data menuju meaning dan menyediakan tindakan seperti `Keep`, `Change schedule`, dan `Reduce target`. fileciteturn5file3L370-L410

## 21.2 Availability

Weekly Review tersedia ketika periode minggu memiliki data yang cukup untuk ditampilkan.

Minggu tanpa data harus tetap memiliki empty state yang jelas.

## 21.3 Period Definition

Default review period:

`Monday 00:00 -> Sunday 23:59`

Locale week-start dapat dikonfigurasi pada future release apabila diperlukan.

Semua tanggal dan metric dalam review harus menggunakan satu definisi periode yang konsisten.

## 21.4 Review Summary

Minimum summary:

- planned habit instances
- completed instances
- completion rate
- repetition count
- current active habits
- paused habits
- recovery count
- journal entries
- mood summary
- sleep summary

## 21.5 Habit Performance

Untuk setiap active habit yang memiliki planned instance pada minggu tersebut, tampilkan:

- habit name
- completion count
- target
- completion rate
- current streak jika relevan
- weekly status

Example:

```text
Morning Walk
5 / 5 completed
100%

Read 5 pages
3 / 5 completed
60%
```

## 21.6 Weekly Ranking

Sistem boleh menampilkan:

- most consistent habit
- habit needing adjustment

Ranking tidak boleh dibuat sebagai leaderboard antar pengguna.

Ranking hanya berada dalam konteks data milik user sendiri.

## 21.7 Mood Summary

Mood summary dapat menampilkan:

- average valence
- dominant emotion label
- optional energy summary
- number of check-ins

Contoh:

```text
Mood
Mostly calm
4 check-ins
```

Output tidak boleh memberi diagnosis.

## 21.8 Sleep Summary

Sleep summary dapat menampilkan:

- average duration
- average quality
- days recorded
- target comparison jika user menetapkan sleep goal

## 21.9 Journal Summary

Minimum:

`Journal entries: 4`

Optional:

- most used tags
- journal type distribution
- reflection categories

Body journal tidak perlu ditampilkan langsung dalam summary kecuali user membuka entry.

## 21.10 Recovery Summary

Recovery summary dapat menampilkan:

`Returned after a break: 2 times`

Metric digunakan untuk memperkuat resilience dan bukan untuk menghakimi.

## 21.11 Reflection Questions

Weekly Review menyediakan pertanyaan pendek.

Minimum prompt set:

`Apa yang membuat minggu ini lebih mudah?`

`Apa yang terasa paling sulit?`

`Apa yang ingin kamu pertahankan?`

`Apa yang ingin kamu ubah minggu depan?`

Prompt bersifat optional dan non-judgmental. Design system menekankan reflection yang mengarah ke adjustment. fileciteturn4file0L86-L126

## 21.12 Adjustment Actions

Untuk habit yang perlu disesuaikan, user dapat memilih:

- Keep
- Change schedule
- Reduce target
- Change cue
- Pause

Action harus mengarah langsung ke screen atau sheet yang relevan.

## 21.13 Keep Action

`Keep` menyimpan keputusan review tanpa mengubah konfigurasi habit.

## 21.14 Change Schedule

Action membuka editor schedule.

Perubahan berlaku mulai dari tanggal yang ditentukan user.

Historical completion tidak boleh berubah.

## 21.15 Reduce Target

Action membuka target editor.

Perubahan target berlaku ke period berikutnya kecuali user secara eksplisit memilih effective date lain.

Historical statistics tidak direcalculate menggunakan target baru.

## 21.16 Change Cue

Action membuka cue editor.

Historical data tidak berubah.

## 21.17 Pause

Action membuka pause flow.

Pause mengikuti semantics pada Section 16.

## 21.18 Review Persistence

Weekly Review dapat menyimpan:

- review period
- reflection answers
- selected adjustments
- createdAt
- updatedAt

Review yang telah disimpan dapat dibuka kembali.

## 21.19 Duplicate Review

Satu user local tidak boleh menghasilkan duplicate review untuk periode yang sama.

Jika review sudah ada, user membuka review existing.

## 21.20 Review Editing

User dapat mengubah reflection dan adjustment decision.

Historical snapshots yang bergantung pada live database harus jelas dibedakan dari saved reflection text.

## 21.21 Local-only

Weekly Review tidak membutuhkan internet.

Seluruh calculation dilakukan dari local data.

## 21.22 Empty State

Jika belum ada data:

```text
Belum cukup data untuk review minggu ini.

Mulai dari satu habit, lalu lihat apa yang berubah.
```

## 21.23 Performance

Weekly Review harus menghindari loading seluruh historical database ke memory.

Query harus dibatasi pada period yang diperlukan.

Derived metrics yang sederhana harus dapat dihitung secara efisien dari database.

## 21.24 Acceptance Criteria

### AC-21-01
Weekly Review uses one consistent week boundary.

### AC-21-02
Review includes habit, mood, sleep, journal, and recovery summaries when data exists.

### AC-21-03
User can save an optional weekly reflection.

### AC-21-04
User can select an adjustment action.

### AC-21-05
Adjustment opens the corresponding configuration workflow.

### AC-21-06
A second review for the same period is not created.

### AC-21-07
Historical completion data remains unchanged after adjustment.

### AC-21-08
Weekly Review works without internet.

---

# 22. Monthly Review

## 22.1 Purpose

Monthly Review memberikan pandangan makro terhadap pola dan perubahan user.

Monthly Review bukan score moral.

Design system menyarankan monthly review menampilkan repetitions, consistency trend, active habits, paused habits, mood pattern, journal frequency, dan meaningful highlights. fileciteturn5file3L414-L436

## 22.2 Period Definition

Default:

First day of month 00:00
through
Last day of month 23:59

## 22.3 Summary Metrics

Minimum:

- completed habit instances
- completion rate
- repetitions
- active habits
- paused habits
- average mood
- journal entry count
- sleep average duration
- recovery count

## 22.4 Trend

Monthly Review dapat membandingkan:

- current month vs previous month
- first half vs second half
- current completion vs historical average

Comparison harus menunjukkan data, bukan judgment.

## 22.5 Highlights

Highlight dapat berupa:

`Most repeated habit`

`Most consistent habit`

`Habit with highest improvement`

`Most common journal tag`

`Longest current rhythm`

## 22.6 Meaningful Change

System dapat menampilkan perubahan seperti:

`Reading increased from 6 to 11 repetitions compared with last month.`

Tidak boleh mengklaim penyebab perubahan tanpa evidence.

## 22.7 Reflection

Prompt:

`Apa yang berubah bulan ini?`

`Apa yang ingin kamu bawa ke bulan berikutnya?`

`Apa yang ingin kamu sederhanakan?`

## 22.8 Monthly Adjustment

User dapat:

- keep habit
- change schedule
- reduce target
- change cue
- pause
- archive

## 22.9 No Moral Score

Sistem tidak boleh menggunakan:

`Score: 63/100`

sebagai penilaian kualitas diri.

Design system secara eksplisit memperingatkan agar monthly review tidak dijadikan rapor moral. fileciteturn5file3L428-L436

## 22.10 Acceptance Criteria

### AC-22-01
Monthly Review uses exact calendar-month boundaries.

### AC-22-02
Metrics exclude data outside the selected month except where comparison requires a previous period.

### AC-22-03
No moral score is presented as the user's quality or worth.

### AC-22-04
Comparison statements are descriptive and data-based.

### AC-22-05
User can save a monthly reflection locally.

---

# 23. Calendar and Heatmap

## 23.1 Purpose

Calendar dan Heatmap digunakan untuk melihat rhythm, frequency, dan pattern dalam bentuk temporal.

## 23.2 Calendar Modes

System mendukung:

- habit-specific calendar
- combined activity calendar
- monthly calendar

## 23.3 Habit Calendar

Habit calendar memperlihatkan status berdasarkan planned instance.

Possible states:

- Completed
- Partial
- Skipped
- Missed
- No Plan
- Paused

## 23.4 No-Plan

No-plan berarti tidak ada obligation pada tanggal tersebut.

No-plan tidak masuk denominator completion rate.

No-plan tidak dianggap missed.

Design system menegaskan bahwa no-plan harus berbeda dari missed. fileciteturn5file3L440-L468

## 23.5 Missed

Missed berarti ada planned instance tetapi user tidak menyelesaikannya dan tidak memilih skip.

Missed harus divisualisasikan secara netral.

## 23.6 Skipped

Skipped berarti user secara eksplisit melewati planned instance.

Skipped tidak menjadi completion.

Skipped juga tidak menggunakan error styling.

## 23.7 Paused

Paused berarti habit sedang tidak aktif berdasarkan pause interval.

Paused date tidak menghasilkan planned instance.

## 23.8 Partial

Partial hanya berlaku jika habit mendukung progress bertingkat atau minimum version.

Contoh:

```text
Target: 30 min
Minimum: 5 min

Completed target: Full
Minimum version: Partial
Not done: Missed
```

Jika suatu habit hanya mendukung binary completion, state partial tidak boleh dipalsukan.

## 23.9 Heatmap Intensity

Heatmap boleh menggunakan intensity untuk menunjukkan quantity atau completion density.

Intensity tidak boleh menyiratkan moral success.

## 23.10 Color Independence

Calendar state tidak boleh dipahami hanya melalui warna.

Setiap state harus memiliki kombinasi setidaknya dua of:

- label
- shape
- iconography
- pattern
- position

Accessibility requirement mengikuti design system. fileciteturn2file0L176-L209

## 23.11 Monthly Navigation

User dapat:

- previous month
- next month
- current month

Next month tidak boleh menunjukkan future completion sebagai actual data.

## 23.12 Date Selection

Selecting a date dapat membuka:

- habit summary
- journal entry
- mood record
- sleep record
- activity summary

## 23.13 Combined Calendar

Combined calendar dapat menunjukkan jumlah aktivitas hari tersebut tanpa mencampurkan semantics antar-domain.

Contoh:

```text
3 habits completed
1 journal
1 sleep record
1 mood check-in
```

## 23.14 Habit Calendar Interaction

Tap date:

`Open day detail`

Long press tidak wajib.

Interaction tidak boleh bergantung pada gesture yang sulit ditemukan.

## 23.15 Heatmap Period

Default heatmap:

`last 12 weeks`

Future release dapat menyediakan 6 months atau 12 months.

## 23.16 Performance

Heatmap tidak boleh membuat satu query besar yang memuat seluruh database apabila hanya membutuhkan agregasi periode.

## 23.17 Acceptance Criteria

### AC-23-01
No-plan dates are not represented as missed.

### AC-23-02
Skipped and missed dates remain distinguishable.

### AC-23-03
Paused dates do not generate planned obligations.

### AC-23-04
Future dates do not contain fabricated completion data.

### AC-23-05
Calendar meaning remains understandable without color alone.

### AC-23-06
Selecting a date can expose available local records for that date.

---

# 24. Insights and Pattern Recognition

## 24.1 Purpose

Insights membantu user memahami pola dari data personal yang sudah tercatat.

Insights bukan diagnosis.

Insights bukan prediction of identity.

Insights bukan replacement for professional advice.

Design system menetapkan empat requirement utama:

1. dapat dijelaskan,
2. berdasarkan data yang cukup,
3. tidak overclaim,
4. actionable. fileciteturn5file3L472-L495

## 24.2 Local Insight Engine

Insight engine harus berjalan secara lokal.

Tidak ada kebutuhan remote AI untuk core insights.

Tidak ada journal body upload ke service eksternal.

## 24.3 Insight Sources

Insight dapat menggunakan:

- habit logs
- habit schedule
- journal metadata
- mood records
- sleep records
- review decisions

## 24.4 Minimum Data Threshold

Setiap insight harus memiliki minimum data threshold.

System tidak boleh menghasilkan insight meaningful dari sample terlalu kecil.

Default minimum threshold harus didefinisikan per insight type.

Contoh:

- habit schedule pattern: minimum multiple planned occurrences
- mood pattern: minimum multiple check-ins
- sleep pattern: minimum multiple recorded days

Threshold adalah domain rule dan harus diuji.

## 24.5 Insight Confidence

Internal model dapat menggunakan confidence level:

- low
- medium
- high

Confidence tidak harus selalu ditampilkan kepada user, tetapi harus tersedia agar renderer tidak menampilkan weak insight sebagai strong conclusion.

## 24.6 Descriptive Insight

Contoh:

`You completed 12 reading sessions this month.`

Ini hanya descriptive.

## 24.7 Comparative Insight

Contoh:

`You completed reading more often this month than last month.`

Perbandingan harus memiliki period yang eksplisit.

## 24.8 Context Insight

Contoh:

`Your reading habit was completed more often after dinner during the last four weeks.`

Insight harus menyebut:

- observed window
- relevant context
- number of observations jika perlu

## 24.9 Correlation Insight

Correlation boleh ditampilkan apabila sample memenuhi threshold dan wording tetap observational.

Contoh:

`On days with 7+ hours of recorded sleep, habit completion was higher in your recent data.`

Bukan:

`7 hours of sleep causes better habit consistency.`

Design system melarang causal overclaim. fileciteturn4file5L932-L948

## 24.10 Actionability

Setiap insight yang ditampilkan sebagai recommendation harus memiliki action yang jelas.

Contoh:

`Reading appears easier after dinner.`

Actions:

- Keep cue
- Move schedule
- Open habit

## 24.11 Insight Dismissal

User dapat dismiss insight.

Dismissed insight tidak langsung muncul lagi pada sesi yang sama.

## 24.12 Insight Detail

User dapat membuka:

- insight statement
- data window
- supporting metrics
- explanation
- optional action

## 24.13 Explainability

Detail dapat menunjukkan:

```text
Based on
Last 4 weeks
11 planned sessions
9 completed

Observed pattern
8 of 9 completions occurred after 19:00
```

## 24.14 No Identity Labels

System tidak boleh menghasilkan:

`You are a night person.`

Karena itu menyimpulkan identitas dari data sederhana.

Design system memberikan contoh ini sebagai weak insight. fileciteturn5file3L481-L495

## 24.15 No Diagnosis

Tidak boleh menghasilkan:

- burnout diagnosis
- anxiety diagnosis
- depression diagnosis
- ADHD claim
- personality diagnosis
- medical diagnosis

## 24.16 No Therapy Claims

Tidak boleh mengatakan:

`This journal exercise will cure your anxiety.`

Journaling diposisikan sebagai reflection tool, bukan automatic therapy. fileciteturn5file0L10-L35

## 24.17 No Surprise Exposure

Insight tidak boleh menampilkan private journal text pada dashboard overview.

Journal excerpts hanya ditampilkan bila user membuka feature yang secara eksplisit meminta content reflection.

## 24.18 Insight Categories

Minimum categories:

- Habit
- Consistency
- Recovery
- Mood
- Sleep
- Journaling
- Cross-domain patterns

## 24.19 Habit Insight Examples

Valid:

`You completed Morning Walk 5 of 6 planned times this week.`

`Your reading completion was higher on days scheduled before 21:00.`

## 24.20 Recovery Insight Examples

Valid:

`You returned to your reading habit twice after a break this month.`

Tujuan insight adalah menyoroti resilience tanpa glorifikasi streak.

## 24.21 Mood Insight Examples

Valid:

`Calm was your most frequently logged emotion this month.`

Tidak valid:

`You are emotionally stable.`

## 24.22 Sleep Insight Examples

Valid:

`Average logged sleep increased by 34 minutes compared with last month.`

Tidak valid:

`Your better sleep fixed your productivity.`

## 24.23 Journal Insight Examples

Valid:

`Reflection entries increased from 2 to 5 this month.`

Tidak valid:

`Your writing proves you are becoming happier.`

## 24.24 Cross-Domain Insight

Cross-domain insight requires:

- enough observations,
- explicit period,
- explicit variables,
- observational wording.

Example:

`During the last four weeks, your habit completion was higher on days when your logged sleep was at least 7 hours.`

## 24.25 Staleness

Insight harus dianggap stale ketika underlying data berubah secara material.

Local insight engine harus recompute atau invalidate cached insights setelah relevant mutation.

## 24.26 Cache

Insight caching diperbolehkan untuk performance.

Cache invalidation harus terjadi setelah changes to:

- habit logs
- schedules
- mood records
- sleep records
- journal metadata
- review decisions

## 24.27 AI

AI-generated insight bukan bagian dari core release.

Jika future release menambahkan on-device AI, harus memiliki explicit opt-in, local processing guarantee, and explainability requirements.

Cloud AI tidak menjadi dependency.

## 24.28 Acceptance Criteria

### AC-24-01
All core insights are generated from local data.

### AC-24-02
Each insight type has a minimum data threshold.

### AC-24-03
Insights expose or can expose the data window supporting the statement.

### AC-24-04
Insights do not claim causation from simple correlations.

### AC-24-05
Insights do not diagnose mental or physical conditions.

### AC-24-06
Insights do not assign personality or identity labels from simple behavioral data.

### AC-24-07
Actionable insights provide a relevant next action.

### AC-24-08
Insight cache invalidates when source data changes.

### AC-24-09
Weak or insufficient data does not produce a confident-looking insight.

### AC-24-10
No cloud AI is required for core insight functionality.

---

# 25. Gamification and Achievements

## 25.1 Purpose

Gamification digunakan sebagai reinforcement ringan.

Tujuan bukan meningkatkan time-in-app.

Tujuan adalah membantu pengguna melihat progress dan mastery.

Design system menyarankan acknowledgement, mastery, progress, dan reflection sebagai fokus reward, bukan pressure. fileciteturn5file7L941-L974

## 25.2 Gamification Principles

Gamification harus:

- optional secara experience
- non-punitive
- tidak menghalangi core feature
- tidak menggunakan artificial urgency
- tidak menggunakan shame
- tidak mewajibkan social comparison
- tidak mengubah habit menjadi kompetisi

## 25.3 Achievement Model

Achievement terdiri dari:

- id
- title
- description
- category
- requirement
- reward
- icon asset reference
- unlock state
- unlockedAt

No emoji-based icon is allowed.

## 25.4 Achievement Categories

Minimum:

- Habit
- Consistency
- Journaling
- Sleep
- Reflection
- Recovery
- Milestone

## 25.5 Unlock Evaluation

Achievement evaluator harus menggunakan domain events atau derived metrics yang benar.

Tidak boleh membuka achievement hanya karena jumlah record yang kebetulan mencapai angka tanpa memenuhi semantic requirement.

## 25.6 First Habit

Requirement:

`Create the first habit.`

Condition:

`total historical habits created >= 1`

## 25.7 Habit Builder

Requirement:

`Create five different habits.`

Condition:

`five distinct historical habit records`

Archived habits tetap dihitung sebagai historical creations.

Duplicate names tidak dianggap distinct jika user tidak membuat entity habit yang berbeda.

## 25.8 Week Consistency Achievement

Achievement yang mensyaratkan beberapa habit hanya unlock jika semua requirement benar-benar terpenuhi.

Contoh requirement:

`Complete all planned habits for seven consecutive days.`

Evaluator harus memeriksa seluruh relevant habits, bukan hanya longest streak dari satu habit.

## 25.9 Journal Achievement

Achievement:

`Write journal entries on fourteen distinct days.`

Condition:

`>= 14 distinct journal dates`

bukan:

`journal entry count >= 14`

## 25.10 Sleep Tracker Achievement

Requirement:

`Record sleep for seven consecutive days.`

Condition:

Ada sleep record pada tujuh tanggal berturut-turut.

Duplicate record pada tanggal sama tidak menambah consecutive-day count.

## 25.11 Sleep Master

Requirement:

`Record at least the personal sleep target for thirty consecutive days.`

Condition:

Untuk setiap tanggal dalam range:

- valid sleep record exists
- duration meets configured target

Tidak boleh memakai total qualifying records saja.

## 25.12 Mood Explorer

Requirement:

`Log mood on fourteen distinct days.`

Condition:

`>= 14 distinct dates with valid mood record`

Journal count alone tidak dapat membuka achievement ini.

## 25.13 Streak Master

Streak achievement harus menggunakan current or historical streak berdasarkan frequency semantics.

Daily habit menggunakan daily streak.

Weekly habit menggunakan successful weekly periods.

## 25.14 Achievement Reward

Reward dapat berupa:

- XP
- milestone acknowledgment
- cosmetic unlock

Reward tidak boleh memberikan access gate ke core functionality.

## 25.15 XP Model

XP dari user action dan achievement harus memiliki aturan yang jelas.

Jika action XP digunakan, nilai harus diterapkan secara konsisten.

Contoh baseline domain:

```text
Habit completion: 10 XP
Journal entry: 15 XP
Sleep log: 5 XP
```

Angka tersebut adalah product rule dan harus digunakan apabila model action XP diaktifkan.

Achievement XP dapat ditambahkan terpisah.

## 25.16 XP Idempotency

User tidak boleh mendapatkan XP dua kali untuk event yang sama akibat duplicate event processing.

Setiap reward-generating event harus memiliki unique event key atau equivalent idempotency mechanism.

## 25.17 Level

Level harus menggunakan satu formula canonical.

Contoh:

```text
level = floor(totalXp / xpPerLevel) + 1
```

`xpPerLevel` harus menjadi single source of truth.

UI progress tidak boleh menggunakan formula berbeda.

## 25.18 Level Progress

Progress toward next level harus dihitung berdasarkan:

```text
xpWithinCurrentLevel / xpRequiredForNextLevel
```

Contoh jika:

`xpPerLevel = 500`

dan:

`totalXp = 650`

maka:

`Level 2`

`150 / 500 progress`

## 25.19 Achievement Detail

Detail menampilkan:

- title
- requirement
- current progress
- reward
- unlocked state
- unlocked date

## 25.20 Achievement List

Filters:

- All
- Unlocked
- Locked
- Habit
- Journal
- Sleep
- Recovery

## 25.21 Locked Achievement

Locked state harus menunjukkan progress yang membantu user memahami requirement.

Tidak boleh menggunakan fear-based copy.

## 25.22 Achievement Celebration

Celebration hanya untuk milestone meaningful.

Gunakan:

- subtle animation
- state transition
- concise message

Jangan menggunakan full-screen interruption untuk setiap small completion.

Design system secara eksplisit menyarankan celebration hanya untuk milestone besar dan menghindari confetti pada setiap completion. fileciteturn2file3L821-L851

## 25.23 Streak Presentation

Streak dapat ditampilkan sebagai momentum signal.

Copy yang diperbolehkan:

`7 hari konsisten`

`7 days in rhythm`

Hindari:

`Streak akan hilang.`

`Jangan sampai gagal.`

Design system melarang streak hostage dan urgent threat copy. fileciteturn2file3L855-L904

## 25.24 Recovery Reward

Recovery dapat memiliki acknowledgment.

Contoh:

`Kamu kembali setelah jeda.`

Tidak harus memberikan XP tambahan setiap kali jika hal tersebut mendorong unnecessary engagement.

## 25.25 Gamification Settings

User dapat mengatur:

- show achievement feedback
- show XP
- show streak
- show milestone animation

Core habit tracking tetap bekerja ketika gamification display dimatikan.

## 25.26 No Leaderboard

Core product tidak menyediakan leaderboard.

Tidak ada ranking pengguna.

Tidak ada social score.

## 25.27 No Daily Reward Calendar

Product tidak menggunakan reward calendar yang memaksa daily app open.

## 25.28 No Reward For App Opening

Membuka aplikasi bukan event XP.

## 25.29 No Reward For Notification Click

Membuka notification bukan event XP.

## 25.30 Local-only

Achievement evaluation, XP, level, dan unlock state seluruhnya dihitung dan disimpan secara lokal.

## 25.31 Data Integrity

Jika achievement evaluator menemukan condition tidak lagi valid karena data correction, historical unlock harus memiliki policy eksplisit.

Default policy:

`Unlocked achievements remain historical records after valid unlock.`

User data correction tidak boleh menyebabkan UI retroactively claiming a newly unlocked state without an event.

## 25.32 Acceptance Criteria

### AC-25-01
Achievements evaluate semantic requirements rather than raw record counts when consecutive or distinct-day semantics are required.

### AC-25-02
Weekly achievements use weekly semantics where required.

### AC-25-03
Mood Explorer uses distinct mood dates.

### AC-25-04
Sleep Tracker uses consecutive sleep dates.

### AC-25-05
Sleep Master checks consecutive qualifying dates rather than total qualifying records.

### AC-25-06
XP is not awarded twice for the same logical event.

### AC-25-07
Level calculation has one canonical formula.

### AC-25-08
Level progress uses the same canonical XP definition as level calculation.

### AC-25-09
Achievements never gate core application functionality.

### AC-25-10
Gamification can be visually reduced or hidden without disabling core tracking.

### AC-25-11
No leaderboard exists in the core product.

### AC-25-12
No reward is granted merely for opening the application.

### AC-25-13
No achievement or streak copy uses shame, coercion, or artificial urgency.

### AC-25-14
All gamification works without internet.

---

# 25.33 Cross-Section Consistency Rules

The following rules are mandatory across Sections 16–25.

## Rule 1
A metric must have one canonical definition.

## Rule 2
A calendar day with no planned habit is not a missed habit.

## Rule 3
Paused periods do not create missed obligations.

## Rule 4
Skipped is distinct from completed and missed.

## Rule 5
Historical completion remains preserved.

## Rule 6
Weekly habits use weekly semantics where applicable.

## Rule 7
Insights must distinguish observation from causal interpretation.

## Rule 8
Achievement logic must match the textual requirement.

## Rule 9
XP and level calculations must use one source of truth.

## Rule 10
Local data remains the authoritative data source.

## Rule 11
No cloud dependency may be introduced for analytics or gamification.

## Rule 12
Every user-visible status must be understandable without emoji.

## Rule 13
Every primary interaction must have a functional implementation.

## Rule 14
Feature behavior must not depend on network availability.

## Rule 15
No screen may present a metric without defining its denominator, period, and semantics in product logic.

## Rule 16
Any future feature that changes a metric definition must update the relevant acceptance criteria and tests.

## Rule 17
No hidden fallback behavior may silently replace missing data with fabricated data.

## Rule 18
A weak data sample must produce no insight rather than a misleading insight.

## Rule 19
A recommendation must have a clear user action or remain descriptive.

## Rule 20
Analytics must help users understand or adjust, not merely create more metrics.





# 26. Local Notifications

## 26.1 Purpose

Notifications berfungsi sebagai alat bantu mengingat, bukan mekanisme kontrol perilaku.

Design system menempatkan reminder sebagai dukungan terhadap memory dan context. Reminder tidak boleh menjadi mesin engagement, tidak boleh berlebihan, dan tidak boleh membuat pengguna merasa dikendalikan oleh aplikasi. fileciteturn5file7L978-L1031

Karena Prokopa sepenuhnya local-only, seluruh penjadwalan notification harus dapat berjalan tanpa backend dan tanpa koneksi internet.

## 26.2 Product Boundary

Notification dalam scope:

- habit reminder
- routine/context reminder jika didukung OS dan data lokal yang tersedia
- recovery reminder
- optional morning planning reminder
- optional evening reflection reminder

Notification di luar scope core:

- server push notification
- social notification
- community activity notification
- marketing notification
- cloud-generated personalized notification
- remote experimentation yang bergantung pada backend

## 26.3 Notification Principle

Setiap notification harus menjawab satu pertanyaan:

`Informasi apa yang membantu pengguna melakukan atau meninjau sesuatu pada saat yang relevan?`

Jika tidak ada jawaban yang jelas, notification tidak dibuat.

## 26.4 Permission Flow

Permission flow minimum:

`Feature selection -> reminder configuration -> explanation -> OS permission -> scheduled locally`

Sistem tidak boleh langsung meminta permission notification pada first launch tanpa konteks.

User harus mengetahui:

- notification digunakan untuk apa
- kapan notification dapat muncul
- bahwa notification dapat dinonaktifkan
- bahwa reminder bekerja secara lokal

## 26.5 Habit Reminder

Habit reminder harus melekat pada habit tertentu.

Minimum configuration:

- enabled/disabled
- time
- selected days atau schedule reference
- notification title
- notification body

Default copy harus netral dan action-oriented.

Contoh:

```text
Read 5 pages
Scheduled for 20:00
```

Hindari:

```text
You are breaking your streak.
Don't fail today.
You must complete this.
```

Tone notification harus mendukung autonomy, bukan guilt.

## 26.6 Routine-Based Reminder

Routine-based reminder hanya tersedia jika implementasi benar-benar menggunakan konteks lokal yang jelas dan tidak membutuhkan surveillance.

Contoh valid:

```text
After dinner -> remind Read 5 pages
```

Konteks harus berasal dari konfigurasi user, bukan inferred location tracking secara diam-diam.

## 26.7 Recovery Reminder

Recovery reminder digunakan ketika habit memiliki pola lapse yang relevan.

Contoh:

```text
Want to continue your habit today?

Continue / Reduce target / Change cue / Pause
```

Recovery reminder tidak boleh menyatakan bahwa missed day adalah kegagalan moral.

## 26.8 Morning Planning Reminder

Optional.

Tujuan:

- membantu memilih fokus hari ini
- meninjau habit yang relevan
- mengurangi decision overload

Tidak boleh berubah menjadi daily KPI report yang panjang.

Design system menyarankan morning plan sebagai salah satu bentuk reminder yang terbatas dan meaningful. fileciteturn5file7L978-L1031

## 26.9 Evening Reflection Reminder

Optional.

Tujuan:

- mengingatkan quick journal
- mengingatkan mood reflection
- menutup hari secara ringan

Notification harus tetap optional.

## 26.10 Notification Frequency

Default policy:

- maksimal satu habit reminder per scheduled habit occurrence
- summary reminder hanya jika user mengaktifkannya
- tidak ada reminder berulang dalam interval pendek untuk action yang sama
- tidak ada notification berdasarkan kebutuhan engagement aplikasi

Sistem harus menyediakan global notification settings.

## 26.11 Quiet Hours

User dapat menentukan quiet hours.

Ketika quiet hours aktif:

- notification tidak ditampilkan pada periode tersebut
- scheduled event dapat ditunda ke next valid delivery window
- sistem tidak boleh menganggap reminder yang ditunda sebagai habit miss

Notification delivery tidak mengubah status habit.

## 26.12 Notification Privacy

Karena journal dan mood bersifat sensitif, isi notification harus privacy-safe.

Default notification tidak boleh menampilkan isi journal, emotion detail, atau data pribadi sensitif.

Contoh aman:

```text
Prokopa reminder
Time for your planned habit.
```

Contoh yang harus dihindari secara default:

```text
You were anxious today. Try journaling about your family problem.
```

## 26.13 Local Scheduling

Notification schedule harus dapat diregenerasi dari local database.

Canonical source:

`Local schedule configuration -> Notification scheduler`

Scheduled notification identifier harus memiliki hubungan deterministik dengan entitas lokal sehingga reschedule tidak menghasilkan duplicate notifications.

## 26.14 Reschedule Rules

Reschedule wajib terjadi ketika:

- habit schedule berubah
- reminder time berubah
- reminder enabled berubah
- habit dipause
- habit diarsipkan
- relevant day configuration berubah
- timezone berubah secara material

Sistem harus membatalkan schedule lama sebelum membuat schedule baru jika identifier tidak immutable.

## 26.15 Timezone Behavior

Schedule harus menggunakan timezone lokal perangkat pada saat delivery.

Perubahan timezone tidak boleh memindahkan historical completion.

Perubahan timezone hanya memengaruhi future scheduling.

## 26.16 Notification State

Notification state minimum:

- Not scheduled
- Scheduled
- Disabled
- Permission unavailable
- Scheduling failed

State tidak boleh menggunakan istilah sync seperti `synced` atau `syncing`.

## 26.17 Permission Denied

Jika user menolak OS notification permission:

- habit tetap berjalan normal
- completion tetap tersedia
- journal tetap tersedia
- progress tetap tersedia
- app tidak boleh memblokir core feature

Settings harus memberi jalan untuk mengaktifkan permission kembali melalui OS settings bila platform menyediakan.

## 26.18 Scheduling Failure

Jika local scheduling gagal:

- persist error state lokal
- tampilkan message yang dapat dipahami
- jangan mengubah habit completion state
- jangan retry tanpa batas

Contoh:

```text
Reminder could not be scheduled.
Your habit is still saved locally.
```

## 26.19 Notification Copy Rules

Copy harus:

- singkat
- jelas
- netral
- action-oriented
- tidak shame-based
- tidak mengancam streak
- tidak menampilkan data sensitif secara default

## 26.20 Notification Acceptance Criteria

1. User dapat mengaktifkan reminder tanpa account.
2. Reminder dapat dijadwalkan tanpa network.
3. Reminder tidak mengubah status habit dengan sendirinya.
4. Permission denied tidak memblokir core app.
5. Pause membatalkan notification aktif untuk habit tersebut.
6. Schedule change mengubah future reminder dan tidak mengubah historical data.
7. Duplicate scheduling tidak menghasilkan duplicate reminder.
8. Quiet hours dihormati.
9. Notification tidak memperlihatkan isi journal secara default.
10. Tidak ada cloud dependency dalam notification execution.

---

# 27. Privacy and App Lock

## 27.1 Purpose

Prokopa menyimpan data personal yang kemungkinan sensitif, khususnya journal, mood, dan behavioral history.

Design system menekankan bahwa journal adalah data yang sangat private dan privacy harus dibangun ke dalam UX, termasuk app lock, notification privacy, dan user-controlled export/delete. fileciteturn5file8L1125-L1159

## 27.2 Privacy Model

Default privacy posture:

`Private by default`

Artinya:

- tidak ada account
- tidak ada public profile
- tidak ada social feed
- tidak ada cloud sync
- tidak ada automatic remote upload
- tidak ada server-side journal processing

## 27.3 Local-Only Guarantee

Core data harus tetap berada pada local storage perangkat.

Sistem tidak boleh mengirim:

- journal text
- mood history
- habit history
- sleep data
- app lock credential
- backup content

ke remote service sebagai bagian dari core feature.

## 27.4 App Lock Is Not Authentication

App lock merupakan local security feature.

App lock tidak membuat account.

App lock tidak menyediakan:

- username
- email
- password account
- cloud identity
- session token

## 27.5 App Lock Methods

Metode yang dapat didukung platform:

- PIN/passcode lokal
- biometric unlock jika OS menyediakan

Implementasi final mengikuti capability platform dan permission model OS.

## 27.6 App Lock Enable Flow

Minimum flow:

`Profile -> Privacy -> App Lock -> choose method -> confirm -> enabled`

User harus melakukan confirmation sebelum lock aktif.

## 27.7 App Lock Disable Flow

Disable harus memerlukan valid local verification.

Tidak boleh cukup dengan membuka settings biasa jika app lock sedang aktif.

## 27.8 Auto-Lock Timing

Pilihan minimum:

- immediately
- after 1 minute
- after 5 minutes
- after 15 minutes

Default dapat ditentukan pada implementation phase tetapi harus konsisten dan terdokumentasi.

## 27.9 Background Protection

Ketika app masuk background:

- protected screens tidak boleh tetap mudah terlihat dalam app switcher jika OS mendukung secure rendering
- app harus mengunci sesuai configured timeout
- notification preview harus tetap mengikuti privacy setting

## 27.10 Failed Unlock

Failed unlock harus:

- menjaga data tetap inaccessible
- tidak menghapus data secara default
- tidak memaksa account recovery karena tidak ada account

Recovery mechanism untuk forgotten PIN harus ditentukan secara eksplisit sebagai tradeoff.

### 27.10.1 Recovery Constraint

Karena tidak ada server account, Prokopa tidak dapat menawarkan password reset melalui email.

Jika user lupa local PIN, product harus memilih salah satu policy yang terdokumentasi:

A. biometric recovery jika biometrics sudah enrolled dan platform mengizinkan

B. local reset dengan konsekuensi penghapusan protected local data

C. kombinasi recovery mechanism yang tersedia secara aman pada platform

Tidak boleh membuat false promise bahwa PIN dapat dipulihkan dari cloud.

## 27.11 Journal Privacy

Journal editor tidak boleh menampilkan isi entry lain secara tidak sengaja.

Search dan preview journal harus tetap berada dalam local app boundary.

## 27.12 Screenshot Protection

Jika platform mendukung screenshot/screen-capture restriction, app dapat menggunakannya untuk protected content.

Namun feature harus diperlakukan sebagai defense-in-depth, bukan jaminan absolut terhadap semua bentuk capture.

## 27.13 Notification Privacy Settings

User dapat memilih:

- show generic notification text
- show more detail jika user mengaktifkan
- hide sensitive preview

Default harus privacy-preserving.

## 27.14 Data Export

Privacy settings harus memiliki akses ke:

`Export my data`

Export adalah user-initiated dan tidak otomatis mengirim data ke cloud.

## 27.15 Delete Controls

Minimum controls:

- delete selected journal entries
- delete selected data category jika didukung
- delete all data

Delete all data harus menggunakan explicit confirmation.

## 27.16 Destructive Action Confirmation

Confirmation harus menyebutkan:

- data apa yang dihapus
- apakah action irreversible
- apakah backup lokal tetap tersedia

Contoh:

```text
Delete all local data?
This removes habits, journal entries, progress, mood, and settings from this device.
This action cannot be undone unless you have a backup.
```

## 27.17 No Hidden Telemetry Requirement

Core privacy model melarang data personal dikirim untuk analytics product behavior tanpa product requirement dan explicit privacy treatment.

Untuk scope local-only, analytics remote bukan bagian dari core implementation.

## 27.18 Privacy Acceptance Criteria

1. Tidak ada account requirement.
2. Tidak ada cloud sync.
3. Journal tersimpan lokal.
4. App lock tidak bergantung pada backend.
5. Permission denial tidak menyebabkan data loss.
6. Notification preview memiliki privacy-safe default.
7. Export dapat dilakukan tanpa login.
8. Delete all data memiliki confirmation.
9. Tidak ada recovery flow yang mengklaim cloud account recovery.
10. Privacy settings dapat diakses secara lokal.

---

# 28. Data Model and Database Rules

## 28.1 Purpose

Section ini mendefinisikan canonical local data model agar seluruh feature menggunakan sumber data yang konsisten.

Database harus menjadi source of truth untuk state produk.

UI state bukan authoritative source untuk historical data.

## 28.2 Local Database Boundary

Database lokal minimal menyimpan:

- app settings
- profile preferences
- habits
- schedules
- habit occurrences/instances bila diperlukan oleh persistence strategy
- completions
- skip records
- pause records
- journal entries
- journal tags
- moods
- sleep records
- review metadata bila perlu
- achievements
- XP/level state jika diperlukan untuk cache yang terkontrol
- schema/version metadata

## 28.3 Canonical Entities

Recommended conceptual entities:

```text
UserProfile
AppSettings
Habit
HabitSchedule
HabitOccurrence
HabitCompletion
HabitSkip
HabitPause
JournalEntry
JournalTag
MoodEntry
SleepEntry
Achievement
UserProgress
BackupMetadata
SchemaMetadata
```

Nama class/table final dapat berubah selama semantics tetap sama.

## 28.4 UserProfile

Karena tidak ada account, `UserProfile` hanya mewakili local preference/persona state.

Minimum fields:

```text
id
name nullable
createdAt
updatedAt
```

Tidak boleh memuat:

- email
- password
- remote user id
- access token

## 28.5 AppSettings

Contoh fields:

```text
themeMode
weekStartDay
locale
timezone
firstDayExperienceCompleted
notificationEnabled
quietHoursStart
quietHoursEnd
appLockEnabled
appLockMethod
appLockTimeout
notificationPrivacyMode
```

Only settings relevant to implemented features boleh ditambahkan.

## 28.6 Habit

Conceptual fields:

```text
id
name
why
cue
minimumVersion
status
createdAt
updatedAt
archivedAt nullable
```

`status` minimum:

- active
- paused
- archived

## 28.7 HabitSchedule

Schedule harus dipisahkan dari identity habit jika perubahan schedule perlu dilacak tanpa merusak historical interpretation.

Fields conceptually:

```text
id
habitId
frequencyType
frequencyConfig
startDate
endDate nullable
createdAt
updatedAt
```

Frequency types mengikuti semantics yang telah ditetapkan:

- daily
- specific days
- x times per week
- interval
- custom

## 28.8 HabitOccurrence

Occurrence merepresentasikan planned opportunity pada periode tertentu.

Conceptual fields:

```text
id
habitId
scheduleId
date
planned
state
createdAt
updatedAt
```

State harus membedakan setidaknya:

- no-plan
- upcoming
- available
- completed
- skipped
- missed

Jika occurrence generation bersifat virtual, implementasi boleh menghitungnya secara deterministic daripada menyimpan seluruh row. Namun semantics harus tetap sama.

## 28.9 HabitCompletion

Completion adalah fakta bahwa planned action telah dilakukan.

Fields conceptually:

```text
id
habitId
occurrenceId nullable
completedAt
completionSource
note nullable
moodEntryId nullable
createdAt
updatedAt
```

Completion harus idempotent terhadap primary business key yang ditetapkan.

## 28.10 HabitSkip

Skip harus menyimpan alasan ketika user memilih reason.

Conceptual fields:

```text
id
habitId
occurrenceId
reason
note nullable
createdAt
```

Reason minimum:

- sick
- travel
- rest
- schedule_changed
- other

Skip adalah berbeda dari miss.

## 28.11 HabitPause

Pause merepresentasikan decision user untuk menghentikan sementara schedule.

Fields conceptually:

```text
id
habitId
startedAt
resumeAt nullable
reason nullable
createdAt
updatedAt
```

Pause bukan completion dan bukan miss.

## 28.12 JournalEntry

Minimum fields:

```text
id
entryDate
createdAt
updatedAt
title nullable
body
moodEntryId nullable
isDraft
isDeleted
```

Body adalah content utama.

Editor harus mendukung local autosave.

## 28.13 JournalTag

Tag dipisahkan agar search/filter tetap konsisten.

Conceptual mapping:

```text
JournalEntry <-> JournalTag
```

Tag harus dinormalisasi atau memiliki aturan canonicalization yang jelas untuk mencegah duplicate semantic tags.

## 28.14 MoodEntry

Mood adalah self-report.

Conceptual fields:

```text
id
recordedAt
valence nullable
energy nullable
emotionLabel nullable
contextTags
note nullable
source
```

Mood tidak boleh disimpan dengan semantics diagnosis.

## 28.15 SleepEntry

Sleep crossing midnight harus direpresentasikan dengan timestamp, bukan hanya date string.

Conceptual fields:

```text
id
sleepStart
sleepEnd
quality nullable
note nullable
createdAt
updatedAt
```

Validation minimum:

`sleepEnd > sleepStart`

Durasi dihitung dari timestamp.

## 28.16 Achievement

Achievement definition sebaiknya immutable pada installed app version kecuali migration diperlukan.

User state menyimpan unlock fakta.

Conceptual fields:

```text
id
achievementKey
unlockedAt
progressSnapshot nullable
```

Achievement criteria harus tidak bergantung pada UI state.

## 28.17 UserProgress

Jika XP dan level digunakan, canonical progress entity dapat menyimpan:

```text
xp
level
updatedAt
```

Namun `xp` harus dapat direbuild dari immutable user events jika arsitektur implementation memungkinkan.

Jangan memiliki dua formula level yang berbeda pada screen berbeda.

## 28.18 BackupMetadata

Metadata backup lokal dapat mencatat:

```text
backupId
createdAt
appVersion
schemaVersion
itemCounts
formatVersion
```

Tidak perlu menyimpan data pribadi tambahan hanya untuk metadata.

## 28.19 SchemaMetadata

Minimum:

```text
schemaVersion
migrationState
lastMigrationAt
```

Schema migration harus explicit.

## 28.20 ID Strategy

Setiap persistent entity harus memiliki stable unique identifier.

ID generation harus berjalan offline.

Requirement:

- collision-resistant
- deterministic relation where needed
- tidak bergantung pada server-assigned ID

## 28.21 Timestamp Rules

Timestamp canonical harus disimpan dengan precision yang konsisten.

System harus membedakan:

- date semantics untuk calendar-based habit planning
- timestamp semantics untuk events seperti completion, journal save, sleep start/end

Jangan menyamakan date-only dan timestamp secara sembarang.

## 28.22 Historical Integrity

Edit terhadap habit saat ini tidak boleh mengubah historical record secara tidak terkendali.

Contoh:

Jika user mengubah frequency dari Daily menjadi 3x/week, historical completion sebelumnya tetap dihitung berdasarkan rule yang berlaku pada periode tersebut.

## 28.23 Schedule Versioning

Schedule changes harus memiliki effective period.

Historical metric harus dapat menjawab:

`Schedule apa yang berlaku ketika occurrence ini direncanakan?`

## 28.24 Deletion Semantics

Untuk data yang memengaruhi metric historical, prefer soft-delete atau tombstone ketika diperlukan agar referential integrity tetap dapat dipertahankan.

Hard-delete hanya bila requirement memang mengharuskannya dan downstream references ditangani.

## 28.25 Referential Integrity

Constraint minimum:

- completion tidak boleh merujuk habit yang tidak ada
- journal mood reference tidak boleh broken
- schedule harus memiliki parent habit
- pause harus memiliki parent habit
- journal tags tidak boleh merujuk entry yang tidak ada

## 28.26 Derived Metrics

Metric seperti:

- completion rate
- streak
- consistency
- monthly rhythm
- recovery count
- XP
- level

harus dihitung dari canonical source atau derived cache yang dapat divalidasi.

UI tidak boleh menjadi source of truth.

## 28.27 Calculation Reproducibility

Untuk input data yang sama, metric engine harus menghasilkan output yang sama.

Contoh:

`same habit history + same schedule + same period -> same completion rate`

## 28.28 Database Transaction Rules

Operasi yang mengubah beberapa entity yang saling bergantung harus transactional.

Contoh:

`complete habit -> persist completion -> update derived state -> persist notification/review effect jika diperlukan`

Jika salah satu critical operation gagal, system tidak boleh meninggalkan partial state yang menyesatkan.

## 28.29 Draft Persistence

Journal draft harus disimpan lokal secara incremental ketika editor digunakan.

Minimum state:

`new -> draft -> saving -> saved locally`

Error:

`save failed`

Tidak boleh menggunakan `syncing` atau `synced` sebagai state core karena product tidak memiliki cloud sync.

## 28.30 Database Error Handling

Database failure harus menghasilkan:

- safe user-visible error
- preservation attempt of existing data
- no fabricated success state
- diagnostic logging lokal bila diperlukan

## 28.31 Data Model Acceptance Criteria

1. Semua core entity memiliki stable identifier.
2. Historical metrics tidak berubah secara diam-diam karena edit current state.
3. No cloud ID diperlukan untuk core persistence.
4. Semua relation memiliki referential integrity.
5. Derived metrics memiliki satu canonical source.
6. Date dan timestamp semantics dibedakan.
7. Schema memiliki version.
8. Migration dapat dijalankan deterministic.
9. Journal draft dapat dipersist locally.
10. Database failure tidak dilaporkan sebagai save success.

---

# 29. Backup, Export, Import, and Restore

## 29.1 Purpose

Backup menyediakan portability dan recovery tanpa mengubah model local-only.

Backup bukan cloud sync.

Export adalah action user.

Import adalah action user.

Restore adalah proses mengembalikan local data dari backup yang valid.

## 29.2 Product Model

Data flow:

```text
Local Database
      |
      v
Export / Backup File
      |
 user-controlled storage
      |
      v
Import / Restore
      |
      v
Local Database
```

Prokopa tidak secara otomatis mengunggah backup ke server.

## 29.3 Supported Operations

Minimum:

- Export all data
- Import backup
- Restore from backup
- Validate backup
- Show backup metadata

Optional future:

- Export selected categories
- Import selected categories

## 29.4 Backup Format

Format harus:

- versioned
- self-describing
- deterministic enough for validation
- robust terhadap schema evolution
- capable of representing all required core entities

Format implementation dapat berupa JSON container atau format lain yang terdefinisi jelas.

## 29.5 Backup Envelope

Conceptual structure:

```text
backupFormatVersion
appVersion
schemaVersion
createdAt
deviceTimezone
checksum
payload
```

`payload` berisi data domain yang diperlukan.

## 29.6 Checksum / Integrity Marker

Backup sebaiknya memiliki integrity marker agar corrupted file dapat dideteksi sebelum import.

Checksum tidak dimaksudkan sebagai encryption.

## 29.7 Backup Encryption

Jika implementation mendukung encrypted backup, key management harus dijelaskan secara eksplisit.

Jangan menawarkan label `encrypted backup` jika file sebenarnya plaintext.

Jika encryption belum dapat diimplementasikan dengan aman, product harus menyatakan backup sebagai user-controlled file tanpa klaim encryption.

## 29.8 Export Flow

Minimum flow:

`Profile -> Data -> Export -> choose destination -> generate -> success/failure`

Export harus dibuat secara lokal.

## 29.9 Export Success

User harus menerima informasi:

- file successfully created
- format/version
- approximate data scope

Contoh:

```text
Backup created successfully.
Your data was exported to a local file.
```

## 29.10 Export Failure

Jika export gagal:

- jangan membuat file yang dilabeli sebagai success
- tampilkan failure state
- jangan menghapus source data

## 29.11 Import Flow

Minimum:

`Select file -> validate format -> validate integrity -> inspect summary -> confirm -> restore/import`

Jangan langsung overwrite database ketika file dipilih.

## 29.12 Import Preview

Preview minimum:

- backup date
- app/schema version
- habits count
- journal count
- mood count
- sleep count
- achievement count

Preview harus bersumber dari file yang dipilih.

## 29.13 Invalid Backup

File dianggap invalid jika:

- format version unsupported
- mandatory fields missing
- checksum invalid jika checksum digunakan
- payload malformed
- relational constraints tidak dapat dipenuhi

User harus menerima alasan yang actionable tanpa technical dump.

## 29.14 Restore Strategy

Restore harus memiliki strategy yang jelas.

Minimum supported strategy pada release awal dapat berupa:

`replace local data with validated backup`

Merge dapat ditambahkan kemudian hanya jika conflict semantics benar-benar sudah ditetapkan.

## 29.15 Replace Restore

Sebelum replace:

- validate seluruh backup
- confirm destructive consequence
- create safety snapshot/temporary backup jika implementation memungkinkan

Setelah restore:

- rebuild derived metrics
- rebuild notification schedules
- revalidate app settings
- update schema if needed

## 29.16 Merge Import

Merge tidak boleh diam-diam diimplementasikan.

Jika future release mendukung merge, requirement minimal harus mendefinisikan:

- entity identity matching
- conflict resolution
- duplicate prevention
- historical preservation
- user preview

Tanpa definisi ini, merge berada di out-of-scope.

## 29.17 Import Safety

Imported content tidak boleh mengeksekusi code.

Parser harus memperlakukan backup sebagai data.

File harus diproses sandboxed sesuai capability platform dan library.

## 29.18 Schema Migration During Restore

Old valid backup boleh di-import jika migration path tersedia.

Flow:

`backup schema N -> validate -> migrate to current schema -> validate again -> persist`

Jika migration tidak tersedia, import ditolak dengan alasan yang jelas.

## 29.19 Version Compatibility

App harus membedakan:

- format version
- schema version
- app version

App version tidak otomatis sama dengan schema version.

## 29.20 Partial Import

Default release policy:

Jangan lakukan partial import untuk replace restore jika integrity keseluruhan belum dijamin.

Lebih baik seluruh restore gagal daripada local database berisi setengah data yang tidak konsisten.

## 29.21 Restore Interruption

Jika app ditutup atau process interrupted di tengah restore:

- gunakan transactional approach jika platform/database mendukung
- jangan meninggalkan database dalam state half-restored
- recover ke last known consistent state

## 29.22 Rebuild Derived Data

Setelah restore, derived state harus direcalculate:

- completion rate
- streak
- consistency
- recovery count
- monthly rhythm
- achievements status
- XP/level jika applicable

Jangan percaya derived values dari backup tanpa validation bila dapat direcompute dari canonical records.

## 29.23 Notification Rebuild

Setelah restore:

- clear obsolete scheduled notifications
- rebuild current valid schedules
- respect current OS permission
- respect current quiet hours

Historical backup tidak boleh membuat notification historis kembali muncul.

## 29.24 Backup Naming

Default filename harus informatif, misalnya:

```text
prokopa-backup-YYYY-MM-DD
```

Tidak perlu memasukkan private journal text ke filename.

## 29.25 User Control

Backup harus selalu dipicu user.

Tidak ada automatic cloud backup sebagai core behavior.

## 29.26 Data Scope Disclosure

Export confirmation harus menjelaskan scope.

Contoh:

```text
This backup includes your habits, progress, journal, mood, sleep, settings, and achievements.
```

## 29.27 Delete After Export

Export dan delete adalah dua action berbeda.

Export tidak otomatis delete source data.

## 29.28 Import Acceptance Criteria

1. Backup dapat dibuat tanpa login.
2. Backup dapat digunakan tanpa network.
3. Invalid backup ditolak sebelum overwrite.
4. Restore tidak menghasilkan half-restored database.
5. Old supported schema dapat dimigrasikan.
6. Derived metrics dibangun ulang secara konsisten.
7. Notification schedule dibangun ulang untuk future state saja.
8. Import tidak mengeksekusi code dari file.
9. Replace restore memerlukan explicit confirmation.
10. Tidak ada cloud service yang diperlukan untuk export/import/restore.

---

# 30. Local Data Integrity

## 30.1 Purpose

Local-only berarti kualitas data sepenuhnya bergantung pada reliability storage, validation, migration, dan recovery strategy di perangkat.

Local data integrity harus diperlakukan sebagai core product requirement.

## 30.2 Integrity Principles

Prinsip minimum:

- no fabricated success
- no silent corruption
- deterministic calculations
- transactional critical writes
- explicit migration
- recoverable failure
- historical preservation
- validation at boundaries

## 30.3 Write Safety

Setiap critical write harus memiliki hasil yang dapat dibedakan:

```text
success
failure
unknown / interrupted
```

UI tidak boleh mengasumsikan success hanya karena user menekan tombol.

## 30.4 Atomic Operations

Operasi yang harus atomic bila memungkinkan:

- habit completion + associated event state
- journal autosave transaction
- deletion of entity with required dependents
- restore
- schema migration

## 30.5 Autosave Integrity

Journal autosave harus menghindari:

- overwrite dengan data kosong karena race
- save lama menimpa save baru
- false `Saved` state

Editor harus menggunakan ordering/version strategy sehingga write terakhir tidak kehilangan perubahan terbaru.

## 30.6 Draft Recovery

Jika app ditutup saat journal sedang disimpan:

Saat reopen, sistem harus menentukan apakah:

- latest persisted draft tersedia
- unsaved local buffer tersedia
- recovery prompt diperlukan

Tidak boleh diam-diam membuang draft terbaru yang masih dapat dipulihkan.

## 30.7 Duplicate Prevention

Operation yang secara bisnis idempotent harus aman dipanggil dua kali.

Contoh:

User menekan completion action dua kali secara sangat cepat.

Hasil akhir tidak boleh menghasilkan dua completion yang secara semantic berarti satu completion ganda untuk occurrence yang sama, kecuali habit memang secara eksplisit mendukung multiple repetitions pada tanggal tersebut.

## 30.8 Concurrency Rules

Mobile UI dapat memiliki race antara:

- autosave
- navigation
- background/foreground
- notification callback
- database migration

Database layer harus menjadi coordinator untuk critical state.

## 30.9 Date Boundary Integrity

Date-based calculations harus menggunakan calendar date sesuai timezone yang berlaku.

Contoh:

Journal pukul 00:05 tidak boleh salah dipindahkan ke previous date hanya karena UTC conversion yang tidak sesuai product semantics.

## 30.10 Timezone Change Integrity

Historical event timestamps tetap immutable.

Timezone change hanya memengaruhi interpretation yang memang berbasis local calendar bila requirement menyatakan demikian.

Semua ambiguity harus diselesaikan oleh satu canonical time policy.

## 30.11 Clock Anomaly

Device clock dapat berubah manual.

Sistem tidak boleh menganggap waktu perangkat selalu benar untuk security atau integrity critical decisions.

Untuk habit analytics, behavior terhadap clock anomaly harus sederhana dan terdokumentasi.

Contoh policy:

- historical event timestamp tetap disimpan
- future schedules mengikuti current device time
- impossible interval seperti sleep end before sleep start ditolak

## 30.12 Migration Integrity

Setiap migration harus:

- memiliki version number
- dapat dijalankan sesuai order
- tidak kehilangan field tanpa explicit policy
- dapat diverifikasi
- gagal secara visible jika tidak lengkap

Migration tidak boleh bergantung pada network.

## 30.13 Migration Backup

Sebelum destructive schema migration, implementation sebaiknya menyediakan safety mechanism lokal jika feasible.

Minimal requirement:

`do not silently destroy unreadable old data`

## 30.14 Validation Layers

Validation minimum berada pada beberapa layer:

### UI validation

Untuk feedback langsung kepada user.

### Domain validation

Untuk memastikan business rule.

### Persistence validation

Untuk memastikan data yang akan disimpan valid.

### Restore validation

Untuk memastikan imported backup konsisten.

Tidak satu layer pun boleh menjadi satu-satunya defense.

## 30.15 Impossible State Examples

Sistem harus menolak atau memperbaiki secara deterministic state seperti:

- completion untuk archived/nonexistent habit tanpa historical justification
- sleep end before sleep start
- journal entry tanpa required identity
- schedule dengan invalid frequency configuration
- pause end before pause start
- negative XP
- duplicate achievement unlock for same immutable achievement key jika semantics single unlock

## 30.16 Recovery After Database Failure

Jika database mengalami failure:

- preserve existing valid data
- stop cascading writes bila perlu
- show actionable error
- allow safe retry
- do not present stale cached success as confirmed persistence

## 30.17 Corruption Detection

Corruption detection dapat menggunakan:

- schema validation
- foreign-key checks
- checksums where applicable
- invariant checks
- count consistency

Detection harus lebih diutamakan daripada silent repair untuk data sensitif.

## 30.18 Automatic Repair

Automatic repair hanya boleh dilakukan untuk invariant yang:

- deterministic
- safe
- lossless

Contoh aman:

Rebuild derived cache dari canonical records.

Contoh berisiko:

Mengarang completion record yang hilang untuk memperbaiki streak.

Yang kedua dilarang.

## 30.19 Derived Cache Policy

Cache untuk metric diperbolehkan hanya jika:

- ada canonical source
- cache memiliki versioning atau invalidation
- cache dapat dibangun ulang

Cache tidak boleh menjadi satu-satunya tempat penyimpanan data penting.

## 30.20 Historical Recalculation

Ketika business logic version berubah, migration/recalculation harus memiliki policy.

Jangan mengubah historical metric secara diam-diam hanya karena UI versi baru memiliki formula berbeda.

Jika formula memang berubah sebagai product requirement, perubahan harus:

- terdokumentasi
- diuji
- memiliki acceptance criteria baru

## 30.21 Backup Verification

User dapat memperoleh verifikasi setelah export.

Minimum verification:

- file exists
- format valid
- payload readable
- checksum valid jika digunakan

Jangan menyatakan backup aman hanya karena file berhasil ditulis.

## 30.22 Restore Verification

Setelah restore, jalankan integrity check minimal pada:

- entity references
- required fields
- date/timestamp constraints
- metric recalculation
- notification configuration

## 30.23 Integrity Status

Local data status dapat memiliki:

- Healthy
- Needs attention
- Recovery required

Status hanya ditampilkan bila benar-benar dibutuhkan.

Jangan membuat anxiety dengan integrity indicator yang terus-menerus tampil tanpa actionable value.

## 30.24 Error Logging

Diagnostic logs:

- boleh lokal
- tidak boleh memuat journal body secara default
- tidak boleh menyertakan credential
- tidak boleh mengekspos app lock secret
- harus dibatasi agar tidak tumbuh tanpa batas

## 30.25 Crash Recovery

Setelah unexpected termination, app harus membuka pada last known consistent state.

Startup recovery tidak boleh menganggap UI cache sebagai source of truth.

## 30.26 Integrity Testing Matrix

Minimum test categories:

```text
create
update
delete
rapid repeated action
app restart
background/foreground
process interruption
migration
export
import
restore
timezone change
invalid input
corrupted backup
```

## 30.27 Acceptance Criteria

1. Critical writes memiliki explicit success/failure semantics.
2. Journal draft tidak hilang pada normal app interruption jika data sudah persisted.
3. Duplicate completion tidak menciptakan semantic duplicate.
4. Restore bersifat transactional atau equivalent safe recovery.
5. Migration memiliki versioning.
6. Derived caches dapat direbuild.
7. Impossible states ditolak.
8. Corruption tidak disamarkan sebagai success.
9. Logs tidak membocorkan journal content atau secrets.
10. Semua core integrity operations bekerja tanpa network.

---

# 31. Cross-Section Rules for Sections 26–30

## Rule 1
Local notification adalah convenience layer, bukan source of truth.

## Rule 2
App lock adalah security control lokal, bukan authentication system.

## Rule 3
Database lokal adalah authoritative source untuk core product state.

## Rule 4
Backup/export/import tidak sama dengan synchronization.

## Rule 5
Tidak boleh ada feature yang membutuhkan backend hanya untuk menyimpan atau memulihkan core user data.

## Rule 6
Historical data tidak boleh berubah secara diam-diam karena perubahan current configuration.

## Rule 7
No-plan, skipped, missed, paused, dan completed harus tetap distinct di persistence layer ketika semantic distinction dibutuhkan oleh analytics.

## Rule 8
Journal data harus diperlakukan sebagai highly private local content.

## Rule 9
Notification copy tidak boleh menggunakan shame, threat, atau streak hostage language.

## Rule 10
Tidak boleh ada `syncing`, `synced`, atau `sync failed` sebagai status core local-only.

## Rule 11
Import data dianggap untrusted input sampai validation selesai.

## Rule 12
Derived metric harus reproducible dari canonical data.

## Rule 13
Automatic repair tidak boleh mengarang historical events.

## Rule 14
Tidak boleh menyatakan `Saved`, `Exported`, atau `Restored` sebelum operation benar-benar committed.

## Rule 15
Setiap destructive restore/delete harus memiliki explicit user confirmation.

## Rule 16
Failure pada notification tidak boleh memengaruhi habit data integrity.

## Rule 17
Failure pada analytics tidak boleh menghapus atau mengubah canonical user records.

## Rule 18
Schema migration tidak boleh membutuhkan internet.

## Rule 19
Timezone changes must preserve event history.

## Rule 20
Backup file version harus dapat dibedakan dari app version dan database schema version.

## Rule 21
No secret, credential, or app lock PIN boleh masuk ke plain diagnostic logs.

## Rule 22
Tidak boleh ada silent partial restore.

## Rule 23
Tidak boleh ada fake recovery promise untuk local PIN yang tidak benar-benar didukung implementation.

## Rule 24
Semua privacy-sensitive preview harus default ke minimization.

## Rule 25
Semua feature dalam Sections 26–30 harus dapat diuji secara offline.

---

# 32. Transition to Next Batch

Sections 26–30 menetapkan fondasi untuk:

- local reminder behavior
- local privacy and app security
- canonical persistence model
- user-controlled data portability
- recovery and integrity guarantees

Batch berikutnya dapat melanjutkan ke:

`31. Error, Empty, Loading, and Recovery States`
`32. Design System and Visual Language`
`33. Brand Identity and UI Tokens`
`34. Accessibility and Inclusive Interaction`
`35. Interaction, Motion, and Feedback`

Scope tersebut harus tetap terhubung dengan rule local-only dan source-of-truth yang telah ditetapkan di Part 6.




# 31. Error, Empty, Loading, and Recovery States

## 31.1 Purpose

Prokopa harus tetap dapat dipahami ketika data belum tersedia, proses sedang berjalan, penyimpanan gagal, input tidak valid, database sedang dimigrasikan, atau sebuah fitur tidak dapat menyelesaikan operasi.

State UI bukan dekorasi. State harus menjelaskan kondisi sistem yang nyata, tindakan yang tersedia, dan konsekuensi dari tindakan tersebut.

Design system menetapkan bahwa komponen perlu memiliki state seperti Default, Hover, Pressed, Focus, Selected, Disabled, Loading, dan Error. Habit dan journal juga memiliki state domain yang spesifik. fileciteturn2file0L39-L74

Karena Prokopa local-only, state jaringan seperti `syncing`, `synced`, dan `sync failed` tidak digunakan sebagai core state.

## 31.2 State Taxonomy

UI harus membedakan sekurang-kurangnya:

- loading: operasi sedang berlangsung dan hasil belum tersedia
- empty: fitur valid tetapi belum memiliki data
- zero: data tersedia secara konseptual tetapi nilai saat ini memang nol
- error: operasi gagal
- invalid: input atau konfigurasi tidak memenuhi rule
- locked: konten ada tetapi akses membutuhkan autentikasi lokal
- saving: perubahan sedang ditulis ke local persistence
- saved: perubahan telah berhasil committed ke local persistence
- recovery: aplikasi menawarkan pemulihan setelah kegagalan atau lapse
- unavailable: fitur tidak dapat digunakan pada kondisi perangkat/configuration tertentu

State harus berasal dari state machine yang dapat direproduksi, bukan dari hard-coded visual shortcut.

## 31.3 Loading Rules

Loading digunakan ketika pengguna memang menunggu operasi yang tidak dapat diselesaikan secara sinkron tanpa risiko jank atau blocking yang terlihat.

Loading tidak boleh muncul hanya untuk membuat interface terlihat aktif.

Untuk operasi lokal yang sangat cepat:

`User action -> local operation -> immediate UI update`

Loading indicator hanya digunakan ketika threshold waktu atau proses migrasi/komputasi membuat penundaan terlihat.

Selama loading:

- primary action yang dapat menyebabkan duplicate operation harus disabled atau idempotent
- state sebelumnya tidak boleh disamarkan tanpa alasan
- pengguna harus mengetahui kapan operasi selesai

## 31.4 Saving State

Journal dan data lain yang membutuhkan write operation harus menggunakan state yang benar-benar mencerminkan persistence.

Minimum state:

`NEW -> DRAFT -> SAVING -> SAVED LOCALLY`

Failure:

`SAVING -> SAVE FAILED`

Save failed tidak boleh menghapus draft yang masih berada di memory selama proses recovery memungkinkan.

Copy yang sesuai:

```text
Menyimpan…
Tersimpan di perangkat
Gagal menyimpan. Coba lagi.
```

Status sukses hanya boleh ditampilkan setelah commit berhasil. Rule ini mengikuti integrity contract Part 6.

## 31.5 Error Message Principles

Error harus:

1. menyebut apa yang gagal
2. menjelaskan dampak yang benar-benar terjadi
3. memberikan next action bila ada
4. tidak menyalahkan pengguna
5. tidak mengklaim data aman bila belum diverifikasi

Hindari:

```text
Oops!
Something went wrong.
Please try again later.
```

Gunakan bentuk yang lebih informatif:

```text
Entri jurnal belum tersimpan.
Draft masih tersedia di perangkat ini.
Coba simpan lagi.
```

## 31.6 Empty State Hierarchy

Empty state harus menjawab:

`Apa yang kosong? Mengapa? Apa langkah paling relevan berikutnya?`

### Today tanpa habit

```text
Belum ada habit hari ini.
Tambahkan satu kebiasaan kecil untuk mulai.
[Tambah habit]
```

### Journal tanpa entry

```text
Belum ada jurnal.
Mulai dengan beberapa kalimat tentang hari ini.
[Tulis jurnal]
```

### Insights tanpa cukup data

```text
Belum cukup data untuk pola yang bermakna.
Terus gunakan Prokopa beberapa hari lagi, lalu periksa kembali.
```

Empty state tidak boleh menggunakan angka palsu, progress palsu, achievement palsu, atau ilustrasi yang menyiratkan data telah dianalisis ketika belum ada data.

## 31.7 Zero State vs Empty State

`0` bukan selalu `empty`.

Contoh:

- `0 completed this week` berarti tracking sudah aktif dan hasil minggu ini nol
- `No journal entries` berarti belum ada journal record
- `0 missed` berarti tidak ada missed event, yang berbeda dari belum memiliki habit

UI harus mempertahankan perbedaan ini karena analytics bergantung pada semantic state.

## 31.8 Invalid Input State

Validation dilakukan sedekat mungkin dengan sumber input.

Contoh validation:

- habit name wajib memiliki nilai valid
- weekly target harus berada pada rentang yang diizinkan
- reminder time harus valid
- date range tidak boleh menghasilkan konfigurasi yang mustahil
- import field wajib memenuhi schema

Validation message harus konkret:

```text
Target mingguan harus antara 1 dan 7 kali.
```

Bukan:

```text
Input tidak valid.
```

## 31.9 Locked State

Jika App Lock aktif, konten private tidak boleh ditampilkan melalui preview yang tidak semestinya.

Locked screen harus minimalis dan tidak membocorkan:

- judul journal
- isi journal
- mood terakhir
- tag sensitif
- insight privat

Label umum diperbolehkan:

```text
Prokopa terkunci
Buka untuk melanjutkan
```

## 31.10 Recovery State

Recovery adalah state normal dalam product philosophy, bukan special case yang menyiratkan kegagalan moral.

Untuk habit lapse:

```text
Habit ini sempat terlewat.
Bagaimana ingin melanjutkannya?

[ Lanjutkan ]
[ Kurangi target ]
[ Ubah cue ]
[ Jeda habit ]
```

Design system menekankan recovery, neutral missed state, dan pause sebagai pilihan adaptasi, bukan punishment. fileciteturn2file3L952-L994

## 31.11 Database Migration State

Saat schema migration diperlukan:

`Open app -> detect old schema -> validate migration path -> migrate locally -> verify -> continue`

Migration harus berjalan tanpa internet.

Jika migration gagal:

- jangan membuka database pada state setengah bermigrasi
- pertahankan backup atau snapshot yang diperlukan untuk recovery
- tampilkan error yang jujur
- jangan mengarang restored data

## 31.12 Destructive Failure State

Operation seperti delete all, restore backup, atau overwrite import harus memiliki confirmation sebelum perubahan irreversible.

Setelah confirmation:

`Confirm -> operation -> verify -> success/failure`

UI tidak boleh mengatakan selesai sebelum verification pass.

---

# 32. Design System and Visual Language

## 32.1 Design Intent

Visual language Prokopa harus terasa:

- calm
- warm
- focused
- low-pressure
- reflective
- quietly rewarding
- trustworthy

Produk harus terasa seperti personal space dan reflection tool, bukan scoreboard, casino, atau notification machine. fileciteturn4file3L480-L495

Mental modes utama tetap:

`DO -> REFLECT -> REVIEW`

Screen tidak boleh mencampur terlalu banyak mode mental sekaligus. fileciteturn5file0L184-L200

## 32.2 Visual Reference Direction

Visual UI harus mengikuti karakter utama dari screenshot referensi yang telah digunakan untuk produk:

- rounded surfaces
- whitespace yang cukup
- visual hierarchy yang jelas
- typography yang mudah dibaca
- cards yang tidak berlebihan
- decorative treatment yang restrained
- navigation yang familiar
- interaction yang terasa langsung

Screenshot adalah referensi visual, bukan kontrak untuk menyalin pixel secara buta.

Implementasi harus tetap mempertahankan semantic behavior yang berasal dari design system psikologi.

## 32.3 Layout Philosophy

Prioritas horizontal pada mobile:

`content -> readable width -> breathing room -> secondary decoration`

Konten utama tidak boleh dikorbankan demi ornamen.

Komponen besar harus memiliki alasan informasi atau interaksi.

Dashboard tidak boleh berubah menjadi kumpulan KPI.

Today screen secara eksplisit bukan analytics dashboard dan tidak seharusnya menampilkan terlalu banyak metric sekaligus. fileciteturn4file1L282-L320

## 32.4 Spacing Scale

Gunakan spacing scale:

`4 / 8 / 12 / 16 / 24 / 32 / 40 / 48 / 64`

Token ini menjadi default layout scale agar spacing konsisten lintas screen. fileciteturn2file1L366-L450

Rule:

- 4: micro alignment
- 8: compact grouping
- 12: control spacing
- 16: default component padding
- 24: section grouping
- 32: major separation
- 40–64: page-level breathing room

Jangan menambah arbitrary spacing value tanpa alasan desain yang jelas.

## 32.5 Radius Scale

Gunakan radius:

`8 / 12 / 16 / 20 / full`

Makna penggunaan:

- 8: small controls
- 12: inputs and compact cards
- 16: primary cards/surfaces
- 20: larger elevated containers
- full: chips, pills, avatars, circular controls

Radius harus konsisten dan tidak random per-screen.

## 32.6 Surface Hierarchy

Hierarchy utama:

`App background -> section/surface -> interactive card -> pressed/selected state`

Elevation harus restrained.

Jangan menggunakan shadow berat sebagai default.

Visual hierarchy terutama dibangun melalui:

- spacing
- typography
- surface contrast
- border/subtle separation
- semantic state

## 32.7 Typography Hierarchy

Typography harus memiliki hierarchy yang cukup untuk scan cepat.

Minimum semantic levels:

- page title
- section title
- card title
- body
- secondary text
- metadata
- control label
- helper/error text

Body text harus menjadi elemen yang nyaman untuk dibaca berulang kali, terutama journal dan reflection copy.

Ukuran font tidak boleh menjadi satu-satunya pembeda hierarchy; weight dan spacing harus ikut digunakan.

## 32.8 Content Density

Default density harus ringan.

Untuk Today:

1. greeting/date
2. relevant habit content
3. small progress signal
4. reflection entry point
5. navigation

Untuk Journal:

1. entries
2. editor
3. search/filter saat relevan

Untuk Insights:

1. insight yang cukup data
2. supporting evidence
3. suggested adjustment/reflection

## 32.9 Cards

Card digunakan ketika grouping informasi meningkatkan comprehension.

Card tidak boleh digunakan hanya untuk membungkus setiap elemen.

Habit card minimum hierarchy:

`action -> cue -> status -> primary action`

Referensi design system menyatakan habit card perlu memprioritaskan action, cue, status, dan primary action. fileciteturn2file3L772-L800

## 32.10 Buttons

Button hierarchy minimum:

- primary: next most important action
- secondary: supportive action
- tertiary/text: low-emphasis action
- destructive: irreversible risk action

Tidak semua screen boleh memiliki banyak primary button.

Primary CTA harus mewakili mode mental utama screen.

## 32.11 Inputs

Input harus:

- memiliki visible label atau equivalent accessible name
- memiliki hit area memadai
- memberikan validation dekat dengan sumber masalah
- mempertahankan user input ketika validation gagal
- tidak menghapus draft karena navigation sederhana

## 32.12 Navigation

Navigation utama yang disepakati:

`Today | Journal | Progress | Insights | Profile`

Profile adalah ruang local settings, privacy, data management, appearance, notification configuration, dan app lock. Bukan account center.

Tidak ada:

- login screen
- signup screen
- account avatar requirement
- password account flow
- cloud sync page

## 32.13 Semantic Color Usage

Warna harus memiliki semantic intent.

Brand primary berasal dari identitas Prokopa dan digunakan secara konsisten.

Warna success digunakan untuk completion/success state, bukan menggantikan brand primary di seluruh UI.

Error digunakan secara semantic untuk failure/destructive risk.

Warning digunakan untuk kondisi yang membutuhkan perhatian tetapi bukan error.

Missed state habit tidak boleh menggunakan warna merah agresif sebagai shame cue.

Color tidak boleh menjadi satu-satunya pembawa makna. Design system mensyaratkan semantic status tidak disampaikan melalui color-only. fileciteturn2file0L176-L209

## 32.14 Illustration and Decoration

Illustration/decorative graphics harus:

- ringan
- relevan dengan context
- tidak mengambil fokus dari action atau reflection
- tidak terasa seperti game reward screen

Decorative component tidak boleh ditambahkan hanya agar screen terlihat “penuh”.

## 32.15 Copy Tone

Copy harus:

- calm
- direct
- supportive
- non-judgmental
- specific
- action-oriented saat user perlu bertindak

Hindari copy seperti:

```text
Jangan putus streak!
Kamu gagal hari ini.
Pertahankan kemenanganmu!
Kamu tertinggal!
```

Gunakan:

```text
Belum selesai hari ini.
Masih ada waktu untuk melanjutkan.
```

Untuk consistency gunakan framing seperti `7 hari konsisten` atau `7 days in rhythm`, bukan bahasa yang menjadikan streak sebagai ancaman. fileciteturn2file3L855-L904

---

# 33. Brand Identity and UI Tokens

## 33.1 Brand Name

Nama produk resmi yang tampil di UI dan dokumentasi produk:

`Prokopa: Habits and Jurnaling`

Ejaan `Jurnaling` dipertahankan persis sebagai keputusan brand.

## 33.2 Logo

Logo menjadi sumber identitas visual utama.

Asset brand yang tersedia:

- `prokopa.svg`
- `prokopa-darkmode.svg`

Implementasi harus memakai asset resmi tersebut daripada menggambar ulang logo secara manual.

## 33.3 Brand Color Direction

Identitas utama menggunakan nuansa indigo dari logo.

Primary brand token yang telah ditetapkan dari asset identitas:

`#3949AB`

Green dipertahankan untuk semantic success/completion, bukan sebagai pengganti brand primary global.

Exact shades turunan harus didefinisikan sebagai design token agar penggunaan konsisten dan dapat diperbaiki tanpa search-and-replace lintas widget.

## 33.4 Color Token Groups

Token layer minimum:

### Brand

```text
brand.primary
brand.primaryContainer
brand.onPrimary
brand.onPrimaryContainer
```

### Surface

```text
surface.background
surface.primary
surface.secondary
surface.elevated
surface.inverse
```

### Content

```text
text.primary
text.secondary
text.tertiary
text.inverse
```

### Semantic

```text
semantic.success
semantic.onSuccess
semantic.warning
semantic.onWarning
semantic.error
semantic.onError
semantic.info
semantic.onInfo
```

### State

```text
state.focus
state.pressed
state.selected
state.disabled
state.loading
```

Nilai konkret dark/light variant harus terpusat di theme/token layer.

## 33.5 Theme Architecture

Minimum theme architecture:

`Design Tokens -> Theme -> Component styles -> Screen composition`

Screen tidak boleh menjadi tempat utama untuk mendefinisikan warna, radius, atau spacing arbitrary.

Perubahan visual global harus dapat dilakukan dari token/theme layer dengan surface area yang kecil.

## 33.6 Light and Dark Mode

Prokopa harus mendukung theme yang konsisten dengan operating system dan pengaturan lokal pengguna.

Logo dapat menggunakan asset dark-mode yang sesuai:

`prokopa-darkmode.svg`

Dark mode bukan sekadar membalik warna. Semua semantic pair harus diperiksa ulang untuk contrast dan hierarchy.

## 33.7 Token Naming

Gunakan nama semantic, bukan nama visual yang terlalu literal.

Lebih baik:

```text
brand.primary
surface.primary
text.secondary
semantic.success
```

Daripada:

```text
blue500
white2
lightGrey3
```

Tujuannya agar implementation tetap stabil bila visual palette disempurnakan.

## 33.8 Component Token Contract

Setiap reusable component harus mengambil token dari theme.

Contoh contract:

```text
HabitCard
  -> spacing tokens
  -> radius tokens
  -> text tokens
  -> semantic state tokens
  -> interaction tokens
```

Tidak boleh ada widget yang mendefinisikan ulang brand palette secara lokal tanpa alasan yang terdokumentasi pada design decision.

## 33.9 Iconography

Icon harus:

- konsisten dalam stroke/weight
- mudah dikenali
- tidak menggantikan textual meaning ketika meaning kritis
- tidak menggunakan emoji sebagai icon system

Semua UI symbol harus berasal dari icon asset atau icon set yang disepakati.

## 33.10 Emoji Prohibition

Repository dan aplikasi tidak boleh mengandung emoji.

Larangan berlaku untuk:

- UI strings
- labels
- notifications
- seed data
- mock data
- tests
- accessibility labels
- placeholder text
- docs yang menjadi source untuk generated UI
- analytics/event strings

Emoji tidak digunakan sebagai shortcut visual untuk mood, status, achievement, navigation, atau button label.

---

# 34. Accessibility and Inclusive Interaction

## 34.1 Baseline

Accessibility adalah bagian dari component contract, bukan polish tahap akhir.

Design system menetapkan baseline contrast WCAG 2.2, target touch sekitar 44–48 px, reduced motion, dan dukungan text scaling. fileciteturn2file0L176-L209

## 34.2 Contrast

Target minimum:

- normal text: 4.5:1
- large text: 3:1
- non-text UI where required: 3:1

Semua token light/dark harus divalidasi terhadap background aktual.

## 34.3 Touch Targets

Target minimum praktis:

`44–48 px`

Primary interactive controls dapat menggunakan `56 px` bila layout memungkinkan.

Jangan membuat icon-only control terlalu kecil hanya demi visual density.

## 34.4 Semantic Status

Status harus tersedia melalui lebih dari warna.

Contoh:

`Completed` menggunakan combination:

- icon/state indicator
- label
- color
- optional shape/fill distinction

`Missed` juga tidak boleh hanya dibedakan dengan red tint.

## 34.5 Text Scaling

Text harus tetap usable ketika system font scale diperbesar.

Layout tidak boleh mengandalkan fixed height yang menyebabkan:

- text clipping
- overlap
- hidden labels
- inaccessible buttons

Journal body adalah area yang paling penting untuk tetap nyaman pada ukuran text besar.

## 34.6 Screen Reader Semantics

Setiap interactive element harus memiliki semantic name yang jelas.

Jangan mengandalkan visual icon untuk menyampaikan action.

Contoh:

```text
Semantics label: Tandai Read 5 pages sebagai selesai
```

Bukan:

```text
Semantics label: Circle
```

## 34.7 Focus Order

Keyboard/focus navigation bila tersedia harus mengikuti reading order dan task order.

Fokus tidak boleh melompat secara acak ke hidden element atau decorative component.

## 34.8 Reduced Motion

User dengan reduced motion harus tetap memperoleh informasi state change tanpa animation dependency.

Motion penting harus memiliki non-motion equivalent:

`animated completion -> visible state change + updated label`

## 34.9 Cognitive Accessibility

Copy harus mengurangi ambiguity.

Avoid:

- vague labels
- overloaded dashboards
- unexplained icons
- hidden state transitions
- unexpected destructive actions

Prefer:

- explicit action labels
- stable navigation
- predictable placement
- consistent terminology

## 34.10 Error Accessibility

Error tidak boleh hanya ditampilkan melalui warna atau toast yang cepat hilang.

Field-level error harus dapat dibaca screen reader dan terlihat cukup lama untuk dipahami.

Untuk critical failure, gunakan persistent inline message atau dialog yang jelas.

## 34.11 Privacy Accessibility

Accessibility tidak boleh membocorkan konten private.

Screen reader semantics pada locked screen harus sama minimnya dengan visual locked UI.

Jangan memasukkan isi journal ke accessibility label untuk tombol generik.

## 34.12 Motion Accessibility

Motion token harus menyediakan reduced-motion variant.

Default motion mengikuti scale:

`80 / 120 / 160 / 220 / 300 ms`.

Durasi lebih panjang hanya digunakan ketika perubahan memang membutuhkan orientasi spasial. fileciteturn2file1L366-L450

---

# 35. Interaction, Motion, and Feedback

## 35.1 Purpose

Interaction harus memperjelas hubungan:

`user action -> system response -> updated state`

Motion bukan reward spectacle.

Motion digunakan untuk menjelaskan perubahan state, hierarchy, dan continuity.

Design system menyatakan motion seharusnya menjelaskan state change dan bukan memaksimalkan engagement. fileciteturn4file7L1126-L1157

## 35.2 Interaction States

Minimum interactive states:

`Default -> Hover -> Pressed -> Focus -> Selected -> Disabled -> Loading -> Error`

Touch-first interface tetap harus memiliki pressed/selected feedback yang jelas meskipun hover tidak relevan pada device tertentu.

## 35.3 Press Feedback

Primary actions harus merespons secara langsung terhadap tap.

Feedback minimum dapat berupa:

- state change
- subtle scale/elevation adjustment
- color/surface transition
- platform haptic bila appropriate

Jangan menggunakan motion besar untuk setiap tap.

## 35.4 Habit Completion Interaction

Completion harus low friction:

`Tap completion control -> update canonical completion state -> subtle visual feedback -> update progress`

Design system secara eksplisit mendorong tap langsung tanpa modal/full-screen interruption dan tanpa confetti sebagai default. fileciteturn2file3L805-L851

Optional note/mood/duration dapat dilakukan setelah completion tanpa menghalangi primary completion.

## 35.5 Completion Feedback

Feedback completion harus:

- cukup terlihat untuk mengonfirmasi
- cukup singkat agar tidak mengganggu flow
- tidak menciptakan pressure untuk mengulang action demi animation

Contoh state:

```text
Due -> Completed
```

Perubahan dapat diikuti dengan:

- subtle check transition
- progress recalculation
- short haptic

Tidak:

- fullscreen celebration
- confetti burst
- loud sound
- forced achievement modal

## 35.6 Journal Autosave Interaction

Journal editor harus meminimalkan anxiety terhadap data loss.

State indicator:

`Saving… -> Tersimpan di perangkat`

Jika save gagal:

`Gagal menyimpan -> Coba lagi`

Draft tetap dipertahankan bila recovery memungkinkan.

## 35.7 Navigation Motion

Navigation transition harus membantu user memahami spatial continuity.

Gunakan transition ringan.

Jangan memakai dramatic animation antar-tab yang membuat app terasa lambat.

Bottom navigation harus mempertahankan sense of place tanpa over-animation.

## 35.8 Modal Rules

Modal/dialog hanya untuk:

- destructive confirmation
- focused decision
- permission explanation bila diperlukan
- critical blocking issue

Jangan menggunakan modal untuk:

- setiap habit completion
- success acknowledgement sederhana
- low-value informational copy
- upsell

## 35.9 Bottom Sheet Rules

Bottom sheet dapat digunakan untuk:

- quick actions
- filters
- contextual options
- habit adjustment actions

Sheet harus tetap mempertahankan primary context.

Action count harus dibatasi agar pengguna tidak menghadapi list pilihan yang terlalu besar.

## 35.10 Haptic Feedback

Haptic bersifat optional dan semantic.

Layak digunakan untuk:

- completion confirmation
- important toggle state
- destructive confirmation acknowledgement

Tidak digunakan secara terus-menerus untuk setiap minor visual change.

System setting untuk haptic/reduced motion harus dihormati sejauh platform memungkinkan.

## 35.11 Notification Interaction

Notification click harus membuka konteks yang tepat.

Contoh:

`Habit reminder -> Today -> relevant habit`

`Evening reflection -> Journal -> new reflection context`

Notification tidak boleh membuka screen yang tidak terkait hanya untuk meningkatkan app opens.

## 35.12 Recovery Interaction

Setelah lapse, UI harus mengutamakan return-to-action.

Flow:

`Notice lapse -> present neutral state -> offer adjustment -> continue`

Bukan:

`Notice lapse -> emphasize lost streak -> guilt -> forced restart`

## 35.13 Progress Interaction

Progress UI boleh memiliki micro-animation saat angka berubah, tetapi perubahan harus tetap terbaca tanpa motion.

Contoh:

`4/5 -> 5/5`

Label harus berubah secara deterministik walaupun animation disabled.

## 35.14 Achievement Interaction

Achievement unlocked tidak boleh memblokir core task.

Prefer:

`small inline confirmation -> optional details`

Daripada:

`fullscreen celebration -> mandatory dismiss -> unrelated upsell`

Achievement tetap menjadi pendukung reflection/progress dan bukan pusat engagement.

## 35.15 Animation Budget

Setiap screen harus memiliki animation budget yang konservatif.

Prioritas:

1. state clarity
2. hierarchy
3. spatial continuity
4. delight

Delight tidak boleh mengorbankan tiga prioritas sebelumnya.

## 35.16 Motion Timing

Gunakan:

- 80 ms: immediate feedback
- 120 ms: micro transition
- 160 ms: small component transition
- 220 ms: standard navigation/component transition
- 300 ms: larger contextual transition

Durasi harus disesuaikan dengan device performance dan reduced-motion preference. fileciteturn2file1L366-L450

## 35.17 No Fake Progress

Animation tidak boleh menyiratkan progress yang tidak terjadi.

Contoh terlarang:

- progress bar bergerak sebelum habit commit berhasil
- success animation muncul sebelum save committed
- “restored” animation sebelum verification

UI harus mengikuti canonical state dari Part 6.

## 35.18 Offline Feedback

Karena produk local-only, aplikasi tidak perlu menampilkan network error untuk operasi inti.

Tidak ada:

```text
Offline mode
Trying to reconnect
Syncing…
```

sebagai status rutin.

Operasi core dianggap native-to-device.

Status yang relevan adalah status local persistence:

```text
Tersimpan di perangkat
Gagal menyimpan
Memulihkan draft
```

## 35.19 Interaction Consistency

Action yang sama harus memiliki feedback yang sama lintas screen.

Contoh:

- complete habit selalu menggunakan completion interaction yang konsisten
- delete selalu memiliki destructive affordance yang konsisten
- save status journal selalu menggunakan wording/status yang konsisten
- back navigation tidak boleh memiliki behavior berbeda-beda tanpa alasan

## 35.20 Completion Criteria for Part 7

Part 7 dianggap terpenuhi apabila:

- semua major feature memiliki defined loading, empty, error, dan recovery state yang relevan
- local save status dapat dibedakan dari network sync status
- visual language memiliki token yang terpusat
- brand primary menggunakan identitas Prokopa yang konsisten
- light/dark mode menggunakan semantic tokens
- tidak ada emoji di repository/project scope
- touch target memenuhi baseline 44–48 px
- contrast baseline telah diperiksa
- color bukan satu-satunya semantic indicator
- reduced motion didukung
- habit completion tidak menggunakan blocking celebration
- destructive operation memiliki explicit confirmation
- animation mengikuti canonical state dan tidak menciptakan fake progress

## 35.21 Transition to Next Batch

Sections 31–35 menetapkan bagaimana state data canonical dari Part 6 diwujudkan dalam UI yang konsisten, accessible, calm, dan recoverable.

Batch berikutnya melanjutkan ke fondasi implementasi:

`36. Performance and Offline-Native Runtime`
`37. Flutter Architecture and Local Persistence Boundary`
`38. Clean Code and Engineering Rules`
`39. Testing Strategy`
`40. Observability and Diagnostics`

Batch berikutnya harus tetap mempertahankan prinsip sederhana: minimum code, surgical changes, local-first, dan tidak menambahkan abstraction tanpa kebutuhan yang dapat diverifikasi.




# 36. Performance, Offline Runtime, and Reliability

## 36.1 Purpose

Prokopa adalah aplikasi local-first sehingga kualitas pengalaman tidak boleh bergantung pada kualitas koneksi internet. Pengguna harus dapat membuka, membaca, menulis, menyelesaikan habit, meninjau progress, menulis jurnal, melakukan review, dan mengelola data tanpa network dependency.

Performance bukan sekadar target teknis. Untuk aplikasi habit dan journaling, delay yang panjang menambah friction pada tindakan yang seharusnya singkat. Produk harus terasa cepat terutama pada dua aktivitas inti: completion habit dan journal capture.

## 36.2 Performance Principles

### 36.2.1 Local by Default

Read path untuk data utama menggunakan local persistence.

Write path utama juga menggunakan local persistence.

Tidak ada request jaringan yang menjadi prasyarat untuk:

- membuka Today
- melihat habit
- menandai habit selesai
- mengubah status habit
- membuka journal
- membuat draft journal
- menyimpan journal
- melihat progress
- melihat review
- melihat insights lokal
- membuka Profile
- melakukan export
- melakukan import lokal

## 36.3 Startup Requirements

Aplikasi harus memprioritaskan first usable frame daripada memuat seluruh analitik sekaligus.

Urutan startup yang diharapkan:

1. bootstrap aplikasi
2. load theme dan brand configuration
3. initialize local database
4. verify schema/version
5. restore required local state
6. render first useful screen
7. load non-critical derived information lazily
8. finish deferred maintenance work bila tersedia

Tidak boleh ada startup yang menunggu kalkulasi analytics berat bila Today dapat ditampilkan tanpa kalkulasi tersebut.

## 36.4 First Useful Render

First useful render berarti pengguna dapat memahami screen dan melakukan tindakan dasar tanpa menunggu modul non-esensial.

Today minimal harus dapat menampilkan:

- tanggal aktif
- habit yang relevan hari itu
- state completion yang sudah tersimpan
- navigasi utama

Elemen tambahan seperti statistik ringkas atau insight preview dapat dimuat setelah content utama tersedia.

## 36.5 Interaction Latency

Aksi completion habit harus terasa immediate.

Urutan yang diharapkan:

1. user taps completion control
2. UI berpindah ke state pressed/active
3. domain command dijalankan
4. local persistence diperbarui
5. derived state diperbarui
6. UI menunjukkan completion

Tidak boleh ada modal confirmation untuk completion normal.

Bila persistence memerlukan waktu, optimasi UX boleh menggunakan optimistic visual update hanya jika sistem memiliki jalur rollback yang deterministik dan tidak memungkinkan data palsu bertahan. Untuk implementasi awal, local transaction yang singkat lebih disukai daripada speculative optimism.

## 36.6 Journal Save Responsiveness

Journal adalah input yang dapat panjang dan bersifat sensitif. Pengguna tidak boleh kehilangan teks karena perpindahan screen, app backgrounding, atau lifecycle event yang normal.

Autosave harus:

- berjalan lokal
- tidak membuat cursor jump
- tidak memblokir typing secara noticeable
- menyimpan draft secara incremental
- menghasilkan state Saved Locally ketika commit berhasil

Status Saving harus singkat dan tidak mengganggu fokus menulis.

## 36.7 Autosave Debouncing

Autosave boleh menggunakan debounce untuk mengurangi write amplification.

Debounce tidak boleh menjadi satu-satunya mekanisme persistence. Save juga harus dipicu pada event penting seperti:

- navigation away
- app lifecycle pause/background
- explicit save action bila tersedia
- closing editor melalui route transition

## 36.8 Read Amplification

Screen tidak boleh menjalankan query identik berulang kali hanya karena beberapa widget meminta data yang sama.

Data yang sama dalam satu screen harus berasal dari state holder atau query result yang dapat digunakan kembali ketika tidak mengorbankan correctness.

Abstraksi tidak boleh dibuat hanya untuk menghindari satu query kecil. Optimasi harus berbasis profiling atau bottleneck yang terverifikasi.

## 36.9 Derived Metrics

Metric seperti completion rate, weekly consistency, repetition count, streak, recovery count, monthly rhythm, dan insight harus dihitung dari canonical data.

Derived values tidak boleh menjadi sumber kebenaran alternatif yang dapat menyimpang dari event historis.

Cache derived metric boleh digunakan ketika:

- invalidation rule jelas
- canonical data tetap tersedia
- stale state dapat dideteksi
- rebuild dapat dilakukan

## 36.10 Pagination and Long Journals

Journal list harus mempertimbangkan jumlah entry besar.

Implementasi awal harus mampu menangani koleksi yang berkembang tanpa memuat seluruh body journal ke memory setiap kali daftar dibuka.

List screen sebaiknya memuat metadata yang dibutuhkan untuk preview. Full body hanya dimuat ketika entry dibuka.

## 36.11 Search Performance

Search journal harus menggunakan data yang relevan secara efisien.

Tahap awal dapat menggunakan database query sederhana apabila ukuran data realistis masih kecil.

Full-text indexing hanya diterapkan jika profiling menunjukkan query teks menjadi bottleneck nyata atau dataset tumbuh cukup besar.

Tidak boleh membangun search engine kompleks secara speculative.

## 36.12 Calendar and Heatmap Performance

Calendar dan heatmap menggunakan aggregate yang sudah tersedia atau query terarah.

Screen tidak boleh membuat object domain baru untuk setiap pixel/calendar cell secara berlebihan.

Periode yang ditampilkan harus terbatas pada kebutuhan viewport atau period selector.

## 36.13 Insights Performance

Insight lokal harus dihitung secara deterministic.

Insight tidak boleh menyebabkan app startup tertahan.

Perhitungan dapat dijalankan:

- saat screen dibuka
- saat data relevan berubah
- secara lazy
- secara cached jika invalidation jelas

Tidak diperlukan background analytics service kompleks pada versi awal.

## 36.14 Notification Reliability

Local reminder bergantung pada kemampuan dan policy OS, bukan pada server aplikasi.

App harus menyimpan sumber konfigurasi reminder di local database sehingga schedule dapat dibangun ulang ketika diperlukan.

Notification state tidak boleh dianggap sebagai canonical evidence bahwa user membaca atau melakukan habit.

## 36.15 App Lifecycle

Lifecycle events yang harus dipertimbangkan:

- cold start
- foreground resume
- background pause
- process termination
- device restart bila OS mendukung recovery

Data penting harus sudah tersimpan sebelum lifecycle state yang berisiko menyebabkan termination tanpa callback lanjutan.

## 36.16 Offline Runtime Contract

Istilah offline di Prokopa berarti normal operating mode, bukan degraded mode.

UI tidak perlu menampilkan banner “Offline” secara global hanya karena tidak ada jaringan.

Network permission tidak dibutuhkan untuk core features local-only.

Tidak ada state `sync pending` atau `waiting for server`.

## 36.17 Reliability Rules

Local write harus atomic sejauh kemampuan database yang digunakan.

Operasi multi-record yang secara domain harus konsisten harus menggunakan transaction.

Contoh:

- completion dan associated completion metadata
- import batch
- restore snapshot
- delete data dalam scope yang ditentukan
- schema migration

## 36.18 Recovery After Crash

Setelah force close atau crash pada lifecycle normal, aplikasi harus dapat membuka database tanpa kehilangan data yang telah committed.

Draft journal yang sudah dipersist harus dapat dipulihkan.

State UI sementara tidak perlu dipulihkan kecuali memang merupakan bagian dari product requirement.

## 36.19 Memory Discipline

Tidak boleh menyimpan entire journal corpus di memory hanya untuk memungkinkan navigasi normal.

Image asset tidak boleh di-load dalam resolusi yang lebih besar dari kebutuhan tampilan.

Object lifetime harus mengikuti scope screen/domain dan tidak membuat global singleton untuk data yang tidak benar-benar global.

## 36.20 Battery Discipline

Prokopa tidak boleh menjalankan polling background.

Tidak ada continuous telemetry loop.

Tidak ada background network synchronization.

Local reminder scheduling menggunakan mekanisme OS yang sesuai, bukan timer Dart yang berjalan terus-menerus.

## 36.21 Performance Budget Concept

PRD ini menetapkan arah budget, bukan mengunci angka tanpa profiling device target.

Baseline verification harus dilakukan pada:

- device Android kelas menengah
- device Android kelas bawah yang realistis
- release build

Screen kritis untuk profiling:

- startup
- Today
- Journal list
- Journal editor
- Progress
- Insights

## 36.22 Performance Acceptance

Produk dianggap memenuhi performance contract ketika:

- core screen usable tanpa network
- completion habit tidak memerlukan confirmation modal
- typing journal tidak terputus oleh autosave
- database write tidak menghasilkan freeze yang jelas
- list journal tetap usable saat data bertambah
- insight calculation tidak menghalangi first useful render
- app reopen setelah termination mempertahankan committed data

---

# 37. Flutter Architecture

## 37.1 Architectural Intent

Architecture Prokopa harus cukup jelas untuk menjaga domain logic, persistence, UI, dan platform integration tetap terpisah, tetapi tidak boleh menjadi framework architecture yang berlebihan.

Aturan utama:

- domain rules tidak ditanam di widget
- persistence detail tidak menyebar ke seluruh UI
- UI tidak mengubah database secara sembarang
- state transition harus dapat diuji
- dependency harus bergerak menuju lapisan yang lebih stabil

## 37.2 Recommended Layers

Struktur konseptual minimum:

```text
Presentation
    ↓
Application / Use Cases
    ↓
Domain
    ↓
Data / Persistence
    ↓
Platform
```

Tidak semua feature membutuhkan folder untuk setiap layer apabila complexity-nya kecil. Layer adalah boundary konseptual, bukan alasan membuat banyak file.

## 37.3 Presentation Layer

Presentation bertanggung jawab terhadap:

- rendering UI
- user interaction
- visual state
- navigation intent
- accessibility semantics
- loading/error/empty presentation

Presentation tidak bertanggung jawab langsung terhadap SQL atau file serialization.

## 37.4 Application Layer

Application layer mengorkestrasi use case.

Contoh use case:

- complete habit
- skip habit
- pause habit
- create habit
- edit habit
- save journal
- restore draft
- create review
- export backup
- import backup
- lock app

Tidak semua command perlu class terpisah. Function/service sederhana diperbolehkan jika jumlah logic masih kecil dan boundary tetap jelas.

## 37.5 Domain Layer

Domain berisi rule yang menentukan makna data.

Contoh:

- frequency semantics
- completion semantics
- missed vs no-plan
- streak semantics
- weekly target calculation
- pause behavior
- recovery count
- review period boundaries
- achievement criteria
- insight eligibility

Domain logic tidak boleh tergantung widget Flutter.

## 37.6 Data Layer

Data layer bertanggung jawab terhadap:

- database
- repositories
- serializers
- backup file format
- migration
- transactional persistence

Repository tidak boleh mengubah product semantics secara diam-diam.

## 37.7 Platform Layer

Platform integration mencakup:

- local notifications
- biometric/PIN lock
- secure key/value storage jika diperlukan
- filesystem picker
- share sheet/export destination
- device lifecycle integration

Platform layer harus memiliki interface yang dapat di-mock atau di-fake untuk test.

## 37.8 Dependency Direction

Komponen domain tidak boleh mengimpor Flutter UI classes.

Komponen domain tidak boleh mengetahui package database spesifik bila dependency dapat dihindari.

Presentation boleh bergantung pada application abstraction.

Data implementation boleh bergantung pada domain contract.

## 37.9 State Management

State management dipilih berdasarkan kompleksitas nyata project.

Kriteria minimum:

- state transition jelas
- rebuild terkontrol
- testable
- tidak membutuhkan boilerplate berlebihan
- tidak menyimpan domain state hanya di widget lokal ketika state diperlukan lintas screen

Jangan memasukkan state management library kedua hanya untuk satu feature.

## 37.10 Navigation

Navigation harus mengikuti information architecture yang telah didefinisikan.

Core destinations:

- Today
- Journal
- Progress
- Insights
- Profile

Detail/editor screen berada di atas destination, bukan menjadi bottom navigation item tambahan kecuali ada kebutuhan product yang jelas.

## 37.11 Routing Contract

Route argument harus menggunakan identifier yang stabil.

Jangan mengoper object database mutable ke banyak screen sebagai default.

Screen detail menerima identifier atau immutable view model sesuai kebutuhan.

## 37.12 Domain Commands

Command yang mengubah state harus dapat dijelaskan sebagai operasi bisnis.

Contoh:

`CompleteHabit(habitId, date)`

bukan:

`UpdateHabitRowWithBoolean(true)`

Detail persistence tidak boleh menjadi bahasa utama domain.

## 37.13 Read Models

Untuk screen yang membutuhkan banyak aggregate sederhana, read model khusus diperbolehkan.

Read model harus tetap derived dan tidak menggantikan canonical storage.

Read model sebaiknya dibuat ketika:

- query terlalu kompleks untuk UI
- beberapa source perlu digabung
- screen membutuhkan shape khusus

## 37.14 Repository Boundary

Repository menyediakan operasi yang relevan terhadap domain.

Contoh:

- getTodayHabits
- saveJournalEntry
- getJournalEntries
- getHabitHistory
- getReviewPeriodData

Repository tidak sebaiknya mengekspos raw SQL ke presentation.

## 37.15 Transaction Boundary

Transaction ditetapkan pada operation yang harus all-or-nothing.

Transaction tidak perlu membungkus setiap read biasa.

Import dan restore harus transactional sejauh desain format memungkinkan.

## 37.16 Serialization Boundary

Internal domain model dan export schema tidak harus identik.

Backup format harus memiliki version field sendiri.

Perubahan internal class tidak boleh otomatis dianggap perubahan backup contract.

## 37.17 Time Handling

Tanggal habit dan journaling harus mengikuti semantics local date yang didefinisikan produk.

Timestamp internal harus memiliki definisi yang jelas.

Jangan menggunakan string tanggal dengan interpretasi berbeda di setiap feature.

Cross-midnight sleep harus menggunakan start/end semantics yang sudah ditetapkan.

## 37.18 Idempotency

Command yang secara user experience dapat dipanggil ulang harus aman dari duplicate side effects.

Contoh:

- grant achievement
- grant XP
- import record dengan identity conflict
- restore
- schedule notification

## 37.19 No Hidden Global State

Global mutable state hanya boleh digunakan untuk concern yang benar-benar global seperti app configuration atau dependency registry yang disepakati.

Data habit/journal tidak disimpan dalam singleton global hanya demi kemudahan.

## 37.20 Error Model

Error domain harus dapat dibedakan dari technical error.

Contoh:

- invalid habit frequency = domain validation
- database locked = infrastructure failure
- malformed backup = import validation error
- biometrics unavailable = platform capability issue

Presentation memetakan error menjadi user-facing message tanpa menampilkan stack trace.

## 37.21 Feature Foldering

Struktur berbasis feature direkomendasikan agar perubahan lebih surgical.

Contoh konseptual:

```text
features/
  today/
  journal/
  progress/
  insights/
  profile/
  habits/
```

Shared code hanya masuk common/shared ketika memang dipakai lintas feature dan memiliki semantic boundary yang stabil.

## 37.22 Avoid Premature Abstraction

Jangan membuat base repository, generic use case hierarchy, abstract factory, service locator berlapis, atau adapter generik tanpa kebutuhan nyata.

Prinsip ini mengikuti AGENTS.md: minimum code, tidak membuat abstraksi speculative, dan perubahan harus surgical. fileciteturn3file0L7-L25

## 37.23 Widget Discipline

Widget yang hanya bertanggung jawab atas layout tidak boleh memiliki business rule kompleks.

Widget besar harus dipecah ketika:

- sulit diuji
- state lokal bertabrakan
- rebuild terlalu luas
- accessibility menjadi sulit dipelihara

Pemecahan file bukan tujuan. Readability dan correctness adalah tujuan.

## 37.24 UI State Source

Visual state harus berasal dari state yang dapat dilacak.

Tidak diperbolehkan:

- mengubah warna hanya karena callback tertentu tanpa update domain state
- menampilkan Saved padahal write belum commit
- menampilkan completion padahal command gagal

## 37.25 Async Discipline

Async operation harus memiliki:

- lifecycle safety
- cancellation atau stale-result protection bila relevan
- error handling
- loading state bila durasi terlihat user

Jangan update widget state setelah screen dispose.

## 37.26 Testability Requirement

Setiap domain rule penting harus dapat diuji tanpa rendering seluruh app.

Setiap feature kritis harus memiliki setidaknya satu integration-level test yang memverifikasi jalur persistence nyata atau test environment equivalent.

## 37.27 Architecture Success Criteria

Architecture dianggap cukup baik ketika:

- domain rules dapat diuji tanpa widget
- database implementation dapat diganti pada test
- UI tidak mengetahui SQL details
- import/export dapat diuji tanpa manual UI interaction
- notification scheduling dapat di-fake
- perubahan feature tidak memaksa rewrite unrelated feature

---

# 38. Clean Code and Engineering Rules

## 38.1 Source of Truth

Product semantics berasal dari PRD dan design source yang disepakati.

Code tidak boleh menciptakan behavior baru hanya karena implementor menganggapnya “lebih engaging”.

## 38.2 Follow AGENTS.md

Aturan engineering harus mengikuti AGENTS.md:

- jangan berasumsi tanpa dasar
- surface tradeoff
- utamakan kesederhanaan
- lakukan perubahan surgical
- definisikan success criteria yang dapat diverifikasi

fileciteturn3file0L7-L25

## 38.3 No Vibe Coding

Implementasi tidak boleh dimulai dengan menulis banyak file sebelum boundary dan success criteria jelas.

Urutan minimal:

1. baca requirement terkait
2. identifikasi assumption
3. tentukan perubahan minimum
4. implementasikan
5. jalankan verification
6. perbaiki hanya failure yang relevan

## 38.4 No Speculative Features

Jangan menambahkan:

- account system
- social feed
- cloud sync
- leaderboard
- public profile
- ads
- AI chat
- unnecessary analytics
- gamification yang tidak ada di scope

hanya karena library atau template menyediakan feature tersebut.

## 38.5 Naming

Nama harus mencerminkan domain.

Contoh yang baik:

- `HabitFrequency`
- `JournalEntry`
- `CompletionStatus`
- `RecoveryAction`
- `WeeklyReview`

Hindari nama generik seperti:

- `DataManager2`
- `ThingHelper`
- `CommonService`
- `UtilsManager`

kecuali memang semantic-nya benar-benar jelas.

## 38.6 No Unnecessary Comments

Repository harus bebas dari komentar kode yang tidak diperlukan.

Code harus dijelaskan melalui naming dan structure.

Komentar hanya dipertimbangkan untuk constraint eksternal yang tidak dapat direpresentasikan dengan code secara jelas.

## 38.7 No Emoji in Repository

Tidak boleh ada emoji pada repository/project.

Larangan mencakup:

- UI strings
- seed data
- fixtures
- test strings
- sample journal
- notifications
- accessibility labels
- documentation dalam repository
- error messages

Status dan tone harus dibentuk melalui copy, spacing, iconography non-emoji, typography, dan semantic color.

## 38.8 Formatting

Gunakan formatter/linter resmi stack Flutter yang dipilih project.

Jangan melakukan manual formatting yang bertentangan dengan formatter.

CI harus dapat menjalankan formatter check atau equivalent verification.

## 38.9 Null Safety

Null safety harus digunakan dengan makna yang jelas.

Jangan mengubah seluruh nilai optional menjadi nullable hanya untuk memudahkan parsing.

Gunakan required field jika domain memang membutuhkan field tersebut.

## 38.10 Error Handling

Tangkap error pada boundary yang dapat mengambil tindakan yang benar.

Jangan:

- catch semua exception lalu diam
- menampilkan raw exception kepada user
- mengubah error menjadi success palsu

## 38.11 Logging

Logging hanya untuk diagnostic value.

Jangan log:

- full journal body
- sensitive notes
- PIN
- biometric details
- backup contents
- private mood context yang tidak diperlukan

## 38.12 Secrets

Jangan menyimpan secret sebagai hard-coded value.

Core app seharusnya tidak membutuhkan API key untuk fungsi local-only.

## 38.13 Local Storage

Persistence schema harus explicit.

Nama field, default, migration, dan nullable behavior harus terdokumentasi dalam code structure atau schema definition yang menjadi sumber kebenaran.

## 38.14 Migration Discipline

Schema migration harus:

- memiliki version
- deterministic
- dapat diuji
- tidak bergantung internet
- menjaga data lama sejauh contract mengharuskan

Tidak boleh mengubah schema secara diam-diam hanya karena app version berubah tanpa migration strategy.

## 38.15 Data Deletion

Delete semantics harus eksplisit.

Contoh:

- delete one journal entry
- delete selected data
- delete all data
- archive habit

Archive tidak boleh diam-diam berarti delete.

## 38.16 Import Validation

Import harus memvalidasi:

- file structure
- backup version
- required fields
- identifier validity
- date validity
- enum values
- relationship integrity

File invalid tidak boleh masuk partial state kecuali feature secara eksplisit memiliki transactional partial-import semantics.

## 38.17 Backup Compatibility

Backup version harus diperlakukan sebagai contract.

App yang lebih baru boleh mempertahankan importer untuk backup version sebelumnya bila product scope mendukung.

Jika backup version tidak didukung, user harus mendapat error yang jelas dan data aktif tidak boleh rusak.

## 38.18 Date and Time Tests

Test wajib mencakup:

- timezone boundary yang relevan
- month boundary
- year boundary
- week boundary
- cross-midnight sleep
- daylight saving behavior bila platform/timezone target memerlukannya

## 38.19 Locale

User-facing date and number formatting harus mengikuti locale yang dipilih/tersedia.

Canonical storage tidak boleh berubah hanya karena locale UI berubah.

## 38.20 Accessibility in Code

Semantics harus diberikan pada interactive control.

Tap target tidak boleh bergantung pada visual size saja.

Text scaling tidak boleh dinonaktifkan tanpa alasan product yang jelas.

## 38.21 Copy Discipline

UI copy harus konsisten dengan principles:

- calm
- non-judgmental
- autonomy-supportive
- recovery-first

Jangan memperkenalkan copy “failed as a person”, “don’t break your streak”, atau urgency yang memaksa.

Design source secara eksplisit menekankan bahwa streak adalah momentum signal, bukan threat, dan missed day harus dapat diperlakukan netral. fileciteturn2file3L855-L904

## 38.22 Git Hygiene

Perubahan harus kecil dan dapat ditelusuri.

Jangan mencampur:

- feature work
- broad refactor
- unrelated formatting
- asset migration

dalam perubahan yang sama kecuali memang saling diperlukan.

## 38.23 Dependency Discipline

Dependency baru harus memiliki alasan yang nyata.

Pertanyaan minimum sebelum menambah package:

1. kebutuhan apa yang diselesaikan
2. mengapa Flutter/Dart standard tidak cukup
3. apakah package aktif dan sesuai target platform
4. apa biaya maintenance dan ukuran binary

## 38.24 Package Surface

Hindari dependency yang membawa feature yang tidak digunakan.

Local-only architecture seharusnya membuat dependency graph relatif sederhana.

## 38.25 Code Review Gate

Pull request/changeset harus dapat menjawab:

- requirement mana yang diimplementasikan
- file utama yang berubah
- test apa yang ditambahkan
- bagaimana failure case diverifikasi
- apakah ada behavior baru di luar scope

## 38.26 Engineering Success Criteria

Code dianggap memenuhi contract ketika:

- no emoji ada di repository
- no unwanted auth/cloud dependency ada di core
- business rules dapat di-trace ke requirement
- formatter/linter bersih
- tests untuk critical rules tersedia
- failures tidak disilent
- change surface tetap terkontrol

---

# 39. Testing Strategy

## 39.1 Testing Philosophy

Testing Prokopa harus memverifikasi makna behavior, bukan hanya screenshot atau line coverage.

Prioritas testing mengikuti risk:

1. data integrity
2. habit semantics
3. journal persistence
4. backup/restore
5. privacy/app lock
6. review/insight correctness
7. navigation/UI behavior
8. visual regression

## 39.2 Test Pyramid

Gunakan kombinasi:

- unit tests
- repository/data tests
- integration tests
- widget tests
- targeted end-to-end tests

Jangan membuat seluruh suite menjadi end-to-end karena mahal dan lambat.

## 39.3 Unit Test Scope

Unit test harus mencakup domain rules yang berisiko salah.

Minimum:

- frequency calculation
- completion state
- weekly target
- streak semantics
- no-plan vs missed
- pause
- skip
- recovery
- completion rate
- review period
- achievement criteria
- insight eligibility
- XP idempotency

## 39.4 Habit Completion Tests

Test minimal:

- completion berubah dari incomplete menjadi complete
- completion ulang tidak menggandakan event
- reverse completion hanya terjadi bila product flow mengizinkan
- historical date tetap dapat ditampilkan sesuai policy
- completion tidak mengubah habit definition

## 39.5 Frequency Tests

Daily harus dievaluasi terhadap daily expectation.

Specific days hanya menghitung planned dates.

X times/week harus mengevaluasi target minggu.

Interval harus memakai interval rule yang ditentukan.

Custom harus mematuhi custom schedule tanpa fallback ke daily semantics.

## 39.6 Streak Tests

Test:

- consecutive completion
- missed planned day
- no-plan day
- paused period
- weekly target completion
- week boundary
- recovery after lapse

Streak tidak boleh reset hanya karena membuka atau tidak membuka app.

## 39.7 Recovery Tests

Test bahwa lapse memungkinkan action:

- continue
- reduce target
- change cue
- pause

Recovery count hanya meningkat ketika kriteria recovery terpenuhi.

## 39.8 Journal Tests

Test:

- create entry
- edit entry
- autosave
- restore draft
- save failure
- search metadata
- filter
- delete
- duplicate-safe identity
- ordering

Journal body harus tetap private dan tidak dikirim ke external service.

## 39.9 Journal Draft Recovery

Simulasikan:

1. create draft
2. type content
3. persist draft
4. terminate editor/process
5. reopen editor
6. verify same draft can be recovered

## 39.10 Mood Tests

Test bahwa mood adalah self-report label/scale sesuai product definition.

Tidak ada logic yang mengubah mood menjadi diagnosis.

Tidak ada insight yang menyatakan sebab hanya karena dua variabel berkorelasi.

## 39.11 Sleep Tests

Test cross-midnight sessions.

Contoh:

start 23:30, end 07:00 → duration dihitung melewati midnight.

Invalid end before start harus diperlakukan berdasarkan model overnight yang benar, bukan menghasilkan durasi negatif diam-diam.

## 39.12 Review Tests

Weekly review harus memakai exact period semantics.

Monthly review harus memakai bulan kalender yang benar.

Preview dan summary tidak boleh mencampur data dari period lain.

## 39.13 Calendar Tests

Pastikan state berbeda untuk:

- completed
- partial
- skipped
- no-plan
- missed

No-plan tidak boleh diwarnai atau dihitung sebagai missed.

## 39.14 Insight Tests

Setiap insight harus diuji pada:

- insufficient data
- sufficient data
- conflicting data
- edge period
- zero occurrences
- threshold boundary

Weak evidence harus menghasilkan no insight, bukan fabricated insight.

## 39.15 Gamification Tests

Achievement harus diberikan tepat ketika criteria terpenuhi.

XP harus idempotent.

Level calculation harus konsisten dengan canonical formula.

Tidak boleh ada XP hanya karena membuka app.

Tidak ada leaderboard state yang perlu diuji karena tidak termasuk scope.

## 39.16 Notification Tests

Test configuration persistence dan schedule calculation secara lokal.

Test bahwa disable reminder benar-benar menghapus atau menonaktifkan schedule yang relevan.

Notification content tidak boleh memasukkan data jurnal pribadi.

## 39.17 Privacy Tests

Test:

- lock enabled
- lock disabled
- failed unlock
- lock on resume sesuai policy
- private data hidden when locked
- no sensitive preview in notification

## 39.18 App Lock Tests

Jika PIN digunakan:

- set PIN
- confirm PIN
- change PIN
- invalid PIN
- lockout policy jika ada
- delete/reset flow

PIN tidak boleh tersimpan sebagai plain text.

## 39.19 Backup Tests

Test export menghasilkan file yang:

- valid schema
- versioned
- complete terhadap data in-scope
- importable

Test bahwa export failure tidak menghapus local data.

## 39.20 Import Tests

Test:

- valid backup
- malformed file
- unsupported version
- duplicate IDs
- conflicting records
- corrupted field
- missing required field
- empty backup

Active database harus tetap valid jika import gagal.

## 39.21 Restore Tests

Restore harus memverifikasi bahwa data canonical kembali konsisten.

Setelah restore:

- Today benar
- Journal benar
- Progress benar
- Insights dapat dihitung ulang
- achievements tidak double grant

## 39.22 Migration Tests

Untuk setiap migration:

1. seed old schema
2. run migration
3. verify new schema
4. verify preserved data
5. verify indexes/constraints yang diperlukan

## 39.23 Repository Tests

Repository test harus memverifikasi mapping antara domain object dan local persistence.

Fokus:

- create
- read
- update
- delete
- query by period
- transaction
- ordering

## 39.24 Widget Tests

Widget tests memverifikasi behavior yang terlihat user.

Contoh:

- tap completion control
- save button state
- empty journal state
- error retry
- pause dialog
- filter selection
- locked state

Jangan membuat widget test mengandalkan implementation detail seperti exact internal provider call count kecuali itu memang kontrak.

## 39.25 Navigation Tests

Test major flow:

- launch → Today
- Today → Habit detail
- Today → Journal
- Journal → Entry
- Journal → New Entry
- Today → Progress
- Today → Insights
- Today → Profile

## 39.26 Accessibility Tests

Checklist automated/manual:

- semantics labels
- focus order
- scalable text
- sufficient contrast
- target size
- state not conveyed by color only

Design source menetapkan baseline contrast 4.5:1 untuk normal text dan practical touch target 44–48 px. fileciteturn2file0L176-L209

## 39.27 Visual Regression

Gunakan visual regression hanya pada screen dan component yang stabil.

Prioritas:

- Today
- Journal editor
- habit card
- bottom navigation
- progress summary
- locked state

Visual tests tidak boleh menggantikan behavior tests.

## 39.28 Device Matrix

Minimum verification matrix harus mempertimbangkan:

- small screen
- medium screen
- large screen
- Android version yang didukung
- reduced motion
- large text
- light mode/dark mode bila kedua mode tersedia

## 39.29 Failure Injection

Simulasikan failure yang realistis:

- database read error
- database write error
- malformed backup
- insufficient filesystem permission
- notification scheduling unavailable
- biometric unavailable
- app terminated during draft save

## 39.30 Regression Test Rule

Setiap bug yang telah diperbaiki dan memiliki risiko repeatable harus menghasilkan regression test sebelum dianggap selesai.

## 39.31 Test Data

Fixture harus:

- deterministic
- tidak mengandung emoji
- tidak mengandung data pribadi nyata
- cukup kecil untuk dipahami
- mencakup edge case

## 39.32 Fake Clock

Time-dependent logic harus dapat diuji dengan controlled clock.

Jangan membuat unit test bergantung pada wall clock saat test dijalankan.

## 39.33 Randomness

Core domain tidak boleh menggunakan random state untuk menentukan outcome penting.

Achievements, progress, metrics, dan insights harus deterministic.

## 39.34 Golden Rules Verification

Test suite harus memverifikasi golden principles berikut:

- missed day bukan moral failure
- no-plan berbeda dari missed
- pause bukan failure
- streak bukan hostage
- recovery tersedia
- mood bukan diagnosis
- insight explainable
- private data tetap local

## 39.35 Coverage Philosophy

Coverage adalah signal, bukan tujuan tunggal.

Critical domain branch yang gagal di coverage harus ditangani bila branch tersebut merepresentasikan product rule nyata.

High line coverage pada generated boilerplate tidak dianggap bukti kualitas.

## 39.36 Test Exit Criteria

Feature dianggap test-complete ketika:

- happy path tervalidasi
- failure path utama tervalidasi
- relevant edge cases tervalidasi
- persistence path tervalidasi
- accessibility baseline tervalidasi untuk UI kritis
- regression risk tertutup

---

# 40. Observability, Diagnostics, and Verification

## 40.1 Purpose

Karena Prokopa tidak menggunakan backend dan tidak memerlukan analytics cloud untuk core behavior, observability harus difokuskan pada kemampuan developer mendiagnosis masalah tanpa mengorbankan privasi user.

## 40.2 Privacy-First Diagnostics

Diagnostic system tidak boleh mengumpulkan isi jurnal sebagai telemetry.

Tidak boleh mengirim:

- journal body
- journal title bila sensitif
- mood note bebas
- habit note bebas
- backup contents
- PIN
- private tags

ke remote analytics atau crash service sebagai default.

## 40.3 Local Diagnostic Logging

Logging lokal dapat digunakan selama development.

Level minimal:

- debug
- info
- warning
- error

Release build harus membatasi debug verbosity.

## 40.4 Structured Diagnostic Context

Log dapat berisi:

- feature
- event type
- operation duration
- local database operation category
- error category
- app version
- schema version

Gunakan identifier anonim atau generated local ID bila diperlukan.

## 40.5 No Sensitive Payloads

Diagnostic event tidak boleh menyimpan raw text pengguna.

Bila perlu menelusuri ukuran atau bentuk data, gunakan metadata seperti:

- character count
- entry count
- record count
- payload size

bukan content.

## 40.6 Performance Tracing

Development profiling harus dapat mengukur:

- startup duration
- query duration
- journal save duration
- export duration
- import duration
- insight calculation duration

Profiling dilakukan untuk menemukan bottleneck, bukan untuk mengejar angka benchmark tanpa konteks.

## 40.7 Crash Handling

Crash yang tidak terduga harus:

- tidak menyebabkan data committed hilang pada restart normal
- dapat direproduksi bila mungkin
- menghasilkan diagnostic context yang aman

Crash report external hanya boleh digunakan bila benar-benar dibutuhkan dan privacy contract telah secara eksplisit mengizinkannya. Core product tidak boleh bergantung pada layanan external tersebut.

## 40.8 Error Taxonomy

Error sebaiknya dikategorikan:

- ValidationError
- PersistenceError
- SerializationError
- MigrationError
- PlatformError
- NotificationError
- SecurityError
- UnknownError

Kategori tidak wajib diwujudkan sebagai class terpisah jika simple enum/value object cukup.

## 40.9 User-Facing Error Contract

User-facing error harus menjawab tiga hal:

1. apa yang terjadi
2. apakah data aman
3. apa tindakan yang tersedia

Contoh struktur:

`Journal belum tersimpan. Draft terakhir tetap tersedia secara lokal. Coba simpan lagi.`

Copy exact dapat disempurnakan saat UI implementation, tetapi semantic contract harus dipertahankan.

## 40.10 Retry Semantics

Retry hanya tersedia bila operation dapat diulang dengan aman.

Contoh cocok:

- failed local write
- failed export
- failed notification scheduling

Retry tidak boleh mengulang side effect yang non-idempotent tanpa protection.

## 40.11 Diagnostics for Import

Import diagnostics harus dapat menjelaskan:

- unsupported file
- unsupported version
- invalid field
- duplicate identifier
- integrity failure

Detail teknis yang tidak membantu user tidak perlu ditampilkan pada UI normal. Developer diagnostics dapat menyimpan category dan stack/context tanpa private payload.

## 40.12 Diagnostics for Migration

Migration failure adalah high-risk state.

Aplikasi harus dapat:

- mengidentifikasi schema version saat ini
- mengetahui migration step yang gagal
- mencegah data corruption
- menampilkan recovery path yang aman

Tidak boleh diam-diam membuka database setengah-migrated sebagai data valid.

## 40.13 Data Integrity Check

Prokopa harus memiliki integrity check yang dapat dijalankan ketika diperlukan.

Check minimal:

- foreign/reference relationships valid
- no impossible state combinations
- no orphan records yang dilarang schema
- IDs unique
- dates valid
- required fields non-null

## 40.14 Startup Integrity Strategy

Integrity verification pada startup harus seimbang dengan performance.

Full deep scan tidak wajib setiap startup bila terlalu mahal.

Strategi dapat berupa:

- schema validation setiap startup
- lightweight integrity checks setiap startup
- deeper repair/diagnostic check on demand

## 40.15 Repair Strategy

Repair tidak boleh menjadi silent data rewrite.

Ketika repair diperlukan, sistem harus:

- menentukan rule repair
- mempertahankan data valid
- mengisolasi record invalid bila memungkinkan
- memberikan diagnostic state
- tidak membuat nilai baru yang tidak memiliki dasar

## 40.16 Recovery UX

Recovery screen harus tenang dan informative.

Jangan menggunakan panic copy.

User harus mengetahui apakah data:

- aman
- sebagian aman
- membutuhkan retry
- membutuhkan restore backup

## 40.17 Developer Verification Loop

Setiap implementasi feature mengikuti loop:

1. define success criteria
2. implement minimum change
3. format
4. static analysis
5. unit tests
6. targeted integration/widget tests
7. manual smoke test
8. inspect diff
9. verify no unintended behavior

Loop ini selaras dengan prinsip goal-driven execution dalam AGENTS.md. fileciteturn3file0L21-L25

## 40.18 Smoke Test Matrix

Smoke test release candidate minimal:

### Core Daily Flow

Launch → Today → complete habit → verify progress → reopen app.

### Journal Flow

Today/Journal → new entry → type → autosave → exit → reopen → verify content.

### Recovery Flow

Miss planned habit → show neutral missed state → choose recovery action → verify updated state.

### Backup Flow

Export → verify file → alter local dataset in test environment → import/restore → verify canonical data.

### Privacy Flow

Enable lock → background app → reopen → verify lock gate → unlock → verify content.

## 40.19 Release Diagnostics

Release build harus memiliki cara bagi developer/support workflow untuk membedakan:

- app version
- schema version
- backup version
- platform version

Tanpa perlu membaca journal atau sensitive content.

## 40.20 No Engagement Telemetry

Core product tidak membutuhkan telemetry untuk mengoptimalkan “time in app”, “daily opens”, “session length”, atau metric engagement manipulatif.

Data usage analytics yang mungkin ditambahkan di masa depan harus melalui product decision terpisah dan tidak boleh diasumsikan sebagai bagian dari core architecture.

## 40.21 Diagnostics Success Criteria

Observability dianggap cukup ketika developer dapat menjawab:

- operasi apa yang gagal
- di feature mana
- kategori error apa
- apakah data committed masih aman
- langkah recovery apa yang tersedia

tanpa perlu memperoleh isi jurnal atau private user text.

---

# 41. Cross-Section Engineering Constraints

Section ini mengikat Sections 36–40 agar tidak ditafsirkan terpisah.

## Rule 1

Performance optimization tidak boleh mengubah semantic correctness.

## Rule 2

Architecture tidak boleh menjadi lebih kompleks daripada kebutuhan feature yang sedang diselesaikan.

## Rule 3

Domain rule harus tetap dapat diuji secara deterministic.

## Rule 4

Local-only means no network dependency for core success paths.

## Rule 5

No external analytics is required to prove user habit behavior.

## Rule 6

No user private text enters diagnostic logs.

## Rule 7

No emoji exists anywhere in repository/project artifacts.

## Rule 8

No code comment should be added hanya untuk menjelaskan code yang seharusnya dapat dijelaskan melalui naming/structure.

## Rule 9

No speculative abstraction.

## Rule 10

No speculative feature.

## Rule 11

Any failure affecting persisted data must have an explicit recovery semantics.

## Rule 12

Any user-facing success state must correspond to a committed state, not merely a callback invocation.

## Rule 13

Any cached derived metric must be rebuildable from canonical data.

## Rule 14

Any import/restore operation that changes multiple related records must preserve referential integrity.

## Rule 15

Any bug fix with repeatable behavior risk should add regression coverage.

## Rule 16

Any implementation decision that materially changes product semantics must be surfaced rather than silently chosen.

## Rule 17

Any new dependency must have a concrete requirement and maintenance rationale.

## Rule 18

Any performance target used for release gating must be measured on release build and a representative device class.

## Rule 19

Any privacy-sensitive feature must define its storage location and data exposure explicitly.

## Rule 20

Any screen state must map to a real domain/application state or a clearly defined UI-only transient state.

---

# 42. Handoff to Next Batch

Part 8 selesai pada engineering/runtime boundary. Bagian berikutnya harus mengubah seluruh requirement menjadi kontrak verifikasi produk yang dapat dipakai sebagai checklist implementasi.

Batch berikutnya direncanakan mencakup:

- Section 43 — Functional Acceptance Criteria
- Section 44 — Non-Functional Requirements
- Section 45 — Release Readiness and Definition of Done
- Section 46 — Explicit Out of Scope and Future Considerations
- Section 47 — Requirement Traceability and AI Coding Agent Contract

Setelah Section 47, struktur PRD inti sudah lengkap untuk tahap implementation handoff. Tahap berikutnya bukan menambah feature baru, melainkan melakukan consolidation, consistency check antar-part, dan cleanup istilah/brand agar seluruh dokumen menjadi satu canonical PRD.

---

# 43. Canonical Continuity Notes

Dokumen ini harus dibaca setelah Part 1–7.

Kontrak yang tidak boleh berubah diam-diam:

- brand: **Prokopa: Habits and Jurnaling**
- local-only
- no login
- no signup
- no account backend
- no cloud sync
- no core cloud AI
- privacy-first
- recovery-first
- autonomy-supportive
- no emoji in repository/project
- calm, warm, focused, minimal visual language
- logo-driven brand identity
- bottom navigation centered on Today, Journal, Progress, Insights, Profile

Perubahan terhadap salah satu kontrak di atas harus diperlakukan sebagai perubahan requirement, bukan detail implementation biasa.

---

# 44. Source Alignment Notes

Bagian engineering ini mempertahankan prinsip sumber desain yang telah digunakan pada batch sebelumnya:

- low-friction action
- stable context
- meaningful progress
- gentle reflection
- recovery-first UX
- user autonomy

Formula tersebut menjadi alasan mengapa performance, local persistence, recovery, dan simplicity diperlakukan sebagai product requirements, bukan sekadar implementation preferences. fileciteturn5file1L241-L297

Information architecture inti juga tetap mengikuti struktur Today, Journal, Progress, Insights, dan Profile. fileciteturn2file2L501-L555

Autosave lokal dan distraction-free journaling tetap menjadi requirement utama journal editor. fileciteturn4file1L324-L360

Privacy diperlakukan sebagai bagian product behavior karena journal merupakan data yang sangat privat. fileciteturn5file8L1125-L1159

---

# 45. Part 8 Completion Checklist

## Performance

- local-first runtime defined
- startup priorities defined
- journal autosave performance defined
- list and search scalability guidance defined
- lifecycle behavior defined
- crash recovery defined
- battery constraints defined

## Architecture

- presentation boundary defined
- application/use-case boundary defined
- domain boundary defined
- data boundary defined
- platform boundary defined
- dependency direction defined
- state management constraints defined
- navigation and routing rules defined

## Engineering

- AGENTS.md principles integrated
- no speculative abstraction
- no speculative feature
- no emoji rule reinforced
- error handling rules defined
- migration discipline defined
- dependency discipline defined
- data deletion semantics defined

## Testing

- unit strategy defined
- repository/data testing defined
- widget/integration coverage defined
- import/export tests defined
- privacy tests defined
- time-boundary tests defined
- failure injection defined
- regression strategy defined

## Diagnostics

- privacy-safe logging defined
- error taxonomy defined
- integrity verification defined
- repair semantics defined
- smoke tests defined
- release diagnostics defined

---

# 46. Stop Condition for Batch 8

Part 8 dianggap selesai karena seluruh lima area yang direncanakan telah memiliki contract yang dapat diterjemahkan menjadi task implementation dan verification.

Tidak ada feature product baru yang ditambahkan di luar area engineering yang direncanakan.

Batch berikutnya adalah batch terakhir untuk melengkapi sections inti sebelum consolidation.




# 43. Functional Acceptance Criteria

## 43.1 Purpose

Bagian ini mengubah requirement produk menjadi kondisi yang dapat diverifikasi. Acceptance criteria tidak boleh hanya berbunyi “fitur tersedia”; setiap kriteria harus menjelaskan perilaku yang dapat diamati dan kondisi keberhasilannya.

## 43.2 Global Product Acceptance

### AC-G01 — Local-Only Operation

**Given** aplikasi berjalan pada perangkat tanpa koneksi internet,
**when** pengguna menggunakan fungsi inti,
**then** fungsi inti tetap dapat dipakai tanpa request network sebagai prasyarat.

Fungsi inti mencakup Today, habit management, completion, journal, mood, progress, review, insights lokal, Profile, export, dan import lokal.

### AC-G02 — No Account Requirement

Aplikasi dapat digunakan tanpa login, signup, email, password, Google authentication, Apple authentication, atau account recovery berbasis server.

### AC-G03 — No Cloud Sync

Perubahan data pengguna tetap berada pada local store kecuali pengguna secara eksplisit melakukan export atau memindahkan backup secara manual.

### AC-G04 — No Emoji in Repository

Repository, source code, UI strings, seed data, tests, fixtures, accessibility labels, notification copy, dan sample content tidak boleh mengandung emoji.

### AC-G05 — Privacy by Default

Journal, mood, habit notes, dan data personal tidak dikirim ke server atau layanan analitik eksternal oleh default.

---

## 43.3 Onboarding and Profile Acceptance

### AC-O01 — Minimal Onboarding

Onboarding menjelaskan nilai produk dan membangun komitmen kecil tanpa meminta profile data berlebihan.

### AC-O02 — First Habit

Pengguna dapat membuat habit pertama melalui flow yang mencakup setidaknya nama, alasan/why, frequency, cue, minimum version, reminder bila diinginkan, dan start date.

### AC-O03 — Local Profile

Pengguna dapat mengatur preferensi lokal yang memang dibutuhkan produk tanpa membuat account.

### AC-O04 — Skip Optional Context

Field opsional tidak boleh menjadi blocker untuk memulai penggunaan inti.

---

## 43.4 Habit Management Acceptance

### AC-H01 — Create Habit

Pengguna dapat membuat habit baru dengan schedule yang valid dan menyimpannya secara lokal.

### AC-H02 — Edit Habit

Perubahan nama, why, cue, frequency, target, reminder, dan konfigurasi habit yang didukung dapat disimpan tanpa merusak completion history sebelumnya.

### AC-H03 — Pause Habit

Pengguna dapat pause habit sampai tanggal tertentu atau sampai dilanjutkan kembali, dan pause tidak dihitung sebagai failure.

### AC-H04 — Skip Habit

Pengguna dapat menandai planned occurrence sebagai skipped dengan alasan yang tersedia, dan skip tetap dibedakan dari missed.

### AC-H05 — Archive Habit

Habit yang diarsipkan tidak muncul sebagai tugas aktif pada Today, tetapi historical records tetap dapat dibaca sesuai aturan history.

### AC-H06 — Schedule Semantics

Daily habit menggunakan daily semantics; weekly target menggunakan weekly semantics. Sistem tidak boleh memperlakukan target mingguan sebagai streak harian palsu.

### AC-H07 — Cue Visibility

Cue yang dikonfigurasi tampil pada context yang relevan agar hubungan cue → action mudah dipahami pengguna.

---

## 43.5 Habit Completion Acceptance

### AC-C01 — One-Tap Completion

Completion normal dapat dilakukan dari primary control tanpa membuka modal.

### AC-C02 — Idempotent Completion

Repeated tap atau retry terhadap occurrence yang sudah completed tidak boleh menggandakan completion record atau XP.

### AC-C03 — Immediate Feedback

Perubahan state terlihat segera setelah action berhasil diproses.

### AC-C04 — Optional Follow-Up

Catatan, mood, duration, atau metadata tambahan setelah completion bersifat opsional dan tidak menjadi blocker.

### AC-C05 — Missed Day Neutrality

Missed occurrence tidak ditampilkan sebagai hukuman moral dan tidak menghapus historical record.

### AC-C06 — Recovery

Setelah lapse, pengguna tetap dapat melanjutkan, mengurangi target, mengubah cue, atau pause tanpa kehilangan seluruh history.

---

## 43.6 Progress, Streak, and Calendar Acceptance

### AC-P01 — Completion Rate

Completion rate memakai numerator dan denominator yang konsisten dengan planned occurrences pada period yang dipilih.

### AC-P02 — Distinct-Day Rules

Metric yang mensyaratkan distinct day hanya menghitung satu kali per hari yang memenuhi kriteria.

### AC-P03 — Consecutive-Day Rules

Streak harian hanya bertambah pada hari kalender berturut-turut yang benar-benar memenuhi aturan habit tersebut.

### AC-P04 — Weekly Semantics

Habit berbasis X-times-per-week menilai pencapaian terhadap target mingguan, bukan memaksa streak harian.

### AC-P05 — No-Plan State

Hari tanpa occurrence terjadwal dibedakan dari missed.

### AC-P06 — Calendar Integrity

Calendar/heatmap menampilkan setidaknya distinction yang diperlukan antara completed, partial bila berlaku, skipped, no-plan, dan missed.

### AC-P07 — Historical Stability

Perubahan konfigurasi habit saat ini tidak boleh secara diam-diam menulis ulang historical completion yang sudah sah.

---

## 43.7 Journal Acceptance

### AC-J01 — Create Entry

Pengguna dapat membuat entry dengan date, optional mood, optional title, body, dan optional tags.

### AC-J02 — Body First

Body tetap menjadi focus utama editor dan tidak dibebani mandatory prompt, score, atau word count.

### AC-J03 — Local Autosave

Draft disimpan secara lokal selama lifecycle yang normal sehingga perpindahan screen atau backgrounding tidak menyebabkan kehilangan teks yang telah committed.

### AC-J04 — Save State

Editor dapat membedakan setidaknya draft/saving/saved locally/save failed ketika state tersebut relevan.

### AC-J05 — Draft Recovery

Draft yang belum selesai dapat dipulihkan setelah interruption yang normal.

### AC-J06 — Search and Filter

Pengguna dapat menemukan journal berdasarkan query/filter yang memang disediakan produk tanpa memerlukan server.

### AC-J07 — Delete

Pengguna dapat menghapus entry yang dipilih dengan confirmation yang proporsional untuk data sensitif.

---

## 43.8 Guided Journal Acceptance

### AC-GJ01 — Optional Prompts

Prompt guided journal dapat dilewati.

### AC-GJ02 — Progressive Prompting

Prompt dapat disajikan satu per satu agar reflection tidak terasa seperti form panjang.

### AC-GJ03 — Non-Judgmental Wording

Prompt tidak boleh mengasumsikan pengguna harus positif, produktif, atau sedang baik-baik saja.

---

## 43.9 Mood and Sleep Acceptance

### AC-M01 — Self-Report Only

Mood diperlakukan sebagai self-report dan bukan diagnosis.

### AC-M02 — Emotion Labels

Sistem dapat menyediakan label emosi/context yang konsisten dengan design system tanpa bergantung pada emoji.

### AC-M03 — Sleep Cross-Midnight

Sleep period yang melewati tengah malam disimpan dan dihitung sebagai satu sleep session yang benar.

### AC-M04 — No Medical Claim

UI dan insight tidak menyatakan diagnosis, kondisi klinis, atau kepastian sebab-akibat dari data mood/sleep.

---

## 43.10 Review and Insights Acceptance

### AC-R01 — Weekly Review

Weekly review menampilkan data period tersebut dan mengarahkan pengguna pada meaning serta adjustment untuk periode berikutnya.

### AC-R02 — Monthly Review

Monthly review menggunakan batas periode yang konsisten dan tidak berubah karena current date rendering.

### AC-I01 — Explainable Insight

Insight menyebutkan pattern yang dapat ditelusuri kembali ke data yang menjadi basisnya.

### AC-I02 — Minimum Data Threshold

Insufficient-data state digunakan ketika data belum cukup untuk insight yang berarti.

### AC-I03 — No Causal Overclaim

Insight tidak mengubah korelasi sederhana menjadi klaim kausal.

### AC-I04 — Actionable Output

Insight yang ditampilkan memiliki relevance terhadap adjustment atau reflection, bukan hanya angka.

### AC-I05 — No Sensitive Text Exposure

Isi journal sensitif tidak muncul pada insight/preview secara tidak terduga.

---

## 43.11 Gamification Acceptance

### AC-GM01 — Achievement Semantics

Achievement memiliki criteria yang eksplisit dan dapat dihitung ulang dari canonical data.

### AC-GM02 — Idempotent XP

XP dari event yang sama hanya dapat dihitung sesuai rule satu kali.

### AC-GM03 — No Competition

Tidak ada leaderboard atau social ranking dalam scope produk saat ini.

### AC-GM04 — No App-Open Farming

Membuka aplikasi berulang kali tidak memberikan reward progress yang dapat difarm.

---

## 43.12 Notification Acceptance

### AC-N01 — User Controlled

Reminder dapat diaktifkan atau dimatikan per habit atau melalui preference yang relevan.

### AC-N02 — Local Scheduling

Reminder yang tersedia di core product dijadwalkan secara lokal pada perangkat.

### AC-N03 — Calm Frequency

Notification strategy tidak mengandalkan volume tinggi atau repeated nudging untuk mempertahankan engagement.

### AC-N04 — Recovery Reminder

Recovery-related notification, bila diaktifkan, membantu return-to-action tanpa framing punishment.

### AC-N05 — Privacy-Safe Preview

Notification tidak menampilkan isi journal sensitif secara default.

---

## 43.13 Backup and Import Acceptance

### AC-B01 — Export Complete Enough

Export menghasilkan backup yang memuat data yang diperlukan untuk restore sesuai format/version contract.

### AC-B02 — Explicit User Action

Export dan import hanya terjadi melalui tindakan pengguna yang eksplisit.

### AC-B03 — Validation Before Commit

Imported backup divalidasi sebelum data hasil import dipersist sebagai dataset final.

### AC-B04 — Failure Safety

Import yang gagal tidak boleh menghasilkan dataset setengah-tertulis yang dianggap berhasil.

### AC-B05 — Restore Consistency

Setelah restore berhasil, data utama, history, configuration, dan derived data dapat kembali ke keadaan yang konsisten sesuai isi backup.

---

## 43.14 Privacy and App Lock Acceptance

### AC-S01 — App Lock

Bila App Lock aktif, screen privat tetap terlindungi saat kondisi lock terpenuhi.

### AC-S02 — No Auth Confusion

App Lock tidak dipresentasikan sebagai login/account authentication.

### AC-S03 — Data Deletion

Penghapusan selected data dan full data deletion memiliki confirmation dan semantics yang jelas.

### AC-S04 — Private by Default

Privacy messaging menyatakan local/private behavior tanpa memberikan klaim yang lebih luas daripada implementasi nyata.

---

## 43.15 Acceptance Test Matrix

Minimal smoke matrix sebelum release:

| Area | Scenario | Expected Result |
|---|---|---|
| Startup | Fresh install | App opens to usable first-run state |
| Startup | Existing local data | Data restored without account |
| Today | Complete habit | State updates once and persists |
| Habit | Missed/skip | State semantics remain distinct |
| Journal | Type and background | Committed draft remains recoverable |
| Journal | Save failure | User can recover without silent loss |
| Progress | Daily habit | Metrics follow daily semantics |
| Progress | Weekly target | Metrics follow weekly semantics |
| Review | Weekly period boundary | Correct period data shown |
| Insights | Insufficient data | No fabricated insight |
| Backup | Export | Valid local backup produced |
| Backup | Invalid import | Existing dataset remains safe |
| Privacy | Lock enabled | Private content remains protected |
| Privacy | Delete all | Dataset removal is complete |
| Offline | Airplane mode | Core functions remain usable |
| Notifications | Disabled reminder | No local notification delivered for that schedule |

---

# 44. Non-Functional Requirements

## 44.1 Purpose

Non-functional requirements menentukan kualitas minimum yang harus dirasakan pengguna dan dipertahankan engineering. Nilai di bawah adalah target produk/engineering, bukan janji performa absolut pada semua perangkat.

## 44.2 Offline and Availability

### NFR-01 — Core Offline Availability

Core flows harus tetap usable tanpa internet.

### NFR-02 — No Network Critical Path

Tidak boleh ada mandatory network call pada startup, completion, journal save, atau local review.

### NFR-03 — Deterministic Local Behavior

Dengan input dan local dataset yang sama, rule-based calculations harus menghasilkan output yang konsisten.

---

## 44.3 Performance

### NFR-04 — First Usable Screen

Startup memprioritaskan first useful render dan tidak menunggu analytics non-critical.

### NFR-05 — Habit Completion

Completion normal harus terasa near-immediate pada device yang supported dan tidak memerlukan progress spinner untuk operasi lokal sederhana.

### NFR-06 — Journal Typing

Typing tidak boleh terputus secara noticeable akibat autosave.

### NFR-07 — Search Scalability

Search journal harus tetap usable pada dataset realistis tanpa full-database reprocessing pada setiap keystroke bila dapat dihindari.

### NFR-08 — Memory Discipline

Long journal bodies dan list besar tidak boleh menyebabkan seluruh dataset dimuat ke UI sekaligus tanpa kebutuhan.

---

## 44.4 Reliability

### NFR-09 — Transactional Writes

Perubahan yang harus atomik menggunakan transaction atau mekanisme setara.

### NFR-10 — Crash Recovery

Crash/lifecycle interruption tidak boleh menyebabkan silent corruption pada dataset yang sudah committed.

### NFR-11 — Import Safety

Import failure tidak boleh meninggalkan dataset pada state yang tidak diketahui.

### NFR-12 — Migration Safety

Schema migration harus versioned, deterministic, dan dapat diverifikasi.

---

## 44.5 Privacy and Security

### NFR-13 — No External Data Transfer by Default

Data personal tidak ditransfer ke external service kecuali ada future feature yang secara eksplisit mengubah scope dan memperoleh persetujuan requirement baru.

### NFR-14 — Minimal Permissions

Aplikasi meminta permission platform hanya jika benar-benar diperlukan oleh feature yang dipakai.

### NFR-15 — Privacy-Safe Notifications

Notification content tidak boleh mengekspos journal body atau data sensitif secara default.

### NFR-16 — Protected Private Views

App Lock bila aktif harus melindungi private surfaces sesuai lifecycle contract.

---

## 44.6 Accessibility

### NFR-17 — Contrast

Text normal mengikuti baseline contrast minimal 4.5:1; large text dan non-text UI mengikuti baseline 3:1 sebagaimana design contract.

### NFR-18 — Touch Targets

Interactive targets menargetkan practical minimum sekitar 44–48 px sesuai konteks komponen.

### NFR-19 — Text Scaling

Layout tidak boleh menjadi unusable ketika pengguna meningkatkan text size dalam range yang didukung platform.

### NFR-20 — Reduced Motion

Motion yang tidak esensial dapat dikurangi ketika reduce-motion preference aktif.

### NFR-21 — Non-Color Semantics

Status penting tidak dikomunikasikan melalui warna saja.

---

## 44.7 UX Quality

### NFR-22 — Low Friction

Completion dan capture inti membutuhkan langkah seminimal mungkin tanpa mengorbankan correctness.

### NFR-23 — No Shame Framing

Copy error/recovery/missed state tidak boleh menggunakan bahasa yang mempermalukan pengguna.

### NFR-24 — Explainability

Metric dan insight utama dapat dipahami tanpa requiring domain expertise.

### NFR-25 — Consistency

Terminology, state semantics, spacing, interaction, dan navigation tetap konsisten lintas screen.

---

## 44.8 Maintainability

### NFR-26 — Small Changes Stay Small

Architecture harus memungkinkan perubahan localized tanpa ripple refactor yang tidak perlu.

### NFR-27 — Explicit Dependencies

Dependency antar-layer mudah diidentifikasi dan tidak disembunyikan melalui global mutable state yang tidak perlu.

### NFR-28 — Rule Centralization

Business rules yang berdampak pada metrics, streaks, XP, schedule, migration, atau import validation memiliki single canonical implementation.

### NFR-29 — Testability

Critical domain and data behavior dapat diuji tanpa membutuhkan real network service.

---

## 44.9 Repository Hygiene

### NFR-30 — No Emoji

Tidak ada emoji di repository/project.

### NFR-31 — No Dead Feature Scaffolding

Jangan menambahkan placeholder architecture untuk future cloud sync, social graph, AI service, atau backend yang belum menjadi requirement.

### NFR-32 — Clean Code

Kode mengikuti prinsip pada AGENTS.md: jangan berasumsi, simplicity first, surgical changes, dan goal-driven verification. fileciteturn3file0L7-L25

---

# 45. Release Readiness and Definition of Done

## 45.1 Purpose

Release readiness menentukan kapan implementation dianggap selesai secara product, technical, data, privacy, accessibility, dan verification.

## 45.2 Feature Definition of Done

Sebuah feature dianggap Done hanya jika:

1. requirement telah dipetakan ke acceptance criteria;
2. happy path telah diimplementasikan;
3. relevant edge states telah ditangani;
4. persistence behavior telah diverifikasi bila feature menyimpan data;
5. failure behavior telah didefinisikan;
6. accessibility semantics telah diperiksa;
7. tidak menambahkan network dependency yang tidak direncanakan;
8. tidak menambahkan emoji;
9. test yang relevan telah ditambahkan atau diperbarui;
10. scope tetap sesuai PRD.

## 45.3 Release Gate — Functional

Sebelum release:

- Today dapat dibuka dan digunakan.
- Habit create/edit/pause/skip/archive bekerja.
- Completion dan recovery bekerja.
- Journal create/edit/autosave/recovery/delete bekerja.
- Mood dan sleep tidak membuat medical claims.
- Progress/calendar/review menggunakan semantics yang benar.
- Insights tidak menghasilkan fabricated patterns.
- Achievements/XP tidak double-count.
- Notifications dapat dikontrol dan tetap privacy-safe.
- Export/import tervalidasi.
- App Lock dan data deletion bekerja sesuai contract.

## 45.4 Release Gate — Offline

Smoke test harus lulus dalam kondisi network disabled.

Minimal:

- fresh launch
- existing-data launch
- habit completion
- journal edit/save
- progress calculation
- review calculation
- local insights
- export
- import
- privacy lock

## 45.5 Release Gate — Data Integrity

Sebelum release, team harus memiliki bukti bahwa:

- schema version tersedia;
- migration path teruji untuk supported source versions;
- import validation aktif;
- deletion semantics teruji;
- duplicate event tidak menggandakan canonical records;
- derived data dapat dihitung ulang atau diverifikasi;
- corrupted/invalid input tidak diam-diam diterima.

## 45.6 Release Gate — Accessibility

Review manual dan automated checks harus mencakup:

- contrast;
- labels/semantics untuk controls;
- keyboard/focus behavior bila platform menuntut;
- larger text;
- reduced motion;
- touch targets;
- status yang tidak bergantung pada warna saja.

## 45.7 Release Gate — Privacy

Tidak boleh ada:

- analytics SDK yang mengirim journal content;
- hidden account creation;
- background network call sebagai bagian core data path;
- notification preview yang mengekspos sensitive journal text secara default;
- cloud AI call yang tidak menjadi requirement eksplisit.

## 45.8 Release Gate — Repository

Repository review harus memastikan:

- no emoji;
- no unused code introduced by the release;
- no speculative abstractions;
- no speculative backend/cloud layer;
- no accidental debug data;
- no secrets;
- dependency list tetap minimal dan relevan.

## 45.9 Release Gate — Documentation

Minimum documentation internal implementation:

- architecture boundary;
- database/schema version;
- migration notes;
- backup format/version;
- critical business-rule notes;
- test commands;
- release verification checklist.

## 45.10 Definition of Done — Whole Product

Product dapat dinyatakan Done untuk scope PRD ketika semua acceptance criteria kritis lulus, NFR kritis tidak memiliki known blocker, data migration/backup safety telah diverifikasi, privacy boundary sesuai local-only contract, dan release checklist ditandatangani oleh team.

“Feature terlihat di UI” tidak cukup sebagai Definition of Done.

---

# 46. Explicit Out of Scope and Future Considerations

## 46.1 Purpose

Section ini mencegah scope creep. Out-of-scope bukan bug dan bukan kekurangan implementation selama requirement saat ini memang tidak mencakupnya.

## 46.2 Explicitly Out of Scope — Current Product

### OOS-01 — User Accounts

Tidak ada login/signup/account registration.

### OOS-02 — Cloud Sync

Tidak ada automatic multi-device cloud sync.

### OOS-03 — Backend

Tidak ada custom backend sebagai bagian core product.

### OOS-04 — Social Features

Tidak ada following, followers, friend graph, shared habits, social feed, leaderboard, atau public profile.

### OOS-05 — Competitive Gamification

Tidak ada ranking kompetitif atau reward yang dirancang untuk mempertahankan session secara manipulatif.

### OOS-06 — Cloud AI Core Dependency

Core app tidak bergantung pada remote LLM/AI untuk dapat digunakan.

### OOS-07 — Medical/Clinical Product

Aplikasi bukan diagnostic, treatment, therapy, atau clinical monitoring system.

### OOS-08 — Wearable/Health Platform Dependency

Integrasi wearable/health platform tidak termasuk core release kecuali requirement terpisah disetujui.

### OOS-09 — Automatic Web Import

Scraping/import otomatis dari layanan web pihak ketiga tidak termasuk core backup/import.

### OOS-10 — Marketing Analytics

Engagement telemetry untuk optimasi addiction/retention bukan product requirement.

### OOS-11 — Forced Journaling

Pengguna tidak dipaksa mengisi journal untuk mempertahankan streak habit.

### OOS-12 — Forced Mood Tracking

Mood bukan syarat untuk completion habit atau journal entry.

### OOS-13 — Unlimited Feature Surface

Tidak ada kewajiban menambahkan feature hanya karena competitor memiliki feature tersebut.

---

## 46.3 Future Considerations — Not Commitments

Future consideration harus tetap dianggap proposal sampai requirement baru dibuat, dinilai, dan diterima.

### FC-01 — Optional Encrypted Sync

Cloud sync dapat dipertimbangkan di masa depan hanya bila privacy model, encryption, ownership, conflict resolution, offline merge, authentication, dan legal/data requirements telah didefinisikan ulang.

### FC-02 — Optional AI Assistance

AI journaling assistance dapat dipertimbangkan hanya dengan disclosure yang jelas, consent, minimization of sensitive text exposure, dan mode yang tetap memungkinkan produk berjalan tanpa AI.

### FC-03 — Wearable Integration

Wearable data dapat menjadi input tambahan setelah permission, data mapping, provenance, dan deletion semantics jelas.

### FC-04 — Advanced Analytics

Analytics yang lebih kompleks dapat dipertimbangkan selama tetap explainable, privacy-safe, dan tidak berubah menjadi diagnosis atau deterministic personality labeling.

### FC-05 — Cross-Device Backup UX

Cross-device transfer dapat dipertimbangkan melalui user-controlled encrypted backup sebelum automatic sync dipertimbangkan.

### FC-06 — Additional Review Templates

Template review baru dapat ditambahkan jika tetap optional dan tidak mengubah core reflection philosophy.

### FC-07 — Localization

Bahasa tambahan dapat ditambahkan sebagai requirement terpisah; terminology habit, mood, review, dan privacy harus tetap konsisten.

## 46.4 Scope Change Rule

Future consideration tidak boleh masuk codebase sebagai hidden feature, dead scaffold, placeholder API, atau speculative abstraction hanya karena “mungkin nanti dipakai”. Ini mengikuti simplicity-first dan no-speculation rule pada AGENTS.md. fileciteturn3file0L17-L25

## 46.5 Priority Rule for New Requests

Ketika request baru datang, evaluasi dengan urutan:

1. apakah benar-benar menyelesaikan user problem;
2. apakah melanggar local-only/privacy contract;
3. apakah menambah complexity yang tidak proporsional;
4. apakah sudah tercakup requirement existing;
5. apakah membutuhkan requirement change formal.

---

# 47. Requirement Traceability and AI Coding Agent Contract

## 47.1 Purpose

Bagian terakhir ini menjadi jembatan antara PRD dan implementation. Tujuannya adalah memastikan coding agent atau developer mengerjakan requirement yang dapat ditelusuri, bukan membuat aplikasi berdasarkan interpretasi bebas.

## 47.2 Traceability Chain

Setiap implementation task harus dapat ditelusuri melalui chain berikut:

**User Problem → Product Principle → Requirement → Acceptance Criterion → Implementation Change → Automated/Manual Verification**

Perubahan yang tidak dapat dijelaskan melalui chain ini harus dipertanyakan sebelum implementation.

## 47.3 Canonical Product Contracts

Kontrak berikut bersifat canonical untuk implementation:

| Contract | Canonical Rule |
|---|---|
| Brand | Prokopa: Habits and Jurnaling |
| Data | Local-only |
| Account | None |
| Backend | None |
| Sync | No cloud sync |
| AI | No core cloud AI dependency |
| Privacy | Private by default |
| Habit philosophy | Context/action/repetition, not streak hostage |
| Recovery | Missed day is not moral failure |
| Journal | Reflection space, body first |
| Mood | Self-report, not diagnosis |
| Insights | Explainable, thresholded, actionable |
| Gamification | Optional semantic progress, no competition |
| Notifications | Local, calm, user-controlled |
| Backup | Explicit user-controlled export/import |
| Navigation | Today, Journal, Progress, Insights, Profile |
| Visual direction | Calm, warm, focused, minimal |
| Brand identity | Logo-driven |
| Repository | No emoji |

## 47.4 Requirement Identification

Requirement ID harus tetap stabil setelah consolidation kecuali ada perubahan struktur PRD yang disengaja.

Contoh:

- AC-H01 = habit creation acceptance;
- AC-C01 = habit completion acceptance;
- AC-J03 = journal local autosave acceptance;
- AC-B03 = import validation acceptance;
- NFR-13 = no external data transfer by default.

Implementation issue atau commit message sebaiknya merujuk ID ketika perubahan cukup besar untuk membutuhkan traceability.

## 47.5 Agent Pre-Implementation Protocol

Sebelum coding task dimulai, agent wajib membuat internal implementation plan yang singkat dan eksplisit mengenai:

- requirement ID yang dikerjakan;
- files/modules yang diperkirakan disentuh;
- assumptions yang digunakan;
- unknowns yang masih perlu diklarifikasi;
- verification method.

Agent tidak boleh menutupi ambiguity dengan menebak.

## 47.6 Ambiguity Rule

Jika requirement memiliki dua interpretasi material yang menghasilkan behavior berbeda, agent harus berhenti pada boundary tersebut dan meminta clarification, kecuali PRD atau existing implementation sudah memberikan canonical answer.

## 47.7 Minimal-Change Rule

Agent harus memilih perubahan terkecil yang memenuhi requirement.

Agent tidak boleh:

- melakukan refactor besar yang tidak diperlukan;
- membuat abstraction layer untuk satu use case;
- menambahkan generic framework tanpa requirement;
- menambah backend interface yang belum dipakai;
- menambahkan sync model “untuk nanti”; atau
- mengganti architecture tanpa alasan yang dapat diverifikasi.

Prinsip ini langsung selaras dengan “Simplicity First” dan “Surgical Changes” dalam AGENTS.md. fileciteturn3file0L17-L24

## 47.8 No Speculative Product Behavior

Agent tidak boleh menginvent feature berdasarkan kebiasaan aplikasi sejenis.

Contoh yang tidak boleh muncul tanpa requirement baru:

- login popup;
- cloud backup prompt;
- social sharing;
- AI chatbot;
- leaderboard;
- streak freeze monetization;
- ads;
- subscription upsell;
- account profile;
- email collection;
- remote telemetry untuk behavior optimization.

## 47.9 No Speculative Technical Behavior

Agent tidak boleh membuat network client, repository abstraction, sync conflict model, API DTO, authentication token, atau cloud SDK hanya sebagai persiapan masa depan.

## 47.10 No Emoji Enforcement

Agent harus memperlakukan “no emoji” sebagai repository constraint, bukan hanya UI style.

Sebelum menyelesaikan task, verifikasi minimal pada changed files bahwa tidak ada emoji yang baru diperkenalkan.

## 47.11 Data-Safety Priority

Ketika terdapat tradeoff antara convenience dan kemungkinan kehilangan user data, agent harus memilih jalur yang menjaga data atau meminta clarification.

Contoh:

- jangan mengganti save path dengan delayed-only save jika dapat menyebabkan data hilang;
- jangan overwrite existing dataset sebelum import tervalidasi;
- jangan mengubah historical records hanya untuk memudahkan metric baru;
- jangan menjalankan destructive migration tanpa versioned recovery plan.

## 47.12 Business-Rule Canonicality

Rules untuk scheduling, planned occurrence, completion, skip, missed, streak, recovery, XP, review period, dan import validation tidak boleh di-duplicate dalam banyak widget.

UI hanya mengonsumsi canonical application/domain behavior.

## 47.13 UI Constraint

Widget/UI layer tidak boleh menjadi tempat utama untuk menyimpan business rules kompleks.

UI bertanggung jawab atas:

- presentation;
- user interaction;
- accessibility semantics;
- visual state;
- loading/error/empty representation.

Application/domain layer bertanggung jawab atas behavior dan rules.

## 47.14 Local-Only Constraint

Untuk core flow, agent harus dapat menjawab pertanyaan:

> “Apa yang terjadi bila perangkat benar-benar offline?”

Jawaban harus tetap valid tanpa mengandalkan request server.

## 47.15 Testing Before Claiming Done

“Done” tidak boleh berarti compile-only.

Minimum verification disesuaikan dengan risiko:

| Change | Minimum Verification |
|---|---|
| Pure UI copy | Widget/snapshot review as appropriate |
| UI interaction | Widget test/manual interaction |
| Domain rule | Unit tests |
| Persistence | Repository/database tests |
| Migration | Versioned migration tests |
| Import/export | Round-trip + invalid-input tests |
| Privacy/App Lock | Lifecycle + access tests |
| Notification | Scheduling/state tests |
| Cross-feature change | Relevant integration test |

## 47.16 Goal-Driven Verification

Verification harus didefinisikan sebagai kondisi lulus yang dapat diamati.

Contoh buruk:

“Pastikan journal aman.”

Contoh baik:

“Setelah app backgrounded selama editor terbuka, committed draft dapat dipulihkan tanpa kehilangan text.”

Prinsip goal-driven verification harus mengikuti AGENTS.md. fileciteturn3file0L29-L38

## 47.17 Change Review Questions

Sebelum merge/release, agent/developer harus dapat menjawab:

1. Requirement mana yang berubah?
2. Acceptance criterion mana yang dibuktikan?
3. Apakah ada behavior baru di luar scope?
4. Apakah ada data migration impact?
5. Apakah ada privacy impact?
6. Apakah offline behavior tetap benar?
7. Apakah ada duplicate business rule?
8. Apakah test memverifikasi risiko utama?
9. Apakah emoji baru masuk repository?
10. Apakah perubahan dapat dibuat lebih kecil?

## 47.18 Conflict Resolution Hierarchy

Jika terdapat konflik antara sumber requirement, gunakan prioritas berikut:

1. explicit current user-approved requirement;
2. canonical PRD section setelah consolidation;
3. existing project constraints yang memang diwajibkan;
4. source design guidance untuk detail UX;
5. engineering convention;
6. agent preference.

Agent preference tidak boleh mengalahkan requirement.

## 47.19 Source of Truth Rule

Setelah consolidation final selesai, satu canonical PRD harus menjadi source of truth untuk product behavior.

Part 1–9 dipertahankan sebagai rebuild history/reference, tetapi implementation task tidak boleh mengambil dua interpretasi berbeda dari dua part tanpa resolution pada canonical document.

## 47.20 AI Coding Agent Output Contract

Setiap implementation response dari coding agent idealnya dapat diringkas menjadi:

**Scope → Assumptions → Changes → Verification → Remaining Risk**

Jangan menyatakan success bila verification belum dilakukan.

## 47.21 Stop Conditions

Agent harus stop dan meminta keputusan ketika:

- requirement contradictory;
- data migration dapat destructive tanpa migration contract;
- privacy behavior tidak jelas;
- local-only contract akan dilanggar;
- acceptance criterion tidak dapat diverifikasi dengan informasi yang tersedia;
- implementation membutuhkan feature baru yang tidak disetujui;
- task mengharuskan perubahan besar di luar scope yang diminta.

## 47.22 Final Handoff Checklist

Sebelum implementation handoff dari PRD:

- [ ] Product name exact: **Prokopa: Habits and Jurnaling**
- [ ] Local-only contract explicit
- [ ] No-login contract explicit
- [ ] No-cloud-sync contract explicit
- [ ] No-core-cloud-AI contract explicit
- [ ] Privacy contract explicit
- [ ] Recovery-first contract explicit
- [ ] Acceptance criteria defined
- [ ] NFR defined
- [ ] Release gate defined
- [ ] Out-of-scope defined
- [ ] Future considerations marked non-commitment
- [ ] Requirement IDs defined
- [ ] AI coding-agent rules defined
- [ ] No emoji rule defined
- [ ] AGENTS.md principles represented
- [ ] Consolidation required before implementation kickoff

---

# 48. Batch 9 Completion and Transition to Consolidation

Part 9 menutup requirement batch inti. Tidak ada section product besar tambahan yang diperlukan sebelum consolidation.

Tahap berikutnya harus bersifat editorial/verification, bukan brainstorming feature baru.

## 48.1 Consolidation Tasks

Consolidation final harus:

1. menggabungkan Part 1–9 menjadi satu canonical PRD;
2. mengganti seluruh penyebutan brand lama yang tidak lagi canonical menjadi **Prokopa: Habits and Jurnaling**;
3. memeriksa konflik terminology antar-part;
4. memastikan local-only/no-login/no-sync contract konsisten;
5. memastikan no-emoji rule tidak bertentangan dengan copy/sample data;
6. memastikan duplicate requirements dipadatkan tanpa menghilangkan acceptance behavior;
7. memastikan setiap critical feature memiliki requirement dan verification path;
8. memastikan out-of-scope tidak diam-diam muncul kembali sebagai implementation expectation;
9. membuat final table of contents dan requirement index;
10. melakukan final contradiction scan sebelum PRD dinyatakan canonical.

## 48.2 Consolidation Non-Goals

Jangan menggunakan consolidation untuk:

- menambahkan feature baru tanpa approval;
- mengubah product philosophy;
- menambahkan cloud architecture;
- menambah social feature;
- menambahkan medical claims;
- menambah AI dependency;
- mengubah visual identity secara spekulatif.

## 48.3 Final Stop Condition

PRD canonical dianggap selesai ketika consolidation menghasilkan satu dokumen yang dapat diberikan kepada developer/coding agent tanpa memerlukan tebakan terhadap kontrak inti produk.

Kesuksesan akhir bukan jumlah halaman, melainkan kemampuan dokumen untuk membuat implementation dan verification menjadi deterministik.
