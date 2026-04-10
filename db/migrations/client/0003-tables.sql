CREATE TABLE IF NOT EXISTS "user" (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  username text UNIQUE NOT NULL CHECK (username ~ '^[a-zA-Z0-9]+([._-]+[a-zA-Z0-9]+)*$'),
  name text CHECK (name = trim(name)),

  by uuid NOT NULL REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb
);
CREATE INDEX IF NOT EXISTS user_by_idx             ON "user" ("by");
CREATE INDEX IF NOT EXISTS user_at_idx             ON "user" (at);
CREATE INDEX IF NOT EXISTS user_deleted_at_idx     ON "user" (deleted_at);
CREATE INDEX IF NOT EXISTS user_meta_idx           ON "user" USING gin (meta);


CREATE TABLE IF NOT EXISTS role (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  name text UNIQUE NOT NULL CHECK (name = trim(name)),

  by uuid NOT NULL REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb
);
CREATE INDEX IF NOT EXISTS role_by_idx             ON role ("by");
CREATE INDEX IF NOT EXISTS role_at_idx             ON role (at);
CREATE INDEX IF NOT EXISTS role_deleted_at_idx     ON role (deleted_at);
CREATE INDEX IF NOT EXISTS role_meta_idx           ON role USING gin (meta);


CREATE TABLE IF NOT EXISTS tag (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  name text UNIQUE NOT NULL CHECK (name = trim(name)),

  by uuid NOT NULL REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb
);
CREATE INDEX IF NOT EXISTS tag_by_idx             ON tag ("by");
CREATE INDEX IF NOT EXISTS tag_at_idx             ON tag (at);
CREATE INDEX IF NOT EXISTS tag_deleted_at_idx     ON tag (deleted_at);
CREATE INDEX IF NOT EXISTS tag_meta_idx           ON tag USING gin (meta);


CREATE TABLE IF NOT EXISTS reaction (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  emoji text UNIQUE NOT NULL,
  name text UNIQUE NOT NULL CHECK (name ~ '^[a-z0-9_]+$'),

  by uuid NOT NULL REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb
);
CREATE INDEX IF NOT EXISTS reaction_emoji_idx          ON reaction (emoji);
CREATE INDEX IF NOT EXISTS reaction_by_idx             ON reaction ("by");
CREATE INDEX IF NOT EXISTS reaction_at_idx             ON reaction (at);
CREATE INDEX IF NOT EXISTS reaction_deleted_at_idx     ON reaction (deleted_at);
CREATE INDEX IF NOT EXISTS reaction_meta_idx           ON reaction USING gin (meta);


