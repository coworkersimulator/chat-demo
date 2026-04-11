CREATE OR REPLACE FUNCTION guard_insert_ownership()
RETURNS trigger AS $$
DECLARE
  actor text := current_setting('app.user_id', true);
BEGIN
  IF actor IS NULL OR actor = '' OR actor != NEW.created_by::text THEN
    RAISE EXCEPTION 'created_by must match app.user_id (table: %, app.user_id: %, created_by: %)',
      TG_TABLE_NAME, actor, NEW.created_by;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_guard_insert_ownership
  BEFORE INSERT ON "user"
  FOR EACH ROW EXECUTE FUNCTION guard_insert_ownership();

CREATE TRIGGER role_guard_insert_ownership
  BEFORE INSERT ON role
  FOR EACH ROW EXECUTE FUNCTION guard_insert_ownership();

CREATE TRIGGER tag_guard_insert_ownership
  BEFORE INSERT ON tag
  FOR EACH ROW EXECUTE FUNCTION guard_insert_ownership();

CREATE TRIGGER reaction_guard_insert_ownership
  BEFORE INSERT ON reaction
  FOR EACH ROW EXECUTE FUNCTION guard_insert_ownership();

CREATE TRIGGER note_guard_insert_ownership
  BEFORE INSERT ON note
  FOR EACH ROW EXECUTE FUNCTION guard_insert_ownership();

CREATE TRIGGER file_guard_insert_ownership
  BEFORE INSERT ON file
  FOR EACH ROW EXECUTE FUNCTION guard_insert_ownership();

CREATE TRIGGER note_tag_guard_insert_ownership
  BEFORE INSERT ON note_tag
  FOR EACH ROW EXECUTE FUNCTION guard_insert_ownership();

CREATE TRIGGER note_user_guard_insert_ownership
  BEFORE INSERT ON note_user
  FOR EACH ROW EXECUTE FUNCTION guard_insert_ownership();

CREATE TRIGGER note_reaction_guard_insert_ownership
  BEFORE INSERT ON note_reaction
  FOR EACH ROW EXECUTE FUNCTION guard_insert_ownership();

CREATE TRIGGER note_note_guard_insert_ownership
  BEFORE INSERT ON note_note
  FOR EACH ROW EXECUTE FUNCTION guard_insert_ownership();


CREATE OR REPLACE FUNCTION guard_update_ownership()
RETURNS trigger AS $$
DECLARE
  actor text := current_setting('app.user_id', true);
BEGIN
  IF actor IS NULL OR actor = '' OR actor != OLD.created_by::text THEN
    RAISE EXCEPTION 'only the record creator can update (table: %, created_by: %)',
      TG_TABLE_NAME, OLD.created_by;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_guard_update_ownership
  BEFORE UPDATE ON "user"
  FOR EACH ROW EXECUTE FUNCTION guard_update_ownership();

CREATE TRIGGER role_guard_update_ownership
  BEFORE UPDATE ON role
  FOR EACH ROW EXECUTE FUNCTION guard_update_ownership();

CREATE TRIGGER tag_guard_update_ownership
  BEFORE UPDATE ON tag
  FOR EACH ROW EXECUTE FUNCTION guard_update_ownership();

CREATE TRIGGER reaction_guard_update_ownership
  BEFORE UPDATE ON reaction
  FOR EACH ROW EXECUTE FUNCTION guard_update_ownership();

CREATE TRIGGER note_guard_update_ownership
  BEFORE UPDATE ON note
  FOR EACH ROW EXECUTE FUNCTION guard_update_ownership();

CREATE TRIGGER file_guard_update_ownership
  BEFORE UPDATE ON file
  FOR EACH ROW EXECUTE FUNCTION guard_update_ownership();

CREATE TRIGGER note_tag_guard_update_ownership
  BEFORE UPDATE ON note_tag
  FOR EACH ROW EXECUTE FUNCTION guard_update_ownership();

CREATE TRIGGER note_user_guard_update_ownership
  BEFORE UPDATE ON note_user
  FOR EACH ROW EXECUTE FUNCTION guard_update_ownership();

CREATE TRIGGER note_reaction_guard_update_ownership
  BEFORE UPDATE ON note_reaction
  FOR EACH ROW EXECUTE FUNCTION guard_update_ownership();

CREATE TRIGGER note_note_guard_update_ownership
  BEFORE UPDATE ON note_note
  FOR EACH ROW EXECUTE FUNCTION guard_update_ownership();
