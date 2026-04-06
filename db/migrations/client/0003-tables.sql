CREATE TABLE IF NOT EXISTS "user" (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  username text UNIQUE NOT NULL CHECK (username = trim(username)),

  by uuid REFERENCES "user" (id),
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

  by uuid REFERENCES "user" (id),
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

  by uuid REFERENCES "user" (id),
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

  name text UNIQUE NOT NULL CHECK (name = trim(name)),

  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb
);
CREATE INDEX IF NOT EXISTS reaction_by_idx             ON reaction ("by");
CREATE INDEX IF NOT EXISTS reaction_at_idx             ON reaction (at);
CREATE INDEX IF NOT EXISTS reaction_deleted_at_idx     ON reaction (deleted_at);
CREATE INDEX IF NOT EXISTS reaction_meta_idx           ON reaction USING gin (meta);


CREATE TABLE IF NOT EXISTS note (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seq uuid DEFAULT uuidv7_now() UNIQUE NOT NULL,

  title text CHECK (title IS NULL OR title = trim(title)),
  body text CHECK (body IS NULL OR body = trim(body)),

  by uuid REFERENCES "user" (id),
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

  by uuid REFERENCES "user" (id),
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


CREATE TABLE IF NOT EXISTS relation (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
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

  by uuid REFERENCES "user" (id),
  at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at timestamptz,
  meta jsonb,
  CHECK (num_nonnulls(on_user_id, on_role_id, on_tag_id, on_note_id, on_file_id, on_relation) = 1),
  CHECK (num_nonnulls(to_user_id, to_role_id, to_tag_id, to_note_id, to_file_id, to_relation) > 1)
);
CREATE INDEX IF NOT EXISTS relation_by_idx             ON relation ("by");
CREATE INDEX IF NOT EXISTS relation_at_idx             ON relation (at);
CREATE INDEX IF NOT EXISTS relation_deleted_at_idx     ON relation (deleted_at);
CREATE INDEX IF NOT EXISTS relation_meta_idx           ON relation USING gin (meta);
CREATE INDEX IF NOT EXISTS relation_on_user_id_idx     ON relation (on_user_id)   WHERE on_user_id   IS NOT NULL;
CREATE INDEX IF NOT EXISTS relation_on_role_id_idx     ON relation (on_role_id)   WHERE on_role_id   IS NOT NULL;
CREATE INDEX IF NOT EXISTS relation_on_tag_id_idx      ON relation (on_tag_id)    WHERE on_tag_id    IS NOT NULL;
CREATE INDEX IF NOT EXISTS relation_on_note_id_idx     ON relation (on_note_id)   WHERE on_note_id   IS NOT NULL;
CREATE INDEX IF NOT EXISTS relation_on_file_id_idx     ON relation (on_file_id)   WHERE on_file_id   IS NOT NULL;
CREATE INDEX IF NOT EXISTS relation_on_relation_idx    ON relation (on_relation)  WHERE on_relation  IS NOT NULL;
CREATE INDEX IF NOT EXISTS relation_to_user_id_idx     ON relation (to_user_id)   WHERE to_user_id   IS NOT NULL;
CREATE INDEX IF NOT EXISTS relation_to_role_id_idx     ON relation (to_role_id)   WHERE to_role_id   IS NOT NULL;
CREATE INDEX IF NOT EXISTS relation_to_tag_id_idx      ON relation (to_tag_id)    WHERE to_tag_id    IS NOT NULL;
CREATE INDEX IF NOT EXISTS relation_to_note_id_idx     ON relation (to_note_id)   WHERE to_note_id   IS NOT NULL;
CREATE INDEX IF NOT EXISTS relation_to_file_id_idx     ON relation (to_file_id)   WHERE to_file_id   IS NOT NULL;
CREATE INDEX IF NOT EXISTS relation_to_relation_idx    ON relation (to_relation)  WHERE to_relation  IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS relation_on_user_to_role_tag_uniq    ON relation (on_user_id, to_role_id, to_tag_id)   NULLS NOT DISTINCT WHERE on_user_id  IS NOT NULL AND to_role_id  IS NOT NULL AND deleted_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS relation_on_user_to_user_tag_uniq    ON relation (on_user_id, to_user_id, to_tag_id)   NULLS NOT DISTINCT WHERE on_user_id  IS NOT NULL AND to_user_id  IS NOT NULL AND deleted_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS relation_on_rel_to_rel_tag_uniq      ON relation (on_relation, to_relation, to_tag_id) NULLS NOT DISTINCT WHERE on_relation IS NOT NULL AND to_relation IS NOT NULL AND deleted_at IS NULL;
