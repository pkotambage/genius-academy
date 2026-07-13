# Genius Academy Architecture

Version: 2.0 Foundation
Author: Pradhara Kotambage & ChatGPT
Status: Living Architecture Document

---

# Vision

Genius Academy is a scalable learning platform designed to provide high-quality education, aptitude training, examination preparation, parenting knowledge, language learning, and life skills through a single mobile application.

The platform is intended to grow continuously without requiring major architectural redesign.

Primary goals:

- Excellent user experience
- Modular architecture
- Easy maintenance
- Offline-first capability
- Firebase synchronization
- Cross-platform (Android, iOS, Web)
- Long-term scalability

---

# Platform Structure

```
Genius Academy
│
├── Genius IQ
├── Genius Mum
├── Genius Pet Care
├── Government Exams
├── School Learning
├── English
├── Sinhala
└── General Knowledge
```

Future modules may be added without changing the architecture.

---

# Learning Hierarchy

Every learning branch follows the same structure.

```
Academy Branch
        │
Programme
        │
Subject
        │
Topic
        │
Lesson
        │
Quiz
        │
Question
```

Example:

```
Government Exams

    SLAS

        General Knowledge

            Sri Lankan Constitution

                Lesson

                    Quiz
```

Example:

```
Genius Mum

    Toddler Development

        Language Development

            18-24 Months

                Lesson

                    Activity Quiz
```

---

# Architecture Layers

```
Presentation Layer

        │

Repository Layer

        │

Service Layer

        │

Data Source
```

Presentation Layer

- Screens
- Widgets

Repository Layer

- Business-facing data access
- Future cache handling
- Firebase switching
- Offline synchronization

Service Layer

- Reads JSON
- Reads Firebase
- Reads APIs
- Reads local storage

Data Sources

- JSON
- Firebase
- Hive
- SQLite
- REST API
- Downloadable Content Packs

Screens must never directly access JSON or Firebase.

---

# Current Folder Structure

```
lib
│
├── models
├── repositories
├── screens
├── services
├── widgets
```

Future Version 2.x

```
lib
│
├── core
├── features
├── shared
└── main.dart
```

Migration will occur only after Version 2 foundation is stable.

---

# Data Driven Design

The application should avoid hardcoded UI whenever possible.

Current JSON files:

```
academy_branches.json

quiz_categories.json

iq_questions.json
```

Future JSON files:

```
programmes.json

subjects.json

topics.json

lessons.json

courses.json

achievements.json

badges.json

notifications.json
```

Adding new learning content should ideally require editing JSON only.

---

# Current Repository Layer

```
AcademyBranchRepository

CategoryRepository

QuestionRepository
```

Future repositories:

```
ProgrammeRepository

SubjectRepository

TopicRepository

LessonRepository

ProgressRepository

AchievementRepository

SubscriptionRepository

UserRepository
```

---

# Current Services

```
AcademyBranchService

CategoryService

QuestionService
```

Future services:

```
FirebaseService

AnalyticsService

NotificationService

AuthenticationService

DownloadService

AIService
```

---

# UI Philosophy

The interface should feel:

Professional

Modern

Minimal

Friendly

Premium

Educational

Never cluttered.

Spacing should be generous.

Cards should have rounded corners.

Animations should feel smooth.

Typography should prioritize readability.

---

# Color Palette

Primary

Blue

White

Accent

Orange

Green

Background

Light Grey / White

Premium

Gold / Orange

---

# Navigation Philosophy

```
Academy

↓

Branch

↓

Programme

↓

Subject

↓

Topic

↓

Lesson

↓

Quiz

↓

Results
```

Navigation should always feel simple.

The user should never feel lost.

---

# Learning Engine

Every learning module should eventually support:

Theory

Examples

Practice

Quiz

Explanation

Progress Tracking

Revision

Achievements

Certificates (future)

---

# User System

Future functionality:

Profile

Learning Progress

Achievements

XP

Levels

Daily Streak

Bookmarks

Continue Learning

History

Cloud Sync

Settings

---

# Premium System

Premium should unlock:

Advanced quizzes

Video lessons

AI Tutor

Unlimited practice

Downloadable lessons

Mock exams

Certificates

Premium branches

---

# AI Integration

Future AI features:

Personal Tutor

Answer Explanation

Adaptive Difficulty

Learning Recommendations

Revision Plans

Exam Preparation Assistant

Parenting Assistant

Pet Care Assistant

---

# Coding Standards

Prefer composition over inheritance.

Avoid duplicate code.

Keep widgets small.

Business logic belongs in repositories/services.

UI should never contain business logic.

Every feature should be reusable.

Prefer const constructors.

Use meaningful class names.

Follow Flutter lint recommendations.

---

# Naming Conventions

Classes

PascalCase

Variables

camelCase

Files

snake_case

JSON keys

camelCase

---

# Git Strategy

main

Stable releases

development

Current development

feature/*

Individual features

release/*

Release preparation

Tags

v1.0

v1.1

v2.0

etc.

---

# Roadmap

Completed

✅ MVP

✅ Dynamic Categories

✅ Repository Layer

✅ Academy Branches

Current

🔵 Learning Engine

Upcoming

User System

Achievements

Firebase Sync

Premium Platform

Offline Downloads

AI Tutor

Long Term

Government Exams

School Learning

English

Sinhala

General Knowledge

Pet Care

International Expansion

---

# Architecture Principle

The application must be designed so that new learning branches, subjects, lessons and quizzes can be added with minimal code changes.

Content should drive the application—not hardcoded UI.

The architecture should remain scalable for many years.

---

# Motto

Learn.
Grow.
Succeed.

# Core Development Rules

Every new feature must answer YES to these questions before implementation.

□ Can it be reused?

□ Is it scalable?

□ Is it data-driven?

□ Does it avoid duplicated code?

□ Does it fit the architecture?

□ Will it still work when the app has hundreds of courses and thousands of lessons?

If the answer to any question is "No", redesign before implementation.