CREATE TABLE IF NOT EXISTS note (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  title text CHECK (title IS NULL OR title = trim(title)),
  body text CHECK (body IS NULL OR body = trim(body)),

  by uuid NOT NULL REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb,
  CHECK (title IS NOT NULL OR body IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS note_title_idx           ON note (title);
CREATE INDEX IF NOT EXISTS note_body_idx            ON note USING gin (to_tsvector('english', body));
CREATE INDEX IF NOT EXISTS note_by_idx              ON note ("by");
CREATE INDEX IF NOT EXISTS note_at_idx              ON note (at);
CREATE INDEX IF NOT EXISTS note_deleted_at_idx      ON note (deleted_at);
CREATE INDEX IF NOT EXISTS note_meta_idx            ON note USING gin (meta);


CREATE TABLE IF NOT EXISTS file (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  filename text CHECK (filename IS NULL OR filename = trim(filename)),
  mime text NOT NULL CHECK (mime = trim(mime)),
  data bytea NOT NULL,

  by uuid NOT NULL REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb
);
CREATE INDEX IF NOT EXISTS file_filename_idx       ON file (filename);
CREATE INDEX IF NOT EXISTS file_mime_idx           ON file (mime);
CREATE INDEX IF NOT EXISTS file_by_idx             ON file ("by");
CREATE INDEX IF NOT EXISTS file_at_idx             ON file (at);
CREATE INDEX IF NOT EXISTS file_deleted_at_idx     ON file (deleted_at);
CREATE INDEX IF NOT EXISTS file_meta_idx           ON file USING gin (meta);


CREATE TABLE IF NOT EXISTS note_tag (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  note_id uuid NOT NULL REFERENCES note (id),
  tag_id uuid NOT NULL REFERENCES tag (id),

  by uuid NOT NULL REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb
);
CREATE INDEX IF NOT EXISTS note_tag_note_id_idx      ON note_tag (note_id);
CREATE INDEX IF NOT EXISTS note_tag_tag_id_idx       ON note_tag (tag_id);
CREATE INDEX IF NOT EXISTS note_tag_by_idx           ON note_tag ("by");
CREATE INDEX IF NOT EXISTS note_tag_at_idx           ON note_tag (at);
CREATE INDEX IF NOT EXISTS note_tag_deleted_at_idx   ON note_tag (deleted_at);
CREATE INDEX IF NOT EXISTS note_tag_meta_idx         ON note_tag USING gin (meta);
CREATE UNIQUE INDEX IF NOT EXISTS note_tag_uniq      ON note_tag (note_id, tag_id) WHERE deleted_at IS NULL;


CREATE TABLE IF NOT EXISTS note_user (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  note_id uuid NOT NULL REFERENCES note (id),
  user_id uuid NOT NULL REFERENCES "user" (id),

  by uuid NOT NULL REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb
);
CREATE INDEX IF NOT EXISTS note_user_note_id_idx      ON note_user (note_id);
CREATE INDEX IF NOT EXISTS note_user_user_id_idx      ON note_user (user_id);
CREATE INDEX IF NOT EXISTS note_user_by_idx           ON note_user ("by");
CREATE INDEX IF NOT EXISTS note_user_at_idx           ON note_user (at);
CREATE INDEX IF NOT EXISTS note_user_deleted_at_idx   ON note_user (deleted_at);
CREATE INDEX IF NOT EXISTS note_user_meta_idx         ON note_user USING gin (meta);
CREATE UNIQUE INDEX IF NOT EXISTS note_user_uniq      ON note_user (note_id, user_id) WHERE deleted_at IS NULL;


CREATE TABLE IF NOT EXISTS note_reaction (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  note_id     uuid NOT NULL REFERENCES note (id),
  reaction_id uuid NOT NULL REFERENCES reaction (id),

  by uuid NOT NULL REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb
);
CREATE INDEX IF NOT EXISTS note_reaction_note_id_idx      ON note_reaction (note_id);
CREATE INDEX IF NOT EXISTS note_reaction_reaction_id_idx  ON note_reaction (reaction_id);
CREATE INDEX IF NOT EXISTS note_reaction_by_idx           ON note_reaction ("by");
CREATE INDEX IF NOT EXISTS note_reaction_at_idx           ON note_reaction (at);
CREATE INDEX IF NOT EXISTS note_reaction_deleted_at_idx   ON note_reaction (deleted_at);
CREATE INDEX IF NOT EXISTS note_reaction_meta_idx         ON note_reaction USING gin (meta);
CREATE UNIQUE INDEX IF NOT EXISTS note_reaction_uniq      ON note_reaction (note_id, reaction_id, by) WHERE deleted_at IS NULL;


CREATE TABLE IF NOT EXISTS note_note (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  note_id   uuid NOT NULL REFERENCES note (id),
  parent_id uuid NOT NULL REFERENCES note (id),

  by uuid NOT NULL REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb
);
CREATE INDEX IF NOT EXISTS note_note_note_id_idx      ON note_note (note_id);
CREATE INDEX IF NOT EXISTS note_note_parent_id_idx    ON note_note (parent_id);
CREATE INDEX IF NOT EXISTS note_note_by_idx           ON note_note ("by");
CREATE INDEX IF NOT EXISTS note_note_at_idx           ON note_note (at);
CREATE INDEX IF NOT EXISTS note_note_deleted_at_idx   ON note_note (deleted_at);
CREATE INDEX IF NOT EXISTS note_note_meta_idx         ON note_note USING gin (meta);
CREATE UNIQUE INDEX IF NOT EXISTS note_note_uniq      ON note_note (note_id, parent_id) WHERE deleted_at IS NULL;


