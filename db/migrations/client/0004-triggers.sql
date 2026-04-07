CREATE OR REPLACE FUNCTION bump_seq()
RETURNS trigger AS $$
BEGIN
  NEW.seq := uuidv7_now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER _user_bump_seq
  BEFORE UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();

CREATE TRIGGER _role_bump_seq
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();

CREATE TRIGGER _tag_bump_seq
  BEFORE UPDATE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();

CREATE TRIGGER _reaction_bump_seq
  BEFORE UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();

CREATE TRIGGER _note_bump_seq
  BEFORE UPDATE ON note
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();

CREATE TRIGGER _file_bump_seq
  BEFORE UPDATE ON file
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();

CREATE TRIGGER _relation_bump_seq
  BEFORE UPDATE ON relation
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();


CREATE OR REPLACE FUNCTION guard_user_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION 'user.id cannot be modified';
  END IF;
  IF NEW.by IS DISTINCT FROM OLD.by THEN
    RAISE EXCEPTION 'user.by cannot be modified';
  END IF;
  IF NEW.at IS DISTINCT FROM OLD.at THEN
    RAISE EXCEPTION 'user.at cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_guard_immutable
  BEFORE UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION guard_user_immutable();


CREATE OR REPLACE FUNCTION guard_role_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION 'role.id cannot be modified';
  END IF;
  IF NEW.by IS DISTINCT FROM OLD.by THEN
    RAISE EXCEPTION 'role.by cannot be modified';
  END IF;
  IF NEW.at IS DISTINCT FROM OLD.at THEN
    RAISE EXCEPTION 'role.at cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER role_guard_immutable
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION guard_role_immutable();


CREATE OR REPLACE FUNCTION guard_tag_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION 'tag.id cannot be modified';
  END IF;
  IF NEW.by IS DISTINCT FROM OLD.by THEN
    RAISE EXCEPTION 'tag.by cannot be modified';
  END IF;
  IF NEW.at IS DISTINCT FROM OLD.at THEN
    RAISE EXCEPTION 'tag.at cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tag_guard_immutable
  BEFORE UPDATE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION guard_tag_immutable();


CREATE OR REPLACE FUNCTION guard_reaction_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION 'reaction.id cannot be modified';
  END IF;
  IF NEW.by IS DISTINCT FROM OLD.by THEN
    RAISE EXCEPTION 'reaction.by cannot be modified';
  END IF;
  IF NEW.at IS DISTINCT FROM OLD.at THEN
    RAISE EXCEPTION 'reaction.at cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reaction_guard_immutable
  BEFORE UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION guard_reaction_immutable();


CREATE OR REPLACE FUNCTION guard_note_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION 'note.id cannot be modified';
  END IF;
  IF NEW.by IS DISTINCT FROM OLD.by THEN
    RAISE EXCEPTION 'note.by cannot be modified';
  END IF;
  IF NEW.at IS DISTINCT FROM OLD.at THEN
    RAISE EXCEPTION 'note.at cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER note_guard_immutable
  BEFORE UPDATE ON note
  FOR EACH ROW
  EXECUTE FUNCTION guard_note_immutable();


CREATE OR REPLACE FUNCTION guard_file_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION 'file.id cannot be modified';
  END IF;
  IF NEW.by IS DISTINCT FROM OLD.by THEN
    RAISE EXCEPTION 'file.by cannot be modified';
  END IF;
  IF NEW.at IS DISTINCT FROM OLD.at THEN
    RAISE EXCEPTION 'file.at cannot be modified';
  END IF;
  IF NEW.data IS DISTINCT FROM OLD.data THEN
    RAISE EXCEPTION 'file.data cannot be modified, delete and create a new file instead';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER file_guard_immutable
  BEFORE UPDATE ON file
  FOR EACH ROW
  EXECUTE FUNCTION guard_file_immutable();


