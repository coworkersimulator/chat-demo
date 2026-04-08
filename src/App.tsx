import multiavatar from '@multiavatar/multiavatar';
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
  if (isToday(date)) return format(date, 'p');
  if (isYesterday(date)) return `Yesterday at ${format(date, 'p')}`;
  return format(date, 'MMM d, p');
}

function ReactionBar({ noteId, reactions, allReactions, pickerFor, setPickerFor, onToggle }: {
  noteId: string;
  reactions: { emoji: string; count: number; mine: boolean }[];
  allReactions: { id: string; emoji: string; name: string }[];
  pickerFor: string | null;
  setPickerFor: (id: string | null) => void;
  onToggle: (noteId: string, reactionId: string, emoji: string) => void;
}) {
  return (
    <div className="reaction-bar">
      {reactions.map((r) => (
        <button
          key={r.emoji}
          className={`reaction-chip ${r.mine ? 'reaction-chip-mine' : ''}`}
          onClick={() => {
            const ar = allReactions.find((x) => x.emoji === r.emoji);
            if (ar) onToggle(noteId, ar.id, r.emoji);
          }}
        >
          {r.emoji} {r.count}
        </button>
      ))}
      <button className="reaction-add-btn" onClick={() => setPickerFor(pickerFor === noteId ? null : noteId)}>
        &#x1F642;
      </button>
      {pickerFor === noteId && (
        <div className="reaction-picker">
          {allReactions.map((r) => (
            <button key={r.id} className="reaction-picker-emoji" onClick={() => onToggle(noteId, r.id, r.emoji)}>
              {r.emoji}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

function App() {
  const [users, setUsers] = useState<User[]>([]);
  const [userId, setUserId] = useState('');
  const [topics, setTopics] = useState<Topic[]>([]);
  const [dms, setDms] = useState<Record<string, Dm[]>>({});
  const [topicId, setTopicId] = useState<string | null>(null);
  const [dmId, setDmId] = useState<string | null>(null);
  const [dmTitle, setDmTitle] = useState<string>('');
  const [messages, setMessages] = useState<Message[]>([]);
  const [reactions, setReactions] = useState<Record<string, { emoji: string; count: number; mine: boolean }[]>>({});
  const [allReactions, setAllReactions] = useState<{ id: string; emoji: string; name: string }[]>([]);
  const [pickerFor, setPickerFor] = useState<string | null>(null);
  const [draft, setDraft] = useState('');
  const [newDm, setNewDm] = useState(false);
  const [newDmSelected, setNewDmSelected] = useState<string[]>([]);
  const [newTopic, setNewTopic] = useState(false);
  const [newTopicTitle, setNewTopicTitle] = useState('');
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
    db.selectFrom('reaction').select(['id', 'emoji', 'name']).execute().then(setAllReactions);
  }, []);

  async function loadReactions(messageIds: string[]) {
    if (messageIds.length === 0) { setReactions({}); return; }
    const rows = await db
      .selectFrom('rel as r')
      .innerJoin('reaction as rx', (join) => join.onRef('rx.id', '=', 'r.asReactionId'))
      .where('r.onNoteId', 'in', messageIds)
      .where('r.asReactionId', 'is not', null)
      .select(['r.onNoteId as noteId', 'rx.emoji as emoji', 'r.by'])
      .execute();
    const grouped: Record<string, { emoji: string; count: number; mine: boolean }[]> = {};
    for (const row of rows) {
      if (!row.noteId) continue;
      const existing = grouped[row.noteId] ??= [];
      const slot = existing.find((e) => e.emoji === row.emoji);
      if (slot) { slot.count++; if (row.by === userId) slot.mine = true; }
      else existing.push({ emoji: row.emoji, count: 1, mine: row.by === userId });
    }
    setReactions(grouped);
  }

  async function toggleReaction(noteId: string, reactionId: string, emoji: string) {
    const existing = await db
      .selectFrom('rel')
      .where('onNoteId', '=', noteId)
      .where('asReactionId', '=', reactionId)
      .where('by', '=', userId)
      .select('id')
      .executeTakeFirst();
    if (existing) {
      await db.deleteFrom('rel').where('id', '=', existing.id).execute();
    } else {
      await db.insertInto('rel').values({ onNoteId: noteId, asReactionId: reactionId, by: userId }).execute();
    }
    setPickerFor(null);
    await loadReactions(messages.map((m) => m.id));
  }

  async function loadTopics() {
    if (!userId) return;
    const rows = await db
      .selectFrom('tag as t')
      .where('t.name', '=', ':topic:')
      .innerJoin('rel as r', (join) => join.onRef('r.asTagId', '=', 't.id'))
      .innerJoin('note as n', (join) => join.onRef('n.id', '=', 'r.onNoteId'))
      .select(['n.id', 'n.title'])
      .orderBy(sql`lower(n.title)`, 'asc')
      .execute();
    setTopics(rows as Topic[]);
  }

  useEffect(() => {
    void loadTopics();
  }, [userId]);

  async function handleNewTopic() {
    if (!newTopicTitle.trim()) return;
    const tag = await db
      .selectFrom('tag')
      .where('name', '=', ':topic:')
      .select('id')
      .executeTakeFirst();
    if (!tag) return;
    const note = await db
      .insertInto('note')
      .values({ title: newTopicTitle.trim(), by: userId })
      .returning('id')
      .executeTakeFirst();
    if (!note) return;
    await db.insertInto('rel').values({ onNoteId: note.id, asTagId: tag.id }).execute();
    setNewTopic(false);
    setNewTopicTitle('');
    await loadTopics();
    setTopicId(note.id);
    setDmId(null);
  }

  async function loadDms(selectId?: string) {
    if (!userId) return;
    const rows = await db
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
      .orderBy('lastAt', 'desc')
      .execute();
    const grouped = (rows as Dm[]).reduce<Record<string, Dm[]>>((acc, row) => {
      (acc[row.noteId] ??= []).push(row);
      return acc;
    }, {});
    setDms(grouped);
    setDmId(selectId ?? Object.keys(grouped)[0] ?? null);
  }

  useEffect(() => {
    void loadDms();
  }, [userId]);

  async function handleNewDm() {
    if (newDmSelected.length === 0) return;
    const title = newDmSelected
      .map((id) => users.find((u) => u.id === id))
      .map((u) => u ? (u.name ?? u.username) : '')
      .sort()
      .join(', ');
    setDmTitle(title);
    const tag = await db
      .selectFrom('tag')
      .where('name', '=', ':dm:')
      .select('id')
      .executeTakeFirst();
    if (!tag) return;
    const note = await db
      .insertInto('note')
      .values({ body: '', by: userId })
      .returning('id')
      .executeTakeFirst();
    if (!note) return;
    await db.insertInto('rel').values([
      { onNoteId: note.id, asTagId: tag.id },
      { onNoteId: note.id, asUserId: userId },
      ...newDmSelected.map((id) => ({ onNoteId: note.id, asUserId: id })),
    ]).execute();
    setNewDm(false);
    setNewDmSelected([]);
    setTopicId(null);
    await loadDms(note.id);
  }

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
    void q.execute().then((rows) => {
      const msgs = rows as Message[];
      setMessages(msgs);
      void loadReactions(msgs.map((m) => m.id));
    });
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
    const msgs = rows as Message[];
    setMessages(msgs);
    await loadReactions(msgs.map((m) => m.id));
    if (dmId) await loadDms(dmId);
  }

  async function handleUserChange(id: string) {
    setUserId(id);
    await sql`SET LOCAL app.user_id = ${sql.lit(id)}`.execute(db);
  }

  return (
    <div className="app">
      <div className="app-header">
        <div />
        <span className="app-title">Work Chat</span>
        <div className="app-header-right">
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
      </div>
      <div className="app-body">
        <div className="sidebar">
          <div className="sidebar-section">
            <div className="sidebar-section-header">
              Topics
              <button className="sidebar-new-btn" onClick={() => setNewTopic((v) => !v)}>+</button>
            </div>
            {newTopic && (
              <div className="sidebar-new-topic">
                <input
                  className="sidebar-new-topic-input"
                  value={newTopicTitle}
                  onChange={(e) => setNewTopicTitle(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') void handleNewTopic();
                    if (e.key === 'Escape') { setNewTopic(false); setNewTopicTitle(''); }
                  }}
                  placeholder="Topic name"
                  autoFocus
                />
                <button
                  className={`dm-start-btn ${newTopicTitle.trim() ? 'dm-start-btn-active' : ''}`}
                  disabled={!newTopicTitle.trim()}
                  onClick={() => void handleNewTopic()}
                >
                  Create
                </button>
              </div>
            )}
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
            <div className="sidebar-section-header">
              Direct Messages
              <button className="sidebar-new-btn" onClick={() => setNewDm((v) => !v)}>+</button>
            </div>
            {newDm && (
              <div className="sidebar-user-picker">
                <ul className="sidebar-list">
                  {users
                    .filter((u) => u.id !== userId)
                    .map((u) => (
                      <li
                        key={u.id}
                        onClick={() =>
                          setNewDmSelected((prev) =>
                            prev.includes(u.id)
                              ? prev.filter((id) => id !== u.id)
                              : [...prev, u.id],
                          )
                        }
                        className={newDmSelected.includes(u.id) ? 'active' : undefined}
                      >
                        {u.name ? `${u.name} (${u.username})` : u.username}
                      </li>
                    ))}
                </ul>
                <button
                  className={`dm-start-btn ${newDmSelected.length > 0 ? 'dm-start-btn-active' : ''}`}
                  disabled={newDmSelected.length === 0}
                  onClick={() => void handleNewDm()}
                >
                  Open
                </button>
              </div>
            )}
            <ul className="sidebar-list">
              {Object.entries(dms).map(([noteId, rows]) => (
                <li
                  key={noteId}
                  onClick={() => {
                    setDmId(noteId);
                    setTopicId(null);
                    setDmTitle(
                      rows.filter((r) => r.userId !== userId).map((r) => r.userName ?? r.username).sort().join(', ')
                    );
                  }}
                  className={noteId === dmId ? 'active' : undefined}
                >
                  {rows
                    .filter((r) => r.userId !== userId)
                    .map((r) => r.username)
                    .sort()
                    .join(', ')}
                </li>
              ))}
            </ul>
          </div>
        </div>
        <div className="channel">
          <div className="channel-header">
            {dmId && <span className="channel-title">{dmTitle}</span>}
            {topicId && (
              <span className="channel-title">
                # {topics.find((t) => t.id === topicId)?.title}
              </span>
            )}
          </div>
        <div className="messages" ref={messagesRef}>
          {messages.map((m, i) => {
            const name = m.userName ?? m.username;
            const prev = messages[i - 1];
            const isContinuation = prev &&
              prev.authorId === m.authorId &&
              new Date(m.at).getTime() - new Date(prev.at).getTime() < 5 * 60 * 1000;
            const reactionBar = (
              <ReactionBar
                noteId={m.id}
                reactions={reactions[m.id] ?? []}
                allReactions={allReactions}
                pickerFor={pickerFor}
                setPickerFor={setPickerFor}
                onToggle={toggleReaction}
              />
            );
            return isContinuation ? (
              <div key={m.id} className="message message-continuation">
                <div className="message-continuation-time">{formatAt(new Date(m.at))}</div>
                <p className="message-body">{m.body}</p>
                {reactionBar}
              </div>
            ) : (
              <div key={m.id} className="message">
                <img
                  src={`data:image/svg+xml;utf8,${encodeURIComponent(multiavatar(m.authorId))}`}
                  width={28}
                  height={28}
                  className="message-avatar"
                />
                <div className="message-content">
                  <div className="message-meta">
                    <span className="message-author">{name}</span>
                    <span className="message-time">{formatAt(new Date(m.at))}</span>
                  </div>
                  <p className="message-body">{m.body}</p>
                  {reactionBar}
                </div>
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
