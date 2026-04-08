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
  const [topics, setTopics] = useState<Topic[]>([]);
  const [dms, setDms] = useState<Record<string, Dm[]>>({});
  const [topicId, setTopicId] = useState<string | null>(null);
  const [dmId, setDmId] = useState<string | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [draft, setDraft] = useState('');
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
      .where('t.name', '=', ':topic:')
      .innerJoin('rel as r', (join) => join.onRef('r.asTagId', '=', 't.id'))
      .innerJoin('note as n', (join) => join.onRef('n.id', '=', 'r.onNoteId'))
      .select(['n.id', 'n.title'])
      .orderBy(sql`lower(n.title)`, 'asc');
    void q.execute().then((rows) => setTopics(rows as Topic[]));
  }, [userId]);

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

  const channelId = topicId ?? dmId;

  useEffect(() => {
    if (!channelId) return;
    const q = db
      .selectFrom('rel as r')
      .where('r.asNoteId', '=', channelId)
      .innerJoin('note as n', (join) => join.onRef('n.id', '=', 'r.onNoteId'))
      .innerJoin('user as u', (join) => join.onRef('u.id', '=', 'n.by'))
      .select(['n.id', 'n.body', 'n.at', 'u.id as authorId', 'u.username', 'u.name as userName'])
      .orderBy('n.at', 'asc');
    void q.execute().then((rows) => setMessages(rows as Message[]));
  }, [channelId]);

  useEffect(() => {
    if (messagesRef.current) {
      messagesRef.current.scrollTop = messagesRef.current.scrollHeight;
    }
  }, [messages]);

  async function handleSend() {
    if (!draft.trim() || !channelId) return;
    const note = await db
      .insertInto('note')
      .values({ body: draft.trim(), by: userId })
      .returning('id')
      .executeTakeFirst();
    if (!note) return;
    await db
      .insertInto('rel')
      .values({ onNoteId: note.id, asNoteId: channelId })
      .execute();
    setDraft('');
    const rows = await db
      .selectFrom('rel as r')
      .where('r.asNoteId', '=', channelId)
      .innerJoin('note as n', (join) => join.onRef('n.id', '=', 'r.onNoteId'))
      .innerJoin('user as u', (join) => join.onRef('u.id', '=', 'n.by'))
      .select(['n.id', 'n.body', 'n.at', 'u.id as authorId', 'u.username', 'u.name as userName'])
      .orderBy('n.at', 'asc')
      .execute();
    setMessages(rows as Message[]);
  }

  async function handleUserChange(id: string) {
    setUserId(id);
    await sql`SET LOCAL app.user_id = ${sql.lit(id)}`.execute(db);
  }

  return (
    <div className="app">
      <div className="app-header">
        <span className="app-title">Work Chat</span>
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
        <div className="sidebar">
          <div className="sidebar-section">
            <div className="sidebar-section-header">Topics</div>
            <ul className="sidebar-list">
              {topics.map((t) => (
                <li
                  key={t.id}
                  onClick={() => { setTopicId(t.id); setDmId(null); }}
                  className={t.id === topicId ? 'active' : undefined}
                >
                  {t.title}
                </li>
              ))}
            </ul>
          </div>
          <div className="sidebar-section">
            <div className="sidebar-section-header">Direct Messages</div>
            <ul className="sidebar-list">
              {Object.entries(dms).map(([noteId, rows]) => (
                <li
                  key={noteId}
                  onClick={() => { setDmId(noteId); setTopicId(null); }}
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
          </div>
        </div>
        <div className="channel">
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
          <div className="message-entry">
            <div className="message-entry-box">
              <textarea
                className="message-input"
                value={draft}
                onChange={(e) => setDraft(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    void handleSend();
                  }
                }}
                placeholder="Message"
                rows={1}
              />
              <div className="message-entry-toolbar">
                <button
                  className={`send-button ${draft.trim() ? 'send-button-active' : ''}`}
                  disabled={!draft.trim()}
                  onClick={() => void handleSend()}
                >
                  &#9658;
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
