import type { Page } from '@playwright/test';
import { expect, test } from '@playwright/test';

const URL = '/chat-demo/';

async function waitForApp(page: Page) {
  await page.goto(URL);
  await page.waitForSelector('.sidebar-list', { timeout: 20_000 });
  await page.waitForTimeout(500);
}

async function goToSidebar(page: Page) {
  const backBtn = page.locator('.channel-back-btn');
  if (await backBtn.isVisible()) {
    await backBtn.tap();
    await page.waitForTimeout(200);
  }
}

async function getChannelTitles(page: Page): Promise<string[]> {
  const texts = await page
    .locator('.sidebar-section:first-child .sidebar-list li')
    .allTextContents();
  return texts.map((t) => t.replace(/^#\s*/, '').trim());
}

async function goToChannel(page: Page, title: string) {
  await goToSidebar(page);
  await page
    .locator('.sidebar-section:first-child .sidebar-list li', { hasText: title })
    .tap();
  await page.waitForSelector('.channel-header', { state: 'visible' });
}

async function sendMessage(page: Page, text: string) {
  const input = page.locator('.message-input');
  await input.tap();
  await input.fill(text);
  await input.press('Enter');
  await expect(page.locator('.message-body').last()).toHaveText(text, {
    timeout: 10_000,
  });
}

// Returns display names parsed from switch-user options ("Name (username)" → "Name")
async function getUserDisplayNames(page: Page): Promise<string[]> {
  await page.locator('.switch-user-label').tap();
  await page.locator('.switch-user-option').first().waitFor({ state: 'visible' });
  const texts = await page.locator('.switch-user-option').allTextContents();
  await page.locator('.switch-user-label').tap(); // close
  await page.waitForTimeout(100);
  return texts.map((raw) => {
    const idx = raw.indexOf('(');
    return idx > -1 ? raw.slice(0, idx).trim() : raw.trim();
  });
}

async function switchUser(page: Page, index: number) {
  await page.locator('.switch-user-label').tap();
  await page.locator('.switch-user-option').nth(index).waitFor({ state: 'visible' });
  await page.locator('.switch-user-option').nth(index).tap();
  await page.waitForTimeout(300);
}

// Creates a DM with a single user by display name and navigates into it
async function createDm(page: Page, displayName: string) {
  await goToSidebar(page);
  await page.locator('.sidebar-section:last-child .sidebar-new-btn').tap();
  await page.waitForSelector('.dm-composer', { state: 'visible' });
  await page.locator('.dm-composer-input').fill(displayName);
  await page.waitForTimeout(200);
  await page.locator('.dm-suggestions li').first().tap();
  await page.locator('.dm-start-btn').tap();
  await page.waitForSelector('.channel-header', { state: 'visible' });
}

// Picks the first emoji from the reaction picker on the last message
async function addReactionToLastMessage(page: Page) {
  await page.locator('.message').last().locator('.reaction-add-btn').tap();
  await page.waitForSelector('.reaction-picker', { state: 'visible' });
  await page.locator('.reaction-picker-emoji').first().tap();
  await expect(page.locator('.reaction-picker')).not.toBeVisible();
}

// Taps the edit button on the last message and waits for the edit input
async function startEditLastMessage(page: Page) {
  await page.locator('.message').last().tap();
  await page.locator('.message').last().locator('.message-edit-btn').tap();
  await page.waitForSelector('.message-edit-input', { state: 'visible' });
}

// Submits the edit by pressing Enter
async function submitEdit(page: Page, newText: string) {
  const input = page.locator('.message-edit-input');
  await input.fill(newText);
  await input.press('Enter');
  await expect(page.locator('.message-edit-input')).not.toBeVisible({ timeout: 5_000 });
}

// Taps the delete button on the last message, confirms, and waits for the placeholder
async function deleteLastMessage(page: Page) {
  await page.locator('.message').last().tap();
  await page.locator('.message').last().locator('.message-delete-btn').tap();
  await page.locator('.message-delete-yes-btn').tap();
  await expect(page.locator('.message-deleted').last()).toBeVisible({ timeout: 5_000 });
}

test.describe('Deleting', () => {
  test('user A deletes own message in a channel', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    await goToChannel(page, channels[0]);

    await sendMessage(page, 'to be deleted');
    await deleteLastMessage(page);

    await expect(page.locator('.message-body').last()).toContainText('deleted');
    await expect(page.locator('.message-delete-btn')).not.toBeVisible();
    await expect(page.locator('.message-edit-btn')).not.toBeVisible();
  });

  test('cancel keeps the message intact', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    await goToChannel(page, channels[0]);

    await sendMessage(page, 'do not delete');

    await page.locator('.message').last().tap();
    await page.locator('.message').last().locator('.message-delete-btn').tap();
    await page.locator('.message-delete-no-btn').tap();

    await expect(page.locator('.message-deleted')).not.toBeVisible();
    await expect(page.locator('.message-body').last()).toHaveText('do not delete');
  });

  test('user B sees deleted placeholder in same channel', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    await goToChannel(page, channels[0]);

    await sendMessage(page, 'A will delete this');
    await deleteLastMessage(page);

    await switchUser(page, 1);
    await goToChannel(page, channels[0]);

    await expect(page.locator('.message-body').last()).toContainText('deleted');
  });

  test('user B cannot delete user A message (delete button absent)', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    await goToChannel(page, channels[0]);

    await sendMessage(page, 'only A can delete this');

    await switchUser(page, 1);
    await goToChannel(page, channels[0]);

    await page.locator('.message').last().tap();
    await expect(page.locator('.message').last().locator('.message-delete-btn')).not.toBeVisible();
  });

  test('user A deletes own message in a DM, user B sees placeholder', async ({ page }) => {
    await waitForApp(page);
    const displayNames = await getUserDisplayNames(page);
    const [userADisplay, userBDisplay] = displayNames;

    await createDm(page, userBDisplay);
    await sendMessage(page, 'dm to delete');
    await deleteLastMessage(page);

    await expect(page.locator('.message-body').last()).toContainText('deleted');

    await switchUser(page, 1);
    await page.waitForTimeout(500);
    await page
      .locator('.sidebar-section:last-child .sidebar-list li', { hasText: userADisplay })
      .first()
      .tap();
    await page.waitForSelector('.channel-header', { state: 'visible' });

    await expect(page.locator('.message-body').last()).toContainText('deleted');
  });

  test('user B deletes own reply in a DM, user A sees placeholder', async ({ page }) => {
    await waitForApp(page);
    const displayNames = await getUserDisplayNames(page);
    const [userADisplay, userBDisplay] = displayNames;

    await createDm(page, userBDisplay);
    await sendMessage(page, 'hello from A');

    await switchUser(page, 1);
    await page.waitForTimeout(500);
    await page
      .locator('.sidebar-section:last-child .sidebar-list li', { hasText: userADisplay })
      .first()
      .tap();
    await page.waitForSelector('.channel-header', { state: 'visible' });

    await sendMessage(page, 'reply from B');
    await deleteLastMessage(page);

    await switchUser(page, 0);
    await page.waitForTimeout(500);
    await page
      .locator('.sidebar-section:last-child .sidebar-list li', { hasText: userBDisplay })
      .first()
      .tap();
    await page.waitForSelector('.channel-header', { state: 'visible' });

    await expect(page.locator('.message-body').last()).toContainText('deleted');
  });
});

