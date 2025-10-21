# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BottleScout (formerly WineTime) is transitioning from an iOS native app to a web application. The app allows users to photograph wine and alcohol bottle labels, analyze them using AI vision models, and manage their collection with an inventory system.

**Current State**: Legacy iOS app in Swift (WineTime/ directory)
**Target State**: Web app optimized for iPhone, deployed via Vercel

## Design Goals

- Personal use web application
- Keep implementation simple
- Guide user on best practices
- Mobile-first design for iPhone compatibility

## Core Application Flow

1. User captures photo of wine/alcohol label via camera
2. Image sent to vision LLM with prompt: *"What are the tasting notes for this wine? What is the price range? If this is not wine, provide similar context for its style of alcohol. Return the answer in bulleted text"*
3. AI response displayed and saved to inventory
4. User can toggle whether item is currently in their collection

## Architecture Decisions

### AI Model Selection
The original iOS app used OpenAI GPT-4o-mini. For the web app, evaluate:
- **Google Gemini Flash** - cost-effective vision
- **Anthropic Claude Haiku** - if vision capabilities available
- **OpenAI GPT-4o-mini** - current baseline
- Consider: pricing, response quality, structured output support

### Web Stack (Proposed)
- **Framework**: Next.js for Vercel deployment
- **Camera**: HTML5 media capture API or PWA capabilities
- **Storage**: Browser localStorage/IndexedDB (offline-first)
- **Image Processing**: Client-side compression before API submission
- **Deployment**: Vercel

## Data Model

### Simplified Web Schema
```
{
  id: string (UUID),
  name: string,
  tastingNotes: string,
  priceRange: string,
  imageUrl: string,
  inCollection: boolean,
  timestamp: date,
  alcoholType: string (wine/spirits/beer/etc)
}
```

### Legacy iOS Schema (Reference)
- **WineData**: name, producer, vintage, region, grapeVariety, tastingNotes, foodPairings, priceRange
- **HistoryEntry**: UUID, imageFilename, timestamp, wineData
- **PriceRange**: min/max with currency support

## Image Handling

### Optimization Strategy (from iOS implementation)
- Resize images to max 800px for API submission
- JPEG compression: 50% for API calls, 80% for storage
- Base64 encode for vision API
- Store original compressed images locally

## Key Features

### Must Have (MVP)
- Mobile camera capture
- AI vision analysis
- Inventory list view
- In/out of collection toggle
- Local data persistence
- Image storage

### Future Enhancements
- Search and filtering
- Price range filters
- Export/share functionality
- Collection statistics
- Barcode/UPC scanning

## Development Workflow

This repository currently contains only the legacy iOS Swift code. Web app development should:
1. Create new web app in project root or subdirectory
2. Reference iOS implementation for feature parity
3. Simplify data model per new requirements
4. Optimize for mobile-first experience
5. Deploy to Vercel

## iOS Legacy Code Structure (Reference Only)

- `WineTime/AIAnalyzer.swift` - OpenAI vision API integration
- `WineTime/CameraCapture.swift` - Native camera interface
- `WineTime/ContentView.swift` - Main UI with search and list
- `WineTime/ImageProcessing.swift` - Image optimization utilities
- `WineTime/KeychainManager.swift` - Secure API key storage
- `WineTime/Models.swift` - Data models
- `WineTime/PersistenceManager.swift` - UserDefaults + file system storage
- `WineTime/SettingsView.swift` - API key configuration

The iOS implementation provides reference patterns for image optimization, error handling, and offline capabilities that should be adapted for the web version.
