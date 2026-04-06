CREATE OR REPLACE FUNCTION guard_name_emoji()
RETURNS trigger AS $$
BEGIN
  IF NEW.name !~ (
    '^(('
    -- Emoticons, misc symbols & pictographs, transport, maps, supplemental symbols,
    -- geometric shapes extended, chess symbols, symbols & pictographs extended-A
    -- \x{1F000}-\x{1FAFF}
    || '[🀀-🫿]'
    -- Miscellaneous symbols (☀️ ☎️ ♻️ etc.) and dingbats (✂️ ✈️ ✨ etc.)
    -- \x{2600}-\x{27BF}
    || '|[☀-➿]'
    -- Miscellaneous technical (⌚ ⌨️ ⏰ ⏳ etc.)
    -- \x{2300}-\x{23FF}
    || '|[⌀-⏿]'
    -- Miscellaneous symbols and arrows (⭐ ⬅️ ⬆️ etc.)
    -- \x{2B00}-\x{2BFF}
    || '|[⬀-⯿]'
    -- Letter-like symbols: trademark ™, etc.
    -- \x{2100}-\x{214F}
    || '|[℀-⅏]'
    -- Copyright © and registered ®
    -- \x{00A9}, \x{00AE}
    || '|[©®]'
    -- General punctuation: double exclamation ‼️, exclamation question ⁉️
    -- \x{203C}, \x{2049}
    || '|[‼⁉]'
    -- Arrows: directional ↔️↕️↖️↗️↘️↙️ and returning ↩️↪️
    -- \x{2194}-\x{2199}, \x{21A9}-\x{21AA}
    || '|[↔-↙↩↪]'
    -- Enclosed alphanumerics: circled M Ⓜ️
    -- \x{24C2}
    || '|Ⓜ'
    -- Geometric shapes: small squares ▪️▫️, triangles ▶️◀️, medium squares ◻️◼️◽◾
    -- \x{25AA}-\x{25AB}, \x{25B6}, \x{25C0}, \x{25FB}-\x{25FE}
    || '|[▪▫▶◀◻-◾]'
    -- Supplemental arrows: curving up/down ⤴️⤵️
    -- \x{2934}-\x{2935}
    || '|[⤴⤵]'
    -- CJK symbols and punctuation: wavy dash 〰️, part alternation mark 〽️
    -- \x{3030}, \x{303D}
    || '|[〰〽]'
    -- Enclosed CJK: Japanese congratulations ㊗️ and secret ㊙️
    -- \x{3297}, \x{3299}
    || '|[㊗㊙]'
    -- Skin tone modifiers: Fitzpatrick scale type 1-2 through 6 (🏻 🏼 🏽 🏾 🏿)
    -- \x{1F3FB}-\x{1F3FF}
    || '|[🏻-🏿]'
    -- Variation selector-16: forces emoji presentation over text presentation
    -- \x{FE0F}
    || '|' || chr(65039)
    -- Zero-width joiner: combines multiple emoji into one (👨‍👩‍👧 👩‍💻 etc.)
    -- \x{200D}
    || '|' || chr(8205)
    -- Combining enclosing keycap: used in number/symbol sequences (1️⃣ *️⃣ etc.)
    -- \x{20E3}
    || '|' || chr(8419)
    || '){1,11}'
    -- keycap sequences: #️⃣ *️⃣ 0️⃣-9️⃣ (base char + variation selector-16 + combining enclosing keycap)
    -- \x{0023}, \x{002A}, \x{0030}-\x{0039}, \x{FE0F}, \x{20E3}
    || '|[#*0-9]' || chr(65039) || chr(8419)
    || ')$'
  ) THEN
    RAISE EXCEPTION 'reaction.name must be an emoji, got: %', NEW.name;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reaction_guard_emoji
  BEFORE INSERT OR UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION guard_name_emoji();
