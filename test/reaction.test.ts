import assert from 'node:assert/strict';
import { after, describe, it } from 'node:test';
import db from '../db/kysely';

after(() => db.destroy());

async function insertReaction(name: string) {
  return db
    .insertInto('reaction')
    .values({ name })
    .returningAll()
    .executeTakeFirstOrThrow();
}

async function rejectsReaction(name: string) {
  return assert.rejects(
    db.insertInto('reaction').values({ name }).execute(),
    /reaction\.name must be an emoji/,
  );
}

describe('reaction emoji guard — affirmative', () => {
  // [\x{1F000}-\x{1FAFF}] — emoticons, misc symbols & pictographs, transport, supplemental
  it('allows emoticons (1F000–1FAFF)', async () => {
    assert.equal((await insertReaction('🀀')).name, '🀀'); // U+1F000 mahjong tile east wind (lower bound)
    assert.equal((await insertReaction('👍')).name, '👍'); // U+1F44D thumbs up
    assert.equal((await insertReaction('😊')).name, '😊'); // U+1F60A smiling face
    assert.equal((await insertReaction('🎉')).name, '🎉'); // U+1F389 party popper
    assert.equal((await insertReaction('🚀')).name, '🚀'); // U+1F680 rocket
    assert.equal((await insertReaction('🧠')).name, '🧠'); // U+1F9E0 brain
    assert.equal((await insertReaction('🫿')).name, '🫿'); // U+1FAFF (upper bound)
  });

  // [\x{2600}-\x{27BF}] — miscellaneous symbols and dingbats
  it('allows misc symbols & dingbats (2600–27BF)', async () => {
    assert.equal((await insertReaction('☀')).name, '☀'); // U+2600 sun (lower bound)
    assert.equal((await insertReaction('♻')).name, '♻'); // U+267B recycling
    assert.equal((await insertReaction('✂')).name, '✂'); // U+2702 scissors
    assert.equal((await insertReaction('✈')).name, '✈'); // U+2708 airplane
    assert.equal((await insertReaction('✨')).name, '✨'); // U+2728 sparkles
    assert.equal((await insertReaction('➿')).name, '➿'); // U+27BF double curly loop (upper bound)
  });

  // [\x{2300}-\x{23FF}] — miscellaneous technical
  it('allows misc technical (2300–23FF)', async () => {
    assert.equal((await insertReaction('⌀')).name, '⌀'); // U+2300 diameter sign (lower bound)
    assert.equal((await insertReaction('⌚')).name, '⌚'); // U+231A watch
    assert.equal((await insertReaction('⌨')).name, '⌨'); // U+2328 keyboard
    assert.equal((await insertReaction('⏰')).name, '⏰'); // U+23F0 alarm clock
    assert.equal((await insertReaction('⏳')).name, '⏳'); // U+23F3 hourglass
    assert.equal((await insertReaction('⏿')).name, '⏿'); // U+23FF (upper bound)
  });

  // [\x{2B00}-\x{2BFF}] — miscellaneous symbols and arrows
  it('allows misc symbols & arrows (2B00–2BFF)', async () => {
    assert.equal((await insertReaction('⬀')).name, '⬀'); // U+2B00 north east white arrow (lower bound)
    assert.equal((await insertReaction('⬅')).name, '⬅'); // U+2B05 left arrow
    assert.equal((await insertReaction('⬆')).name, '⬆'); // U+2B06 up arrow
    assert.equal((await insertReaction('⭐')).name, '⭐'); // U+2B50 star
    assert.equal((await insertReaction('⯿')).name, '⯿'); // U+2BFF (upper bound)
  });

  // [\x{2100}-\x{214F}] — letter-like symbols (™ etc.)
  it('allows letter-like symbols (2100–214F)', async () => {
    assert.equal((await insertReaction('℀')).name, '℀'); // U+2100 account of (lower bound)
    assert.equal((await insertReaction('℃')).name, '℃'); // U+2103 degree celsius
    assert.equal((await insertReaction('™')).name, '™'); // U+2122 trade mark
    assert.equal((await insertReaction('℉')).name, '℉'); // U+2109 degree fahrenheit
    assert.equal((await insertReaction('⅏')).name, '⅏'); // U+214F symbol for samaritan source (upper bound)
  });

  // \x{00A9} and \x{00AE} — copyright and registered
  it('allows © and ®', async () => {
    assert.equal((await insertReaction('©')).name, '©'); // U+00A9
    assert.equal((await insertReaction('®')).name, '®'); // U+00AE
  });

  // [\x{203C}\x{2049}] — double exclamation and exclamation-question
  it('allows ‼ and ⁉ (203C, 2049)', async () => {
    assert.equal((await insertReaction('‼')).name, '‼'); // U+203C
    assert.equal((await insertReaction('⁉')).name, '⁉'); // U+2049
  });

  // [\x{2194}-\x{2199}] — bidirectional and diagonal arrows
  it('allows directional arrows (2194–2199)', async () => {
    assert.equal((await insertReaction('↔')).name, '↔'); // U+2194 left-right
    assert.equal((await insertReaction('↕')).name, '↕'); // U+2195 up-down
    assert.equal((await insertReaction('↖')).name, '↖'); // U+2196
    assert.equal((await insertReaction('↗')).name, '↗'); // U+2197
    assert.equal((await insertReaction('↘')).name, '↘'); // U+2198
    assert.equal((await insertReaction('↙')).name, '↙'); // U+2199
  });

  // [\x{21A9}-\x{21AA}] — returning arrows
  it('allows returning arrows (21A9–21AA)', async () => {
    assert.equal((await insertReaction('↩')).name, '↩'); // U+21A9
    assert.equal((await insertReaction('↪')).name, '↪'); // U+21AA
  });

  // \x{24C2} — circled M
  it('allows Ⓜ (24C2)', async () => {
    assert.equal((await insertReaction('Ⓜ')).name, 'Ⓜ'); // U+24C2
  });

  // [\x{25AA}-\x{25AB}\x{25B6}\x{25C0}\x{25FB}-\x{25FE}] — geometric shapes
  it('allows geometric shapes (25AA–25FE subset)', async () => {
    assert.equal((await insertReaction('▪')).name, '▪'); // U+25AA small black square
    assert.equal((await insertReaction('▫')).name, '▫'); // U+25AB small white square
    assert.equal((await insertReaction('▶')).name, '▶'); // U+25B6 right-pointing triangle
    assert.equal((await insertReaction('◀')).name, '◀'); // U+25C0 left-pointing triangle
    assert.equal((await insertReaction('◻')).name, '◻'); // U+25FB medium white square
    assert.equal((await insertReaction('◼')).name, '◼'); // U+25FC medium black square
    assert.equal((await insertReaction('◽')).name, '◽'); // U+25FD
    assert.equal((await insertReaction('◾')).name, '◾'); // U+25FE
  });

  // [\x{2934}-\x{2935}] — supplemental arrows
  it('allows supplemental arrows (2934–2935)', async () => {
    assert.equal((await insertReaction('⤴')).name, '⤴'); // U+2934 arrow curving up
    assert.equal((await insertReaction('⤵')).name, '⤵'); // U+2935 arrow curving down
  });

  // [\x{3030}\x{303D}] — CJK symbols
  it('allows CJK wavy dash and part alternation mark (3030, 303D)', async () => {
    assert.equal((await insertReaction('〰')).name, '〰'); // U+3030 wavy dash
    assert.equal((await insertReaction('〽')).name, '〽'); // U+303D part alternation mark
  });

  // [\x{3297}\x{3299}] — enclosed CJK
  it('allows enclosed CJK congratulations and secret (3297, 3299)', async () => {
    assert.equal((await insertReaction('㊗')).name, '㊗'); // U+3297 circled ideograph congratulation
    assert.equal((await insertReaction('㊙')).name, '㊙'); // U+3299 circled ideograph secret
  });

  // [\x{1F3FB}-\x{1F3FF}] — Fitzpatrick skin tone modifiers
  it('allows skin tone modifiers (1F3FB–1F3FF)', async () => {
    assert.equal((await insertReaction('🏻')).name, '🏻'); // U+1F3FB light
    assert.equal((await insertReaction('🏼')).name, '🏼'); // U+1F3FC medium-light
    assert.equal((await insertReaction('🏽')).name, '🏽'); // U+1F3FD medium
    assert.equal((await insertReaction('🏾')).name, '🏾'); // U+1F3FE medium-dark
    assert.equal((await insertReaction('🏿')).name, '🏿'); // U+1F3FF dark
  });

  // keycap sequences: base + U+FE0F + U+20E3
  it('allows keycap sequences (#, *, 0–9)', async () => {
    assert.equal((await insertReaction('#️⃣')).name, '#️⃣'); // U+0023 U+FE0F U+20E3
    assert.equal((await insertReaction('*️⃣')).name, '*️⃣'); // U+002A U+FE0F U+20E3
    assert.equal((await insertReaction('0️⃣')).name, '0️⃣'); // U+0030 U+FE0F U+20E3
    assert.equal((await insertReaction('9️⃣')).name, '9️⃣'); // U+0039 U+FE0F U+20E3
  });

  // multi-codepoint emoji using ZWJ and variation selector
  it('allows multi-codepoint emoji (ZWJ sequences, variation selectors)', async () => {
    assert.equal((await insertReaction('❤️')).name, '❤️'); // U+2764 U+FE0F
    assert.equal((await insertReaction('👨‍💻')).name, '👨‍💻'); // man + ZWJ + laptop
  });

  // color variant ZWJ sequences: base emoji + ZWJ + color square (E13.0–E15.1)
  it('allows color variant ZWJ sequences', async () => {
    assert.equal((await insertReaction('🐈‍⬛')).name, '🐈‍⬛'); // U+1F408 U+200D U+2B1B black cat
    assert.equal((await insertReaction('🐦‍⬛')).name, '🐦‍⬛'); // U+1F426 U+200D U+2B1B black bird
    assert.equal((await insertReaction('🍋‍🟩')).name, '🍋‍🟩'); // U+1F34B U+200D U+1F7E9 lime
    assert.equal((await insertReaction('🍄‍🟫')).name, '🍄‍🟫'); // U+1F344 U+200D U+1F7EB brown mushroom
  });

  // base emoji + each Fitzpatrick skin tone modifier
  it('allows emoji with each skin tone modifier', async () => {
    assert.equal((await insertReaction('👍🏻')).name, '👍🏻'); // U+1F44D U+1F3FB light
    assert.equal((await insertReaction('👍🏼')).name, '👍🏼'); // U+1F44D U+1F3FC medium-light
    assert.equal((await insertReaction('👍🏽')).name, '👍🏽'); // U+1F44D U+1F3FD medium
    assert.equal((await insertReaction('👍🏾')).name, '👍🏾'); // U+1F44D U+1F3FE medium-dark
    assert.equal((await insertReaction('👍🏿')).name, '👍🏿'); // U+1F44D U+1F3FF dark
  });

  // ZWJ family sequences, with and without skin tones
  it('allows ZWJ family sequences with skin tones', async () => {
    assert.equal((await insertReaction('👨‍👩‍👧')).name, '👨‍👩‍👧'); // man + ZWJ + woman + ZWJ + girl
    assert.equal((await insertReaction('👨🏽‍👩🏽‍👧🏽')).name, '👨🏽‍👩🏽‍👧🏽'); // family, all medium skin tone
    assert.equal((await insertReaction('👩🏽‍💻')).name, '👩🏽‍💻'); // woman + medium skin tone + ZWJ + laptop
    assert.equal((await insertReaction('🧑🏾‍🤝‍🧑🏻')).name, '🧑🏾‍🤝‍🧑🏻'); // people holding hands, mixed skin tones
  });

  // 11-token ZWJ sequence: man🏽 + ZWJ + woman🏽 + ZWJ + boy🏽 + ZWJ + boy🏽 — at the regex {1,11} limit
  it('allows 11-token ZWJ sequence (regex upper limit)', async () => {
    assert.equal((await insertReaction('👨🏽‍👩🏽‍👦🏽‍👦🏽')).name, '👨🏽‍👩🏽‍👦🏽‍👦🏽');
  });
});

describe('reaction emoji guard — negative', () => {
  it('rejects plain ASCII text', async () => {
    await rejectsReaction('hello');
    await rejectsReaction('like');
  });

  it('rejects digits without keycap decoration', async () => {
    await rejectsReaction('1');
    await rejectsReaction('0');
  });

  it('rejects special ASCII characters', async () => {
    await rejectsReaction('#'); // hash without FE0F + 20E3
    await rejectsReaction('*'); // asterisk without FE0F + 20E3
  });

  it('rejects empty string', async () => {
    await rejectsReaction('');
  });

  it('rejects emoji mixed with text', async () => {
    await rejectsReaction('👍like');
    await rejectsReaction('good👍');
  });
});