CREATE OR REPLACE FUNCTION guard_relation_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION 'relation.id cannot be modified';
  END IF;
  IF NEW.by IS DISTINCT FROM OLD.by THEN
    RAISE EXCEPTION 'relation.by cannot be modified';
  END IF;
  IF NEW.at IS DISTINCT FROM OLD.at THEN
    RAISE EXCEPTION 'relation.at cannot be modified';
  END IF;
  IF NEW.on_user_id IS DISTINCT FROM OLD.on_user_id THEN
    RAISE EXCEPTION 'relation.on_user_id cannot be modified';
  END IF;
  IF NEW.on_role_id IS DISTINCT FROM OLD.on_role_id THEN
    RAISE EXCEPTION 'relation.on_role_id cannot be modified';
  END IF;
  IF NEW.on_tag_id IS DISTINCT FROM OLD.on_tag_id THEN
    RAISE EXCEPTION 'relation.on_tag_id cannot be modified';
  END IF;
  IF NEW.on_note_id IS DISTINCT FROM OLD.on_note_id THEN
    RAISE EXCEPTION 'relation.on_note_id cannot be modified';
  END IF;
  IF NEW.on_file_id IS DISTINCT FROM OLD.on_file_id THEN
    RAISE EXCEPTION 'relation.on_file_id cannot be modified';
  END IF;
  IF NEW.on_relation IS DISTINCT FROM OLD.on_relation THEN
    RAISE EXCEPTION 'relation.on_relation cannot be modified';
  END IF;
  IF NEW.to_user_id IS DISTINCT FROM OLD.to_user_id THEN
    RAISE EXCEPTION 'relation.to_user_id cannot be modified';
  END IF;
  IF NEW.to_role_id IS DISTINCT FROM OLD.to_role_id THEN
    RAISE EXCEPTION 'relation.to_role_id cannot be modified';
  END IF;
  IF NEW.to_tag_id IS DISTINCT FROM OLD.to_tag_id THEN
    RAISE EXCEPTION 'relation.to_tag_id cannot be modified';
  END IF;
  IF NEW.to_note_id IS DISTINCT FROM OLD.to_note_id THEN
    RAISE EXCEPTION 'relation.to_note_id cannot be modified';
  END IF;
  IF NEW.to_file_id IS DISTINCT FROM OLD.to_file_id THEN
    RAISE EXCEPTION 'relation.to_file_id cannot be modified';
  END IF;
  IF NEW.to_relation IS DISTINCT FROM OLD.to_relation THEN
    RAISE EXCEPTION 'relation.to_relation cannot be modified';
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
  old_fields jsonb := jsonb_build_object('seq', OLD.seq);
  new_fields jsonb := jsonb_build_object('seq', NEW.seq);
