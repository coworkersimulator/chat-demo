CREATE OR REPLACE FUNCTION bump_seq()
RETURNS trigger AS $$
BEGIN
  NEW.seq := uuidv7_now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER entity_bump_seq
  BEFORE UPDATE ON entity
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();


CREATE OR REPLACE FUNCTION guard_entity_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION 'entity.id cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER entity_guard_immutable
  BEFORE UPDATE ON entity
  FOR EACH ROW
  EXECUTE FUNCTION guard_entity_immutable();


CREATE OR REPLACE FUNCTION guard_type_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION 'id cannot be modified';
  END IF;
  IF NEW.by IS DISTINCT FROM OLD.by THEN
    RAISE EXCEPTION 'by cannot be modified';
  END IF;
  IF NEW.at IS DISTINCT FROM OLD.at THEN
    RAISE EXCEPTION 'at cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER relation_type_immutable
  BEFORE UPDATE ON relation
  FOR EACH ROW
  EXECUTE FUNCTION guard_type_immutable();

CREATE TRIGGER user_type_immutable
  BEFORE UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION guard_type_immutable();

CREATE TRIGGER role_type_immutable
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION guard_type_immutable();

CREATE TRIGGER reaction_type_immutable
  BEFORE UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION guard_type_immutable();

CREATE TRIGGER tag_type_immutable
  BEFORE UPDATE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION guard_type_immutable();

CREATE TRIGGER note_type_immutable
  BEFORE UPDATE ON note
  FOR EACH ROW
  EXECUTE FUNCTION guard_type_immutable();

CREATE TRIGGER file_type_immutable
  BEFORE UPDATE ON file
  FOR EACH ROW
  EXECUTE FUNCTION guard_type_immutable();


CREATE OR REPLACE FUNCTION guard_relation_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW."on" IS DISTINCT FROM OLD."on" THEN
    RAISE EXCEPTION 'relation.on cannot be modified';
  END IF;
  IF NEW."to" IS DISTINCT FROM OLD."to" THEN
    RAISE EXCEPTION 'relation.to cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER relation_guard_immutable
  BEFORE UPDATE ON relation
  FOR EACH ROW
  EXECUTE FUNCTION guard_relation_immutable();


CREATE OR REPLACE FUNCTION log_relation_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := '{}'::jsonb;
  new_fields jsonb := '{}'::jsonb;
BEGIN
  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  IF old_fields != '{}'::jsonb THEN
    UPDATE entity
    SET meta = jsonb_set(
      COALESCE(meta, '{}'::jsonb),
      '{changes}',
      COALESCE(meta->'changes', '[]'::jsonb) || jsonb_build_object(
        'old', old_fields,
        'new', new_fields,
        'by', current_setting('app.user_id', true),
        'at', now()
      )
    )
    WHERE id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER relation_log_change
  AFTER UPDATE ON relation
  FOR EACH ROW
  EXECUTE FUNCTION log_relation_change();


CREATE OR REPLACE FUNCTION log_user_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := '{}'::jsonb;
  new_fields jsonb := '{}'::jsonb;
BEGIN
  IF NEW.username IS DISTINCT FROM OLD.username THEN
    old_fields := old_fields || jsonb_build_object('username', OLD.username);
    new_fields := new_fields || jsonb_build_object('username', NEW.username);
  END IF;

  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  IF old_fields != '{}'::jsonb THEN
    UPDATE entity
    SET meta = jsonb_set(
      COALESCE(meta, '{}'::jsonb),
      '{changes}',
      COALESCE(meta->'changes', '[]'::jsonb) || jsonb_build_object(
        'old', old_fields,
        'new', new_fields,
        'by', current_setting('app.user_id', true),
        'at', now()
      )
    )
    WHERE id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_log_change
  AFTER UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION log_user_change();


CREATE OR REPLACE FUNCTION log_role_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := '{}'::jsonb;
  new_fields jsonb := '{}'::jsonb;
