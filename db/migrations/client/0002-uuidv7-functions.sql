CREATE OR REPLACE FUNCTION uuidv7_now(ts timestamptz DEFAULT now()) RETURNS uuid AS $$
  SELECT encode(
    substring(int8send((extract(epoch FROM ts) * 1000)::bigint)
      FROM 3 FOR 6)
    || set_byte(
      set_byte(r, 0, (get_byte(r, 0) & 15) | 112),
      2,
      (get_byte(r, 2) & 63) | 128
    ),
    'hex')::uuid
  FROM gen_random_bytes(10) AS r
$$ LANGUAGE sql VOLATILE PARALLEL SAFE COST 10;


CREATE OR REPLACE FUNCTION uuidv7_wall() RETURNS uuid AS $$
  SELECT uuidv7_now(clock_timestamp())
$$ LANGUAGE sql VOLATILE PARALLEL SAFE COST 15;


CREATE OR REPLACE FUNCTION uuidv7_floor(u uuid)
RETURNS uuid AS $$
  SELECT encode(
    substring(uuid_send(u) FROM 1 FOR 6)
    || '\x7000800000000000000000'::bytea,
    'hex'
  )::uuid
$$ LANGUAGE sql IMMUTABLE PARALLEL SAFE COST 5;
