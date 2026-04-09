import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './test/e2e',
  snapshotDir: './test/e2e/snapshots',
  updateSnapshots: 'missing',
  timeout: 30_000,
  fullyParallel: true,
  workers: 4,
  retries: 0,
  reporter: [['list'], ['html', { open: 'never' }]],

  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173/chat-demo/',
    reuseExistingServer: true,
    timeout: 15_000,
  },

  projects: [
    {
      name: 'iPhone 15 (Safari)',
      use: {
        ...devices['iPhone 15'],
        baseURL: 'http://localhost:5173',
      },
    },
    {
      name: 'Pixel 7 (Chrome)',
      use: {
        ...devices['Pixel 7'],
        baseURL: 'http://localhost:5173',
      },
    },
  ],
});