BEGIN
  IF NEW.name IS DISTINCT FROM OLD.name THEN
    old_fields := old_fields || jsonb_build_object('name', OLD.name);
    new_fields := new_fields || jsonb_build_object('name', NEW.name);
  END IF;

  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  IF old_fields != '{}'::jsonb THEN
    UPDATE entity
    SET meta = jsonb_set(
      COALESCE(meta, '{}'::jsonb),
      '{changes}',
      COALESCE(meta->'changes', '[]'::jsonb) || jsonb_build_object(
        'old', old_fields,
        'new', new_fields,
        'by', current_setting('app.user_id', true),
        'at', now()
      )
    )
    WHERE id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER role_log_change
  AFTER UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION log_role_change();


CREATE OR REPLACE FUNCTION log_reaction_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := '{}'::jsonb;
  new_fields jsonb := '{}'::jsonb;
BEGIN
  IF NEW.name IS DISTINCT FROM OLD.name THEN
    old_fields := old_fields || jsonb_build_object('name', OLD.name);
    new_fields := new_fields || jsonb_build_object('name', NEW.name);
  END IF;

  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  IF old_fields != '{}'::jsonb THEN
    UPDATE entity
    SET meta = jsonb_set(
      COALESCE(meta, '{}'::jsonb),
      '{changes}',
      COALESCE(meta->'changes', '[]'::jsonb) || jsonb_build_object(
        'old', old_fields,
        'new', new_fields,
        'by', current_setting('app.user_id', true),
        'at', now()
      )
    )
    WHERE id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reaction_log_change
  AFTER UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION log_reaction_change();


CREATE OR REPLACE FUNCTION log_tag_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := '{}'::jsonb;
  new_fields jsonb := '{}'::jsonb;
BEGIN
  IF NEW.name IS DISTINCT FROM OLD.name THEN
    old_fields := old_fields || jsonb_build_object('name', OLD.name);
    new_fields := new_fields || jsonb_build_object('name', NEW.name);
  END IF;

  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  IF old_fields != '{}'::jsonb THEN
    UPDATE entity
    SET meta = jsonb_set(
      COALESCE(meta, '{}'::jsonb),
      '{changes}',
      COALESCE(meta->'changes', '[]'::jsonb) || jsonb_build_object(
        'old', old_fields,
        'new', new_fields,
        'by', current_setting('app.user_id', true),
        'at', now()
      )
    )
    WHERE id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tag_log_change
  AFTER UPDATE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION log_tag_change();


CREATE OR REPLACE FUNCTION log_note_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := '{}'::jsonb;
  new_fields jsonb := '{}'::jsonb;
BEGIN
  IF NEW.title IS DISTINCT FROM OLD.title THEN
    old_fields := old_fields || jsonb_build_object('title', OLD.title);
    new_fields := new_fields || jsonb_build_object('title', NEW.title);
  END IF;

  IF NEW.body IS DISTINCT FROM OLD.body THEN
    old_fields := old_fields || jsonb_build_object('body', OLD.body);
    new_fields := new_fields || jsonb_build_object('body', NEW.body);
  END IF;

  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  IF old_fields != '{}'::jsonb THEN
    UPDATE entity
    SET meta = jsonb_set(
      COALESCE(meta, '{}'::jsonb),
      '{changes}',
      COALESCE(meta->'changes', '[]'::jsonb) || jsonb_build_object(
        'old', old_fields,
        'new', new_fields,
        'by', current_setting('app.user_id', true),
        'at', now()
      )
    )
    WHERE id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER note_log_change
  AFTER UPDATE ON note
  FOR EACH ROW
  EXECUTE FUNCTION log_note_change();


CREATE OR REPLACE FUNCTION log_file_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := '{}'::jsonb;
  new_fields jsonb := '{}'::jsonb;
BEGIN
  IF NEW.filename IS DISTINCT FROM OLD.filename THEN
    old_fields := old_fields || jsonb_build_object('filename', OLD.filename);
    new_fields := new_fields || jsonb_build_object('filename', NEW.filename);
  END IF;

  IF NEW.mime IS DISTINCT FROM OLD.mime THEN
    old_fields := old_fields || jsonb_build_object('mime', OLD.mime);
    new_fields := new_fields || jsonb_build_object('mime', NEW.mime);
  END IF;

  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  IF old_fields != '{}'::jsonb THEN
    UPDATE entity
    SET meta = jsonb_set(
      COALESCE(meta, '{}'::jsonb),
      '{changes}',
      COALESCE(meta->'changes', '[]'::jsonb) || jsonb_build_object(
        'old', old_fields,
        'new', new_fields,
        'by', current_setting('app.user_id', true),
        'at', now()
      )
    )
    WHERE id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER file_log_change
  AFTER UPDATE ON file
  FOR EACH ROW
  EXECUTE FUNCTION log_file_change();


