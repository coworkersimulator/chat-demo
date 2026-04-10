INSERT INTO "user" (id, username, name, created_by) VALUES
  ('00000000-0000-0000-0000-000000000000', 'root', null, '00000000-0000-0000-0000-000000000000');

INSERT INTO "user" (username, name, created_by)
SELECT v.username, v.name, '00000000-0000-0000-0000-000000000000'
FROM (VALUES
  ('amara.osei',        'Amara Osei'          ),
  ('fatima_z',          'Fatima Zahra'        ),
  ('yuki',              'Yuki'                ),
  ('priya.sharma',      'Priya Sharma'        ),
  ('cloudwatcher',      'Ingrid Solberg'      ),
  ('nadia.k',           'Nadia Kovács'        ),
  ('mei',               'Mei'                 ),
  ('layla_writes',      'Layla Al-Amin'       ),
  ('botanica',          'Esperanza Ruiz'      ),
  ('saoirse.m',         'Saoirse Ó Murchadha'),
  ('sloane.w',          'Sloane Whitfield'    ),
  ('bitsy',             'Bitsy Aldrich'       ),

  ('kwame',             'Kwame'               ),
  ('tariq.r',           'Tariq Rahman'        ),
  ('breadhead',         'Dmitri Volkov'       ),
  ('hiroshi.t',         'Hiroshi Tanaka'      ),
  ('emeka_dev',         'Emeka Okafor'        ),
  ('luca.b',            'Luca Bianchi'        ),
  ('stargazer77',       'Ravi Krishnamurthy'  ),
  ('anders.l',          'Anders Lindqvist'    ),
  ('joon',              'Joon-ho'             ),
  ('tomas.n',           'Tomáš Novák'         ),
  ('trip.hartwell',     'Trip Hartwell'       ),
  ('chazz',             'Chazz Pennington'    )
) AS v(username, name);
