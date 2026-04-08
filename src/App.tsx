import { sql } from 'kysely';
import { useEffect, useState } from 'react';
import './App.css';
import db from './db/db';

interface User {
  id: string;
  username: string;
  name: string | null;
}

interface Topic {
  id: string;
  title: string | null;
}

interface Message {
  id: string;
  body: string | null;
  at: Date;
  username: string;
  author: string | null;
}

function App() {
  const [users, setUsers] = useState<User[]>([]);
  const [userId, setUserId] = useState('');

  useEffect(() => {
    db.selectFrom('user')
      .select(['id', 'username', 'name'])
      .orderBy('username')
      .execute()
      .then((rows) => {
        setUsers(rows);
        if (rows.length > 0) handleUserChange(rows[0].id);
      });
  }, []);

  useEffect(() => {
    if (!userId) return;
    const q = db
      .selectFrom('tag as t')
      .where('t.name', '=', ':dm:')
      .innerJoin('rel as rtn', (join) => join.onRef('rtn.asTagId', '=', 't.id'))
      .innerJoin('rel as rn', (join) =>
        join.onRef('rn.asNoteId', '=', 'rtn.onNoteId'),
      )
      .innerJoin('rel as rp', (join) =>
        join
          .onRef('rp.onNoteId', '=', 'rtn.onNoteId')
          .on('rp.asUserId', 'is not', null),
      )
      .innerJoin('rel as rme', (join) =>
        join
          .onRef('rme.onNoteId', '=', 'rtn.onNoteId')
          .on('rme.asUserId', '=', userId),
      )
      .innerJoin('note as n', (join) => join.onRef('rn.onNoteId', '=', 'n.id'))
      .innerJoin('user as u', (join) => join.onRef('u.id', '=', 'rp.asUserId'))
      .groupBy(['rtn.onNoteId', 'u.id', 'u.username', 'u.name'])
      .select([
        'rtn.onNoteId as noteId',
        'u.id as userId',
        'u.username',
        'u.name as userName',
      ])
      .select((eb) => eb.fn.max('n.at').as('lastAt'))
      .orderBy('lastAt', 'desc');
    q.execute().then(console.log);
  }, [userId]);

  async function handleUserChange(id: string) {
    setUserId(id);
    await sql`SET LOCAL app.user_id = ${sql.lit(id)}`.execute(db);
  }

  return (
    <>
      <select value={userId} onChange={(e) => handleUserChange(e.target.value)}>
        {users.map((u) => (
          <option key={u.id} value={u.id}>
            {u.name ? `${u.name} (${u.username})` : u.username}
          </option>
        ))}
      </select>
    </>
  );
}

export default App;