CREATE OR REPLACE FUNCTION guard_role_relation()
RETURNS trigger AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM role r
    WHERE r.id = NEW."to"
      AND r.deleted_at IS NULL
  ) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM "user" u
      WHERE u.id = NEW."on"
        AND u.deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'a role can only be assigned to an active user, got on=%', NEW."on";
    END IF;
  ELSIF EXISTS (SELECT 1 FROM role WHERE id = NEW."to") THEN
    RAISE EXCEPTION 'cannot assign a deleted role, got to=%', NEW."to";
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER relation_guard_role
  BEFORE INSERT OR UPDATE ON relation
  FOR EACH ROW
  EXECUTE FUNCTION guard_role_relation();


CREATE OR REPLACE FUNCTION guard_file_data()
RETURNS trigger AS $$
BEGIN
  IF NEW.data IS DISTINCT FROM OLD.data THEN
    RAISE EXCEPTION 'file.data cannot be modified, delete and create a new file instead';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER file_guard_data
  BEFORE UPDATE ON file
  FOR EACH ROW
  EXECUTE FUNCTION guard_file_data();


CREATE OR REPLACE FUNCTION check_admin()
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1
    FROM relation r
    JOIN role ro ON ro.id = r."to"
    JOIN "user" u ON u.id = r."on"
    WHERE r."on" = current_setting('app.user_id', true)::uuid
      AND ro.name = 'admin'
      AND r.deleted_at IS NULL
      AND ro.deleted_at IS NULL
      AND u.deleted_at IS NULL
  )
$$ LANGUAGE sql STABLE PARALLEL SAFE COST 30;


CREATE OR REPLACE FUNCTION guard_admin_only()
RETURNS trigger AS $$
BEGIN
  IF NOT check_admin() THEN
    RAISE EXCEPTION 'only admin can perform this action';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER role_guard_admin
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION guard_admin_only();

CREATE TRIGGER tag_guard_admin
  BEFORE UPDATE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION guard_admin_only();

CREATE TRIGGER reaction_guard_admin
  BEFORE UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION guard_admin_only();


CREATE OR REPLACE FUNCTION guard_admin_role_rename()
RETURNS trigger AS $$
BEGIN
  IF OLD.name = 'admin' AND NEW.name IS DISTINCT FROM OLD.name THEN
    RAISE EXCEPTION 'the admin role cannot be renamed';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER role_guard_admin_rename
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION guard_admin_role_rename();


CREATE OR REPLACE FUNCTION guard_file_mime_admin()
RETURNS trigger AS $$
BEGIN
  IF NEW.mime IS DISTINCT FROM OLD.mime THEN
    IF NOT check_admin() THEN
      RAISE EXCEPTION 'only admin can change file.mime';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER file_guard_mime
  BEFORE UPDATE ON file
  FOR EACH ROW
  EXECUTE FUNCTION guard_file_mime_admin();


CREATE OR REPLACE FUNCTION guard_role_create()
RETURNS trigger AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM role r
    WHERE r.name = 'admin'
      AND r.deleted_at IS NULL
  ) THEN
    IF NOT check_admin() THEN
      RAISE EXCEPTION 'only admin can create roles';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER role_guard_create
  BEFORE INSERT ON role
  FOR EACH ROW
  EXECUTE FUNCTION guard_role_create();


CREATE OR REPLACE FUNCTION guard_role_assignment()
RETURNS trigger AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM role WHERE id = NEW."to") THEN
    IF EXISTS (
      SELECT 1
      FROM relation r
      JOIN role ro ON ro.id = r."to"
      WHERE ro.name = 'admin'
        AND r.deleted_at IS NULL
        AND ro.deleted_at IS NULL
    ) THEN
      IF NOT check_admin() THEN
        RAISE EXCEPTION 'only admin can assign roles';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER relation_guard_role_assignment
  BEFORE INSERT OR UPDATE ON relation
  FOR EACH ROW
  EXECUTE FUNCTION guard_role_assignment();


