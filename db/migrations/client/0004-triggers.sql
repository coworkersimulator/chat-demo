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

CREATE TRIGGER _rel_bump_seq
  BEFORE UPDATE ON rel
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


CREATE OR REPLACE FUNCTION guard_rel_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION 'rel.id cannot be modified';
  END IF;
  IF NEW.by IS DISTINCT FROM OLD.by THEN
    RAISE EXCEPTION 'rel.by cannot be modified';
  END IF;
  IF NEW.at IS DISTINCT FROM OLD.at THEN
    RAISE EXCEPTION 'rel.at cannot be modified';
  END IF;
  IF NEW.on_user_id IS DISTINCT FROM OLD.on_user_id THEN
    RAISE EXCEPTION 'rel.on_user_id cannot be modified';
  END IF;
  IF NEW.on_role_id IS DISTINCT FROM OLD.on_role_id THEN
    RAISE EXCEPTION 'rel.on_role_id cannot be modified';
  END IF;
  IF NEW.on_tag_id IS DISTINCT FROM OLD.on_tag_id THEN
    RAISE EXCEPTION 'rel.on_tag_id cannot be modified';
  END IF;
  IF NEW.on_note_id IS DISTINCT FROM OLD.on_note_id THEN
    RAISE EXCEPTION 'rel.on_note_id cannot be modified';
  END IF;
  IF NEW.on_file_id IS DISTINCT FROM OLD.on_file_id THEN
    RAISE EXCEPTION 'rel.on_file_id cannot be modified';
  END IF;
  IF NEW.on_rel_id IS DISTINCT FROM OLD.on_rel_id THEN
    RAISE EXCEPTION 'rel.on_rel_id cannot be modified';
  END IF;
  IF NEW.as_user_id IS DISTINCT FROM OLD.as_user_id THEN
    RAISE EXCEPTION 'rel.as_user_id cannot be modified';
  END IF;
  IF NEW.as_role_id IS DISTINCT FROM OLD.as_role_id THEN
    RAISE EXCEPTION 'rel.as_role_id cannot be modified';
  END IF;
  IF NEW.as_tag_id IS DISTINCT FROM OLD.as_tag_id THEN
    RAISE EXCEPTION 'rel.as_tag_id cannot be modified';
  END IF;
  IF NEW.as_note_id IS DISTINCT FROM OLD.as_note_id THEN
    RAISE EXCEPTION 'rel.as_note_id cannot be modified';
  END IF;
  IF NEW.as_file_id IS DISTINCT FROM OLD.as_file_id THEN
    RAISE EXCEPTION 'rel.as_file_id cannot be modified';
  END IF;
  IF NEW.as_rel_id IS DISTINCT FROM OLD.as_rel_id THEN
    RAISE EXCEPTION 'rel.as_rel_id cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rel_guard_immutable
  BEFORE UPDATE ON rel
  FOR EACH ROW
  EXECUTE FUNCTION guard_rel_immutable();


CREATE OR REPLACE FUNCTION log_change()
RETURNS trigger AS $$
DECLARE
  old_json jsonb := row_to_json(OLD)::jsonb;
  new_json jsonb := row_to_json(NEW)::jsonb;
  old_diff jsonb := '{}'::jsonb;
  new_diff jsonb := '{}'::jsonb;
  key text;
BEGIN
  FOR key IN SELECT jsonb_object_keys(new_json) LOOP
    IF key != 'meta' AND old_json->key IS DISTINCT FROM new_json->key THEN
      old_diff := old_diff || jsonb_build_object(key, old_json->key);
      new_diff := new_diff || jsonb_build_object(key, new_json->key);
    END IF;
  END LOOP;

  NEW.meta := COALESCE(NEW.meta, '{}'::jsonb) || jsonb_build_object(
    'changes',
    COALESCE(NEW.meta->'changes', '[]'::jsonb) || jsonb_build_object(
      'old', old_diff,
      'new', new_diff,
      'by', current_setting('app.user_id', true),
      'at', now()
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rel_log_change
  BEFORE UPDATE ON rel
  FOR EACH ROW
  EXECUTE FUNCTION log_change();

CREATE TRIGGER user_log_change
  BEFORE UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION log_change();

CREATE TRIGGER role_log_change
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION log_change();

CREATE TRIGGER reaction_log_change
  BEFORE UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION log_change();

CREATE TRIGGER tag_log_change
  BEFORE UPDATE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION log_change();

CREATE TRIGGER note_log_change
  BEFORE UPDATE ON note
  FOR EACH ROW
  EXECUTE FUNCTION log_change();

CREATE TRIGGER file_log_change
  BEFORE UPDATE ON file
  FOR EACH ROW
  EXECUTE FUNCTION log_change();


CREATE OR REPLACE FUNCTION guard_role_rel()
RETURNS trigger AS $$
BEGIN
  IF NEW.as_role_id IS NOT NULL THEN
    IF EXISTS (SELECT 1 FROM role WHERE id = NEW.as_role_id AND deleted_at IS NOT NULL) THEN
      RAISE EXCEPTION 'cannot assign a deleted role, got as_role_id=%', NEW.as_role_id;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM "user" WHERE id = NEW.on_user_id AND deleted_at IS NULL) THEN
      RAISE EXCEPTION 'a role can only be assigned to an active user, got on_user_id=%', NEW.on_user_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rel_guard_role
  BEFORE INSERT OR UPDATE ON rel
  FOR EACH ROW
  EXECUTE FUNCTION guard_role_rel();



CREATE OR REPLACE FUNCTION check_admin()
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1
    FROM rel r
    JOIN role ro ON ro.id = r.as_role_id
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
  IF NEW.as_role_id IS NOT NULL THEN
    IF EXISTS (
      SELECT 1
      FROM rel r
      JOIN role ro ON ro.id = r.as_role_id
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

CREATE TRIGGER rel_guard_role_assignment
  BEFORE INSERT OR UPDATE ON rel
  FOR EACH ROW
  EXECUTE FUNCTION guard_role_assignment();


CREATE OR REPLACE FUNCTION guard_hard_delete()
RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'hard deletes are not allowed, use soft delete instead';
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER rel_guard_hard_delete
  BEFORE DELETE ON rel
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
      FROM rel r
      JOIN role ro ON ro.id = r.as_role_id
      WHERE r.id = NEW.id
        AND ro.name = 'admin'
    ) THEN
      IF NOT check_admin() THEN
        RAISE EXCEPTION 'only admin can delete an admin role assignment';
      END IF;

      IF (
        SELECT count(*)
        FROM rel r
        JOIN role ro ON ro.id = r.as_role_id
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
        FROM rel r
        JOIN role ro ON ro.id = r.as_role_id
        WHERE r.on_user_id = NEW.id
          AND ro.name = 'admin'
          AND r.deleted_at IS NULL
      ) THEN
        IF (
          SELECT count(*)
          FROM rel r
          JOIN role ro ON ro.id = r.as_role_id
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

CREATE TRIGGER rel_guard_protected_delete
  BEFORE UPDATE ON rel
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