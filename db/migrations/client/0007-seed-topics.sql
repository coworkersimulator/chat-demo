INSERT INTO migration (version) VALUES ('0007');

INSERT INTO tag (name) VALUES (':topic:'), (':dm:');


DO $$
DECLARE
  tag_topic uuid;
  title     text;
  n         uuid;
BEGIN
  SELECT id INTO tag_topic FROM tag WHERE name = ':topic:';

  FOREACH title IN ARRAY ARRAY[
    'DevOps', 'comms', 'Q2', 'facilities', 'Events', 'Engineering',
    'hr', 'Finance', 'marketing', 'Sales', 'Design', 'security',
    'Legal', 'data', 'Product', 'release notes', 'Happy Hour',
    'lunch pics', 'Must Love Dogs', 'cat ladies and gentlepeople',
    'Book Club', 'weekend warriors', 'Foodies', 'Coffee & Chat'
  ] LOOP
    INSERT INTO note (title) VALUES (title) RETURNING id INTO n;
    INSERT INTO rel (on_note_id, as_tag_id) VALUES (n, tag_topic);
  END LOOP;
END $$;


DO $$
DECLARE
  u_amara     uuid;
  u_fatima    uuid;
  u_yuki      uuid;
  u_priya     uuid;
  u_ingrid    uuid;
  u_nadia     uuid;
  u_mei       uuid;
  u_layla     uuid;
  u_esperanza uuid;
  u_saoirse   uuid;
  u_sloane    uuid;
  u_bitsy     uuid;
  u_kwame     uuid;
  u_tariq     uuid;
  u_dmitri    uuid;
  u_hiroshi   uuid;
  u_emeka     uuid;
  u_luca      uuid;
  u_ravi      uuid;
  u_anders    uuid;
  u_joon      uuid;
  u_tomas     uuid;
  u_trip      uuid;
  u_chazz     uuid;

  t_devops    uuid;
  t_comms     uuid;
  t_q2        uuid;
  t_facilities uuid;
  t_events    uuid;
  t_eng       uuid;
  t_hr        uuid;
  t_finance   uuid;
  t_marketing uuid;
  t_sales     uuid;
  t_design    uuid;
  t_security  uuid;
  t_legal     uuid;
  t_data      uuid;
  t_product   uuid;
  t_releases  uuid;
  t_happyhour uuid;
  t_lunch     uuid;
  t_dogs      uuid;
  t_cats      uuid;
  t_books     uuid;
  t_weekend   uuid;
  t_foodies   uuid;
  t_coffee    uuid;

  m  uuid;
  ts timestamptz;

