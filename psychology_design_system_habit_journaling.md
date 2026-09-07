# Psychology-Driven Design System untuk Aplikasi Habit & Journaling Tracking

> **Panduan berbasis riset untuk merancang aplikasi pembentukan kebiasaan, habit tracking, journaling, mood check-in, refleksi, progress, reminder, streak, insight, dan review yang selaras dengan cara manusia membentuk kebiasaan, memproses emosi, mempertahankan motivasi, serta kembali setelah lapse.**

---

## Metadata Dokumen

- **Domain:** Habit tracking, journaling, personal informatics, self-reflection, behavior change
- **Konteks produk:** Mobile-first app, tablet, web dashboard pribadi
- **Pendekatan:** Psychology-driven, autonomy-supportive, recovery-first, evidence-informed
- **Pengguna utama:** Individu yang ingin membangun kebiasaan, melakukan refleksi, dan memahami pola dirinya
- **Tujuan desain:** Mendukung konsistensi, automaticity, self-awareness, reflection, recovery, dan sense of progress tanpa menciptakan shame, dependency, atau compulsive engagement
- **Versi:** 1.0
- **Tanggal riset:** September 2026
- **Catatan:** Dokumen ini adalah pedoman UX/product design, bukan protokol terapi atau diagnosis medis

---

# Daftar Isi

