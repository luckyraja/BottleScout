# BottleScout Web App

AI-powered wine and alcohol collection manager optimized for iPhone.

## Project Status

**Phase 1: Foundation ✅ COMPLETE**
- Next.js 15 with TypeScript
- Tailwind CSS v4 with mobile-first design
- PWA configuration for iPhone installation
- IndexedDB setup with Dexie.js
- Basic routing structure (Home, Capture, Settings)

## Features

### Current (Phase 1)
- Mobile-optimized layout with iOS safe areas
- PWA manifest for home screen installation
- Offline-first data storage with IndexedDB
- Basic routing structure
- Responsive UI components

### Coming Soon
- **Phase 2:** Camera capture & image processing
- **Phase 3:** AI integration (Gemini Flash/Claude/GPT-4o)
- **Phase 4:** Inventory management & search
- **Phase 5:** Settings & polish
- **Phase 6:** Vercel deployment

## Tech Stack

- **Framework:** Next.js 15 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS v4
- **State:** Zustand (planned)
- **Database:** IndexedDB (via Dexie.js)
- **Image Processing:** browser-image-compression
- **AI Models:** Gemini 2.0 Flash (recommended)
- **Deployment:** Vercel

## Development

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

Visit [http://localhost:3000](http://localhost:3000) to see the app.

## Project Structure

```
web/
├── app/                    # Next.js App Router
│   ├── layout.tsx         # Root layout with PWA config
│   ├── page.tsx           # Home/inventory page
│   ├── capture/           # Camera capture page
│   └── settings/          # Settings page
├── components/            # React components (to be added)
├── lib/                   # Utilities and core logic
│   ├── types.ts          # TypeScript interfaces
│   ├── db.ts             # IndexedDB/Dexie setup
│   └── imageUtils.ts     # Image compression utilities
└── public/
    ├── manifest.json     # PWA manifest
    └── icons/            # App icons (192x192, 512x512)
```

## Data Model

```typescript
interface BottleEntry {
  id: string;              // UUID
  name: string;            // Bottle name
  alcoholType: string;     // wine/spirits/beer/sake/etc
  tastingNotes: string;    // AI-generated notes
  priceRange: string;      // e.g., "$20-30"
  imageUrl: string;        // IndexedDB blob URL
  inCollection: boolean;   // Current inventory toggle
  timestamp: Date;         // Capture date
  rawAIResponse?: string;  // Full AI response
}
```

## Mobile Optimization

- Touch-optimized UI (44px minimum touch targets)
- iOS safe area insets for notch/Dynamic Island
- Prevents zoom on input focus
- PWA-ready for home screen installation
- Offline-first architecture

## Next Steps

1. Implement camera capture component
2. Add image compression pipeline
3. Integrate AI vision API (Gemini Flash)
4. Build inventory list with search/filter
5. Add settings persistence
6. Deploy to Vercel

## License

Personal use only.
