CREATE OR REPLACE FUNCTION normalize_deleted_at()
RETURNS trigger AS $$
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    NEW.deleted_at := NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER _user_normalize_deleted_at
  BEFORE UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION normalize_deleted_at();

CREATE TRIGGER _role_normalize_deleted_at
  BEFORE UPDATE ON role
  FOR EACH ROW
  EXECUTE FUNCTION normalize_deleted_at();

CREATE TRIGGER _tag_normalize_deleted_at
  BEFORE UPDATE ON tag
  FOR EACH ROW
  EXECUTE FUNCTION normalize_deleted_at();

CREATE TRIGGER _reaction_normalize_deleted_at
  BEFORE UPDATE ON reaction
  FOR EACH ROW
  EXECUTE FUNCTION normalize_deleted_at();

CREATE TRIGGER _note_normalize_deleted_at
  BEFORE UPDATE ON note
  FOR EACH ROW
  EXECUTE FUNCTION normalize_deleted_at();

CREATE TRIGGER _file_normalize_deleted_at
  BEFORE UPDATE ON file
  FOR EACH ROW
  EXECUTE FUNCTION normalize_deleted_at();

CREATE TRIGGER _note_user_normalize_deleted_at
  BEFORE UPDATE ON note_user
  FOR EACH ROW
  EXECUTE FUNCTION normalize_deleted_at();

CREATE TRIGGER _note_reaction_normalize_deleted_at
  BEFORE UPDATE ON note_reaction
  FOR EACH ROW
  EXECUTE FUNCTION normalize_deleted_at();

CREATE TRIGGER _note_note_normalize_deleted_at
  BEFORE UPDATE ON note_note
  FOR EACH ROW
  EXECUTE FUNCTION normalize_deleted_at();

CREATE TRIGGER _note_tag_normalize_deleted_at
  BEFORE UPDATE ON note_tag
  FOR EACH ROW
  EXECUTE FUNCTION normalize_deleted_at();
