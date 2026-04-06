CREATE TABLE IF NOT EXISTS "user" (
  id uuid PRIMARY KEY,
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,
  username text UNIQUE NOT NULL,
  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz
);
CREATE INDEX IF NOT EXISTS user_by_idx ON "user" ("by");
CREATE INDEX IF NOT EXISTS user_at_idx ON "user" (at);
CREATE INDEX IF NOT EXISTS user_deleted_at_idx ON "user" (deleted_at);


CREATE TABLE IF NOT EXISTS role (
  id uuid PRIMARY KEY,
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,
  name text UNIQUE NOT NULL,
  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz
);
CREATE INDEX IF NOT EXISTS role_by_idx ON role ("by");
CREATE INDEX IF NOT EXISTS role_at_idx ON role (at);
CREATE INDEX IF NOT EXISTS role_deleted_at_idx ON role (deleted_at);


CREATE TABLE IF NOT EXISTS tag (
  id uuid PRIMARY KEY,
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,
  name text UNIQUE NOT NULL,
  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz
);
CREATE INDEX IF NOT EXISTS tag_by_idx ON tag ("by");
CREATE INDEX IF NOT EXISTS tag_at_idx ON tag (at);
CREATE INDEX IF NOT EXISTS tag_deleted_at_idx ON tag (deleted_at);


CREATE TABLE IF NOT EXISTS reaction (
  id uuid PRIMARY KEY,
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,
  name text UNIQUE NOT NULL,
  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz
);
CREATE INDEX IF NOT EXISTS reaction_by_idx ON reaction ("by");
CREATE INDEX IF NOT EXISTS reaction_at_idx ON reaction (at);
CREATE INDEX IF NOT EXISTS reaction_deleted_at_idx ON reaction (deleted_at);


CREATE TABLE IF NOT EXISTS note (
  id uuid PRIMARY KEY,
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,
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
  id uuid PRIMARY KEY,
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,
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


CREATE TABLE IF NOT EXISTS relation (
  id uuid PRIMARY KEY,
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  on_user_id uuid REFERENCES "user" (id),
  on_role_id uuid REFERENCES role (id),
  on_tag_id uuid REFERENCES tag (id),
  on_note_id uuid REFERENCES note (id),
  on_file_id uuid REFERENCES file (id),
  on_relation uuid REFERENCES relation (id),

  to_user_id uuid REFERENCES "user" (id),
  to_role_id uuid REFERENCES role (id),
  to_tag_id uuid REFERENCES tag (id),
  to_note_id uuid REFERENCES note (id),
  to_file_id uuid REFERENCES file (id),
  to_relation uuid REFERENCES relation (id),
  CHECK (num_nonnulls(on_user_id, on_role_id, on_tag_id, on_note_id, on_file_id, on_relation) = 1),
  CHECK (num_nonnulls(to_user_id, to_role_id, to_tag_id, to_note_id, to_file_id, to_relation) = 1)
);