BEGIN
  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  NEW.meta := COALESCE(NEW.meta, '{}'::jsonb) || jsonb_build_object(
    'changes',
    COALESCE(NEW.meta->'changes', '[]'::jsonb) || jsonb_build_object(
      'old', old_fields,
      'new', new_fields,
      'by', current_setting('app.user_id', true),
      'at', now()
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER relation_log_change
  BEFORE UPDATE ON relation
  FOR EACH ROW
  EXECUTE FUNCTION log_relation_change();


CREATE OR REPLACE FUNCTION log_user_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := jsonb_build_object('seq', OLD.seq);
  new_fields jsonb := jsonb_build_object('seq', NEW.seq);
BEGIN
  IF NEW.username IS DISTINCT FROM OLD.username THEN
    old_fields := old_fields || jsonb_build_object('username', OLD.username);
    new_fields := new_fields || jsonb_build_object('username', NEW.username);
  END IF;

  IF NEW.name IS DISTINCT FROM OLD.name THEN
    old_fields := old_fields || jsonb_build_object('name', OLD.name);
    new_fields := new_fields || jsonb_build_object('name', NEW.name);
  END IF;

  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  NEW.meta := COALESCE(NEW.meta, '{}'::jsonb) || jsonb_build_object(
    'changes',
    COALESCE(NEW.meta->'changes', '[]'::jsonb) || jsonb_build_object(
      'old', old_fields,
      'new', new_fields,
      'by', current_setting('app.user_id', true),
      'at', now()
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_log_change
  BEFORE UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION log_user_change();


CREATE OR REPLACE FUNCTION log_role_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := jsonb_build_object('seq', OLD.seq);
  new_fields jsonb := jsonb_build_object('seq', NEW.seq);
BEGIN
  IF NEW.name IS DISTINCT FROM OLD.name THEN
    old_fields := old_fields || jsonb_build_object('name', OLD.name);
    new_fields := new_fields || jsonb_build_object('name', NEW.name);
  END IF;

  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  NEW.meta := COALESCE(NEW.meta, '{}'::jsonb) || jsonb_build_object(
    'changes',
    COALESCE(NEW.meta->'changes', '[]'::jsonb) || jsonb_build_object(
      'old', old_fields,
      'new', new_fields,
      'by', current_setting('app.user_id', true),
      'at', now()
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER role_log_change
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION log_role_change();


CREATE OR REPLACE FUNCTION log_reaction_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := jsonb_build_object('seq', OLD.seq);
  new_fields jsonb := jsonb_build_object('seq', NEW.seq);
BEGIN
  IF NEW.name IS DISTINCT FROM OLD.name THEN
    old_fields := old_fields || jsonb_build_object('name', OLD.name);
    new_fields := new_fields || jsonb_build_object('name', NEW.name);
  END IF;

  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  NEW.meta := COALESCE(NEW.meta, '{}'::jsonb) || jsonb_build_object(
    'changes',
    COALESCE(NEW.meta->'changes', '[]'::jsonb) || jsonb_build_object(
      'old', old_fields,
      'new', new_fields,
      'by', current_setting('app.user_id', true),
      'at', now()
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reaction_log_change
  BEFORE UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION log_reaction_change();


CREATE OR REPLACE FUNCTION log_tag_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := jsonb_build_object('seq', OLD.seq);
  new_fields jsonb := jsonb_build_object('seq', NEW.seq);
BEGIN
  IF NEW.name IS DISTINCT FROM OLD.name THEN
    old_fields := old_fields || jsonb_build_object('name', OLD.name);
    new_fields := new_fields || jsonb_build_object('name', NEW.name);
  END IF;

  IF NEW.deleted_at IS DISTINCT FROM OLD.deleted_at THEN
    old_fields := old_fields || jsonb_build_object('deleted_at', OLD.deleted_at);
    new_fields := new_fields || jsonb_build_object('deleted_at', NEW.deleted_at);
  END IF;

  NEW.meta := COALESCE(NEW.meta, '{}'::jsonb) || jsonb_build_object(
    'changes',
    COALESCE(NEW.meta->'changes', '[]'::jsonb) || jsonb_build_object(
      'old', old_fields,
      'new', new_fields,
      'by', current_setting('app.user_id', true),
      'at', now()
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tag_log_change
  BEFORE UPDATE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION log_tag_change();


CREATE OR REPLACE FUNCTION log_note_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := jsonb_build_object('seq', OLD.seq);
  new_fields jsonb := jsonb_build_object('seq', NEW.seq);
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

  NEW.meta := COALESCE(NEW.meta, '{}'::jsonb) || jsonb_build_object(
    'changes',
    COALESCE(NEW.meta->'changes', '[]'::jsonb) || jsonb_build_object(
      'old', old_fields,
      'new', new_fields,
      'by', current_setting('app.user_id', true),
      'at', now()
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER note_log_change
  BEFORE UPDATE ON note
  FOR EACH ROW
  EXECUTE FUNCTION log_note_change();


CREATE OR REPLACE FUNCTION log_file_change()
RETURNS trigger AS $$
DECLARE
  old_fields jsonb := jsonb_build_object('seq', OLD.seq);
  new_fields jsonb := jsonb_build_object('seq', NEW.seq);
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

  NEW.meta := COALESCE(NEW.meta, '{}'::jsonb) || jsonb_build_object(
    'changes',
    COALESCE(NEW.meta->'changes', '[]'::jsonb) || jsonb_build_object(
      'old', old_fields,
      'new', new_fields,
      'by', current_setting('app.user_id', true),
      'at', now()
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER file_log_change
  BEFORE UPDATE ON file
  FOR EACH ROW
  EXECUTE FUNCTION log_file_change();


CREATE OR REPLACE FUNCTION guard_role_relation()
RETURNS trigger AS $$
BEGIN
  IF NEW.to_role_id IS NOT NULL THEN
    IF EXISTS (SELECT 1 FROM role WHERE id = NEW.to_role_id AND deleted_at IS NOT NULL) THEN
      RAISE EXCEPTION 'cannot assign a deleted role, got to_role_id=%', NEW.to_role_id;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM "user" WHERE id = NEW.on_user_id AND deleted_at IS NULL) THEN
      RAISE EXCEPTION 'a role can only be assigned to an active user, got on_user_id=%', NEW.on_user_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER relation_guard_role
  BEFORE INSERT OR UPDATE ON relation
  FOR EACH ROW
  EXECUTE FUNCTION guard_role_relation();



CREATE OR REPLACE FUNCTION check_admin()
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1
    FROM relation r
    JOIN role ro ON ro.id = r.to_role_id
    JOIN "user" u ON u.id = r.on_user_id
    WHERE r.on_user_id = current_setting('app.user_id', true)::uuid
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
  IF NEW.to_role_id IS NOT NULL THEN
    IF EXISTS (
      SELECT 1
      FROM relation r
      JOIN role ro ON ro.id = r.to_role_id
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
      JOIN role ro ON ro.id = r.to_role_id
      WHERE r.id = NEW.id
        AND ro.name = 'admin'
    ) THEN
      IF NOT check_admin() THEN
        RAISE EXCEPTION 'only admin can delete an admin role assignment';
      END IF;

      IF (
        SELECT count(*)
        FROM relation r
        JOIN role ro ON ro.id = r.to_role_id
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
        JOIN role ro ON ro.id = r.to_role_id
        WHERE r.on_user_id = NEW.id
          AND ro.name = 'admin'
          AND r.deleted_at IS NULL
      ) THEN
        IF (
          SELECT count(*)
          FROM relation r
          JOIN role ro ON ro.id = r.to_role_id
          JOIN "user" u ON u.id = r.on_user_id
          WHERE ro.name = 'admin'
            AND r.deleted_at IS NULL
            AND u.deleted_at IS NULL
            AND r.on_user_id != NEW.id
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


CREATE OR REPLACE FUNCTION unique_user_on_delete()
RETURNS trigger AS $$
DECLARE
  suffix text := '_' || substr(uuid_generate_v4()::text, 1, 8);
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    NEW.username := NEW.username || suffix;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_unique_on_delete
  BEFORE UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION unique_user_on_delete();


CREATE OR REPLACE FUNCTION unique_role_on_delete()
RETURNS trigger AS $$
DECLARE
  suffix text := '_' || substr(uuid_generate_v4()::text, 1, 8);
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    NEW.name := NEW.name || suffix;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER role_unique_on_delete
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION unique_role_on_delete();


CREATE OR REPLACE FUNCTION unique_tag_on_delete()
RETURNS trigger AS $$
DECLARE
  suffix text := '_' || substr(uuid_generate_v4()::text, 1, 8);
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    NEW.name := NEW.name || suffix;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tag_unique_on_delete
  BEFORE UPDATE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION unique_tag_on_delete();


CREATE OR REPLACE FUNCTION unique_reaction_on_delete()
RETURNS trigger AS $$
DECLARE
  suffix text := '_' || substr(uuid_generate_v4()::text, 1, 8);
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    NEW.name := NEW.name || suffix;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reaction_unique_on_delete
  BEFORE UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION unique_reaction_on_delete();