test.describe('Editing', () => {
  test('user A edits own message in a channel', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    await goToChannel(page, channels[0]);

    await sendMessage(page, 'original text');
    await startEditLastMessage(page);
    await submitEdit(page, 'edited text');

    await expect(page.locator('.message-body').last()).toHaveText(/edited text/);
    await expect(page.locator('.message-edited-label').last()).toBeVisible();
  });

  test('user A edits, user B sees the updated text in the same channel', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    await goToChannel(page, channels[0]);

    await sendMessage(page, 'before edit');
    await startEditLastMessage(page);
    await submitEdit(page, 'after edit');

    await switchUser(page, 1);
    await goToChannel(page, channels[0]);
    await expect(page.locator('.message-body').last()).toHaveText(/after edit/);
    await expect(page.locator('.message-edited-label').last()).toBeVisible();
  });

  test('user B cannot edit user A message (edit button absent)', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    await goToChannel(page, channels[0]);

    await sendMessage(page, 'user A message');

    await switchUser(page, 1);
    await goToChannel(page, channels[0]);

    // Tap the last message and confirm no edit button appears
    await page.locator('.message').last().tap();
    await expect(page.locator('.message').last().locator('.message-edit-btn')).not.toBeVisible();
  });

  test('escape cancels an edit without changing the message', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    await goToChannel(page, channels[0]);

    await sendMessage(page, 'keep this text');
    await startEditLastMessage(page);
    await page.locator('.message-edit-input').fill('discarded');
    await page.locator('.message-edit-input').press('Escape');

    await expect(page.locator('.message-edit-input')).not.toBeVisible();
    await expect(page.locator('.message-body').last()).toHaveText('keep this text');
    await expect(page.locator('.message-edited-label')).not.toBeVisible();
  });

  test('user A edits own message in a DM, user B sees update', async ({ page }) => {
    await waitForApp(page);
    const displayNames = await getUserDisplayNames(page);
    const [, userBDisplay] = displayNames;

    await createDm(page, userBDisplay);
    await sendMessage(page, 'dm original');
    await startEditLastMessage(page);
    await submitEdit(page, 'dm edited');

    await expect(page.locator('.message-body').last()).toHaveText(/dm edited/);
    await expect(page.locator('.message-edited-label').last()).toBeVisible();

    const [userADisplay] = displayNames;
    await switchUser(page, 1);
    await page.waitForTimeout(500);
    await page
      .locator('.sidebar-section:last-child .sidebar-list li', { hasText: userADisplay })
      .first()
      .tap();
    await page.waitForSelector('.channel-header', { state: 'visible' });

    await expect(page.locator('.message-body').last()).toHaveText(/dm edited/);
    await expect(page.locator('.message-edited-label').last()).toBeVisible();
  });

  test('user B edits own reply in a DM, user A sees update', async ({ page }) => {
    await waitForApp(page);
    const displayNames = await getUserDisplayNames(page);
    const [userADisplay, userBDisplay] = displayNames;

    await createDm(page, userBDisplay);
    await sendMessage(page, 'hello from A');

    await switchUser(page, 1);
    await page.waitForTimeout(500);
    await page
      .locator('.sidebar-section:last-child .sidebar-list li', { hasText: userADisplay })
      .first()
      .tap();
    await page.waitForSelector('.channel-header', { state: 'visible' });

    await sendMessage(page, 'reply from B');
    await startEditLastMessage(page);
    await submitEdit(page, 'edited reply from B');

    await switchUser(page, 0);
    await page.waitForTimeout(500);
    await page
      .locator('.sidebar-section:last-child .sidebar-list li', { hasText: userBDisplay })
      .first()
      .tap();
    await page.waitForSelector('.channel-header', { state: 'visible' });

    await expect(page.locator('.message-body').last()).toHaveText(/edited reply from B/);
    await expect(page.locator('.message-edited-label').last()).toBeVisible();
  });
});

