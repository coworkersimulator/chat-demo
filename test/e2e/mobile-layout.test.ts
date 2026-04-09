import { expect, Page, test } from '@playwright/test';

const URL = '/chat-demo/';

// Tolerance for screenshot diffs — allows minor rendering variance
// without masking real layout regressions
const SCREENSHOT_OPTS = {
  fullPage: false,
  maxDiffPixelRatio: 0.05,
} as const;

async function waitForApp(page: Page) {
  await page.goto(URL);
  await page.waitForSelector('.sidebar-list', { timeout: 20_000 });
  await page.waitForTimeout(500);
}

async function goToFirstDm(page: Page) {
  const firstDm = page.locator('.sidebar-section:last-child .sidebar-list li').first();
  await firstDm.tap();
  await page.waitForSelector('.channel-header', { state: 'visible' });
}

test.describe('Mobile layout', () => {

  // ── Structural assertions (never flaky) ─────────────────────────────────

  test('sidebar fills full viewport width', async ({ page }) => {
    await waitForApp(page);
    const sidebar = page.locator('.sidebar');
    const box = await sidebar.boundingBox();
    const vw = page.viewportSize()!.width;
    expect(box!.width).toBeCloseTo(vw, 1);
    expect(box!.x).toBe(0);
  });

  test('channel fills full viewport width', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    const channel = page.locator('.channel');
    const box = await channel.boundingBox();
    const vw = page.viewportSize()!.width;
    expect(box!.width).toBeCloseTo(vw, 1);
    expect(box!.x).toBe(0);
  });

  test('app-header stays at top when message input focused', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.message-input').tap();
    await page.waitForTimeout(600);
    const box = await page.locator('.app-header').boundingBox();
    expect(box!.y).toBeLessThanOrEqual(5);
  });

  test('channel-header stays visible when message input focused', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.message-input').tap();
    await page.waitForTimeout(600);
    const box = await page.locator('.channel-header').boundingBox();
    const vh = page.viewportSize()!.height;
    expect(box!.y).toBeGreaterThanOrEqual(0);
    expect(box!.y + box!.height).toBeLessThanOrEqual(vh);
  });

  test('message-entry bottom is within viewport when input focused', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.message-input').tap();
    await page.waitForTimeout(600);
    const box = await page.locator('.message-entry').boundingBox();
    const vh = page.viewportSize()!.height;
    expect(box!.y + box!.height).toBeLessThanOrEqual(vh + 2);
  });

  test('message-entry bottom is within viewport after blurring input', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.message-input').tap();
    await page.waitForTimeout(600);
    await page.locator('.messages').tap();
    await page.waitForTimeout(400);
    const box = await page.locator('.message-entry').boundingBox();
    const vh = page.viewportSize()!.height;
    expect(box!.y + box!.height).toBeLessThanOrEqual(vh + 2);
  });

  test('DM suggestions list has visible height', async ({ page }) => {
    await waitForApp(page);
    await page.locator('.sidebar-section:last-child .sidebar-new-btn').tap();
    await page.waitForSelector('.dm-suggestions', { state: 'visible' });
    const box = await page.locator('.dm-suggestions').boundingBox();
    expect(box!.height).toBeGreaterThan(50);
  });

  test('DM composer fills full viewport width', async ({ page }) => {
    await waitForApp(page);
    await page.locator('.sidebar-section:last-child .sidebar-new-btn').tap();
    await page.waitForSelector('.dm-composer', { state: 'visible' });
    const box = await page.locator('.dm-composer').boundingBox();
    const vw = page.viewportSize()!.width;
    expect(box!.width).toBeGreaterThanOrEqual(vw - 2);
  });

  test('back button returns to sidebar', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.channel-back-btn').tap();
    const sidebar = page.locator('.sidebar');
    await expect(sidebar).toBeVisible();
    const box = await sidebar.boundingBox();
    const vw = page.viewportSize()!.width;
    expect(box!.width).toBeCloseTo(vw, 1);
  });

  // ── Screenshot baselines (layout shape, not dynamic content) ────────────

  test('screenshot: list view', async ({ page }) => {
    await waitForApp(page);
    await expect(page).toHaveScreenshot('01-list-view.png', SCREENSHOT_OPTS);
  });

  test('screenshot: channel view', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await expect(page).toHaveScreenshot('02-channel-view.png', SCREENSHOT_OPTS);
  });

  test('screenshot: message input focused', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.message-input').tap();
    await page.waitForTimeout(600);
    await expect(page).toHaveScreenshot('03-input-focused.png', SCREENSHOT_OPTS);
  });

  test('screenshot: message input blurred', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.message-input').tap();
    await page.waitForTimeout(600);
    await page.locator('.messages').tap();
    await page.waitForTimeout(400);
    await expect(page).toHaveScreenshot('04-input-blurred.png', SCREENSHOT_OPTS);
  });

  test('screenshot: DM composer', async ({ page }) => {
    await waitForApp(page);
    await page.locator('.sidebar-section:last-child .sidebar-new-btn').tap();
    await page.waitForSelector('.dm-composer', { state: 'visible' });
    await expect(page).toHaveScreenshot('05-dm-composer.png', SCREENSHOT_OPTS);
  });

  test('screenshot: topic channel', async ({ page }) => {
    await waitForApp(page);
    const firstTopic = page.locator('.sidebar-section:first-child .sidebar-list li').first();
    await firstTopic.tap();
    await page.waitForSelector('.channel-header', { state: 'visible' });
    await expect(page).toHaveScreenshot('06-topic-view.png', SCREENSHOT_OPTS);
  });
});
