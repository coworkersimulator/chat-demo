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

async function goToFirstTopic(page: Page) {
  const firstTopic = page.locator('.sidebar-section:first-child .sidebar-list li').first();
  await firstTopic.tap();
  await page.waitForSelector('.channel-header', { state: 'visible' });
}

async function openNewDmComposer(page: Page) {
  await page.locator('.sidebar-section:last-child .sidebar-new-btn').tap();
  await page.waitForSelector('.dm-composer', { state: 'visible' });
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

  test('app-header stays at top after blurring input', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.message-input').tap();
    await page.waitForTimeout(600);
    await page.locator('.messages').tap();
    await page.waitForTimeout(400);
    const box = await page.locator('.app-header').boundingBox();
    expect(box!.y).toBeLessThanOrEqual(5);
  });

  test('channel-header stays visible after blurring input', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.message-input').tap();
    await page.waitForTimeout(600);
    await page.locator('.messages').tap();
    await page.waitForTimeout(400);
    const box = await page.locator('.channel-header').boundingBox();
    const vh = page.viewportSize()!.height;
    expect(box!.y).toBeGreaterThanOrEqual(0);
    expect(box!.y + box!.height).toBeLessThanOrEqual(vh);
  });

  test('channel fills full width on topic channel', async ({ page }) => {
    await waitForApp(page);
    await goToFirstTopic(page);
    const channel = page.locator('.channel');
    const box = await channel.boundingBox();
    const vw = page.viewportSize()!.width;
    expect(box!.width).toBeCloseTo(vw, 1);
    expect(box!.x).toBe(0);
  });

  test('app-header stays at top when input focused on topic channel', async ({ page }) => {
    await waitForApp(page);
    await goToFirstTopic(page);
    await page.locator('.message-input').tap();
    await page.waitForTimeout(600);
    const box = await page.locator('.app-header').boundingBox();
    expect(box!.y).toBeLessThanOrEqual(5);
  });

  test('message-entry within viewport when input focused on topic channel', async ({ page }) => {
    await waitForApp(page);
    await goToFirstTopic(page);
    await page.locator('.message-input').tap();
    await page.waitForTimeout(600);
    const box = await page.locator('.message-entry').boundingBox();
    const vh = page.viewportSize()!.height;
    expect(box!.y + box!.height).toBeLessThanOrEqual(vh + 2);
  });

  test('DM suggestions list has visible height', async ({ page }) => {
    await waitForApp(page);
    await openNewDmComposer(page);
    const box = await page.locator('.dm-suggestions').boundingBox();
    expect(box!.height).toBeGreaterThan(50);
  });

  test('DM composer fills full viewport width', async ({ page }) => {
    await waitForApp(page);
    await openNewDmComposer(page);
    const box = await page.locator('.dm-composer').boundingBox();
    const vw = page.viewportSize()!.width;
    expect(box!.width).toBeGreaterThanOrEqual(vw - 2);
  });

  test('DM composer input is visible', async ({ page }) => {
    await waitForApp(page);
    await openNewDmComposer(page);
    const box = await page.locator('.dm-composer-input').boundingBox();
    const vh = page.viewportSize()!.height;
    expect(box!.y).toBeGreaterThanOrEqual(0);
    expect(box!.y + box!.height).toBeLessThanOrEqual(vh);
  });

  test('DM open button stays in viewport with many recipients', async ({ page }) => {
    await waitForApp(page);
    await openNewDmComposer(page);
    // Add 5 recipients by clicking suggestions
    const suggestions = page.locator('.dm-suggestions li');
    const count = await suggestions.count();
    const toAdd = Math.min(5, count);
    for (let i = 0; i < toAdd; i++) {
      await suggestions.first().tap();
      await page.waitForTimeout(100);
    }
    const openBtn = page.locator('.dm-start-btn');
    const box = await openBtn.boundingBox();
    const vh = page.viewportSize()!.height;
    expect(box!.y).toBeGreaterThanOrEqual(0);
    expect(box!.y + box!.height).toBeLessThanOrEqual(vh + 2);
  });

  test('DM suggestions still visible after adding recipients', async ({ page }) => {
    await waitForApp(page);
    await openNewDmComposer(page);
    const suggestions = page.locator('.dm-suggestions li');
    const count = await suggestions.count();
    const toAdd = Math.min(5, count);
    for (let i = 0; i < toAdd; i++) {
      await suggestions.first().tap();
      await page.waitForTimeout(100);
    }
    const box = await page.locator('.dm-suggestions').boundingBox();
    expect(box!.height).toBeGreaterThan(30);
  });

  test('new topic composer is visible', async ({ page }) => {
    await waitForApp(page);
    await page.locator('.sidebar-section:first-child .sidebar-new-btn').tap();
    await page.waitForSelector('.sidebar-new-topic', { state: 'visible' });
    const box = await page.locator('.sidebar-new-topic').boundingBox();
    const vh = page.viewportSize()!.height;
    expect(box!.y).toBeGreaterThanOrEqual(0);
    expect(box!.y + box!.height).toBeLessThanOrEqual(vh);
  });

  test('reaction picker stays within viewport', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.reaction-add-btn').first().tap();
    await page.waitForSelector('.reaction-picker', { state: 'visible' });
    const box = await page.locator('.reaction-picker').boundingBox();
    const vw = page.viewportSize()!.width;
    const vh = page.viewportSize()!.height;
    expect(box!.x).toBeGreaterThanOrEqual(0);
    expect(box!.x + box!.width).toBeLessThanOrEqual(vw + 2);
    expect(box!.y).toBeGreaterThanOrEqual(0);
    expect(box!.y + box!.height).toBeLessThanOrEqual(vh + 2);
  });

  test('reaction picker closes after picking an emoji', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.reaction-add-btn').first().tap();
    await page.waitForSelector('.reaction-picker', { state: 'visible' });
    await page.locator('.reaction-picker-emoji').first().tap();
    await expect(page.locator('.reaction-picker')).not.toBeVisible();
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
    await openNewDmComposer(page);
    await expect(page).toHaveScreenshot('05-dm-composer.png', SCREENSHOT_OPTS);
  });

  test('screenshot: DM composer with many recipients', async ({ page }) => {
    await waitForApp(page);
    await openNewDmComposer(page);
    const suggestions = page.locator('.dm-suggestions li');
    const count = await suggestions.count();
    const toAdd = Math.min(5, count);
    for (let i = 0; i < toAdd; i++) {
      await suggestions.first().tap();
      await page.waitForTimeout(100);
    }
    await expect(page).toHaveScreenshot('05b-dm-composer-many.png', SCREENSHOT_OPTS);
  });

  test('screenshot: topic channel', async ({ page }) => {
    await waitForApp(page);
    await goToFirstTopic(page);
    await expect(page).toHaveScreenshot('06-topic-view.png', SCREENSHOT_OPTS);
  });

  test('screenshot: topic input focused', async ({ page }) => {
    await waitForApp(page);
    await goToFirstTopic(page);
    await page.locator('.message-input').tap();
    await page.waitForTimeout(600);
    await expect(page).toHaveScreenshot('06b-topic-input-focused.png', SCREENSHOT_OPTS);
  });

  test('screenshot: reaction picker open', async ({ page }) => {
    await waitForApp(page);
    await goToFirstDm(page);
    await page.locator('.reaction-add-btn').first().tap();
    await page.waitForSelector('.reaction-picker', { state: 'visible' });
    await expect(page).toHaveScreenshot('07-reaction-picker.png', SCREENSHOT_OPTS);
  });
});