test.describe('Drafts', () => {
  test('draft is preserved when switching channels', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    const [first, second] = channels;

    await goToChannel(page, first);
    await page.locator('.message-input').tap();
    await page.locator('.message-input').fill('draft in first');

    await goToChannel(page, second);
    await expect(page.locator('.message-input')).toHaveValue('');

    await goToChannel(page, first);
    await expect(page.locator('.message-input')).toHaveValue('draft in first');
  });

  test('each channel keeps its own draft', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    const [first, second] = channels;

    await goToChannel(page, first);
    await page.locator('.message-input').tap();
    await page.locator('.message-input').fill('draft A');

    await goToChannel(page, second);
    await page.locator('.message-input').tap();
    await page.locator('.message-input').fill('draft B');

    await goToChannel(page, first);
    await expect(page.locator('.message-input')).toHaveValue('draft A');

    await goToChannel(page, second);
    await expect(page.locator('.message-input')).toHaveValue('draft B');
  });

  test('drafts are cleared when switching users', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    const [first, second] = channels;

    await goToChannel(page, first);
    await page.locator('.message-input').tap();
    await page.locator('.message-input').fill('draft in first');

    await goToChannel(page, second);
    await page.locator('.message-input').tap();
    await page.locator('.message-input').fill('draft in second');

    await switchUser(page, 1);

    await goToChannel(page, first);
    await expect(page.locator('.message-input')).toHaveValue('');

    await goToChannel(page, second);
    await expect(page.locator('.message-input')).toHaveValue('');
  });

  test('sending clears the draft for that channel', async ({ page }) => {
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    const [first] = channels;

    await goToChannel(page, first);
    await sendMessage(page, 'hello');
    await expect(page.locator('.message-input')).toHaveValue('');
  });
});

