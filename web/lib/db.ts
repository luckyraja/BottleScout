/**
 * IndexedDB Database Setup using Dexie
 * Provides offline-first storage for bottle entries and images
 */

import Dexie, { type EntityTable } from 'dexie';
import type { BottleEntry } from './types';

// Define the database schema
class BottleScoutDB extends Dexie {
  bottles!: EntityTable<BottleEntry, 'id'>;

  constructor() {
    super('BottleScoutDB');

    // Define tables and indexes
    this.version(1).stores({
      bottles: 'id, name, alcoholType, inCollection, timestamp',
    });
  }
}

// Create and export database instance
export const db = new BottleScoutDB();

/**
 * Database utility functions
 */

// Add a new bottle entry
export async function addBottle(bottle: Omit<BottleEntry, 'id' | 'timestamp'>): Promise<string> {
  const id = crypto.randomUUID();
  await db.bottles.add({
    ...bottle,
    id,
    timestamp: new Date(),
  });
  return id;
}

// Update an existing bottle
export async function updateBottle(id: string, updates: Partial<BottleEntry>): Promise<void> {
  await db.bottles.update(id, updates);
}

// Delete a bottle
export async function deleteBottle(id: string): Promise<void> {
  await db.bottles.delete(id);
}

// Get all bottles
export async function getAllBottles(): Promise<BottleEntry[]> {
  return await db.bottles.orderBy('timestamp').reverse().toArray();
}

// Get bottles in collection
export async function getCollectionBottles(): Promise<BottleEntry[]> {
  return await db.bottles.filter(bottle => bottle.inCollection === true).toArray();
}

// Toggle collection status
export async function toggleCollection(id: string): Promise<void> {
  const bottle = await db.bottles.get(id);
  if (bottle) {
    await db.bottles.update(id, { inCollection: !bottle.inCollection });
  }
}

// Search bottles by name or type
export async function searchBottles(query: string): Promise<BottleEntry[]> {
  const lowerQuery = query.toLowerCase();
  return await db.bottles
    .filter(bottle =>
      bottle.name.toLowerCase().includes(lowerQuery) ||
      bottle.alcoholType.toLowerCase().includes(lowerQuery)
    )
    .toArray();
}
