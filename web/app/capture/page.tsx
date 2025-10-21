import Link from 'next/link';

export default function CapturePage() {
  return (
    <div className="min-h-screen flex flex-col bg-black">
      {/* Header */}
      <header className="bg-black/80 text-white p-4 absolute top-0 left-0 right-0 z-10">
        <div className="max-w-4xl mx-auto flex justify-between items-center">
          <Link
            href="/"
            className="text-white flex items-center gap-2"
          >
            <svg
              className="h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M15 19l-7-7 7-7"
              />
            </svg>
            Back
          </Link>
          <h1 className="text-lg font-semibold">Capture Bottle</h1>
          <div className="w-16"></div> {/* Spacer for centering */}
        </div>
      </header>

      {/* Camera View - Placeholder */}
      <main className="flex-1 flex items-center justify-center">
        <div className="text-white text-center p-8">
          <svg
            className="mx-auto h-24 w-24 mb-4"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"
            />
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"
            />
          </svg>
          <p className="text-lg">Camera component will be implemented here</p>
          <p className="text-sm text-gray-400 mt-2">Phase 2: Camera & Image Handling</p>
        </div>
      </main>

      {/* Capture Button */}
      <div className="p-8 pb-12 flex justify-center">
        <button
          className="bg-white rounded-full p-6 shadow-lg hover:bg-gray-100 transition-colors"
          aria-label="Capture photo"
        >
          <div className="h-16 w-16 border-4 border-gray-800 rounded-full"></div>
        </button>
      </div>
    </div>
  );
}
