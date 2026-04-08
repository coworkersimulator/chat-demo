import { format, isToday, isYesterday } from 'date-fns';
import { sql } from 'kysely';
import { useEffect, useRef, useState } from 'react';
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

interface Dm {
  noteId: string;
  userId: string;
  username: string;
  userName: string | null;
  lastAt: Date;
}

interface Message {
  id: string;
  body: string | null;
  at: Date;
  authorId: string;
  username: string;
  userName: string | null;
}

function formatAt(date: Date) {
  if (isToday(date)) return `Today at ${format(date, 'p')}`;
  if (isYesterday(date)) return `Yesterday at ${format(date, 'p')}`;
  return format(date, 'MMM d, yyyy, p');
}

function App() {
  const [users, setUsers] = useState<User[]>([]);
  const [userId, setUserId] = useState('');
  const [dms, setDms] = useState<Record<string, Dm[]>>({});
  const [dmId, setDmId] = useState<string | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const messagesRef = useRef<HTMLDivElement>(null);

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
    void q.execute().then((rows) => {
      const grouped = (rows as Dm[]).reduce<Record<string, Dm[]>>(
        (acc, row) => {
          (acc[row.noteId] ??= []).push(row);
          return acc;
        },
        {},
      );
      setDms(grouped);
      setDmId(Object.keys(grouped)[0] ?? null);
    });
  }, [userId]);

  useEffect(() => {
    if (!dmId) return;
    const q = db
      .selectFrom('rel as r')
      .where('r.asNoteId', '=', dmId)
      .innerJoin('note as n', (join) => join.onRef('n.id', '=', 'r.onNoteId'))
      .innerJoin('user as u', (join) => join.onRef('u.id', '=', 'n.by'))
      .select(['n.id', 'n.body', 'n.at', 'u.id as authorId', 'u.username', 'u.name as userName'])
      .orderBy('n.at', 'asc');
    void q.execute().then((rows) => setMessages(rows as Message[]));
  }, [dmId]);

  useEffect(() => {
    if (messagesRef.current) {
      messagesRef.current.scrollTop = messagesRef.current.scrollHeight;
    }
  }, [messages]);

  async function handleUserChange(id: string) {
    setUserId(id);
    await sql`SET LOCAL app.user_id = ${sql.lit(id)}`.execute(db);
  }

  return (
    <div className="app">
      <div className="app-header">
        <span className="switch-user-label">Switch user:</span>
        <select
          value={userId}
          onChange={(e) => handleUserChange(e.target.value)}
        >
          {users.map((u) => (
            <option key={u.id} value={u.id}>
              {u.name ? `${u.name} (${u.username})` : u.username}
            </option>
          ))}
        </select>
      </div>
      <div className="app-body">
        <ul className="dm-list">
          {Object.entries(dms).map(([noteId, rows]) => (
            <li
              key={noteId}
              onClick={() => setDmId(noteId)}
              className={noteId === dmId ? 'active' : undefined}
            >
              {rows
                .filter((r) => r.userId !== userId)
                .map((r) => r.username)
                .sort()
                .join(' ')}
            </li>
          ))}
        </ul>
        <div className="messages" ref={messagesRef}>
          {messages.map((m) => {
            const isMine = m.authorId === userId;
            return (
              <div key={m.id} className={`message ${isMine ? 'message-mine' : ''}`}>
                {!isMine && (
                  <div className="message-meta">
                    <span className="message-author">{m.userName ?? m.username}</span>
                    <span className="message-time">{formatAt(m.at)}</span>
                  </div>
                )}
                <div className="message-bubble">{m.body}</div>
                {isMine && (
                  <div className="message-meta message-meta-mine">
                    <span className="message-time">{formatAt(m.at)}</span>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

export default App;
