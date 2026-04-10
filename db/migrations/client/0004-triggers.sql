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

CREATE TRIGGER _note_user_bump_seq
  BEFORE UPDATE ON note_user
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();

CREATE TRIGGER _note_reaction_bump_seq
  BEFORE UPDATE ON note_reaction
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();

CREATE TRIGGER _note_note_bump_seq
  BEFORE UPDATE ON note_note
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();

CREATE TRIGGER _note_tag_bump_seq
  BEFORE UPDATE ON note_tag
  FOR EACH ROW
  EXECUTE FUNCTION bump_seq();



CREATE OR REPLACE FUNCTION guard_immutable_fields()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION '%.id cannot be modified', TG_TABLE_NAME;
  END IF;
  IF NEW.created_by IS DISTINCT FROM OLD.created_by THEN
    RAISE EXCEPTION '%.created_by cannot be modified', TG_TABLE_NAME;
  END IF;
  IF NEW.created_at IS DISTINCT FROM OLD.created_at THEN
    RAISE EXCEPTION '%.created_at cannot be modified', TG_TABLE_NAME;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_guard_immutable
  BEFORE UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION guard_immutable_fields();

CREATE TRIGGER role_guard_immutable
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION guard_immutable_fields();

CREATE TRIGGER tag_guard_immutable
  BEFORE UPDATE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION guard_immutable_fields();

CREATE TRIGGER reaction_guard_immutable
  BEFORE UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION guard_immutable_fields();

CREATE TRIGGER note_guard_immutable
  BEFORE UPDATE ON note
  FOR EACH ROW
  EXECUTE FUNCTION guard_immutable_fields();

CREATE TRIGGER file_guard_immutable
  BEFORE UPDATE ON file
  FOR EACH ROW
  EXECUTE FUNCTION guard_immutable_fields();

CREATE TRIGGER note_user_guard_immutable
  BEFORE UPDATE ON note_user
  FOR EACH ROW
  EXECUTE FUNCTION guard_immutable_fields();

CREATE TRIGGER note_reaction_guard_immutable
  BEFORE UPDATE ON note_reaction
  FOR EACH ROW
  EXECUTE FUNCTION guard_immutable_fields();

CREATE TRIGGER note_note_guard_immutable
  BEFORE UPDATE ON note_note
  FOR EACH ROW
  EXECUTE FUNCTION guard_immutable_fields();

CREATE TRIGGER note_tag_guard_immutable
  BEFORE UPDATE ON note_tag
  FOR EACH ROW
  EXECUTE FUNCTION guard_immutable_fields();



CREATE OR REPLACE FUNCTION guard_file_data_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.data IS DISTINCT FROM OLD.data THEN
    RAISE EXCEPTION 'file.data cannot be modified, delete and create a new file instead';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER file_guard_data_immutable
  BEFORE UPDATE ON file
  FOR EACH ROW
  EXECUTE FUNCTION guard_file_data_immutable();




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
      'created_by', current_setting('app.user_id', true),
      'created_at', now()
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER note_user_log_change
  BEFORE UPDATE ON note_user
  FOR EACH ROW
  EXECUTE FUNCTION log_change();

CREATE TRIGGER note_reaction_log_change
  BEFORE UPDATE ON note_reaction
  FOR EACH ROW
  EXECUTE FUNCTION log_change();

CREATE TRIGGER note_note_log_change
  BEFORE UPDATE ON note_note
  FOR EACH ROW
  EXECUTE FUNCTION log_change();

CREATE TRIGGER note_tag_log_change
  BEFORE UPDATE ON note_tag
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


CREATE OR REPLACE FUNCTION guard_hard_delete()
RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'hard deletes are not allowed, use soft delete instead';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION guard_note_user_fk_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.note_id IS DISTINCT FROM OLD.note_id THEN
    RAISE EXCEPTION 'note_user.note_id cannot be modified';
  END IF;
  IF NEW.user_id IS DISTINCT FROM OLD.user_id THEN
    RAISE EXCEPTION 'note_user.user_id cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER note_user_guard_fk_immutable
  BEFORE UPDATE ON note_user
  FOR EACH ROW
  EXECUTE FUNCTION guard_note_user_fk_immutable();

CREATE TRIGGER note_user_guard_hard_delete
  BEFORE DELETE ON note_user
  FOR EACH ROW
  EXECUTE FUNCTION guard_hard_delete();

CREATE OR REPLACE FUNCTION guard_note_reaction_fk_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.note_id IS DISTINCT FROM OLD.note_id THEN
    RAISE EXCEPTION 'note_reaction.note_id cannot be modified';
  END IF;
  IF NEW.reaction_id IS DISTINCT FROM OLD.reaction_id THEN
    RAISE EXCEPTION 'note_reaction.reaction_id cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER note_reaction_guard_fk_immutable
  BEFORE UPDATE ON note_reaction
  FOR EACH ROW
  EXECUTE FUNCTION guard_note_reaction_fk_immutable();

CREATE TRIGGER note_reaction_guard_hard_delete
  BEFORE DELETE ON note_reaction
  FOR EACH ROW
  EXECUTE FUNCTION guard_hard_delete();

CREATE OR REPLACE FUNCTION guard_note_note_fk_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.note_id IS DISTINCT FROM OLD.note_id THEN
    RAISE EXCEPTION 'note_note.note_id cannot be modified';
  END IF;
  IF NEW.parent_id IS DISTINCT FROM OLD.parent_id THEN
    RAISE EXCEPTION 'note_note.parent_id cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER note_note_guard_fk_immutable
  BEFORE UPDATE ON note_note
  FOR EACH ROW
  EXECUTE FUNCTION guard_note_note_fk_immutable();

CREATE TRIGGER note_note_guard_hard_delete
  BEFORE DELETE ON note_note
  FOR EACH ROW
  EXECUTE FUNCTION guard_hard_delete();

CREATE OR REPLACE FUNCTION guard_note_tag_fk_immutable()
RETURNS trigger AS $$
BEGIN
  IF NEW.note_id IS DISTINCT FROM OLD.note_id THEN
    RAISE EXCEPTION 'note_tag.note_id cannot be modified';
  END IF;
  IF NEW.tag_id IS DISTINCT FROM OLD.tag_id THEN
    RAISE EXCEPTION 'note_tag.tag_id cannot be modified';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER note_tag_guard_fk_immutable
  BEFORE UPDATE ON note_tag
  FOR EACH ROW
  EXECUTE FUNCTION guard_note_tag_fk_immutable();

CREATE TRIGGER note_tag_guard_hard_delete
  BEFORE DELETE ON note_tag
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