1. [Ringkasan Eksekutif](#1-ringkasan-eksekutif)
2. [Premis Utama](#2-premis-utama)
3. [Batasan Evidence dan Cara Membaca Dokumen](#3-batasan-evidence-dan-cara-membaca-dokumen)
4. [Model Psikologi Produk](#4-model-psikologi-produk)
5. [Habit Bukan Sekadar Streak](#5-habit-bukan-sekadar-streak)
6. [Habit Formation dan Automaticity](#6-habit-formation-dan-automaticity)
7. [Context–Response Association](#7-contextresponse-association)
8. [Implementation Intentions](#8-implementation-intentions)
9. [Self-Monitoring dan Feedback](#9-self-monitoring-dan-feedback)
10. [Self-Determination Theory](#10-self-determination-theory)
11. [COM-B](#11-com-b)
12. [Self-Compassion dan Recovery](#12-self-compassion-dan-recovery)
13. [Personal Informatics](#13-personal-informatics)
14. [Journaling dan Reflective Practice](#14-journaling-dan-reflective-practice)
15. [Affect Labeling dan Mood Check-In](#15-affect-labeling-dan-mood-check-in)
16. [Gratitude dan Positive Reflection](#16-gratitude-dan-positive-reflection)
17. [Prinsip Etis Psychology-Driven Design](#17-prinsip-etis-psychology-driven-design)
18. [North Star Experience](#18-north-star-experience)
19. [Mental Model Aplikasi](#19-mental-model-aplikasi)
20. [Information Architecture](#20-information-architecture)
21. [Onboarding Psychology](#21-onboarding-psychology)
22. [Habit Creation Flow](#22-habit-creation-flow)
23. [Cue Design](#23-cue-design)
24. [Frequency dan Scheduling](#24-frequency-dan-scheduling)
25. [Habit Card](#25-habit-card)
26. [Completion Interaction](#26-completion-interaction)
27. [Streak Psychology](#27-streak-psychology)
28. [Progress Tanpa Ketergantungan pada Streak](#28-progress-tanpa-ketergantungan-pada-streak)
29. [Lapse, Missed Day, dan Recovery](#29-lapse-missed-day-dan-recovery)
30. [Pause, Skip, Rest, dan Exception](#30-pause-skip-rest-dan-exception)
31. [Rewards dan Gamification](#31-rewards-dan-gamification)
32. [Reminder dan Notification Psychology](#32-reminder-dan-notification-psychology)
33. [Context-Aware Reminder](#33-context-aware-reminder)
34. [Notification Fatigue](#34-notification-fatigue)
35. [Home / Today Screen](#35-home--today-screen)
36. [Journaling System](#36-journaling-system)
37. [Free Journal](#37-free-journal)
38. [Guided Journal](#38-guided-journal)
39. [Reflection Prompt Design](#39-reflection-prompt-design)
40. [Mood Tracking](#40-mood-tracking)
41. [Weekly Review](#41-weekly-review)
42. [Monthly Review](#42-monthly-review)
43. [Calendar dan Heatmap](#43-calendar-dan-heatmap)
44. [Insights dan Pattern Recognition](#44-insights-dan-pattern-recognition)
45. [AI-Generated Insights](#45-ai-generated-insights)
46. [Visual Hierarchy](#46-visual-hierarchy)
47. [Shape Psychology](#47-shape-psychology)
48. [Color System](#48-color-system)
49. [Typography](#49-typography)
50. [Spacing dan Gestalt](#50-spacing-dan-gestalt)
51. [Iconography](#51-iconography)
52. [Touch Targets dan Motor Interaction](#52-touch-targets-dan-motor-interaction)
53. [Motion dan Animation](#53-motion-dan-animation)
54. [Haptic dan Sound](#54-haptic-dan-sound)
55. [Microcopy dan Tone of Voice](#55-microcopy-dan-tone-of-voice)
56. [Component Architecture](#56-component-architecture)
57. [Component States](#57-component-states)
58. [Empty, Loading, Error, Offline](#58-empty-loading-error-offline)
59. [Privacy dan Psychological Safety](#59-privacy-dan-psychological-safety)
60. [Accessibility](#60-accessibility)
61. [Responsive dan Platform](#61-responsive-dan-platform)
62. [Design Tokens](#62-design-tokens)
63. [Screen-Level Specifications](#63-screen-level-specifications)
64. [Anti-Patterns](#64-anti-patterns)
65. [Usability Testing](#65-usability-testing)
66. [Behavioral Metrics](#66-behavioral-metrics)
67. [A/B Testing dengan Guardrails](#67-ab-testing-dengan-guardrails)
68. [Checklist Implementasi](#68-checklist-implementasi)
69. [Golden Rules](#69-golden-rules)
70. [Kesimpulan](#70-kesimpulan)
71. [Referensi](#71-referensi)
72. [Appendix A — Psychology → UI Mapping](#appendix-a--psychology--ui-mapping)
73. [Appendix B — State Models](#appendix-b--state-models)
74. [Appendix C — Suggested Design Tokens](#appendix-c--suggested-design-tokens)
75. [Appendix D — Prompt Library](#appendix-d--prompt-library)
76. [Appendix E — UX Writing Library](#appendix-e--ux-writing-library)

---

# 1. Ringkasan Eksekutif

Aplikasi habit dan journaling tidak seharusnya dirancang seperti game yang tujuan utamanya mempertahankan **daily active users**.

Tujuan yang lebih tepat adalah:

> **membantu pengguna melakukan perilaku yang bermakna, mengenali pola, melakukan refleksi, dan kembali dengan mudah setelah terputus.**

Aplikasi yang berhasil bukan aplikasi yang membuat pengguna harus terus-menerus membuka aplikasi.

Dalam banyak kasus, habit yang sudah matang justru berarti:

> pengguna semakin sedikit membutuhkan aplikasi untuk memulai perilaku tersebut.

Karena itu, psychology-driven design untuk domain ini harus mengoptimalkan:

```text
INTENTION
↓
ACTION
↓
REPETITION
↓
CONTEXT ASSOCIATION
↓
AUTOMATICITY
↓
REFLECTION
↓
ADAPTATION
```

bukan:

```text
NOTIFICATION
↓
APP OPEN
↓
STREAK
↓
REWARD
↓
MORE APP OPEN
```

## 1.1 Prinsip inti

Design system direkomendasikan memiliki tujuh prinsip:

1. **Autonomy over coercion**
2. **Consistency over perfection**
3. **Context over motivation**
4. **Reflection over raw metrics**
5. **Recovery over punishment**
6. **Progress over streak dependency**
7. **Trust over engagement maximization**

## 1.2 Karakter UI

Karakter visual yang disarankan:

> **Calm, warm, focused, low-pressure, reflective, and quietly rewarding.**

Aplikasi sebaiknya terasa seperti:

- ruang pribadi;
- alat refleksi;
- partner yang tenang;
- sistem pencatat yang dapat dipercaya;

bukan seperti:

- bos;
- scoreboard;
- kasino;
- kompetisi;
- mesin notifikasi.

---

# 2. Premis Utama

Habit tracking memiliki dua fungsi yang harus dibedakan.

## 2.1 Tracking sebagai alat perubahan

Pengguna mencatat perilaku agar lebih konsisten.

Contoh:

```text
Minum air
Meditasi
Belajar
Olahraga
Membaca
Tidur tepat waktu
```

## 2.2 Tracking sebagai alat pemahaman

Pengguna mencatat bukan untuk "menang", tetapi untuk memahami pola.

Contoh:

```text
Mood
Energi
Tidur
Fokus
Stres
Jurnal
```

Kedua fungsi tersebut tidak boleh menggunakan psikologi yang sama persis.

Habit completion cocok menggunakan:

- action;
- repetition;
- progress.

Journal dan mood cocok menggunakan:

- reflection;
- labeling;
- context;
- insight.

---

# 3. Batasan Evidence dan Cara Membaca Dokumen

Tidak semua rekomendasi memiliki kekuatan evidence yang sama.

Gunakan tiga tingkat berikut.

## Evidence A — kuat

Didukung oleh:

- meta-analysis;
- systematic review;
- repeated experimental evidence;
- established accessibility standard.

Contoh:

- implementation intentions;
- progress monitoring;
- context stability;
- WCAG contrast.

## Evidence B — moderat

Didukung oleh:

- beberapa eksperimen;
- longitudinal studies;
- qualitative studies;
- evidence yang masih tergantung konteks.

Contoh:

- streak motivation;
- affect labeling;
- digital journaling prompts.

## Evidence C — design heuristic

Berasal dari:

- HCI practice;
- synthesis;
- design reasoning;
- usability principles.

Contoh:

- exact border radius;
- exact motion duration;
- card density;
- typography scale.

Angka UI dalam dokumen ini harus dianggap sebagai **baseline untuk diuji**, bukan angka biologis universal.

---

# 4. Model Psikologi Produk

Model produk dapat dibuat dalam enam lapisan.

```text
1. INTENTION
   Apa yang ingin dilakukan?

2. CUE
   Kapan / di mana tindakan dipicu?

3. ACTION
   Seberapa mudah tindakan dilakukan?

4. REINFORCEMENT
   Apakah pengalaman memberi rasa kemajuan?

5. REFLECTION
   Apa yang dapat dipelajari?

6. RECOVERY
   Apa yang terjadi ketika pengguna berhenti?
```

Design system harus mencakup keenamnya.

---

# 5. Habit Bukan Sekadar Streak

Streak adalah **representasi data**.

Habit adalah **asosiasi yang dipelajari antara konteks dan respons**.

Sebuah aplikasi dapat memiliki:

```text
365-day streak
```

tanpa menjamin perilaku sudah otomatis.

Sebaliknya, seseorang dapat memiliki habit kuat walaupun sesekali tidak melakukan perilaku.

Studi Lally et al. menemukan variasi besar dalam waktu menuju automaticity, sekitar 18–254 hari pada peserta yang modelnya dapat dipasang; melewatkan satu kesempatan tidak secara material memengaruhi proses pembentukan habit.

Implikasi:

> Jangan menjanjikan "21 hari membentuk kebiasaan."

Dan:

> Jangan membuat satu missed day terasa seperti seluruh progress kembali ke nol.

---

# 6. Habit Formation dan Automaticity

Automaticity berarti perilaku semakin sedikit membutuhkan keputusan sadar.

Proses sederhananya:

```text
Stable Context
+
Repeated Behavior
+
Reinforcement
↓
Context–Response Association
↓
Automaticity
```

Automaticity biasanya tumbuh non-linear.

Pada awal:

```text
setiap repetition
→ banyak learning
```

Setelah lama:

```text
repetition tambahan
→ peningkatan automaticity lebih kecil
```

## 6.1 Implikasi UX

Aplikasi harus bertanya:

```text
Apa kebiasaanmu?
```

tetapi juga:

```text
Setelah aktivitas apa kamu ingin melakukannya?
Di mana biasanya kamu berada?
Apa versi terkecilnya?
```

---

# 7. Context–Response Association

Evidence terbaru menegaskan stabilitas konteks penting untuk automaticity.

Konteks bukan hanya jam.

Konteks dapat berupa:

### Temporal

```text
07:00
setelah makan malam
sebelum tidur
```

### Behavioral

```text
setelah menyikat gigi
setelah membuka laptop
setelah pulang kerja
```

### Spatial

```text
di meja kerja
di gym
di kamar
```

### Social

```text
setelah meeting
setelah mengantar anak
```

## 7.1 Prinsip desain

Daripada hanya:

```text
Reminder:
20:00
```

dukung:

```text
Cue:
Setelah makan malam
→ baca 5 halaman
```

Ini lebih dekat dengan mekanisme habit.

---

# 8. Implementation Intentions

Implementation intention menggunakan format:

> **Jika X terjadi, saya akan melakukan Y.**

Meta-analysis Gollwitzer & Sheeran atas 94 independent tests menemukan efek medium-to-large terhadap goal attainment.

Contoh:

```text
Jika selesai sarapan,
saya akan minum vitamin.
```

atau:

```text
Setelah menyikat gigi malam,
saya akan menulis jurnal 3 menit.
```

## 8.1 UI habit setup

Gunakan struktur:

```text
WHEN
Setelah...

WHERE
Di...

ACTION
Saya akan...

MINIMUM VERSION
Setidaknya...
```

Contoh:

```text
Setelah membuka laptop kerja
saya akan menulis 3 prioritas
selama minimal 2 menit.
```

---

# 9. Self-Monitoring dan Feedback

Meta-analysis Harkin et al. atas 138 studies menemukan progress monitoring meningkatkan goal attainment.

Implikasi:

Tracking memang bernilai.

Tetapi tracking harus:

- mudah;
- relevan;
- dapat dipahami;
- menghasilkan feedback;
- mengarah ke adjustment.

Tracking tanpa reflection dapat berubah menjadi pengumpulan angka tanpa makna.

## 9.1 Feedback loop

```text
DO
↓
TRACK
↓
SEE
↓
REFLECT
↓
ADJUST
↓
DO
```

Jangan berhenti pada:

```text
DO
↓
CHECKMARK
```

---

# 10. Self-Determination Theory

Self-Determination Theory menekankan tiga kebutuhan psikologis:

1. **Autonomy**
2. **Competence**
3. **Relatedness**

## 10.1 Autonomy

Pengguna merasa:

> "Saya memilih ini."

Bukan:

> "Aplikasi memaksa saya."

### UI

Berikan kontrol terhadap:

- goal;
- frequency;
- reminder;
- wording;
- icon;
- color;
- streak visibility;
- gamification;
- social sharing.

## 10.2 Competence

Pengguna merasa:

> "Saya mampu."

Dukung dengan:

- small goals;
- visible progress;
- achievable targets;
- meaningful feedback;
- recovery guidance.

## 10.3 Relatedness

Jika social feature digunakan, fokus pada:

- support;
- accountability yang dipilih;
- shared encouragement.

Bukan leaderboard wajib.

---

# 11. COM-B

COM-B menjelaskan behavior sebagai interaksi:

```text
Capability
Opportunity
Motivation
↓
Behavior
```

## 11.1 Capability

Apakah pengguna mampu melakukan habit?

Contoh masalah:

```text
"Olahraga 1 jam setiap hari"
```

terlalu berat.

UI dapat menawarkan:

```text
Mulai dengan 10 menit?
```

## 11.2 Opportunity

Apakah konteks mendukung?

Contoh:

```text
Meditasi di kantor saat meeting
```

mungkin tidak realistis.

Bantu pengguna memilih context yang sesuai.

## 11.3 Motivation

Apakah habit bermakna?

Onboarding dapat bertanya:

```text
Kenapa kebiasaan ini penting untukmu?
```

Jawaban disimpan sebagai private reminder.

---

# 12. Self-Compassion dan Recovery

Kegagalan tidak harus dibingkai sebagai identitas.

Penelitian Breines & Chen menunjukkan self-compassion setelah kegagalan dapat meningkatkan motivasi self-improvement.

Implikasi desain:

Buruk:

```text
Streak hilang.
Kamu gagal menjaga konsistensi.
```

Lebih baik:

```text
Kemarin terlewat.
Progress-mu tetap ada.

Lanjut hari ini?
```

## 12.1 Recovery-first design

Setelah lapse:

```text
Acknowledge
↓
Normalize
↓
Reduce friction
↓
Restart
```

Bukan:

```text
Shame
↓
Loss
↓
Punishment
```

---

# 13. Personal Informatics

Model Personal Informatics memandang self-tracking sebagai beberapa tahap:

```text
Preparation
Collection
Integration
Reflection
Action
```

Aplikasi habit/journal sering kuat pada:

```text
Collection
```

tetapi lemah pada:

```text
Reflection
Action
```

## 13.1 Design implication

Jangan hanya memiliki:

```text
✅ ✅ ✅ ✅ ✅
```

Tambahkan:

```text
Apa yang membuat minggu ini lebih mudah?

Kapan habit paling sering berhasil?

Apa yang ingin kamu ubah minggu depan?
```

---

# 14. Journaling dan Reflective Practice

Journaling dapat membantu reflection dan sensemaking.

Tetapi evidence mengenai manfaat kesehatan expressive writing tidak seragam.

Karena itu:

> Journaling harus dipresentasikan sebagai alat refleksi, bukan obat universal.

## 14.1 Tiga mode journal

### Capture

```text
Apa yang terjadi?
```

### Understand

```text
Apa yang kamu rasakan?
Apa yang memengaruhinya?
```

### Adjust

```text
Apa yang ingin kamu lakukan berikutnya?
```

---

# 15. Affect Labeling dan Mood Check-In

Affect labeling berarti memberi nama pada emosi.

Penelitian menunjukkan memberi label emosi dapat berperan dalam emotion regulation.

UI mood check-in sebaiknya membantu pengguna:

```text
merasakan
→ memberi nama
→ menambah konteks
```

bukan hanya:

```text
🙂 😐 😢
```

## 15.1 Mood flow

```text
Bagaimana perasaanmu?

Calm
Happy
Tired
Anxious
Frustrated
Sad
Other
```

kemudian optional:

```text
Apa yang paling memengaruhi?
```

---

# 16. Gratitude dan Positive Reflection

Meta-analysis lintas 145 studies di 28 negara menemukan gratitude interventions memberi peningkatan well-being rata-rata yang kecil dan bervariasi antarbudaya.

Implikasi:

Jangan:

```text
"3 gratitude setiap hari akan membuatmu lebih bahagia."
```

Gunakan:

```text
"Ingin mencatat sesuatu yang kamu hargai hari ini?"
```

Optional.

---

# 17. Prinsip Etis Psychology-Driven Design

Psychology-driven design bukan berarti:

> menggunakan bias manusia untuk mempertahankan retention.

Harus dibedakan:

### Supportive persuasion

Membantu tujuan yang dipilih pengguna.

### Manipulative persuasion

Mendorong perilaku demi KPI produk.

## 17.1 Jangan optimalkan compulsive engagement

Hindari:

- artificial urgency;
- shame notification;
- fake scarcity;
- random rewards berlebihan;
- streak hostage;
- leaderboard wajib;
- guilt;
- punitive loss.

## 17.2 Definition of success

Produk sukses ketika pengguna:

- melakukan habit;
- memahami dirinya;
- merasa lebih mampu;
- dapat kembali setelah lapse;
- tidak takut membuka aplikasi.

---

# 18. North Star Experience

Pengalaman ideal:

> **Open → Understand Today → Act → Confirm → Reflect → Leave.**

Aplikasi tidak harus membuat pengguna tinggal lama.

## 18.1 Habit mode

```text
OPEN
↓
SEE TODAY
↓
COMPLETE
↓
FEEDBACK
↓
CLOSE
```

## 18.2 Journal mode

```text
OPEN
↓
SETTLE
↓
WRITE
↓
OPTIONAL REFLECTION
↓
SAVE
↓
CLOSE
```

---

# 19. Mental Model Aplikasi

Pisahkan tiga mental mode.

## DO

Untuk menyelesaikan habit.

## REFLECT

Untuk journaling dan mood.

## REVIEW

Untuk melihat pola.

Jangan mencampur ketiganya terlalu agresif pada satu layar.

---

# 20. Information Architecture

Struktur mobile yang direkomendasikan:

```text
Today
Journal
Progress
Insights
Profile
```

Alternatif yang lebih minimal:

```text
Today
Journal
Insights
```

Settings berada di profile.

## 20.1 Today

Fokus:

- habit hari ini;
- quick mood;
- quick journal;
- progress ringan.

## 20.2 Journal

Fokus:

- entries;
- new entry;
- prompts;
- search;
- filters.

## 20.3 Progress

Fokus:

- completion;
- consistency;
- streak;
- calendar.

## 20.4 Insights

Fokus:

- pattern;
- weekly reflection;
- context.

---

# 21. Onboarding Psychology

Onboarding harus membangun:

```text
Meaning
+
Agency
+
Small commitment
```

Bukan mengumpulkan 20 data profile.

## 21.1 Flow

### Step 1 — Intent

```text
Apa yang ingin kamu bangun?
```

### Step 2 — Meaning

```text
Kenapa ini penting untukmu?
```

optional.

### Step 3 — Small action

```text
Apa versi paling ringan yang tetap terasa berarti?
```

### Step 4 — Cue

```text
Kapan paling mudah melakukannya?
```

### Step 5 — Reminder

```text
Perlu diingatkan?
```

### Step 6 — Start

```text
Siap untuk percobaan pertama.
```

## 21.2 Hindari overcommitment

Jangan mendorong:

```text
Tambah 10 habits sekarang!
```

Default lebih baik:

```text
Mulai dengan 1–3 habit.
```

---

# 22. Habit Creation Flow

Form ideal:

```text
Habit name
↓
Why
↓
Frequency
↓
Cue
↓
Minimum version
↓
Reminder
↓
Start date
```

## 22.1 Habit name

Action-oriented.

Lebih baik:

```text
Baca 5 halaman
```

daripada:

```text
Membaca
```

## 22.2 Minimum viable habit

Tambahkan:

```text
Versi minimum
```

Contoh:

```text
Target:
30 menit olahraga

Minimum:
5 menit stretching
```

Tujuan:

mengurangi all-or-nothing thinking.

---

# 23. Cue Design

Cue builder:

```text
[After] [Activity]
[At] [Place]
```

Contoh:

```text
After: Morning coffee
At: Desk
```

## 23.1 Cue strength

Tampilkan sebagai helper:

```text
Cue yang terhubung dengan rutinitas yang sudah ada
biasanya lebih mudah diingat.
```

---

# 24. Frequency dan Scheduling

Jangan mengasumsikan semua habit harus daily.

Opsi:

```text
Daily
Specific days
X times per week
Interval
Custom
```

## 24.1 Weekly habits

Untuk:

```text
Gym 3×/week
```

streak sebaiknya berdasarkan **weekly target**.

Jangan memaksakan daily streak.

## 24.2 Flexible schedule

Jika target:

```text
3× minggu
```

home dapat menunjukkan:

```text
2 / 3 minggu ini
```

bukan:

```text
🔥 0-day streak
```

---

# 25. Habit Card

Card harus cepat dipahami.

```text
[Icon] Read 5 pages
       After dinner

       4 / 5 this week

       [Complete]
```

## 25.1 Hierarchy

1. action;
2. cue;
3. status;
4. primary action.

Metadata sekunder tidak boleh mengganggu.

## 25.2 States

```text
Upcoming
Available
Completed
Skipped
Missed
Paused
```

---

# 26. Completion Interaction

Completion harus sangat rendah friction.

### Tap

```text
○
```

menjadi:

```text
✓
```

## 26.1 Feedback

Gunakan:

- check animation;
- subtle haptic;
- progress update.

Tidak perlu:

- modal;
- confetti;
- full-screen interruption;

untuk setiap completion.

## 26.2 Optional details

Setelah selesai:

```text
✓ Done

Add note
Mood
Duration
```

optional.

Jangan wajibkan banyak input.

---

# 27. Streak Psychology

Streak dapat menjadi motivational representation.

Studi Journal of Consumer Research menunjukkan bahwa ketika recent repeated behavior ditampilkan sebagai intact streak, pengguna cenderung lebih terdorong melanjutkan; broken streak yang disorot dapat mengurangi motivasi.

Artinya streak memiliki dua sisi.

## 27.1 Gunakan streak sebagai momentum

Copy:

```text
7 days in rhythm
```

atau:

```text
7 hari konsisten
```

## 27.2 Jangan gunakan streak sebagai ancaman

Hindari:

```text
⚠ STREAK AKAN HILANG!
TINGGAL 2 JAM!
```

kecuali pengguna secara eksplisit memilih reminder tersebut.

## 27.3 Jangan menyamakan streak dengan worth

Jangan:

```text
Perfect!
Unstoppable!
```

secara berlebihan.

Lebih baik:

```text
7 repetitions.
Rutinitasmu mulai terbentuk.
```

---

# 28. Progress Tanpa Ketergantungan pada Streak

Gunakan beberapa model.

## 28.1 Completion rate

```text
18 / 21 planned
86%
```

## 28.2 Repetition count

```text
42 repetitions
```

## 28.3 Weekly consistency

```text
This week
4 / 5
```

## 28.4 Monthly rhythm

Calendar.

## 28.5 Best streak

Optional.

## 28.6 Recovery count

Metric yang underrated:

```text
Kamu kembali 4 kali setelah jeda.
```

Ini memperkuat resilience.

---

# 29. Lapse, Missed Day, dan Recovery

Lapse harus dianggap bagian normal dari behavior change.

## 29.1 Visual treatment

Jangan membuat missed state:

- merah terang;
- cross besar;
- shame icon.

Gunakan neutral:

```text
○ Not completed
```

atau:

```text
— Missed
```

## 29.2 Re-entry

Setelah beberapa hari:

```text
Welcome back.

Mau melanjutkan target yang sama
atau membuatnya lebih ringan?
```

## 29.3 Recovery options

```text
Continue
Reduce target
Change cue
Pause habit
```

---

# 30. Pause, Skip, Rest, dan Exception

Manusia memiliki:

- sakit;
- perjalanan;
- deadline;
- libur;
- perubahan rutinitas.

Design system harus mengakomodasi real life.

## 30.1 Skip

```text
Skip today
```

optional reason:

```text
Sick
Travel
Rest
Schedule changed
Other
```

## 30.2 Pause

```text
Pause until...
```

Jangan menghukum pause sebagai kegagalan.

---

# 31. Rewards dan Gamification

Gamification dapat membantu engagement awal, tetapi jangan menjadikannya fondasi satu-satunya.

## 31.1 Better rewards

Fokus pada:

- acknowledgment;
- mastery;
- progress;
- reflection.

Contoh:

```text
10 repetitions completed.
```

## 31.2 Cosmetic rewards

Jika digunakan:

- optional;
- tidak menghalangi fitur inti;
- tidak menghasilkan pressure.

## 31.3 Avoid overjustification

Jangan sampai pengguna berpikir:

> "Saya membaca hanya untuk XP."

Reward harus menunjang, bukan menggantikan nilai intrinsik.

---

# 32. Reminder dan Notification Psychology

Reminder memiliki fungsi:

```text
support memory
```

bukan:

```text
control user
```

## 32.1 Reminder types

### Time-based

```text
20:00
```

### Routine-based

```text
After dinner
```

### Context-aware

Jika teknologi mendukung.

### Recovery

```text
Sudah beberapa hari sejak terakhir check-in.
Mau lanjut dengan versi ringan?
```

## 32.2 Ask permission meaningfully

Jangan meminta notification permission saat launch tanpa konteks.

Flow:

```text
Pilih habit
↓
Pilih reminder
↓
Jelaskan manfaat
↓
Request OS permission
```

---

# 33. Context-Aware Reminder

Systematic review 2024 menunjukkan digital habit interventions banyak menggunakan time-based cue, sementara context-aware cue masih relatif jarang diteliti/digunakan.

Artinya:

> context-aware reminder menjanjikan, tetapi jangan dianggap otomatis lebih efektif tanpa testing.

## 33.1 Examples

Jika privacy memungkinkan dan user opt-in:

```text
Saat tiba di gym
Saat pulang ke rumah
Setelah focus session
```

## 33.2 Prefer routine over surveillance

Jangan mengumpulkan data lokasi terus-menerus jika simple routine cue sudah cukup.

---

# 34. Notification Fatigue

Notifikasi memiliki cognitive cost.

Penelitian notification batching menunjukkan predictable batching dapat meningkatkan rasa kontrol, attentiveness, dan productivity dibanding notifikasi biasa pada konteks yang diteliti.

Riset 2026 juga menunjukkan smartphone-style notifications dapat menimbulkan gangguan perhatian sementara.

## 34.1 Default

Jangan:

```text
1 reminder per habit
× 12 habits
= 12 notifications
```

Gunakan:

```text
Morning plan
Evening reflection
```

atau summary bila pengguna menginginkannya.

## 34.2 Notification hierarchy

### Essential

User explicitly scheduled.

### Helpful

Weekly review.

### Optional

Motivational message.

### Avoid

Marketing disguised as habit reminder.

---

# 35. Home / Today Screen

Tujuan:

> mengetahui "apa yang relevan sekarang" dalam satu scan.

## 35.1 Struktur

```text
Good morning

TODAY
3 habits remaining

○ Drink water
✓ Morning walk
○ Read 5 pages

QUICK REFLECTION
How are you feeling?

[+ Journal]
```

## 35.2 Jangan overload

Jangan tampilkan sekaligus:

- 12 KPI;
- streak;
- XP;
- badges;
- quotes;
- ads;
- challenge;
- upsell;
- community feed.

Today bukan dashboard analytics.

---

# 36. Journaling System

Journaling memiliki dua mode penting:

### Low-friction capture

Untuk menulis cepat.

### Deep reflection

Untuk sesi lebih lama.

## 36.1 Editor hierarchy

```text
Date
Mood optional
Title optional
Body
Tags optional
```

Body harus menjadi fokus.

## 36.2 Autosave

Journal harus autosave.

Trust sangat penting.

Tampilkan state:

```text
Saving…
Saved
Offline — saved locally
```

---

# 37. Free Journal

Free journal harus benar-benar bebas.

Jangan paksa:

- word count;
- prompt;
- score;
- mood.

## 37.1 Editor design

Minim distraction.

```text
←
September 4

What’s on your mind?

|
```

Toolbar tidak perlu dominan.

---

# 38. Guided Journal

Guided journal cocok ketika pengguna tidak tahu harus menulis apa.

Kategori:

```text
Daily reflection
Gratitude
Problem solving
Planning
Emotion
Wins
Learning
Relationships
```

## 38.1 Progressive prompting

Jangan tampilkan 10 pertanyaan sekaligus.

Gunakan satu per satu jika mode guided:

```text
Apa yang paling menonjol hari ini?
↓
Apa yang kamu rasakan?
↓
Apa yang ingin kamu bawa ke besok?
```

---

# 39. Reflection Prompt Design

Prompt yang baik:

- specific;
- optional;
- non-judgmental;
- open enough;
- tidak memaksakan positivity.

## 39.1 Hindari leading prompt

Buruk:

```text
Kenapa hari ini luar biasa?
```

Lebih baik:

```text
Apa yang paling kamu ingat dari hari ini?
```

## 39.2 Action reflection

```text
Apa yang membuat habit ini lebih mudah hari ini?
```

## 39.3 Barrier reflection

```text
Apa yang menghalangi?
```

tanpa menyalahkan.

---

# 40. Mood Tracking

Mood tracking bukan diagnosis.

UI harus menjelaskan:

> Mood adalah self-report sesaat, bukan label identitas.

## 40.1 Scale design

Hindari hanya:

```text
😄 🙂 😐 🙁 😭
```

karena valence saja kurang kaya.

Alternatif:

### Valence + energy

```text
Positive / Negative
High / Low energy
```

atau emotion labels.

## 40.2 Tags

```text
Work
Sleep
Family
Health
Social
Weather
Exercise
```

optional.

## 40.3 No causal overclaim

Jangan:

```text
"Kopi menyebabkan kecemasanmu."
```

Lebih aman:

```text
"Pada hari ketika kamu mencatat kopi sore,
mood cemas juga lebih sering tercatat.
Ini hanya pola pada data yang kamu masukkan."
```

---

# 41. Weekly Review

Weekly review merupakan jembatan:

```text
data → meaning
```

## 41.1 Struktur

```text
Your Week

Completed
18 / 21

Most consistent
Morning walk

Hardest
Read before bed

Mood
Mostly calm / tired

Reflection
What helped this week?

Next week
Keep / Adjust / Pause
```

## 41.2 Actionable

Setiap insight idealnya memiliki opsi:

```text
Keep
Change schedule
Reduce target
```

---

# 42. Monthly Review

Monthly review lebih makro.

Tampilkan:

- repetitions;
- consistency trend;
- active habits;
- paused habits;
- mood pattern;
- journal frequency;
- meaningful highlights.

## 42.1 Jangan jadikan monthly review rapor moral

Hindari:

```text
Score: 63/100
```

tanpa makna jelas.

---

# 43. Calendar dan Heatmap

Calendar bagus untuk pattern recognition.

Tetapi full green heatmap dapat memicu:

> all-or-nothing interpretation.

## 43.1 Semantic levels

Contoh:

```text
Completed
Partial
Skipped
No plan
Missed
```

Jangan semua non-complete = merah.

## 43.2 No-plan day

Harus dibedakan dari missed.

Jika habit hanya Senin, Rabu, Jumat:

Selasa bukan kegagalan.

---

# 44. Insights dan Pattern Recognition

Insight harus:

1. dapat dijelaskan;
2. berdasarkan data cukup;
3. tidak overclaim;
4. actionable.

## 44.1 Good insight

```text
Dalam 4 minggu terakhir,
kamu menyelesaikan "Read" lebih sering
ketika dijadwalkan sebelum 21:00.
```

## 44.2 Weak insight

```text
You are a night person.
```

Terlalu menyimpulkan identitas.

---

# 45. AI-Generated Insights

Jika AI digunakan pada journal:

privacy, consent, dan epistemic humility menjadi kritis.

## 45.1 AI tidak boleh

- mendiagnosis;
- mengklaim tahu emosi sebenarnya;
- membuat kesimpulan absolut;
- memunculkan detail sensitif secara mengejutkan;
- mengirim isi jurnal ke model tanpa disclosure.

## 45.2 Better wording

Jangan:

```text
"Kamu mengalami burnout."
```

Gunakan:

```text
"Beberapa entry minggu ini menyebut lelah,
deadline, dan sulit fokus.

Apakah pola ini terasa relevan bagimu?"
```

## 45.3 User control

Berikan:

```text
AI insights: On / Off
Include journal text: On / Off
Delete generated insights
```

---

# 46. Visual Hierarchy

Hierarki harus menyesuaikan mode.

## 46.1 Today

Prioritas:

```text
Current action
↓
Completion
↓
Remaining
↓
Reflection
```

## 46.2 Journal

Prioritas:

```text
Writing area
↓
Prompt
↓
Metadata
```

## 46.3 Insights

Prioritas:

```text
Pattern
↓
Meaning
↓
Action
```

---

# 47. Shape Psychology

Gunakan shape untuk fungsi.

Baseline:

| Component | Radius awal |
|---|---:|
| Input | 8–12 px |
| Button | 10–14 px |
| Habit card | 12–16 px |
| Journal card | 14–18 px |
| Sheet/Dialog | 16–24 px |
| Badge | pill bila benar-benar status |

Angka adalah heuristic.

## 47.1 Rounded but not childish

Wellness UI sering terlalu rounded.

Tujuan:

- approachable;
- soft;

tetapi tetap:

- mature;
- clear;
- structured.

---

# 48. Color System

Jangan menggunakan "color psychology" populer secara literal.

Contoh simplifikasi:

```text
Blue = trust
Green = health
Purple = creativity
```

tidak cukup sebagai dasar sistem.

Gunakan **semantic role**.

## 48.1 Suggested roles

```text
Primary
Secondary
Background
Surface
Surface Elevated
Text Primary
Text Secondary
Border
Success
Attention
Error
Info
Rest
Paused
```

## 48.2 Completion

Success boleh menggunakan green.

Tetapi jangan membuat missed day merah agresif.

Missed lebih tepat:

```text
neutral / muted
```

Error merah disimpan untuk:

- sync failed;
- data loss risk;
- invalid action.

## 48.3 Mood colors

Jika mood menggunakan warna:

selalu sertakan label.

```text
Calm
```

bukan hanya warna biru.

---

# 49. Typography

Karakter:

- readable;
- calm;
- warm;
- high legibility.

## 49.1 Roles

```text
Display
Title
Heading
Body
Label
Caption
Numeric
```

## 49.2 Journal typography

Writing area sebaiknya:

- line-height nyaman;
- width tidak terlalu lebar;
- tidak padat.

## 49.3 Numerical data

Untuk consistency dan charts:

gunakan tabular numerals bila tersedia.

---

# 50. Spacing dan Gestalt

Gunakan proximity untuk grouping.

Scale awal:

```text
4
8
12
16
24
32
40
48
64
```

## 50.1 Reflection needs breathing room

Journal screen membutuhkan whitespace lebih besar daripada analytics screen.

---

# 51. Iconography

Icon harus recognizable.

Habit dapat menggunakan user-selected icons:

```text
📖
🏃
💧
🧘
```

tetapi jangan bergantung hanya emoji bila gaya produk membutuhkan konsistensi lintas platform.

## 51.1 Critical actions

Gunakan icon + text:

```text
Delete journal entry
Pause habit
Reset data
```

---

# 52. Touch Targets dan Motor Interaction

WCAG 2.2 Level AA menetapkan target pointer minimum 24×24 CSS px dengan pengecualian tertentu.

Target Size Enhanced Level AAA menggunakan 44×44 CSS px.

Untuk aplikasi mobile habit:

> gunakan sekitar **44–48 px** sebagai practical baseline untuk target utama.

## 52.1 Completion target

Checkbox habit jangan berupa lingkaran kecil 18px yang hanya area visualnya clickable.

Buat hit area minimal sekitar 44px.

---

# 53. Motion dan Animation

Motion harus:

- memberikan feedback;
- menjaga continuity;
- menunjukkan state transition.

## 53.1 Completion

```text
○ → ✓
```

100–180ms baseline.

## 53.2 Card change

Completed card dapat:

- reduce emphasis;
- move ke Completed section;

tetapi hindari gerakan yang membuat layout lompat secara membingungkan.

## 53.3 Celebration

Milestone besar:

```text
30 repetitions
```

boleh memiliki small celebratory motion.

Tetapi jangan setiap completion.

## 53.4 Reduced motion

Hormati `prefers-reduced-motion` atau setting platform.

WCAG 2.3.3 secara khusus membahas kemampuan menonaktifkan motion animation yang dipicu interaksi pada Level AAA.

---

# 54. Haptic dan Sound

Haptic:

- optional;
- subtle;
- useful for completion.

Sound:

default sebaiknya minimal.

Journal adalah ruang reflektif; sound berlebih dapat mengganggu.

---

# 55. Microcopy dan Tone of Voice

Tone ideal:

> calm, neutral-positive, specific, non-judgmental.

## 55.1 Completion

```text
Done.
```

atau:

```text
Completed.
```

Tidak perlu:

```text
AMAZING!!! YOU'RE A LEGEND!!!
```

setiap kali.

## 55.2 Lapse

Jangan:

```text
You failed.
```

Gunakan:

```text
Kemarin terlewat.
Mau lanjut hari ini?
```

## 55.3 Long absence

```text
Welcome back.
Tidak perlu mengejar hari yang terlewat.

Mulai lagi dari hari ini.
```

---

# 56. Component Architecture

Design system minimal:

## Foundation

- Color
- Type
- Spacing
- Radius
- Elevation
- Motion
- Icon
- Haptic

## Inputs

- Button
- Checkbox
- Toggle
- Slider
- Text field
- Text area
- Chip
- Segmented control
- Date picker
- Time picker

## Habit

- Habit card
- Completion control
- Frequency control
- Cue builder
- Streak indicator
- Consistency indicator
- Habit summary

## Journal

- Journal editor
- Prompt card
- Mood selector
- Emotion chip
- Tag chip
- Entry preview

## Feedback

- Toast
- Snackbar
- Inline feedback
- Banner
- Dialog
- Bottom sheet

## Data

- Calendar
- Heatmap
- Progress bar
- Trend
- Insight card
- Weekly summary

---

# 57. Component States

Setiap interactive component:

```text
Default
Hover
Pressed
Focus
Selected
Disabled
Loading
Error
```

Habit-specific:

```text
Upcoming
Due
Completed
Skipped
Missed
Paused
```

Journal-specific:

```text
Draft
Saving
Saved
Offline
Sync failed
Locked
```

---

# 58. Empty, Loading, Error, Offline

## Empty journal

```text
Belum ada entry.

Mulai dengan apa pun yang sedang ada di pikiranmu.
```

## Empty habits

```text
Belum ada habit aktif.

Mulai dengan satu hal kecil.
```

## Offline journal

```text
Offline
Entry disimpan di perangkat dan akan disinkronkan nanti.
```

hanya jika benar secara teknis.

## Sync failed

```text
Entry tersimpan di perangkat,
tetapi belum berhasil disinkronkan.

[Coba Lagi]
```

---

# 59. Privacy dan Psychological Safety

Journal adalah data yang sangat pribadi.

Privacy bukan sekadar legal requirement.

Privacy memengaruhi:

> willingness to disclose.

Systematic review digital mental health menemukan rasa privacy/confidentiality dapat menjadi facilitator engagement, sedangkan concern terhadap data menjadi barrier.

## 59.1 Privacy cues

Tampilkan dengan jelas:

```text
Private by default
```

jika benar.

## 59.2 App lock

Dukung:

- PIN;
- biometric;
- hide preview.

## 59.3 Notification privacy

Jangan default mengirim:

```text
"Jangan lupa menulis tentang kecemasanmu."
```

pada lock screen.

Lebih aman:

```text
Waktunya check-in.
```

Pengguna dapat memilih detail.

## 59.4 Export dan delete

Sediakan:

```text
Export my data
Delete selected entries
Delete all data
```

---

# 60. Accessibility

Accessibility harus default.

## 60.1 Contrast

WCAG 2.2:

- normal text: 4.5:1 minimum pada Level AA;
- large text: 3:1;
- relevant non-text UI contrast: 3:1.

## 60.2 Use of color

Completion/mood/status tidak boleh color-only.

## 60.3 Focus

Web/desktop:

- clear focus ring;
- logical keyboard order.

## 60.4 Touch

Gunakan practical baseline 44–48px untuk mobile controls penting.

## 60.5 Motion

Dukung reduced motion.

## 60.6 Text scaling

Journal dan habit list harus tetap usable pada font size besar.

---

# 61. Responsive dan Platform

## Mobile

Primary.

Gunakan:

- thumb-friendly;
- bottom navigation;
- bottom sheet;
- large targets.

## Tablet

Dapat menggunakan split view:

```text
Journal list | Entry
```

## Desktop/Web

Dapat menggunakan:

```text
Sidebar | Main content | Context panel
```

Tetapi jangan membuat density terlalu tinggi hanya karena layar besar.

---

# 62. Design Tokens

## Color

```yaml
color:
  bg:
    primary:
    secondary:

  surface:
    primary:
    elevated:
    subtle:

  text:
    primary:
    secondary:
    tertiary:
    inverse:

  border:
    subtle:
    strong:

  action:
    primary:
    hover:
    pressed:

  semantic:
    success:
    info:
    attention:
    error:
    paused:
    rest:
```

## Spacing

```yaml
space:
  1: 4
  2: 8
  3: 12
  4: 16
  5: 24
  6: 32
  7: 40
  8: 48
  9: 64
```

## Radius

```yaml
radius:
  sm: 8
  md: 12
  lg: 16
  xl: 20
  full: 9999
```

## Motion

```yaml
motion:
  instant: 80ms
  micro: 120ms
  fast: 160ms
  normal: 220ms
  slow: 300ms
```

Gunakan `slow` sangat terbatas.

## Target

```yaml
target:
  minimum-practical: 44
  normal: 48
  prominent: 56
```

---

# 63. Screen-Level Specifications

## 63.1 Today

```text
HEADER
Greeting
Date

PROGRESS
3 of 5 completed

HABITS
○ Habit A
✓ Habit B
○ Habit C

REFLECTION
Mood check-in
Journal shortcut

NAV
Today | Journal | Progress | Profile
```

## 63.2 Habit Detail

```text
Habit name
Why
Cue
Frequency

This week
4 / 5

Calendar

Recent notes

Adjust habit
Pause
Archive
```

## 63.3 Journal Editor

```text
Back
Date
Save status

Title optional

Body

Mood optional
Tags optional
```

Keep chrome minimal.

## 63.4 Progress

```text
This Week
18 / 21

Consistency by habit

Calendar

Repetitions

Recovery / return
```

## 63.5 Weekly Review

```text
What happened
↓
What helped
↓
What was difficult
↓
What will change
```

---

# 64. Anti-Patterns

## 64.1 Streak hostage

```text
"Login now or lose 243 days!"
```

## 64.2 Shame

```text
"You're falling behind."
```

## 64.3 Fake urgency

```text
"Only 30 minutes left!"
```

untuk habit yang sebenarnya tidak memiliki deadline intrinsik.

## 64.4 Too many habits

Mendorong user membuat sebanyak mungkin habit.

## 64.5 Confetti everywhere

Reward kehilangan makna.

## 64.6 Over-notification

Reminder per habit tanpa batching/control.

## 64.7 Binary success

```text
complete / failure
```

untuk semua habit.

Dukung partial/minimum version jika relevan.

## 64.8 Toxic positivity

```text
"Always be grateful."
```

## 64.9 Diagnostic insight

```text
"Your journal proves you have..."
```

## 64.10 Social comparison by default

Leaderboard dapat memicu comparison yang tidak relevan dengan intrinsic goal.

## 64.11 Data without action

Charts yang tidak membantu keputusan.

## 64.12 Punitive color

Membuat kalender penuh merah saat user sedang sakit/libur.

---

# 65. Usability Testing

Uji dengan skenario nyata.

## Scenario 1

Buat habit pertama.

Ukur:

- completion time;
- confusion;
- cue understanding.

## Scenario 2

Complete habit.

Ukur:

- taps;
- perceived feedback.

## Scenario 3

Miss 3 days.

Tanyakan:

- apa yang dirasakan?
- apakah user ingin kembali?

## Scenario 4

Pause habit.

Pastikan pengguna menemukan fungsi tanpa takut progress hilang.

## Scenario 5

Write journal.

Ukur:

- distraction;
- trust;
- autosave clarity.

## Scenario 6

Review week.

Tanyakan:

> Apa yang kamu pelajari?

Jika user hanya menjawab:

> "Saya dapat 84%."

reflection design belum cukup.

---

# 66. Behavioral Metrics

Jangan hanya ukur:

```text
DAU
Session duration
Notifications opened
```

## 66.1 Better product metrics

### Action completion

```text
planned habit → performed
```

### Logging friction

Median time untuk check-off.

### Recovery rate

Berapa banyak pengguna kembali setelah lapse?

### Adjustment rate

Apakah user menggunakan:

- reduce target;
- change cue;
- pause?

### Reflection utility

Apakah weekly review menghasilkan perubahan plan?

### Notification dependence

Apakah habit tetap dilakukan tanpa notification?

### Notification opt-out

High opt-out dapat menandakan reminder terlalu agresif.

### Journal trust

- draft loss;
- sync error;
- delete/export use.

---

# 67. A/B Testing dengan Guardrails

Jangan mengoptimalkan hanya:

```text
streak retention
```

A/B test harus memiliki guardrail.

Contoh:

### Experiment

Urgent streak notification vs calm reminder.

### Primary

Habit completion.

### Guardrails

- notification opt-out;
- app uninstall;
- negative feedback;
- next-week return after lapse.

## 67.1 Ethical metric

Jika variant meningkatkan app opens tetapi:

- lebih banyak notification disable;
- lebih banyak stress;
- lebih sedikit recovery setelah broken streak;

variant tidak otomatis lebih baik.

---

# 68. Checklist Implementasi

## Habit

- [ ] User dapat menentukan frequency sendiri.
- [ ] Non-daily habit didukung.
- [ ] Cue dapat disimpan.
- [ ] Minimum version dapat ditentukan.
- [ ] Completion satu tap.
- [ ] Skip berbeda dari miss.
- [ ] Pause tersedia.
- [ ] Lapse tidak menghapus historical progress.
- [ ] Streak tidak menjadi satu-satunya metric.
- [ ] Weekly consistency tersedia.
- [ ] Recovery UX tersedia.

## Journal

- [ ] Free-writing tersedia.
- [ ] Guided prompts optional.
- [ ] Autosave.
- [ ] Save status terlihat.
- [ ] Offline state jelas.
- [ ] Mood optional.
- [ ] Tags optional.
- [ ] Search tersedia.
- [ ] Delete/export jelas.
- [ ] Private by default jika arsitektur mendukung.
- [ ] Lock/privacy control tersedia.

## Notification

- [ ] Permission diminta setelah value dijelaskan.
- [ ] User memilih reminder.
- [ ] Reminder dapat dimatikan per habit.
- [ ] Summary/batching tersedia bila relevan.
- [ ] Lock-screen privacy dipertimbangkan.
- [ ] Tidak ada shame copy.
- [ ] Tidak ada fake urgency.

## Visual

- [ ] Primary task terlihat dalam satu scan.
- [ ] Missed state tidak punitive.
- [ ] Semantic color konsisten.
- [ ] Mood tidak color-only.
- [ ] Contrast memenuhi target accessibility.
- [ ] Touch target cukup besar.
- [ ] Reduced motion didukung.
- [ ] Hierarchy Today berbeda dari Insights.

## Psychology

- [ ] Mendukung autonomy.
- [ ] Mendukung competence.
- [ ] Cue lebih penting daripada motivational quote.
- [ ] Reflection mengarah ke action.
- [ ] Recovery diperlakukan normal.
- [ ] Gamification optional/terkontrol.
- [ ] Progress tidak identik dengan perfect streak.

---

# 69. Golden Rules

1. **Habit adalah context–response association, bukan streak.**
2. **Bantu pengguna membuat cue yang stabil.**
3. **Gunakan implementation intention: ketika X, lakukan Y.**
4. **Mulai dari tindakan kecil yang realistis.**
5. **Self-monitoring harus menghasilkan feedback yang bermakna.**
6. **Autonomy lebih penting daripada coercion.**
7. **Competence tumbuh dari target yang achievable.**
8. **Satu missed day bukan reset psikologis.**
9. **Streak adalah momentum signal, bukan hostage mechanism.**
10. **Tampilkan progress dalam beberapa bentuk.**
11. **Recovery adalah bagian inti dari habit design.**
12. **Pause bukan failure.**
13. **No-plan day bukan missed day.**
14. **Reminder membantu memory; jangan menggantikan context cue.**
15. **Jangan memaksimalkan notification volume.**
16. **Journaling adalah reflection tool, bukan automatic therapy.**
17. **Prompt harus optional dan non-judgmental.**
18. **Mood tracking tidak boleh menjadi diagnosis.**
19. **Insight harus probabilistic, explainable, dan actionable.**
20. **Jangan menyimpulkan sebab-akibat dari korelasi self-tracking sederhana.**
21. **Journal privacy adalah bagian dari UX trust.**
22. **Success feedback harus jelas tetapi tidak berlebihan.**
23. **Motion harus menjelaskan state change.**
24. **Warna membawa semantic meaning, bukan pseudo-psychology.**
25. **Aksesibilitas harus built-in.**
26. **App engagement bukan tujuan akhir behavior change.**
27. **Produk harus membantu pengguna semakin mandiri.**
28. **Optimalkan return-after-lapse, bukan hanya streak preservation.**
29. **Data harus membantu pengguna memahami dan menyesuaikan.**
30. **Design psychology harus mendukung tujuan pengguna, bukan mengeksploitasi bias pengguna.**

---

# 70. Kesimpulan

Psychology Design System untuk habit dan journaling harus dibangun di atas pemahaman bahwa manusia tidak mempertahankan perilaku hanya karena:

- motivasi;
- notifikasi;
- streak;
- badge;
- quote.

Habit berkembang melalui:

```text
meaning
+
repetition
+
stable context
+
low friction
+
reinforcement
```

Sementara self-reflection berkembang melalui:

```text
capture
+
label
+
context
+
reflection
+
adjustment
```

Dan sustainability membutuhkan:

```text
autonomy
+
competence
+
recovery
+
trust
```

Sehingga formula desain utamanya adalah:

> **Low Friction Action + Stable Context + Meaningful Progress + Gentle Reflection + Recovery-First UX + User Autonomy**

Aplikasi terbaik bukan yang membuat pengguna takut kehilangan streak.

Aplikasi terbaik membuat pengguna berpikir:

> **"Saya tahu apa yang ingin saya lakukan, saya tahu kapan melakukannya, saya dapat melihat progress saya, dan jika saya terputus saya tahu bagaimana mulai lagi."**

---

# 71. Referensi

## Habit Formation

1. Lally, P., van Jaarsveld, C. H. M., Potts, H. W. W., & Wardle, J. (2010). **How are habits formed: Modelling habit formation in the real world.** *European Journal of Social Psychology, 40*, 998–1009.  
   https://doi.org/10.1002/ejsp.674

2. Wood, W. (2024). **Habits, Goals, and Effective Behavior Change.** *Current Directions in Psychological Science, 33*(4).  
   https://doi.org/10.1177/09637214241246480

3. Stojanovic, M., Grund, A., & Fries, S. (2022). **Context Stability in Habit Building Increases Automaticity and Goal Attainment.** *Frontiers in Psychology, 13*, 883795.  
   https://doi.org/10.3389/fpsyg.2022.883795

4. Gardner, B., Rebar, A. L., & Lally, P. (2022). **How does habit form? Guidelines for tracking real-world habit formation.**  
   https://doi.org/10.1080/23311908.2022.2041277

5. Stojanovic, M., & Wood, W. (2024). **Beyond deliberate self-control: Habits automatically achieve long-term goals.** *Current Opinion in Psychology, 60*, 101880.  
   https://doi.org/10.1016/j.copsyc.2024.101880

6. Zhu, L., et al. (2026). **Not all cues are equal: A systematic review and three-level meta-analysis of context consistency, physical activity and habit strength.** *Applied Psychology: Health and Well-Being, 18*(4), e70204.  
   https://doi.org/10.1111/aphw.70204

## Goals, Planning, Monitoring, and Behavior Change

7. Gollwitzer, P. M., & Sheeran, P. (2006). **Implementation Intentions and Goal Achievement: A Meta-analysis of Effects and Processes.** *Advances in Experimental Social Psychology, 38*, 69–119.  
   https://doi.org/10.1016/S0065-2601(06)38002-1

8. Harkin, B., Webb, T. L., Chang, B. P. I., et al. (2016). **Does Monitoring Goal Progress Promote Goal Attainment? A Meta-Analysis of the Experimental Evidence.** *Psychological Bulletin, 142*(2), 198–229.  
   https://doi.org/10.1037/bul0000025

9. Michie, S., van Stralen, M. M., & West, R. (2011). **The behaviour change wheel: A new method for characterising and designing behaviour change interventions.** *Implementation Science, 6*, 42.  
   https://doi.org/10.1186/1748-5908-6-42

10. Michie, S., Richardson, M., Johnston, M., et al. (2013). **The Behavior Change Technique Taxonomy (v1) of 93 Hierarchically Clustered Techniques.** *Annals of Behavioral Medicine, 46*(1), 81–95.  
    https://doi.org/10.1007/s12160-013-9486-6

11. **Digital Behavior Change Intervention Designs for Habit Formation: Systematic Review.** *Journal of Medical Internet Research* (2024), 26:e54375.  
    https://www.jmir.org/2024/1/e54375/

## Motivation and Self-Determination

12. Ryan, R. M., & Deci, E. L. (2020). **Intrinsic and extrinsic motivation from a self-determination theory perspective: Definitions, theory, practices, and future directions.** *Contemporary Educational Psychology, 61*, 101860.  
    https://doi.org/10.1016/j.cedpsych.2020.101860

13. Slemp, G. R., et al. (2021). **Interventions to support autonomy, competence, and relatedness needs in organizations: A systematic review.** *Journal of Occupational and Organizational Psychology.*  
    https://doi.org/10.1111/joop.12338

## Streaks, Gamification, and Motivation

14. Silverman, J., Barasch, A. P., & Small, D. A. **On or Off Track: How (Broken) Streaks Affect Consumer Decisions.** *Journal of Consumer Research, 49*(6), 1095–1116.  
    https://academic.oup.com/jcr/article/49/6/1095/6623414

15. Mehr, K. S., Silverman, J., Sharif, M. A., Barasch, A., & Milkman, K. L. (2025). **The motivating power of streaks: Increasing persistence is as easy as 1, 2, 3.** *Organizational Behavior and Human Decision Processes, 187*, 104391.  
    https://doi.org/10.1016/j.obhdp.2025.104391

16. Sami, I., & Matcham, F. (2026). **A Qualitative Study of Student Perspectives on Habit-Tracking Apps: Digital Interventions to Facilitate Habit Development.** *Journal of Technology in Behavioral Science.*  
    https://doi.org/10.1007/s41347-026-00707-2

## Self-Compassion and Recovery

17. Breines, J. G., & Chen, S. (2012). **Self-Compassion Increases Self-Improvement Motivation.** *Personality and Social Psychology Bulletin, 38*(9), 1133–1143.  
    https://doi.org/10.1177/0146167212445599

18. Biber, D. D., & Ellis, R. (2019). **The effect of self-compassion on the self-regulation of health behaviors: A systematic review.** *Journal of Health Psychology, 24*(14), 2060–2071.  
    https://doi.org/10.1177/1359105317713361

19. Anthes, L. S., & Dreisoerner, A. (2026). **Self-Compassion and Mental Health: A Systematic Review and Transactional Model on Mechanisms of Change.** *Mindfulness, 17*, 684–730.  
    https://doi.org/10.1007/s12671-025-02753-y

## Personal Informatics and Reflection

20. Li, I., Dey, A. K., & Forlizzi, J. (2010). **A Stage-Based Model of Personal Informatics Systems.** *CHI 2010*, 557–566.  
    https://doi.org/10.1145/1753326.1753409

21. Epstein, D. A., et al. **A Lived Informatics Model of Personal Informatics.**  
    https://pmc.ncbi.nlm.nih.gov/articles/PMC12435389/

22. **Exploring the role of reflective journaling in the use of wearable smartwatches.** *Telematics and Informatics Reports, 21* (2026), 100309.  
    https://doi.org/10.1016/j.teler.2026.100309

23. **Mobile apps for mood tracking: an analysis of features and user reviews.**  
    https://pmc.ncbi.nlm.nih.gov/articles/PMC5977660/

## Journaling, Emotion, and Well-Being

24. Torre, J. B., & Lieberman, M. D. (2018). **Putting Feelings Into Words: Affect Labeling as Implicit Emotion Regulation.** *Emotion Review, 10*(2).  
    https://doi.org/10.1177/1754073917742706

25. Reinhold, M., Bürkner, P. C., & Holling, H. (2009). **Health effects of expressive writing on stressful or traumatic experiences — a meta-analysis.**  
    https://pmc.ncbi.nlm.nih.gov/articles/PMC2736499/

26. Smyth, J. M., Johnson, J. A., Auer, B. J., et al. (2018). **Online Positive Affect Journaling in the Improvement of Mental Distress and Well-Being in General Medical Patients With Elevated Anxiety Symptoms: A Preliminary Randomized Controlled Trial.** *JMIR Mental Health, 5*(4), e11290.  
    https://doi.org/10.2196/11290

27. Choi, H., Cha, Y., McCullough, M. E., Coles, N. A., & Oishi, S. (2025). **A meta-analysis of the effectiveness of gratitude interventions on well-being across cultures.** *Proceedings of the National Academy of Sciences, 122*(28), e2425193122.  
    https://doi.org/10.1073/pnas.2425193122

## Notifications and Attention

28. Fitz, N., Kushlev, K., Jagannathan, R., Lewis, T., Paliwal, D., & Ariely, D. **Batching smartphone notifications can improve well-being.** *Computers in Human Behavior.*  
    https://www.sciencedirect.com/science/article/pii/S0747563219302596

29. Fournier, H., et al. (2026). **Attention hijacked: How social media notifications disrupt cognitive processing.** *Computers in Human Behavior, 179*, 108926.  
    https://doi.org/10.1016/j.chb.2026.108926

## Digital Mental Health, Engagement, Privacy, and Safety

30. Borghouts, J., Eikey, E., Mark, G., et al. (2021). **Barriers to and Facilitators of User Engagement With Digital Mental Health Interventions: Systematic Review.** *Journal of Medical Internet Research, 23*(3), e24387.  
    https://doi.org/10.2196/24387

31. Cheng, N., Lam, M. K., Grove, C., & Wachowicz, M. (2026). **Factors Influencing the Initiation and Continued Engagement of Digital Mental Health Tools Among Adults: Theory of Planned Behavior–Informed Systematic Review.** *JMIR Mental Health.*  
    PubMed: https://pubmed.ncbi.nlm.nih.gov/42139740/

32. **Systematic review and meta-analysis of adverse events in clinical trials of mental health apps.** *npj Digital Medicine, 7*, 363 (2024).  
    https://www.nature.com/articles/s41746-024-01388-y

## Accessibility

33. W3C. **Web Content Accessibility Guidelines (WCAG) 2.2.**  
    https://www.w3.org/TR/WCAG22/

34. W3C. **Understanding Target Size (Minimum) — SC 2.5.8.**  
    https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum

35. W3C. **Understanding Non-text Contrast — SC 1.4.11.**  
    https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast

36. W3C. **Animation from Interactions — SC 2.3.3.**  
    https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html

---

# Appendix A — Psychology → UI Mapping

| Psychology | Design Interpretation | UI Pattern |
|---|---|---|
| Context association | Bind behavior to stable cue | Cue builder |
| Implementation intention | If X → then Y | Habit setup |
| Self-monitoring | Record progress | Check-off |
| Feedback | Show consequence | Progress update |
| Autonomy | User ownership | Custom goals |
| Competence | Achievable mastery | Small steps |
| Self-compassion | Recovery after lapse | Welcome-back flow |
| Affect labeling | Name emotions | Mood labels |
| Personal informatics | Data → reflection → action | Weekly review |
| Attention management | Reduce interruption | Notification batching |
| Gestalt | Group related info | Cards/spacing |
| Fitts | Easy motor selection | Large targets |

---

# Appendix B — State Models

## Habit

```text
CREATED
↓
ACTIVE
├─ COMPLETED
├─ SKIPPED
├─ MISSED
└─ PAUSED

PAUSED
↓
RESUMED
```

## Daily Habit Instance

```text
UPCOMING
↓
DUE
├─ COMPLETED
├─ SKIPPED
└─ MISSED
```

## Journal

```text
NEW
↓
DRAFT
↓
SAVING
├─ SAVED
└─ SAVE_FAILED

SAVED
↓
SYNCING
├─ SYNCED
└─ SYNC_FAILED
```

## Reminder

```text
OFF
↓
SCHEDULED
↓
DELIVERED
├─ OPENED
├─ DISMISSED
└─ EXPIRED
```

Jangan memperlakukan `DISMISSED` sebagai user failure.

---

# Appendix C — Suggested Design Tokens

```yaml
foundation:

  color:
    background:
      canvas:
      subtle:

    surface:
      primary:
      elevated:
      interactive:

    text:
      primary:
      secondary:
      tertiary:
      inverse:

    border:
      subtle:
      default:
      focus:

    action:
      primary:
      primaryHover:
      primaryPressed:

    semantic:
      success:
      attention:
      error:
      info:
      paused:
      rest:

  spacing:
    xs: 4
    sm: 8
    md: 12
    base: 16
    lg: 24
    xl: 32
    2xl: 40
    3xl: 48
    4xl: 64

  radius:
    sm: 8
    md: 12
    lg: 16
    xl: 20
    full: 9999

  target:
    standard: 44
    comfortable: 48
    prominent: 56

  motion:
    instant: 80ms
    micro: 120ms
    fast: 160ms
    normal: 220ms

  elevation:
    none: 0
    card: 1
    floating: 2
    dialog: 3
```

---

# Appendix D — Prompt Library

## Daily

```text
Apa yang paling menonjol hari ini?
```

```text
Apa yang berjalan lebih mudah dari yang kamu perkirakan?
```

```text
Apa yang terasa berat hari ini?
```

## Habit Reflection

```text
Apa yang membuat habit ini lebih mudah dilakukan?
```

```text
Apakah cue saat ini masih cocok?
```

```text
Apa versi minimum yang realistis untuk hari sibuk?
```

```text
Adakah friction yang bisa kamu kurangi?
```

## Recovery

```text
Apa yang berubah sejak terakhir kali kamu melakukan habit ini?
```

```text
Mau melanjutkan seperti sebelumnya atau membuatnya lebih ringan?
```

## Gratitude

```text
Adakah sesuatu yang ingin kamu hargai dari hari ini?
```

## Emotion

```text
Emosi apa yang paling terasa saat ini?
```

```text
Apa yang mungkin memengaruhi perasaan ini?
```

## Weekly Review

```text
Apa yang paling membantu minggu ini?
```

```text
Apa yang paling sering menghalangi?
```

```text
Apa satu penyesuaian kecil untuk minggu depan?
```

---

# Appendix E — UX Writing Library

## Habit Complete

```text
Done.
```

```text
Completed for today.
```

## Weekly Goal

```text
3 of 4 this week.
```

## Missed

```text
Kemarin terlewat.
Progress sebelumnya tetap tersimpan.
```

## Return

```text
Welcome back.
Mulai lagi dari hari ini.
```

## Pause

```text
Habit dipause.
Kamu bisa melanjutkannya kapan saja.
```

## Journal Saved

```text
Saved.
```

## Offline

```text
Offline.
Perubahan disimpan di perangkat.
```

## Sync Error

```text
Belum berhasil disinkronkan.
Data di perangkat tetap tersimpan.
```

## Notification

```text
Waktunya untuk habit yang kamu jadwalkan.
```

## Gentle Recovery Reminder

```text
Mau kembali ke rutinitasmu hari ini?
Versi kecil tetap dihitung.
```

---

# Final Design Statement

> **The system should reward returning, not punish missing; strengthen context, not dependence; reveal patterns, not judge identity; and make reflection feel safe, private, and useful.**