test.describe('Messaging', () => {
  test('user A sends multiple messages in every channel', async ({ page }) => {
    test.setTimeout(90_000);
    await waitForApp(page);
    const channels = await getChannelTitles(page);
    expect(channels.length).toBeGreaterThan(0);

    for (const channel of channels) {
      await goToChannel(page, channel);
      await sendMessage(page, `First message in ${channel}`);
      await sendMessage(page, `Second message in ${channel}`);
      const bodies = await page.locator('.message-body').allTextContents();
      expect(bodies).toContain(`First message in ${channel}`);
      expect(bodies).toContain(`Second message in ${channel}`);
    }
  });

  test('user A and user B both send messages in every channel', async ({ page }) => {
    test.setTimeout(120_000);
    await waitForApp(page);
    const channels = await getChannelTitles(page);

    for (const channel of channels) {
      await goToChannel(page, channel);
      await sendMessage(page, `A says hello in ${channel}`);
    }

    await switchUser(page, 1);

    for (const channel of channels) {
      await goToChannel(page, channel);
      await sendMessage(page, `B says hello in ${channel}`);
      const bodies = await page.locator('.message-body').allTextContents();
      expect(bodies).toContain(`A says hello in ${channel}`);
      expect(bodies).toContain(`B says hello in ${channel}`);
    }
  });

  test('user A and user B exchange DMs', async ({ page }) => {
    await waitForApp(page);
    const displayNames = await getUserDisplayNames(page);
    expect(displayNames.length).toBeGreaterThanOrEqual(2);
    const [userADisplay, userBDisplay] = displayNames;

    // User A creates a DM with user B
    await createDm(page, userBDisplay);
    await sendMessage(page, 'Hello from A');
    await sendMessage(page, 'Second from A');

    // Switch to user B — the new DM shows user A's name in B's list
    await switchUser(page, 1);
    await page.waitForTimeout(500);
    await page
      .locator('.sidebar-section:last-child .sidebar-list li', { hasText: userADisplay })
      .first()
      .tap();
    await page.waitForSelector('.channel-header', { state: 'visible' });

    const bodiesB = await page.locator('.message-body').allTextContents();
    expect(bodiesB).toContain('Hello from A');
    expect(bodiesB).toContain('Second from A');

    await sendMessage(page, 'Hello from B');

    // Switch back to user A — the DM now shows user B's name, has B's reply
    await switchUser(page, 0);
    await page.waitForTimeout(500);
    await page
      .locator('.sidebar-section:last-child .sidebar-list li', { hasText: userBDisplay })
      .first()
      .tap();
    await page.waitForSelector('.channel-header', { state: 'visible' });

    const bodiesA = await page.locator('.message-body').allTextContents();
    expect(bodiesA).toContain('Hello from B');
  });

  test('user A and user B add reactions in every channel', async ({ page }) => {
    test.setTimeout(120_000);
    await waitForApp(page);
    const channels = await getChannelTitles(page);

    // User A posts and reacts in every channel
    for (const channel of channels) {
      await goToChannel(page, channel);
      await sendMessage(page, `React to me in ${channel}`);
      await addReactionToLastMessage(page);
      await expect(
        page.locator('.message').last().locator('.reaction-chip').first(),
      ).toHaveText(/1/);
    }

    await switchUser(page, 1);

    // User B sees A's reaction and adds their own (same emoji, count → 2)
    for (const channel of channels) {
      await goToChannel(page, channel);
      const chip = page.locator('.message').last().locator('.reaction-chip').first();
      await expect(chip).toBeVisible();
      await chip.tap();
      await expect(chip).toHaveText(/2/);
    }

    await switchUser(page, 0);

    // User A sees the combined count of 2
    for (const channel of channels) {
      await goToChannel(page, channel);
      await expect(
        page.locator('.message').last().locator('.reaction-chip').first(),
      ).toHaveText(/2/);
    }
  });

  test('user A and user B add reactions in a DM', async ({ page }) => {
    await waitForApp(page);
    const displayNames = await getUserDisplayNames(page);
    const [userADisplay, userBDisplay] = displayNames;

    await createDm(page, userBDisplay);
    await sendMessage(page, 'React to this in DM');
    await addReactionToLastMessage(page);
    await expect(
      page.locator('.message').last().locator('.reaction-chip').first(),
    ).toHaveText(/1/);

    await switchUser(page, 1);
    await page.waitForTimeout(500);
    await page
      .locator('.sidebar-section:last-child .sidebar-list li', { hasText: userADisplay })
      .first()
      .tap();
    await page.waitForSelector('.channel-header', { state: 'visible' });

    const chip = page.locator('.message').last().locator('.reaction-chip').first();
    await expect(chip).toBeVisible();
    await chip.tap(); // user B reacts — count → 2
    await expect(chip).toHaveText(/2/);

    await switchUser(page, 0);
    await page.waitForTimeout(500);
    await page
      .locator('.sidebar-section:last-child .sidebar-list li', { hasText: userBDisplay })
      .first()
      .tap();
    await page.waitForSelector('.channel-header', { state: 'visible' });

    await expect(
      page.locator('.message').last().locator('.reaction-chip').first(),
    ).toHaveText(/2/);
  });
});