CREATE OR REPLACE FUNCTION guard_hard_delete()
RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'hard deletes are not allowed, use soft delete instead';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER entity_guard_hard_delete
  BEFORE DELETE ON entity
  FOR EACH ROW
  EXECUTE FUNCTION guard_hard_delete();

CREATE TRIGGER relation_guard_hard_delete
  BEFORE DELETE ON relation
  FOR EACH ROW
  EXECUTE FUNCTION guard_hard_delete();

CREATE TRIGGER user_guard_hard_delete
  BEFORE DELETE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION guard_hard_delete();

CREATE TRIGGER role_guard_hard_delete
  BEFORE DELETE ON role
  FOR EACH ROW
  EXECUTE FUNCTION guard_hard_delete();

CREATE TRIGGER reaction_guard_hard_delete
  BEFORE DELETE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION guard_hard_delete();

CREATE TRIGGER tag_guard_hard_delete
  BEFORE DELETE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION guard_hard_delete();

CREATE TRIGGER note_guard_hard_delete
  BEFORE DELETE ON note
  FOR EACH ROW
  EXECUTE FUNCTION guard_hard_delete();

CREATE TRIGGER file_guard_hard_delete
  BEFORE DELETE ON file
  FOR EACH ROW
  EXECUTE FUNCTION guard_hard_delete();


CREATE OR REPLACE FUNCTION guard_protected_delete()
RETURNS trigger AS $$
BEGIN
  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    IF EXISTS (SELECT 1 FROM role WHERE id = NEW.id AND name = 'admin') THEN
      RAISE EXCEPTION 'the admin role cannot be deleted';
    END IF;

    IF EXISTS (
      SELECT 1
      FROM relation r
      JOIN role ro ON ro.id = r."to"
      WHERE r.id = NEW.id
        AND ro.name = 'admin'
    ) THEN
      IF NOT check_admin() THEN
        RAISE EXCEPTION 'only admin can delete an admin role assignment';
      END IF;

      IF (
        SELECT count(*)
        FROM relation r
        JOIN role ro ON ro.id = r."to"
        WHERE ro.name = 'admin'
          AND r.deleted_at IS NULL
          AND r.id != NEW.id
      ) = 0 THEN
        RAISE EXCEPTION 'cannot delete the last admin assignment';
      END IF;
    END IF;

    IF EXISTS (SELECT 1 FROM "user" WHERE id = NEW.id) THEN
      IF EXISTS (
        SELECT 1
        FROM relation r
        JOIN role ro ON ro.id = r."to"
        WHERE r."on" = NEW.id
          AND ro.name = 'admin'
          AND r.deleted_at IS NULL
      ) THEN
        IF (
          SELECT count(*)
          FROM relation r
          JOIN role ro ON ro.id = r."to"
          JOIN "user" u ON u.id = r."on"
          WHERE ro.name = 'admin'
            AND r.deleted_at IS NULL
            AND u.deleted_at IS NULL
            AND r."on" != NEW.id
        ) = 0 THEN
          RAISE EXCEPTION 'cannot delete the last active admin user';
        END IF;
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER role_guard_protected_delete
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION guard_protected_delete();

CREATE TRIGGER relation_guard_protected_delete
  BEFORE UPDATE ON relation
  FOR EACH ROW
  EXECUTE FUNCTION guard_protected_delete();

CREATE TRIGGER user_guard_protected_delete
  BEFORE UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION guard_protected_delete();


CREATE OR REPLACE FUNCTION unique_on_delete()
RETURNS trigger AS $$
DECLARE
  suffix text := '_' || substr(uuid_generate_v4()::text, 1, 8);
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    IF TG_TABLE_NAME = 'user' THEN
      NEW.username := NEW.username || suffix;
    ELSIF TG_TABLE_NAME IN ('role', 'tag', 'reaction') THEN
      NEW.name := NEW.name || suffix;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_unique_on_delete
  BEFORE UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION unique_on_delete();

CREATE TRIGGER role_unique_on_delete
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION unique_on_delete();

CREATE TRIGGER tag_unique_on_delete
  BEFORE UPDATE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION unique_on_delete();

CREATE TRIGGER reaction_unique_on_delete
  BEFORE UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION unique_on_delete();