/**
 * BottleScout Type Definitions
 */

export interface BottleEntry {
  id: string;                // UUID
  name: string;              // Bottle name
  alcoholType: string;       // wine/spirits/beer/sake/etc
  tastingNotes: string;      // AI-generated tasting notes
  priceRange: string;        // e.g., "$20-30"
  imageUrl: string;          // IndexedDB blob URL or data URL
  inCollection: boolean;     // Toggle for current inventory
  timestamp: Date;           // When captured
  rawAIResponse?: string;    // Store full AI response (optional)
}

export interface AIAnalysisResult {
  name: string;
  alcoholType: string;
  tastingNotes: string;
  priceRange: string;
  rawResponse: string;
}

export interface AppSettings {
  apiKey: string;
  aiModel: 'gemini-flash' | 'claude-haiku' | 'gpt-4o-mini';
  compressionQuality: number;
}
