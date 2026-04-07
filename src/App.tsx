import { sql } from 'kysely';
import { useEffect, useState } from 'react';
import './App.css';
import db from './db';

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
  const [topics, setTopics] = useState<Topic[]>([]);
  const [topicId, setTopicId] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);

  useEffect(() => {
    db.selectFrom('user')
      .select(['id', 'username', 'name'])
      .orderBy('username')
      .execute()
      .then((rows) => {
        setUsers(rows);
        if (rows.length > 0) handleUserChange(rows[0].id);
      });

    db.selectFrom('note as n')
      .innerJoin('relation as r', 'r.on_note_id', 'n.id')
      .innerJoin('tag as t', 't.id', 'r.to_tag_id')
      .select(['n.id', 'n.title'])
      .where('t.name', '=', ':topic:')
      .where('r.deleted_at', 'is', null)
      .where('n.deleted_at', 'is', null)
      .orderBy('n.title')
      .execute()
      .then((rows) => {
        setTopics(rows);
        if (rows.length > 0) loadMessages(rows[0].id);
      });
  }, []);

  async function handleUserChange(id: string) {
    setUserId(id);
    await sql`SET LOCAL app.user_id = ${sql.lit(id)}`.execute(db);
  }

  function loadMessages(id: string) {
    setTopicId(id);
    db.selectFrom('note as n')
      .innerJoin('relation as r', 'r.to_note_id', 'n.id')
      .innerJoin('tag as t', 't.id', 'r.to_tag_id')
      .innerJoin('user as u', 'u.id', 'n.by')
      .select(['n.id', 'n.body', 'n.at', 'u.username', 'u.name as author'])
      .where('r.on_note_id', '=', id)
      .where('t.name', '=', ':message:')
      .where('r.deleted_at', 'is', null)
      .where('n.deleted_at', 'is', null)
      .orderBy('n.at')
      .execute()
      .then(setMessages);
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

      <div style={{ display: 'flex' }}>
        <ul>
          {topics.map((t) => (
            <li
              key={t.id}
              onClick={() => loadMessages(t.id)}
              style={{ cursor: 'pointer', fontWeight: t.id === topicId ? 'bold' : 'normal' }}
            >
              {t.title}
            </li>
          ))}
        </ul>

        <ul>
          {messages.map((m) => (
            <li key={m.id}>
              <strong>{m.author ?? m.username}</strong>{' '}
              <small>{new Date(m.at).toLocaleString()}</small>
              <div>{m.body}</div>
            </li>
          ))}
        </ul>
      </div>
    </>
  );
}

export default App;
