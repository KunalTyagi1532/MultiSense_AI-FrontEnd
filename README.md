# MultiSense AI

> AI-powered multimodal analyzer for social media content — built with Flutter, FastAPI, and Hugging Face Transformers.

---

## What is MultiSense AI?

MultiSense AI is a cross-platform mobile application that understands both **text and images** from social media. Paste a caption, upload a post screenshot, and get instant AI-powered sentiment analysis, content classification, and OCR — all from a clean, modern Flutter interface backed by a live FastAPI server on Hugging Face Spaces.

---

## Features

### Text Analysis
- Sentence-level sentiment breakdown with confidence scores
- Overall sentiment prediction across mixed emotions
- Transformer-powered inference (Twitter RoBERTa + DistilBERT)
- Emotion detection via `j-hartmann/emotion-english`

### Image Analysis
- OCR text extraction via EasyOCR
- Sentiment analysis on extracted text
- Visual content classification via CLIP
- Multi-label image understanding with confidence scoring

### App UI
- Material 3 Design with gradient AppBar
- Dark / Light theme toggle — persists across restarts
- Animated theme switcher icon
- Bottom navigation with preserved screen state
- Expandable history cards with timestamps
- Confidence progress indicators
- Loading states and error handling

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter, Provider, Material 3 |
| HTTP Client | Dio |
| Backend | FastAPI, Uvicorn |
| NLP Models | Twitter RoBERTa, DistilBERT, j-hartmann Emotion |
| Vision Models | CLIP (ViT-B/32), EasyOCR |
| Traditional ML | scikit-learn, VaderSentiment |
| Deployment | Hugging Face Spaces, Docker |
| Persistence | SharedPreferences |

---

## Architecture

```
Flutter App (Mobile)
        │
        │  REST API (Dio)
        ▼
FastAPI Backend (HuggingFace Spaces)
        │
   ┌────┴────────────┐
   ▼                 ▼
Text Pipeline     Image Pipeline
   │                 │
   ├─ RoBERTa        ├─ EasyOCR
   ├─ DistilBERT     ├─ CLIP
   ├─ Emotion Model  └─ VaderSentiment
   └─ VaderSentiment
```

---


## Screenshots

| Text Analysis | Image Analysis | Dark Mode |
|---|---|---|
| <img width="211" height="476" src="https://github.com/user-attachments/assets/6f84fa3e-68f9-4717-b117-3629310f5900" /> | <img width="206" height="467" src="https://github.com/user-attachments/assets/9791a619-a928-4eca-97b3-09196e92a641" /> | <img width="201" height="472" src="https://github.com/user-attachments/assets/03b16f24-5d1f-447d-8f3e-ecc2a81778cc" /> |


---

## Getting Started

### Prerequisites
- Flutter SDK
- Android Studio or Xcode

### Run Locally

```bash
git clone https://github.com/KunalTyagi1532/MultiSense_AI.git
cd MultiSense_AI
flutter pub get
flutter run
```

> The backend is already live on Hugging Face Spaces — no local server setup needed.

---
