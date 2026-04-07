-- Notes (topics)
INSERT INTO note (title, body) VALUES
  ('DevOps',                       'DevOps'),
  ('comms',                        'comms'),
  ('Q2',                           'Q2'),
  ('facilities',                   'facilities'),
  ('Events',                       'Events'),
  ('Engineering',                  'Engineering'),
  ('hr',                           'hr'),
  ('Finance',                      'Finance'),
  ('marketing',                    'marketing'),
  ('Sales',                        'Sales'),
  ('Design',                       'Design'),
  ('security',                     'security'),
  ('Legal',                        'Legal'),
  ('data',                         'data'),
  ('Product',                      'Product'),
  ('release notes',                'release notes'),
  ('Happy Hour',                   'Happy Hour'),
  ('lunch pics',                   'lunch pics'),
  ('Must Love Dogs',               'Must Love Dogs'),
  ('cat ladys and gentlepeople',   'cat ladys and gentlepeople'),
  ('Book Club',                    'Book Club'),
  ('weekend warriors',             'weekend warriors'),
  ('Foodies',                      'Foodies'),
  ('Coffee & Chat',                'Coffee & Chat');


-- Tag all notes as :topic:
INSERT INTO relation (on_note_id, to_tag_id)
SELECT n.id, t.id
FROM note n, tag t
WHERE t.name = ':topic:';