BEGIN
  SELECT id INTO u_amara     FROM "user" WHERE username = 'amara.osei';
  SELECT id INTO u_fatima    FROM "user" WHERE username = 'fatima_z';
  SELECT id INTO u_yuki      FROM "user" WHERE username = 'yuki';
  SELECT id INTO u_priya     FROM "user" WHERE username = 'priya.sharma';
  SELECT id INTO u_ingrid    FROM "user" WHERE username = 'cloudwatcher';
  SELECT id INTO u_nadia     FROM "user" WHERE username = 'nadia.k';
  SELECT id INTO u_mei       FROM "user" WHERE username = 'mei';
  SELECT id INTO u_layla     FROM "user" WHERE username = 'layla_writes';
  SELECT id INTO u_esperanza FROM "user" WHERE username = 'botanica';
  SELECT id INTO u_saoirse   FROM "user" WHERE username = 'saoirse.m';
  SELECT id INTO u_sloane    FROM "user" WHERE username = 'sloane.w';
  SELECT id INTO u_bitsy     FROM "user" WHERE username = 'bitsy';
  SELECT id INTO u_kwame     FROM "user" WHERE username = 'kwame';
  SELECT id INTO u_tariq     FROM "user" WHERE username = 'tariq.r';
  SELECT id INTO u_dmitri    FROM "user" WHERE username = 'breadhead';
  SELECT id INTO u_hiroshi   FROM "user" WHERE username = 'hiroshi.t';
  SELECT id INTO u_emeka     FROM "user" WHERE username = 'emeka_dev';
  SELECT id INTO u_luca      FROM "user" WHERE username = 'luca.b';
  SELECT id INTO u_ravi      FROM "user" WHERE username = 'stargazer77';
  SELECT id INTO u_anders    FROM "user" WHERE username = 'anders.l';
  SELECT id INTO u_joon      FROM "user" WHERE username = 'joon';
  SELECT id INTO u_tomas     FROM "user" WHERE username = 'tomas.n';
  SELECT id INTO u_trip      FROM "user" WHERE username = 'trip.hartwell';
  SELECT id INTO u_chazz     FROM "user" WHERE username = 'chazz';

  SELECT id INTO t_devops    FROM note WHERE title = 'DevOps';
  SELECT id INTO t_comms     FROM note WHERE title = 'comms';
  SELECT id INTO t_q2        FROM note WHERE title = 'Q2';
  SELECT id INTO t_facilities FROM note WHERE title = 'facilities';
  SELECT id INTO t_events    FROM note WHERE title = 'Events';
  SELECT id INTO t_eng       FROM note WHERE title = 'Engineering';
  SELECT id INTO t_hr        FROM note WHERE title = 'hr';
  SELECT id INTO t_finance   FROM note WHERE title = 'Finance';
  SELECT id INTO t_marketing FROM note WHERE title = 'marketing';
  SELECT id INTO t_sales     FROM note WHERE title = 'Sales';
  SELECT id INTO t_design    FROM note WHERE title = 'Design';
  SELECT id INTO t_security  FROM note WHERE title = 'security';
  SELECT id INTO t_legal     FROM note WHERE title = 'Legal';
  SELECT id INTO t_data      FROM note WHERE title = 'data';
  SELECT id INTO t_product   FROM note WHERE title = 'Product';
  SELECT id INTO t_releases  FROM note WHERE title = 'release notes';
  SELECT id INTO t_happyhour FROM note WHERE title = 'Happy Hour';
  SELECT id INTO t_lunch     FROM note WHERE title = 'lunch pics';
  SELECT id INTO t_dogs      FROM note WHERE title = 'Must Love Dogs';
  SELECT id INTO t_cats      FROM note WHERE title = 'cat ladies and gentlepeople';
  SELECT id INTO t_books     FROM note WHERE title = 'Book Club';
  SELECT id INTO t_weekend   FROM note WHERE title = 'weekend warriors';
  SELECT id INTO t_foodies   FROM note WHERE title = 'Foodies';
  SELECT id INTO t_coffee    FROM note WHERE title = 'Coffee & Chat';


  -- ============================================================
  -- DevOps, Mon Feb 23 2026, 09:15
  -- ============================================================
  ts := '2026-02-23 09:15:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Pushed new pipeline config, should cut build times ~40%. Please test and report back', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('nice diff. Clever layer caching. Did you consider parallelising the unit tests too?', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes, parallel tests are next. Wanted to land the caching first and measure', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '4 hours 22 minutes';
  INSERT INTO note (body, by, at) VALUES ('staging deploy failed this morning. Looks like the healthcheck timeout is too short for cold starts', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('Bumped it to 30s in the helm values. Pushing now', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '24 minutes';
  INSERT INTO note (body, by, at) VALUES ('Should we add a readiness probe separate from liveness? cold starts are always going to be slow', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes. Ill open a ticket. Been meaning to do that', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := '2026-02-24 02:07:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('prod alert at 2am, memory spike on the worker nodes. Turned out to be the new log aggregator, was buffering everything in memory', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := '2026-02-24 08:55:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('oof. Are you ok? 2am is brutal', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('On-call life. Coffee is my religion now', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('We should set a memory limit on that container. It shouldnt be able to take down a node', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '21 minutes';
  INSERT INTO note (body, by, at) VALUES ('agreed. Also worth looking at whether we need that aggregator at all, our current setup might handle it', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '2 hours 40 minutes';
  INSERT INTO note (body, by, at) VALUES ('K8s dashboard is back up btw. The cert was expired, renewed and deployed', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('Can we set up cert-manager so this stops happening manually', u_ravi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '33 minutes';
  INSERT INTO note (body, by, at) VALUES ('Already on my list. Will pair with someone this week to get it done properly', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := '2026-02-25 10:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('rollback plan for friday''s release, anyone against doing a feature flag approach instead of a full rollback?', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('Feature flags sound good to me. Less blast radius', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '28 minutes';
  INSERT INTO note (body, by, at) VALUES ('We need to document the flag naming convention before we add more. Its getting messy', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '19 minutes';
  INSERT INTO note (body, by, at) VALUES ('On it. Will have a draft in the wiki by EOD', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := '2026-02-27 16:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('build times down to 4min from 7min. The caching is working 🎉', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '5 minutes';
  INSERT INTO note (body, by, at) VALUES ('Now lets get it under 3', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '3 minutes';
  INSERT INTO note (body, by, at) VALUES ('lol never satisfied', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);
  ts := ts + interval '2 minutes';
  INSERT INTO note (body, by, at) VALUES ('Thats the job', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_devops);


  -- ============================================================
  -- comms, Tue Feb 24 2026, 10:30
  -- ============================================================
  ts := '2026-02-24 10:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('draft of the all-hands email is in the shared doc. Would love eyes before i send, especially the tone of the reorg section', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Read it. The reorg section is fine but the opening feels a bit formal. We usually lead with something warmer', u_sloane, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '15 minutes';
  INSERT INTO note (body, by, at) VALUES ('Agree, maybe start with the win from last quarter before getting into structure changes?', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('Good call. Updating now', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '1 hour 45 minutes';
  INSERT INTO note (body, by, at) VALUES ('can someone update the org chart? its still showing the old reporting lines', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('On it, should be done by tomorrow morning', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := '2026-02-25 09:05:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Internal newsletter going out friday. If your team has something to share, get it to me by thursday noon', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '35 minutes';
  INSERT INTO note (body, by, at) VALUES ('Engineering has a section, will send it over today', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('same from design', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := '2026-02-26 14:20:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Should we move the newsletter to biweekly? weekly feels like a lot to produce consistently', u_sloane, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '27 minutes';
  INSERT INTO note (body, by, at) VALUES ('Im open to it. Readership has been good but production is heavy', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('Biweekly +1 from me. Gives more time to actually write good content', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('lets try it for a month and see', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := '2026-03-02 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Quick reminder: the CEO prefers plain language and short paragraphs. If your section is longer than 3 sentences, trim it', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('noted. I always over-write', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('same. Three sentences is harder than three paragraphs', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_comms);


  -- ============================================================
  -- Q2, Wed Feb 25 2026, 14:00
  -- ============================================================
  ts := '2026-02-25 14:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Q2 OKRs are locked. Sharing the deck now, please review before thursday''s sync', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '42 minutes';
  INSERT INTO note (body, by, at) VALUES ('The revenue target feels aggressive given current pipeline. Are we accounting for the two large deals slipping?', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes, those slips are baked in. The number reflects confirmed pipeline only', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('Good. Last quarter we had surprises from untracked deals and it made forecasting a mess', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '1 hour 5 minutes';
  INSERT INTO note (body, by, at) VALUES ('the product KR around DAU, is that 15% growth over Q1 actuals or Q1 target?', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Actuals. We hit 92% of Q1 target so it matters', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('noted. Updating our team planning doc', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := '2026-02-26 10:15:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Budget approval came through for the infrastructure upgrade. Can engineering confirm timeline?', u_sloane, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '31 minutes';
  INSERT INTO note (body, by, at) VALUES ('6-8 weeks from kickoff. We need two weeks of prep before we touch anything in prod', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('so end of Q2 at the earliest. Does that work for the board deck?', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('Tight but workable. Ill frame it as Q2 kickoff, Q3 completion', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := '2026-03-16 09:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Midpoint check-in for Q2 OKRs is in 3 weeks. Everyone should have a status update ready', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '19 minutes';
  INSERT INTO note (body, by, at) VALUES ('can we do it async this time? the sync last quarter ran 90 minutes', u_chazz, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes, post your update here by friday, ill compile and flag anything that needs a live discussion', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('Much better. Thanks', u_chazz, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := '2026-03-30 14:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Q2 is looking strong. Sales is at 73% of target with 6 weeks left', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '16 minutes';
  INSERT INTO note (body, by, at) VALUES ('great position. What does the close rate look like on remaining pipeline?', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('Roughly 40% weighted. Two enterprise deals are the swing factor', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_q2);


  -- ============================================================
  -- facilities, Mon Mar 2 2026, 09:00
  -- ============================================================
  ts := '2026-03-02 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('The AC on floor 3 is down again. Facilities ticket submitted but has anyone heard an ETA?', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := ts + interval '28 minutes';
  INSERT INTO note (body, by, at) VALUES ('They told me friday. Its going to be a warm week', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := ts + interval '16 minutes';
  INSERT INTO note (body, by, at) VALUES ('floor 2 has space if people want to migrate for the week', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := ts + interval '2 hours 10 minutes';
  INSERT INTO note (body, by, at) VALUES ('The kitchen fridge on 3 also needs cleaning. Leaving a friendly note on it today', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('There is definitely something from before 2024 in the back corner. Not naming names', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := '2026-03-03 11:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Standing desk request for the east wing, can we get 3 more? the waitlist is 6 people', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := ts + interval '35 minutes';
  INSERT INTO note (body, by, at) VALUES ('submitted to procurement. Usually takes 2-3 weeks', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := '2026-03-09 08:50:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Parking situation this week: there is a delivery truck taking spots 12-15 mon-wed', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('thanks for the heads up. Ill bike in', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := '2026-03-10 14:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('The projector in conf room B keeps dropping signal mid-presentation. HDMI issue i think', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := ts + interval '19 minutes';
  INSERT INTO note (body, by, at) VALUES ('IT has a spare HDMI cable, grab it from the cabinet by the printer. Longer term we need to replace that projector', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := ts + interval '41 minutes';
  INSERT INTO note (body, by, at) VALUES ('Added to next budget cycle. That room needs a proper AV refresh', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := '2026-03-16 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('The cleaning crew comes mon/wed/fri now instead of daily. Just so people know', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);
  ts := ts + interval '27 minutes';
  INSERT INTO note (body, by, at) VALUES ('Explains a lot about tuesday mornings', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_facilities);


  -- ============================================================
  -- Events, Tue Mar 3 2026, 11:00
  -- ============================================================
  ts := '2026-03-03 11:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('company anniversary is in 6 weeks, starting to plan. Any ideas for the format this year?', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '31 minutes';
  INSERT INTO note (body, by, at) VALUES ('Last year''s trivia night was a hit. Maybe something more physical this year? scavenger hunt?', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes but please make it accessible, not everyone can run around', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('Good point. Mixed format, some physical, some puzzle-based so teams can split', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '44 minutes';
  INSERT INTO note (body, by, at) VALUES ('can we do a cook-off? everyone brings a dish from their culture', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('I would cook for that. Would be chaos but beautiful chaos', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('Combine both, morning cook-off, afternoon scavenger hunt', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('Logistics nightmare but i love it. Lets scope it', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := '2026-03-10 09:15:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('reminder: summer offsite signup closes friday. 40 spots, 38 claimed', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '23 minutes';
  INSERT INTO note (body, by, at) VALUES ('Signed up. Do we know the agenda yet?', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '17 minutes';
  INSERT INTO note (body, by, at) VALUES ('Rough schedule: day 1 strategy, day 2 workshops + social, day 3 free time. Will share the full deck next week', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('Is the venue dog-friendly? asking for obvious reasons', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '26 minutes';
  INSERT INTO note (body, by, at) VALUES ('I actually asked. Not for this one, sorry', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('noted for next year''s venue selection criteria', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_events);


  -- ============================================================
  -- Engineering, Wed Mar 4 2026, 09:30
  -- ============================================================
  ts := '2026-03-04 09:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('RFC: moving auth to a dedicated service. Draft is up for review. Would love feedback before friday', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '1 hour 12 minutes';
  INSERT INTO note (body, by, at) VALUES ('Read it. The token refresh strategy needs more thought, what happens during the service restart window?', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '28 minutes';
  INSERT INTO note (body, by, at) VALUES ('good catch. Short-lived tokens with a grace period. Ill add a section', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '45 minutes';
  INSERT INTO note (body, by, at) VALUES ('The RFC is solid overall. Bigger question is migration path, do we cut over all clients at once?', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('Definitely not. Phased, internal tools first, then external clients', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := '2026-03-09 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Tech debt sprint is next week. Adding the legacy payment wrapper to the list, its been on borrowed time', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('finally. I have nightmares about that code', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('Who wrote it originally?', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '3 minutes';
  INSERT INTO note (body, by, at) VALUES ('Git blame says... Me. 2019. I was young', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('lol. We''ve all been there', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := '2026-03-10 10:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('test coverage target for Q2: 80% on new code, best effort on legacy. Please track in the coverage report', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '38 minutes';
  INSERT INTO note (body, by, at) VALUES ('80% is achievable. The integration tests are the harder part, unit coverage alone isnt telling the whole story', u_ravi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('agreed. Mutation testing might be worth exploring, gives a much better signal than line coverage', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('Lets not boil the ocean. 80% first, then we can get fancy', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := '2026-03-11 08:55:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('engineering standup moved to 9:30 starting monday, had a conflict with the design sync', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('Works for me', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('👍', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '19 minutes';
  INSERT INTO note (body, by, at) VALUES ('Can we keep it to 15min? last week ran 40', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('blockers only in standup, all other discussion goes async or in a follow-up. Ill enforce it', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_eng);


  -- ============================================================
  -- hr, Mon Mar 9 2026, 10:00
  -- ============================================================
  ts := '2026-03-09 10:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('PTO policy reminder: Q2 is historically the worst for taking time off. Please use it, it doesnt roll over', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('noted. Putting a week on the calendar now before it fills up', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := ts + interval '2 hours 20 minutes';
  INSERT INTO note (body, by, at) VALUES ('Onboarding checklist has been updated, the old one had broken links and outdated tooling', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := ts + interval '17 minutes';
  INSERT INTO note (body, by, at) VALUES ('thank you! new starters kept coming to me confused about the laptop setup section', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := '2026-03-10 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Benefits renewal window opens next monday. Please review your elections, dental and vision plan options have changed', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := ts + interval '28 minutes';
  INSERT INTO note (body, by, at) VALUES ('Is the FSA contribution limit the same as last year?', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := ts + interval '16 minutes';
  INSERT INTO note (body, by, at) VALUES ('Slightly higher, $3,200 this year. Details in the benefits guide which ill share monday', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := '2026-03-16 08:50:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('three new starters joining next week: please be welcoming and check in on them. Its a lot to absorb in week one', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Our team will host a welcome lunch on thursday. All invited', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := '2026-03-25 10:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Performance review season starts in 6 weeks. Self-review forms will be sent out then', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := ts + interval '33 minutes';
  INSERT INTO note (body, by, at) VALUES ('Any changes to the process this year?', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes, peer feedback is now optional rather than mandatory. Managers discretion', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('Interesting change. Peer feedback was often the most useful part for me', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('Managers can still request it, it just isnt required from everyone by default. Reduces noise', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_hr);


  -- ============================================================
  -- Finance, Tue Mar 10 2026, 14:30
  -- ============================================================
  ts := '2026-03-10 14:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Expense reports for march are due friday. Please submit in Expensify, the old form is no longer accepted', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);
  ts := ts + interval '27 minutes';
  INSERT INTO note (body, by, at) VALUES ('the conference reimbursement, does the $500 cap include transport or just the ticket?', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('Ticket only. Transport is separate under T&E', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);
  ts := '2026-03-11 09:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Budget variance report for Q1 is out. We came in 4% under on opex, 2% over on infrastructure', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);
  ts := ts + interval '19 minutes';
  INSERT INTO note (body, by, at) VALUES ('The infra overage, is that the logging service we talked about?', u_sloane, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('partly. Also AWS costs crept up in february during the traffic spike', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Are we using reserved instances or just on-demand?', u_chazz, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);
  ts := ts + interval '31 minutes';
  INSERT INTO note (body, by, at) VALUES ('Mix of both. Engineering is reviewing the on-demand usage to identify candidates for reservation', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);
  ts := '2026-03-16 10:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('International wire transfers now need two approvers over $10k. Updated in the finance policy doc', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);
  ts := ts + interval '24 minutes';
  INSERT INTO note (body, by, at) VALUES ('noted. Is the second approver always finance or can it be a department head?', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('Department head is fine as the second. Finance still needs to initiate', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);
  ts := '2026-03-30 09:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Q2 budget allocations are finalized. Please dont exceed your headcount without a pre-approval', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_finance);


  -- ============================================================
  -- marketing, Wed Mar 11 2026, 09:00
  -- ============================================================
  ts := '2026-03-11 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Spring campaign brief is ready. Theme: "built for scale", targeting mid-market engineering teams', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := ts + interval '38 minutes';
  INSERT INTO note (body, by, at) VALUES ('love the theme. The case studies will be key, do we have any mid-market customers willing to participate?', u_sloane, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Two confirmed so far. Working on a third, a fintech in amsterdam', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := ts + interval '1 hour 15 minutes';
  INSERT INTO note (body, by, at) VALUES ('The linkedin content calendar for Q2 is up. Please flag if your team has something worth sharing', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := ts + interval '44 minutes';
  INSERT INTO note (body, by, at) VALUES ('Engineering just shipped something interesting, ill get you a blurb by tomorrow', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('perfect. Linkedin posts with a real engineer voice tend to outperform the polished ones', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := '2026-03-16 11:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('SEO audit results are back. Our blog is in good shape but product pages are thin on content', u_esperanza, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := ts + interval '26 minutes';
  INSERT INTO note (body, by, at) VALUES ('We rewrote those pages twice last year. What specifically is missing?', u_sloane, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := ts + interval '17 minutes';
  INSERT INTO note (body, by, at) VALUES ('Keyword density and internal linking mostly. Structure is fine, just needs more depth', u_esperanza, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('can you share the audit? id like to see which pages are flagged', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Shared. Top priority pages are highlighted in yellow', u_esperanza, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := '2026-03-24 10:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Webinar next thursday, 120 signups so far. Promotion has been strong', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('Great number. Do we have a follow-up sequence ready for attendees?', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes, 3 email sequence, first one goes out within an hour of the webinar ending', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_marketing);


  -- ============================================================
  -- Sales, Mon Mar 16 2026, 10:00
  -- ============================================================
  ts := '2026-03-16 10:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Closed the Meridian deal. $180k ARR. Took 4 months but we got there', u_chazz, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes!! huge win. What finally moved them?', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('The security audit report. Once their CISO saw it they moved fast', u_chazz, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('noted, security docs are a sales tool now. Worth making them more accessible', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);
  ts := '2026-03-17 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Demo environment was down yesterday during a prospect call. Please flag outages so we can reschedule', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Sorry, we pushed a migration and didnt flag it to sales. Wont happen again', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('Can we get a #demo-status channel so we always know the state?', u_chazz, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('good idea. Ill set it up', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);
  ts := '2026-03-23 09:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Pipeline review friday at 10. Please update your deals in CRM before then', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);
  ts := ts + interval '41 minutes';
  INSERT INTO note (body, by, at) VALUES ('Updated. Flagging the Vantara deal as at-risk, they went quiet after the last call', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('Lets do a joint call with their technical stakeholder. Sometimes that unsticks things', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('worth a try. Ill reach out to set it up', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_sales);


  -- ============================================================
  -- Design, Tue Mar 17 2026, 09:15
  -- ============================================================
  ts := '2026-03-17 09:15:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('New design system components are in Figma. Please use them for anything going into the next sprint', u_yuki, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := ts + interval '33 minutes';
  INSERT INTO note (body, by, at) VALUES ('The button variants look great. One thing, the disabled state could use more contrast', u_mei, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('Good catch. Accessibility pass coming this week', u_yuki, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := ts + interval '2 hours 10 minutes';
  INSERT INTO note (body, by, at) VALUES ('the mobile nav redesign is ready for review. Biggest change: bottom nav instead of hamburger', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := ts + interval '27 minutes';
  INSERT INTO note (body, by, at) VALUES ('Bottom nav is so much better. Does it work with 5 items?', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes, up to 5. Beyond that we collapse into a "more" menu', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := '2026-03-18 10:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Color palette vote, we''re considering dropping the teal accent. Opinions?', u_yuki, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('keep the teal. Its distinctive and users associate it with us', u_esperanza, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('agreed. Maybe tone it down but dont remove it entirely', u_mei, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('Teal stays, slightly muted. Noted', u_yuki, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := '2026-03-23 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Usability session next tuesday, 6 participants. Observers welcome, just be a fly on the wall', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('ill sit in. Always humbling to watch someone use something you designed', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('That is the best way to get better. Bring tissues', u_mei, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := '2026-03-30 11:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('The icon set export from Figma is broken, if you pull icons today they come out the wrong size', u_yuki, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('Use the zip in the shared drive until its fixed', u_yuki, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_design);


  -- ============================================================
  -- security, Wed Mar 18 2026, 11:00
  -- ============================================================
  ts := '2026-03-18 11:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('phishing simulation went out yesterday. 8% click rate, down from 14% last quarter. Progress', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('Who clicked the most? asking for a friend', u_chazz, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('Department breakdown stays internal but training is being assigned to those who clicked', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := ts + interval '2 hours 40 minutes';
  INSERT INTO note (body, by, at) VALUES ('CVE-2024-3400, palo alto vuln. Checking if we''re exposed. Update by EOD', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := ts + interval '34 minutes';
  INSERT INTO note (body, by, at) VALUES ('checked, we dont use PAN-OS in our stack. Not affected', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('Confirmed not affected. Closing the ticket', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := '2026-03-23 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('SOC 2 audit prep starts next month. If your team owns any controls, expect requests from me', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := ts + interval '28 minutes';
  INSERT INTO note (body, by, at) VALUES ('What docs do you typically need from engineering?', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := ts + interval '19 minutes';
  INSERT INTO note (body, by, at) VALUES ('access reviews, change management logs, incident response runbooks, backup verification. Ill send a full list', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := '2026-03-30 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('MFA is now required for all admin access as of monday. No exceptions', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := ts + interval '16 minutes';
  INSERT INTO note (body, by, at) VALUES ('What authenticator app are we standardising on?', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('Okta Verify or hardware key. Google Authenticator acceptable but not preferred', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);
  ts := ts + interval '2 hours 15 minutes';
  INSERT INTO note (body, by, at) VALUES ('reminder: do not share credentials via chat. Even internally. Even for "just a minute"', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_security);


  -- ============================================================
  -- Legal, Mon Mar 23 2026, 14:00
  -- ============================================================
  ts := '2026-03-23 14:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Updated vendor NDA template is in the legal folder. Please use the new version, the old one had a clause that didnt hold up', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_legal);
  ts := ts + interval '24 minutes';
  INSERT INTO note (body, by, at) VALUES ('What was the issue with the old clause?', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_legal);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('The jurisdiction language was ambiguous for UK entities. New version is explicit', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_legal);
  ts := '2026-03-24 09:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('data processing agreement for the EU expansion, external counsel has reviewed, one comment to resolve', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_legal);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('What''s the comment?', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_legal);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('Data retention periods need to align with our privacy policy. Currently they dont match on the 90-day clause', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_legal);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Privacy policy or DPA needs updating, easier to update the DPA to match the existing policy', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_legal);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('agreed. Will update the DPA and send back to counsel', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_legal);
  ts := '2026-03-30 10:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('IP assignment for contractors, please make sure any new SOW includes the standard IP clause. Had a gap last quarter', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_legal);
  ts := ts + interval '28 minutes';
  INSERT INTO note (body, by, at) VALUES ('Is the clause in the SOW template now?', u_chazz, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_legal);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes, added last week. If youre using an older template please replace it', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_legal);


  -- ============================================================
  -- data, Tue Mar 24 2026, 09:00
  -- ============================================================
  ts := '2026-03-24 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('the analytics pipeline is now real-time. Events are landing in the warehouse within 30 seconds', u_ravi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := ts + interval '19 minutes';
  INSERT INTO note (body, by, at) VALUES ('That is going to change a lot of how we make decisions. Nice work', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := ts + interval '1 hour 22 minutes';
  INSERT INTO note (body, by, at) VALUES ('The dashboard for Q2 metrics is live, daily active users, retention, feature adoption', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := ts + interval '44 minutes';
  INSERT INTO note (body, by, at) VALUES ('The feature adoption numbers look off, the new export feature launched 3 weeks ago and its showing 0.2%', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('checking, might be a tracking event missing. Ill look at the implementation', u_ravi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := ts + interval '1 hour 8 minutes';
  INSERT INTO note (body, by, at) VALUES ('Found it, the event fires but the property name doesnt match the dashboard filter. Fixing now', u_ravi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := '2026-03-25 09:15:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Data quality issue: the user signup events from last tuesday are duplicated. Looking into root cause', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := ts + interval '27 minutes';
  INSERT INTO note (body, by, at) VALUES ('Was there a deploy around that time? sometimes retries during a deployment cause duplication', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes, there was a restart at 14:22. That''s the window. Deduplication query is running', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := ts + interval '33 minutes';
  INSERT INTO note (body, by, at) VALUES ('We should add idempotency keys to events to prevent this class of issue', u_ravi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('agreed. Will write up the spec', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := '2026-04-01 11:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('New cohort analysis shows 30-day retention improved 3 points since the onboarding redesign. Statistically significant', u_ravi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('huge. That''s what we were hoping to see. Design team will be pleased', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('Sharing the full cohort breakdown so design can see which steps drove the improvement', u_ravi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_data);


  -- ============================================================
  -- Product, Wed Mar 25 2026, 10:30
  -- ============================================================
  ts := '2026-03-25 10:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Q3 roadmap draft is up. Biggest bets: collaboration features, API v2, mobile. Feedback welcome', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '48 minutes';
  INSERT INTO note (body, by, at) VALUES ('Mobile should be higher priority, we''re losing deals to competitors who have it', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('heard the same from a few accounts last month', u_chazz, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '17 minutes';
  INSERT INTO note (body, by, at) VALUES ('Mobile is scoped but its a 6 month project minimum. Bumping it means pushing collaboration, which is also losing us deals', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '31 minutes';
  INSERT INTO note (body, by, at) VALUES ('What if we do a minimal mobile view first, just the most-used features, not full parity?', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('That''s worth exploring. Could we scope it to 6 weeks for a first cut?', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('depends on which features. Lets do a scope session this week', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := '2026-03-26 14:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('User research findings from last month are now in the product wiki. Key insight: users want bulk actions everywhere', u_ravi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Bulk actions, we hear this constantly in support too. Should be higher in the backlog', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('Moving it up. Design can we get a concept by end of next week?', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes, i have some early sketches already. Will clean them up', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := '2026-04-01 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Feature flag for the new search is rolling out to 10% of users starting tomorrow. Please watch for bug reports', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '16 minutes';
  INSERT INTO note (body, by, at) VALUES ('Monitoring is set up. What''s the rollback trigger?', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('Error rate > 0.5% or p95 latency > 800ms on search endpoints', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('clear thresholds. Good. Alerts are configured', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_product);


  -- ============================================================
  -- release notes, Mon Mar 30 2026, 09:00
  -- ============================================================
  ts := '2026-03-30 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('V2.4.0 is out. Highlights: bulk export, webhook retry logic, search speed improvements. Full notes in the doc', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('The webhook retry was a long time coming. Customers are going to love that', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('Any breaking changes?', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('none. We deprecated two API params in v2.3 with a warning, those are now removed but the migration path was documented', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);
  ts := '2026-03-31 14:22:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Hotfix v2.4.1 out, patched a race condition in the export queue that caused occasional duplicate files', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);
  ts := ts + interval '19 minutes';
  INSERT INTO note (body, by, at) VALUES ('nice catch. Was that from a user report or caught internally?', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('One user reported it, we reproduced it and found it was race condition under load', u_hiroshi, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);
  ts := '2026-04-01 10:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('v2.5 release candidate is in staging, 2 weeks of testing before we cut. Everyone please test your critical paths', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('What''s the biggest change in 2.5?', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('The new search engine. Everything else is smaller. Thats why we want extra testing time', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);
  ts := ts + interval '2 hours 15 minutes';
  INSERT INTO note (body, by, at) VALUES ('Release notes for v2.5 draft, would love a pass from product before it goes out', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);
  ts := ts + interval '38 minutes';
  INSERT INTO note (body, by, at) VALUES ('on it. The search section needs to be customer-facing language not technical. Ill rewrite that part', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_releases);


  -- ============================================================
  -- Happy Hour, Tue Mar 31 2026, 09:00
  -- ============================================================
  ts := '2026-03-31 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Happy hour this friday, rooftop bar on 5th, 5:30pm. Everyone is invited, bring good vibes', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('Finally. Ill be there', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('Rooftop has a great view. See you all there', u_sloane, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('is it an open tab situation or are we on our own?', u_chazz, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('First round is on the company. After that you''re free range', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('fair and civilised', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '37 minutes';
  INSERT INTO note (body, by, at) VALUES ('Does the bar have non-alcoholic options? asking for a few of us', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes, checked the menu, they have a solid mocktail list and good sodas', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('Perfect', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := '2026-04-01 10:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Who''s coming from the engineering side? trying to gauge numbers', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('Me, hiroshi, joon for sure', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '28 minutes';
  INSERT INTO note (body, by, at) VALUES ('i''ll try to make it, depends on the afternoon', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := '2026-04-04 21:15:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Great turnout last night. 30 people made it', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('It was a really good night. Same time next month?', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('Putting it in the calendar now', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('the view from that rooftop is ridiculous by the way. Someone find us an excuse to go back', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);
  ts := ts + interval '3 minutes';
  INSERT INTO note (body, by, at) VALUES ('done. Next month''s happy hour is officially there', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_happyhour);


  -- ============================================================
  -- lunch pics, various days, around midday
  -- ============================================================
  ts := '2026-02-24 12:15:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Made shakshuka this morning and had leftovers for lunch. Eating well today', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('Shakshuka at lunch is elite tier. Recipe?', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('will post it in foodies. Short version: good canned tomatoes are the secret', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := '2026-02-26 12:40:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Katsu curry from the place on grove street, highly recommended if you haven''t been', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('The one next to the bookshop? been meaning to try it', u_yuki, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes. The tonkatsu is better than the chicken. Go with the tonkatsu', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := '2026-03-02 12:05:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('homemade borscht today. Judge me', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('no judgement only admiration. How long did that take?', u_esperanza, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('Made it sunday. Reheated today. The beet takes it to another level by day three', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := '2026-03-04 13:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Sad desk salad reporting in. Dream of better days', u_sloane, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('there is a place downstairs that does really good grain bowls if you want a rescue', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := '2026-03-09 12:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Onigiri from the convenience store counts as lunch right', u_yuki, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('Absolutely yes. Onigiri is peak efficient lunch', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := '2026-03-17 12:45:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Pasta e ceci, brought enough for tomorrow too. The trick is a whole parmesan rind in the pot', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('luca is actually a witch and the parmesan rind is a spell', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);
  ts := ts + interval '3 minutes';
  INSERT INTO note (body, by, at) VALUES ('It is exactly that', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_lunch);


  -- ============================================================
  -- Must Love Dogs, various, some evenings/weekends
  -- ============================================================
  ts := '2026-02-26 08:45:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Bjørn discovered puddles today. Took 40 minutes to get him away from one', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('A man of culture. What kind of dog is Bjørn?', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('Norwegian Elkhound. Very stubborn and very fluffy', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := '2026-03-02 19:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('My dog Biko ate my airpods case last night. This is fine', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('Are the airpods ok at least', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('The airpods survived. The case did not. Biko shows no remorse', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := '2026-03-10 17:45:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('my border collie Finn figured out how to open the garden gate. We have a genius and a problem', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('Border collies are too smart. You need to give him a job before he gives himself one', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('He already has a job: herding my children. Unsolicited but thorough', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := '2026-03-18 08:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Dog park saturday morning, anyone in? the one by the river', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := ts + interval '27 minutes';
  INSERT INTO note (body, by, at) VALUES ('Bjørn and I will be there', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('Biko too. He needs to run off some airpod-related energy', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('My retriever Duke loves that park. See you there', u_trip, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := '2026-03-21 11:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Good turnout at the dog park. Bjørn made three friends and one enemy', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('the enemy was a dachshund, wasn''t it', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);
  ts := ts + interval '3 minutes';
  INSERT INTO note (body, by, at) VALUES ('How did you know', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_dogs);


  -- ============================================================
  -- cat ladys and gentlepeople, evenings and weekends
  -- ============================================================
  ts := '2026-02-27 20:15:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Mochi sat on my keyboard and sent a very alarming email. All handled', u_mei, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('Who was it to and what did it say', u_yuki, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('it was to my manager and it said "jjjjjjjjjjjjjjjjjkkkk". Luckily she found it charming', u_mei, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := '2026-03-04 21:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('My two cats have declared war on each other over the heating vent. Ongoing negotiations', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('Who is winning?', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('The older one holds the vent during the day. The younger one ambushes at night. A cold war with shifts', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := '2026-03-11 19:45:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('my cat Pushkin found a spider and stared at it for two hours without touching it. Art installation', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := ts + interval '16 minutes';
  INSERT INTO note (body, by, at) VALUES ('Cats understand something about contemplation that we do not', u_yuki, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := '2026-03-18 12:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Question: is tuna bad for cats regularly? Mochi is obsessed and im worried im enabling something', u_mei, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Occasional is fine. Daily is not, mercury and nutritional imbalance. Our vet said once a week max', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('good to know. Cutting back on the tuna, Mochi', u_mei, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := '2026-03-25 20:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Saoirse, you have cats right? any advice on a cat who refuses to drink from the bowl?', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := ts + interval '27 minutes';
  INSERT INTO note (body, by, at) VALUES ('Get a fountain. Ours refused still water too. Something about running water feels safe to them', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('They are little drama queens and we love them', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_cats);


  -- ============================================================
  -- Book Club, evenings
  -- ============================================================
  ts := '2026-03-02 20:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('book club pick for this month: Piranesi by Susanna Clarke. Short, strange, perfect', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('I read this last year and didnt talk to anyone for a day afterward. Excellent choice', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Starting tonight. How long is it?', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('Under 300 pages. Readable in a weekend if you get pulled in, which you will', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := '2026-03-09 20:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('finished Piranesi. The unreliable narrator device is so well constructed', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '17 minutes';
  INSERT INTO note (body, by, at) VALUES ('The journal structure makes it work. The reader figures things out just before Piranesi does', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('The house itself is the best character. It''s like nothing else i''ve read', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := '2026-03-16 20:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('What are we reading next month?', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('nominations: The Ministry for the Future, Babel, Demon Copperhead. Vote below', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('Babel', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('Ministry for the Future, think it should be required reading honestly', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('Demon Copperhead. Havent read it and ive been meaning to', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('Babel, it''s about language and power and its devastating', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '19 minutes';
  INSERT INTO note (body, by, at) VALUES ('Babel wins. See you all in four weeks. No spoilers in other channels please', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('Babel is long. I''m starting now', u_bitsy, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_books);


  -- ============================================================
  -- weekend warriors, Thursday planning + post-weekend
  -- ============================================================
  ts := '2026-02-26 17:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('5-a-side football sunday morning, need 2 more. Who''s in?', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('i''m in. What time?', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('9am. Bring boots if you have them, otherwise trainers are fine', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := ts + interval '31 minutes';
  INSERT INTO note (body, by, at) VALUES ('I''ll join if there''s still a spot', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := ts + interval '5 minutes';
  INSERT INTO note (body, by, at) VALUES ('Spot''s yours. We''re set', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := '2026-03-05 17:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('trail run saturday, the coastal path. Roughly 12km. Pace is relaxed, no one gets left behind', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('The coastal path is beautiful this time of year. I''m in', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := ts + interval '16 minutes';
  INSERT INTO note (body, by, at) VALUES ('12km is my limit but ill try. What time?', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('8am at the car park by the lighthouse', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := '2026-03-12 17:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('basketball at the park courts saturday afternoon, informal, just shooting around if anyone wants', u_chazz, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('I''ll come. Haven''t played in months', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := '2026-03-09 10:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Trail run recap: 13km, one blister, one very photogenic fog bank over the water. 10/10 would suffer again', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('The fog was something else. Felt like we were running inside a cloud', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('my legs are still angry but my head is very calm', u_emeka, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_weekend);


  -- ============================================================
  -- Foodies, throughout, midday and evenings
  -- ============================================================
  ts := '2026-02-25 12:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Made mole negro from scratch this weekend. 35 ingredients. Took all day. Worth every minute', u_esperanza, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('From scratch mole is a love language. Did you toast the chilis yourself?', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('Every single one. The kitchen smelled incredible for hours', u_esperanza, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := '2026-03-03 19:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('the new Georgian restaurant on maple street is genuinely excellent. Get the khinkali', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Been meaning to try it. Is it easy to get a table or do you need a reservation?', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('Walk-in was fine on a tuesday. Weekend probably needs a booking', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := '2026-03-10 12:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Team lunch at the thai place friday, the one with the good larb. Everyone welcome', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('always yes to larb', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('How spicy are we going', u_yuki, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('Ordering for the table and getting it properly spicy. If you want mild order separately, no shame', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('There is definitely shame', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := '2026-03-18 17:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('sourdough update: the starter is alive and well. Baked a batard this weekend, best crumb yet', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '19 minutes';
  INSERT INTO note (body, by, at) VALUES ('Bring some in. We will not judge. We will only eat', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('This is why i started baking bread. Thursday', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := '2026-03-26 12:15:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('The jollof at the place by the market is now officially the best in the city. I won''t argue', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('bold claim. Is this better than your aunt''s?', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('Different category. My aunt''s is home. This is a restaurant. Both excellent', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_foodies);


  -- ============================================================
  -- Coffee & Chat, mornings throughout
  -- ============================================================
  ts := '2026-02-23 08:45:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Good morning everyone. Coffee is strong today, which is the correct setting', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('Mornings should not exist before 9am', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := '2026-02-25 09:10:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('has anyone seen that there''s a new bakery opened downstairs? croissants look very serious', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('I walked past. The lamination on those croissants is legitimately impressive', u_fatima, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('This is dangerous information', u_dmitri, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := '2026-03-02 09:30:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Hot take: oat milk in coffee is fine actually', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '7 minutes';
  INSERT INTO note (body, by, at) VALUES ('it is not fine', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '4 minutes';
  INSERT INTO note (body, by, at) VALUES ('It is fine and i will die on this hill', u_priya, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '3 minutes';
  INSERT INTO note (body, by, at) VALUES ('Respect the commitment. Wrong, but respectable', u_luca, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := '2026-03-09 15:05:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Anyone else find that 3pm is the most existential hour of the workday', u_nadia, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('yes. Something about the light changes and suddenly everything feels philosophical', u_layla, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('3pm is when i switch from coffee to tea and accept whatever the day was', u_ingrid, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := '2026-03-17 09:00:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('Walking meeting culture, who''s for it and who''s against', u_kwame, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '14 minutes';
  INSERT INTO note (body, by, at) VALUES ('For it when it''s a 1:1. Against it when notes need to be taken', u_amara, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '9 minutes';
  INSERT INTO note (body, by, at) VALUES ('for it always. Thinking is better when you''re moving', u_anders, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '6 minutes';
  INSERT INTO note (body, by, at) VALUES ('Against it when it''s raining, which is always', u_saoirse, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := '2026-03-30 09:15:00'::timestamptz;
  INSERT INTO note (body, by, at) VALUES ('What''s everyone listening to lately? need something new for the commute', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '18 minutes';
  INSERT INTO note (body, by, at) VALUES ('Khruangbin if you want something that feels like driving through a warm night', u_esperanza, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '11 minutes';
  INSERT INTO note (body, by, at) VALUES ('been on a big Coltrane kick. A Love Supreme on repeat', u_tariq, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '22 minutes';
  INSERT INTO note (body, by, at) VALUES ('Podcasts only. My brain refuses music before 10am', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '8 minutes';
  INSERT INTO note (body, by, at) VALUES ('What podcasts?', u_joon, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);
  ts := ts + interval '12 minutes';
  INSERT INTO note (body, by, at) VALUES ('Darknet Diaries for security stories, 99% Invisible for design and architecture. Both excellent', u_tomas, ts) RETURNING id INTO m;
  INSERT INTO rel (on_note_id, as_note_id) VALUES (m, t_coffee);

END;
$$;
