import Link from 'next/link';

export default function SettingsPage() {
  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}
      <header className="bg-[var(--primary)] text-white p-4 shadow-md">
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
          <h1 className="text-lg font-semibold">Settings</h1>
          <div className="w-16"></div> {/* Spacer for centering */}
        </div>
      </header>

      {/* Settings Content */}
      <main className="flex-1 max-w-4xl mx-auto w-full p-4">
        <div className="space-y-6">
          {/* AI Model Section */}
          <section className="bg-[var(--card-bg)] rounded-lg p-6 border border-[var(--border)]">
            <h2 className="text-lg font-semibold mb-4">AI Configuration</h2>

            <div className="space-y-4">
              <div>
                <label htmlFor="ai-model" className="block text-sm font-medium mb-2">
                  AI Model
                </label>
                <select
                  id="ai-model"
                  className="w-full p-3 border border-[var(--border)] rounded-lg bg-white dark:bg-gray-800"
                >
                  <option value="gemini-flash">Google Gemini 2.0 Flash (Recommended)</option>
                  <option value="claude-haiku">Anthropic Claude 3.5 Haiku</option>
                  <option value="gpt-4o-mini">OpenAI GPT-4o Mini</option>
                </select>
                <p className="text-sm text-gray-500 mt-1">
                  Select the AI model for bottle label analysis
                </p>
              </div>

              <div>
                <label htmlFor="api-key" className="block text-sm font-medium mb-2">
                  API Key
                </label>
                <input
                  type="password"
                  id="api-key"
                  placeholder="Enter your AI API key"
                  className="w-full p-3 border border-[var(--border)] rounded-lg bg-white dark:bg-gray-800"
                />
                <p className="text-sm text-gray-500 mt-1">
                  Your API key is stored securely in your browser
                </p>
              </div>

              <button className="w-full bg-[var(--primary)] text-white py-3 px-4 rounded-lg hover:bg-[var(--primary-dark)] transition-colors">
                Save Settings
              </button>
            </div>
          </section>

          {/* App Info */}
          <section className="bg-[var(--card-bg)] rounded-lg p-6 border border-[var(--border)]">
            <h2 className="text-lg font-semibold mb-4">About</h2>
            <div className="space-y-2 text-sm">
              <p><strong>Version:</strong> 1.0.0</p>
              <p><strong>Storage:</strong> IndexedDB (Offline-first)</p>
              <p className="text-gray-500 mt-4">
                BottleScout uses AI to identify wine and spirits bottles, extract tasting notes,
                and help you manage your collection.
              </p>
            </div>
          </section>

          {/* Data Management */}
          <section className="bg-[var(--card-bg)] rounded-lg p-6 border border-[var(--border)]">
            <h2 className="text-lg font-semibold mb-4">Data Management</h2>
            <div className="space-y-3">
              <button className="w-full bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-white py-3 px-4 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors">
                Export Collection
              </button>
              <button className="w-full bg-red-600 text-white py-3 px-4 rounded-lg hover:bg-red-700 transition-colors">
                Clear All Data
              </button>
            </div>
          </section>
        </div>
      </main>
    </div>
  );
}
