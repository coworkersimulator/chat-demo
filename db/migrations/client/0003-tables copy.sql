CREATE TABLE IF NOT EXISTS entity (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  seq uuid DEFAULT uuidv7_now() NOT NULL,
  meta jsonb
);
CREATE INDEX IF NOT EXISTS entity_seq_idx ON entity (seq);
CREATE INDEX IF NOT EXISTS entity_meta_idx ON entity USING gin (meta);


CREATE TABLE IF NOT EXISTS "user" (
  id uuid PRIMARY KEY REFERENCES entity (id),
  username text UNIQUE NOT NULL,
  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz
);
CREATE INDEX IF NOT EXISTS user_by_idx ON "user" ("by");
CREATE INDEX IF NOT EXISTS user_at_idx ON "user" (at);
CREATE INDEX IF NOT EXISTS user_deleted_at_idx ON "user" (deleted_at);


CREATE TABLE IF NOT EXISTS relation (
  id uuid PRIMARY KEY REFERENCES entity (id),
  "on" uuid NOT NULL REFERENCES entity (id),
  "to" uuid NOT NULL REFERENCES entity (id),
  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  UNIQUE ("on", "to")
);
CREATE INDEX IF NOT EXISTS relation_to_idx ON relation ("to");
CREATE INDEX IF NOT EXISTS relation_by_idx ON relation ("by");
CREATE INDEX IF NOT EXISTS relation_at_idx ON relation (at);
CREATE INDEX IF NOT EXISTS relation_deleted_at_idx ON relation (deleted_at);


CREATE TABLE IF NOT EXISTS role (
  id uuid PRIMARY KEY REFERENCES entity (id),
  name text UNIQUE NOT NULL,
  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz
);
CREATE INDEX IF NOT EXISTS role_by_idx ON role ("by");
CREATE INDEX IF NOT EXISTS role_at_idx ON role (at);
CREATE INDEX IF NOT EXISTS role_deleted_at_idx ON role (deleted_at);


CREATE TABLE IF NOT EXISTS reaction (
  id uuid PRIMARY KEY REFERENCES entity (id),
  name text UNIQUE NOT NULL,
  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz
);
CREATE INDEX IF NOT EXISTS reaction_by_idx ON reaction ("by");
CREATE INDEX IF NOT EXISTS reaction_at_idx ON reaction (at);
CREATE INDEX IF NOT EXISTS reaction_deleted_at_idx ON reaction (deleted_at);


CREATE TABLE IF NOT EXISTS tag (
  id uuid PRIMARY KEY REFERENCES entity (id),
  name text UNIQUE NOT NULL,
  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz
);
CREATE INDEX IF NOT EXISTS tag_by_idx ON tag ("by");
CREATE INDEX IF NOT EXISTS tag_at_idx ON tag (at);
CREATE INDEX IF NOT EXISTS tag_deleted_at_idx ON tag (deleted_at);


CREATE TABLE IF NOT EXISTS note (
  id uuid PRIMARY KEY REFERENCES entity (id),
  title text,
  body text NOT NULL,
  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz
);
CREATE INDEX IF NOT EXISTS note_title_idx ON note (title);
CREATE INDEX IF NOT EXISTS note_body_idx
  ON note USING gin (to_tsvector('english', body));
CREATE INDEX IF NOT EXISTS note_by_idx ON note ("by");
CREATE INDEX IF NOT EXISTS note_at_idx ON note (at);
CREATE INDEX IF NOT EXISTS note_deleted_at_idx ON note (deleted_at);


CREATE TABLE IF NOT EXISTS file (
  id uuid PRIMARY KEY REFERENCES entity (id),
  filename text,
  mime text NOT NULL,
  data bytea NOT NULL,
  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz
);
CREATE INDEX IF NOT EXISTS file_filename_idx ON file (filename);
CREATE INDEX IF NOT EXISTS file_mime_idx ON file (mime);
CREATE INDEX IF NOT EXISTS file_by_idx ON file ("by");
CREATE INDEX IF NOT EXISTS file_at_idx ON file (at);
CREATE INDEX IF NOT EXISTS file_deleted_at_idx ON file (deleted_at);
