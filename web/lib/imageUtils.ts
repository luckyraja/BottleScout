/**
 * Image Processing Utilities
 * Handles image compression, resizing, and conversion for AI analysis
 */

import imageCompression from 'browser-image-compression';

export interface CompressionOptions {
  maxSizeMB: number;
  maxWidthOrHeight: number;
  useWebWorker: boolean;
  quality: number;
}

/**
 * Compress and resize image for AI API submission
 * Target: 800px max dimension, 50% quality, optimized for vision API
 */
export async function compressForAPI(file: File): Promise<Blob> {
  const options: CompressionOptions = {
    maxSizeMB: 1,
    maxWidthOrHeight: 800,
    useWebWorker: true,
    quality: 0.5, // 50% quality for API calls
  };

  return await imageCompression(file, options);
}

/**
 * Compress image for local storage
 * Target: Higher quality (80%) for viewing in app
 */
export async function compressForStorage(file: File): Promise<Blob> {
  const options: CompressionOptions = {
    maxSizeMB: 2,
    maxWidthOrHeight: 1200,
    useWebWorker: true,
    quality: 0.8, // 80% quality for storage
  };

  return await imageCompression(file, options);
}

/**
 * Convert blob to base64 string for AI API
 */
export async function blobToBase64(blob: Blob): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => {
      const base64 = reader.result as string;
      // Remove data URL prefix if present
      const base64Data = base64.split(',')[1] || base64;
      resolve(base64Data);
    };
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}

/**
 * Convert blob to data URL for displaying in img tags
 */
export async function blobToDataURL(blob: Blob): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result as string);
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}

/**
 * Validate file is an image
 */
export function isValidImageFile(file: File): boolean {
  const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
  return validTypes.includes(file.type);
}

/**
 * Get image dimensions from file
 */
export async function getImageDimensions(file: File): Promise<{ width: number; height: number }> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    const url = URL.createObjectURL(file);

    img.onload = () => {
      URL.revokeObjectURL(url);
      resolve({ width: img.width, height: img.height });
    };

    img.onerror = () => {
      URL.revokeObjectURL(url);
      reject(new Error('Failed to load image'));
    };

    img.src = url;
  });
}
