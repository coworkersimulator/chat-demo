import type { PGlite } from '@electric-sql/pglite';
import { PGliteWorker } from '@electric-sql/pglite/worker';
import multiavatar from '@multiavatar/multiavatar';
import { PrismaClient } from '@prisma/client/edge';
import { format, isToday, isYesterday } from 'date-fns';
import { PrismaPGlite } from 'pglite-prisma-adapter';
import { Fragment, useEffect, useLayoutEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import './App.css';
import PgWorker from './db/pglite-worker.ts?worker';
import { softDeleteExtension } from './db/prisma-soft-delete';

function createDb(pgliteWorker: PGlite) {
  const adapter = new PrismaPGlite(pgliteWorker);
  const base = new PrismaClient({ adapter });
  return base.$extends(softDeleteExtension(base));
}
type Db = ReturnType<typeof createDb>;

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

function formatDivider(date: Date) {
  if (isToday(date)) return 'Today';
  if (isYesterday(date)) return 'Yesterday';
  return format(date, 'MMMM d, yyyy');
}

function isSameDay(a: Date, b: Date) {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}

function ReactionPicker({
  anchor,
  noteId,
  allReactions,
  onToggle,
  onClose,
}: {
  anchor: HTMLElement | null;
  noteId: string;
  allReactions: { id: string; emoji: string; name: string }[];
  onToggle: (noteId: string, reactionId: string, emoji: string) => void;
  onClose: () => void;
}) {
  const [query, setQuery] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);
  const pickerRef = useRef<HTMLDivElement>(null);
  const [style, setStyle] = useState<React.CSSProperties>({
    visibility: 'hidden',
    top: 0,
    left: 0,
  });

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  useLayoutEffect(() => {
    if (!anchor || !pickerRef.current) return;
    const btn = anchor.getBoundingClientRect();
    const pw = pickerRef.current.offsetWidth;
    const ph = pickerRef.current.offsetHeight;
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    let top = btn.top - ph - 6;
    if (top < 8) top = btn.bottom + 6;
    if (top + ph > vh - 8) top = vh - ph - 8;
    let left = btn.left;
    if (left + pw > vw - 8) left = vw - pw - 8;
    if (left < 8) left = 8;
    setStyle({ visibility: 'visible', top, left });
  }, [anchor]);

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (
        pickerRef.current &&
        !pickerRef.current.contains(e.target as Node) &&
        anchor &&
        !anchor.contains(e.target as Node)
      )
        onClose();
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, [anchor, onClose]);

  const normalized = query.trim().toLowerCase().replace(/\s+/g, '_');
  const filtered = normalized
    ? allReactions.filter((r) => r.name.includes(normalized))
    : allReactions;

  return createPortal(
    <div
      ref={pickerRef}
      className="reaction-picker"
      style={{ position: 'fixed', ...style }}
    >
      <div className="reaction-picker-search">
        <input
          ref={inputRef}
          className="reaction-picker-input"
          placeholder="Search emoji"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Escape') onClose();
            if (e.key === 'Enter' && filtered.length > 0)
              onToggle(noteId, filtered[0].id, filtered[0].emoji);
          }}
        />
      </div>
      <div className="reaction-picker-grid">
        {filtered.slice(0, 100).map((r) => (
          <button
            key={r.id}
            className="reaction-picker-emoji"
            title={`:${r.name}:`}
            onClick={() => onToggle(noteId, r.id, r.emoji)}
          >
            {r.emoji}
          </button>
        ))}
        {filtered.length === 0 && (
          <div className="reaction-picker-empty">No results</div>
        )}
      </div>
    </div>,
    document.body,
  );
}

function ReactionBar({
  noteId,
  reactions,
  allReactions,
  pickerFor,
  setPickerFor,
  onToggle,
}: {
  noteId: string;
  reactions: { emoji: string; count: number; mine: boolean }[];
  allReactions: { id: string; emoji: string; name: string }[];
  pickerFor: string | null;
  setPickerFor: (id: string | null) => void;
  onToggle: (noteId: string, reactionId: string, emoji: string) => void;
}) {
  const addBtnRef = useRef<HTMLButtonElement>(null);
  return (
    <div className="reaction-bar">
      {reactions.map((r) => (
        <button
          key={r.emoji}
          className={`reaction-chip ${r.mine ? 'reaction-chip-mine' : ''}`}
          title={`:${allReactions.find((x) => x.emoji === r.emoji)?.name}:`}
          onClick={() => {
            const ar = allReactions.find((x) => x.emoji === r.emoji);
            if (ar) onToggle(noteId, ar.id, r.emoji);
          }}
        >
          {r.emoji} {r.count}
        </button>
      ))}
      <button
        ref={addBtnRef}
        className="reaction-add-btn"
        onClick={() => setPickerFor(pickerFor === noteId ? null : noteId)}
      >
        &#x1F642;
      </button>
      {pickerFor === noteId && (
        <ReactionPicker
          anchor={addBtnRef.current}
          noteId={noteId}
          allReactions={allReactions}
          onToggle={(nid, rid, emoji) => {
            onToggle(nid, rid, emoji);
          }}
          onClose={() => setPickerFor(null)}
        />
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
  const [reactions, setReactions] = useState<
    Record<string, { emoji: string; count: number; mine: boolean }[]>
  >({});
  const [allReactions, setAllReactions] = useState<
    { id: string; emoji: string; name: string }[]
  >([]);
  const [pickerFor, setPickerFor] = useState<string | null>(null);
  const [draft, setDraft] = useState('');
  const [newDm, setNewDm] = useState(false);
  const [newDmSelected, setNewDmSelected] = useState<string[]>([]);
  const [newDmQuery, setNewDmQuery] = useState('');
  const [newTopic, setNewTopic] = useState(false);
  const [newTopicTitle, setNewTopicTitle] = useState('');
  const [ready, setReady] = useState(false);
  const messagesRef = useRef<HTMLDivElement>(null);

  const [db, setDb] = useState<Db | null>(null);

  useEffect(() => {
    const pgliteWorker = new PGliteWorker(
      new PgWorker({ name: 'pglite-worker' }),
      { id: 'pglite' },
    ) as unknown as PGlite;

    const db = createDb(pgliteWorker);
    setDb(db);

    return () => {
      db.$disconnect();
      pgliteWorker?.close();
    };
  }, []);

  useEffect(() => {
    if (!db) return;
    db.user
      .findMany({
        select: { id: true, username: true, name: true },
        orderBy: { username: 'asc' },
      })
      .then((rows) => {
        setUsers(rows);
        if (rows.length > 0) handleUserChange(rows[0].id);
      });
  }, [db]);

  useEffect(() => {
    if (!db) return;
    db.reaction
      .findMany({ select: { id: true, emoji: true, name: true } })
      .then(setAllReactions);
  }, [db]);

  async function loadReactions(messageIds: string[]) {
    if (!db) return;
    if (messageIds.length === 0) {
      setReactions({});
      return;
    }
    const rels = await db.rel.findMany({
      where: { onNoteId: { in: messageIds }, asReactionId: { not: null } },
      select: {
        onNoteId: true,
        by: true,
        asReaction: { select: { emoji: true } },
      },
    });
    const grouped: Record<
      string,
      { emoji: string; count: number; mine: boolean }[]
    > = {};
    for (const rel of rels) {
      if (!rel.onNoteId || !rel.asReaction) continue;
      const existing = (grouped[rel.onNoteId] ??= []);
      const slot = existing.find((e) => e.emoji === rel.asReaction!.emoji);
      if (slot) {
        slot.count++;
        if (rel.by === userId) slot.mine = true;
      } else
        existing.push({
          emoji: rel.asReaction.emoji,
          count: 1,
          mine: rel.by === userId,
        });
    }
    setReactions(grouped);
  }

  async function toggleReaction(
    noteId: string,
    reactionId: string,
    emoji: string,
  ) {
    if (!db) return;
    const existing = await db.rel.findFirst({
      where: { onNoteId: noteId, asReactionId: reactionId, by: userId },
      select: { id: true, deletedAt: true },
    });
    if (existing) {
      if (!existing.deletedAt) {
        await db.rel.update({
          where: { id: existing.id },
          data: { deletedAt: new Date() },
        });
      }
    } else {
      await db.rel.create({
        data: { onNoteId: noteId, asReactionId: reactionId, by: userId },
      });
    }
    setPickerFor(null);
    await loadReactions(messages.map((m) => m.id));
  }

  async function loadTopics() {
    if (!db || !userId) return;
    const rels = await db.rel.findMany({
      where: { asTag: { name: ':topic:' } },
      select: { onNote: { select: { id: true, title: true } } },
      orderBy: { onNote: { title: 'asc' } },
    });
    setTopics(
      rels.flatMap((r) =>
        r.onNote ? [{ id: r.onNote.id, title: r.onNote.title }] : [],
      ),
    );
  }

  useEffect(() => {
    void loadTopics();
  }, [userId]);

  async function handleNewTopic() {
    if (!db || !newTopicTitle.trim()) return;
    const tag = await db.tag.findFirst({
      where: { name: ':topic:' },
      select: { id: true },
    });
    if (!tag) return;
    const note = await db.note.create({
      data: { title: newTopicTitle.trim(), by: userId },
      select: { id: true },
    });
    await db.rel.create({ data: { onNoteId: note.id, asTagId: tag.id } });
    setNewTopic(false);
    setNewTopicTitle('');
    await loadTopics();
    setTopicId(note.id);
    setDmId(null);
  }

  async function loadDms(selectId?: string) {
    if (!db || !userId) return;
    const dmRels = await db.rel.findMany({
      where: {
        asTag: { name: ':dm:' },
        onNote: { onRels: { some: { asUserId: userId } } },
      },
      select: {
        onNoteId: true,
        onNote: {
          select: {
            asRels: { select: { onNote: { select: { at: true } } } },
            onRels: {
              where: { asUserId: { not: null } },
              select: {
                asUser: { select: { id: true, username: true, name: true } },
              },
            },
          },
        },
      },
    });

    const grouped: Record<string, Dm[]> = {};
    for (const dmRel of dmRels) {
      const noteId = dmRel.onNoteId!;
      const times =
        dmRel.onNote?.asRels
          .map((r) => r.onNote?.at)
          .filter((t): t is Date => t != null) ?? [];
      const lastAt =
        times.length > 0
          ? new Date(Math.max(...times.map((t) => t.getTime())))
          : new Date(0);
      for (const { asUser: u } of dmRel.onNote?.onRels ?? []) {
        if (!u) continue;
        (grouped[noteId] ??= []).push({
          noteId,
          userId: u.id,
          username: u.username,
          userName: u.name,
          lastAt,
        });
      }
    }

    const sorted = Object.fromEntries(
      Object.entries(grouped).sort(
        ([, a], [, b]) => b[0].lastAt.getTime() - a[0].lastAt.getTime(),
      ),
    );
    setDms(sorted);
    const nextDmId = selectId ?? Object.keys(sorted)[0] ?? null;
    setDmId(nextDmId);
    if (!selectId) setTopicId(null);
  }

  useEffect(() => {
    if (!userId) return;
    loadDms().then(() => setReady(true));
  }, [userId]);

  async function handleNewDm() {
    if (!db || newDmSelected.length === 0) return;
    const title = newDmSelected
      .map((id) => users.find((u) => u.id === id))
      .map((u) => (u ? (u.name ?? u.username) : ''))
      .sort()
      .join(', ');
    setDmTitle(title);
    const tag = await db.tag.findFirst({
      where: { name: ':dm:' },
      select: { id: true },
    });
    if (!tag) return;
    const note = await db.note.create({
      data: { body: '', by: userId },
      select: { id: true },
    });
    await db.rel.createMany({
      data: [
        { onNoteId: note.id, asTagId: tag.id },
        { onNoteId: note.id, asUserId: userId },
        ...newDmSelected.map((id) => ({ onNoteId: note.id, asUserId: id })),
      ],
    });
    setNewDm(false);
    setNewDmSelected([]);
    setTopicId(null);
    await loadDms(note.id);
  }

  const channelId = topicId ?? dmId;

  async function loadMessages(cId: string) {
    if (!db) return;
    const rels = await db.rel.findMany({
      where: { asNoteId: cId },
      select: {
        onNote: {
          select: {
            id: true,
            body: true,
            at: true,
            user: { select: { id: true, username: true, name: true } },
          },
        },
      },
      orderBy: { onNote: { at: 'asc' } },
    });
    const msgs: Message[] = rels.flatMap((r) =>
      r.onNote && r.onNote.user
        ? [
            {
              id: r.onNote.id,
              body: r.onNote.body,
              at: r.onNote.at,
              authorId: r.onNote.user.id,
              username: r.onNote.user.username,
              userName: r.onNote.user.name,
            },
          ]
        : [],
    );
    setMessages(msgs);
    await loadReactions(msgs.map((m) => m.id));
  }

  useEffect(() => {
    if (!channelId) return;
    void loadMessages(channelId);
  }, [channelId]);

  useEffect(() => {
    if (messagesRef.current) {
      messagesRef.current.scrollTop = messagesRef.current.scrollHeight;
    }
  }, [messages]);

  async function handleSend() {
    if (!db || !draft.trim() || !channelId) return;
    const note = await db.note.create({
      data: { body: draft.trim(), by: userId },
      select: { id: true },
    });
    await db.rel.create({ data: { onNoteId: note.id, asNoteId: channelId } });
    setDraft('');
    await loadMessages(channelId);
    if (dmId) await loadDms(dmId);
  }

  async function handleUserChange(id: string) {
    setUserId(id);
    if (!db) return;
    await db.$executeRawUnsafe(`SET LOCAL app.user_id = '${id}'`);
  }

  if (!ready) {
    return (
      <div className="loading-screen">
        <div className="loading-spinner" />
      </div>
    );
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
              <button
                className="sidebar-new-btn"
                onClick={() => setNewTopic((v) => !v)}
              >
                +
              </button>
            </div>
            {newTopic && (
              <div className="sidebar-new-topic">
                <input
                  className="sidebar-new-topic-input"
                  value={newTopicTitle}
                  onChange={(e) => setNewTopicTitle(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') void handleNewTopic();
                    if (e.key === 'Escape') {
                      setNewTopic(false);
                      setNewTopicTitle('');
                    }
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
                  onClick={() => {
                    setTopicId(t.id);
                    setDmId(null);
                  }}
                  className={t.id === topicId ? 'active' : undefined}
                >
                  # {t.title}
                </li>
              ))}
            </ul>
          </div>
          <div className="sidebar-section">
            <div className="sidebar-section-header">
              Direct Messages
              <button
                className="sidebar-new-btn"
                onClick={() => {
                  setNewDm((v) => !v);
                  setNewDmQuery('');
                  setNewDmSelected([]);
                }}
              >
                +
              </button>
            </div>
            {newDm && (
              <div className="dm-composer">
                <div className="dm-composer-to">
                  <span className="dm-composer-to-label">To:</span>
                  <div className="dm-composer-chips">
                    {newDmSelected.map((id) => {
                      const u = users.find((u) => u.id === id);
                      return (
                        <span key={id} className="dm-chip">
                          {u?.name ?? u?.username}
                          <button
                            className="dm-chip-remove"
                            onClick={() =>
                              setNewDmSelected((prev) =>
                                prev.filter((x) => x !== id),
                              )
                            }
                          >
                            ×
                          </button>
                        </span>
                      );
                    })}
                    <input
                      className="dm-composer-input"
                      placeholder={
                        newDmSelected.length === 0 ? 'Search people' : ''
                      }
                      value={newDmQuery}
                      onChange={(e) => setNewDmQuery(e.target.value)}
                      autoFocus
                    />
                  </div>
                </div>
                <ul className="sidebar-list dm-suggestions">
                  {users
                    .filter(
                      (u) => u.id !== userId && !newDmSelected.includes(u.id),
                    )
                    .filter((u) => {
                      const q = newDmQuery.toLowerCase();
                      return (
                        !q ||
                        (u.name ?? u.username).toLowerCase().includes(q) ||
                        u.username.toLowerCase().includes(q)
                      );
                    })
                    .map((u) => (
                      <li
                        key={u.id}
                        onClick={() => {
                          setNewDmSelected((prev) => [...prev, u.id]);
                          setNewDmQuery('');
                        }}
                      >
                        {u.name ?? u.username}
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
                      rows
                        .filter((r) => r.userId !== userId)
                        .map((r) => r.userName ?? r.username)
                        .sort()
                        .join(', '),
                    );
                  }}
                  className={noteId === dmId ? 'active' : undefined}
                >
                  {rows
                    .filter((r) => r.userId !== userId)
                    .map((r) => r.userName ?? r.username)
                    .sort()
                    .join(', ')}
                </li>
              ))}
            </ul>
          </div>
        </div>
        <div className="channel">
          {!channelId ? (
            <div className="empty-state">
              <div className="empty-state-title">Work Chat</div>
              <div className="empty-state-body">
                Select a topic or direct message to start chatting.
              </div>
            </div>
          ) : (
            <>
              <div className="channel-header">
                {dmId && (
                  <>
                    <span className="channel-title">{dmTitle}</span>
                    {(dms[dmId]?.length ?? 0) > 2 && (
                      <span className="channel-subtitle">
                        {dms[dmId].length} members
                      </span>
                    )}
                  </>
                )}
                {topicId && (
                  <>
                    <span className="channel-title">
                      # {topics.find((t) => t.id === topicId)?.title}
                    </span>
                    <span className="channel-subtitle">Topic</span>
                  </>
                )}
              </div>
              <div className="messages" ref={messagesRef}>
                {messages.map((m, i) => {
                  const name = m.userName ?? m.username;
                  const prev = messages[i - 1];
                  const at = new Date(m.at);
                  const showDivider =
                    !prev || !isSameDay(new Date(prev.at), at);
                  const isContinuation =
                    !showDivider &&
                    prev &&
                    prev.authorId === m.authorId &&
                    at.getTime() - new Date(prev.at).getTime() < 5 * 60 * 1000;
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
                  return (
                    <Fragment key={m.id}>
                      {showDivider && (
                        <div className="date-divider">
                          <span>{formatDivider(at)}</span>
                        </div>
                      )}
                      {isContinuation ? (
                        <div className="message message-continuation">
                          <div className="message-continuation-time">
                            {formatAt(at)}
                          </div>
                          <p className="message-body">{m.body}</p>
                          {reactionBar}
                        </div>
                      ) : (
                        <div className="message">
                          <img
                            src={`data:image/svg+xml;utf8,${encodeURIComponent(multiavatar(m.authorId))}`}
                            width={36}
                            height={36}
                            className="message-avatar"
                          />
                          <div className="message-content">
                            <div className="message-meta">
                              <span className="message-author">{name}</span>
                              <span className="message-time">
                                {formatAt(at)}
                              </span>
                            </div>
                            <p className="message-body">{m.body}</p>
                            {reactionBar}
                          </div>
                        </div>
                      )}
                    </Fragment>
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
                    placeholder={
                      topicId
                        ? `Message #${topics.find((t) => t.id === topicId)?.title ?? ''}`
                        : dmTitle
                          ? `Message ${dmTitle}`
                          : 'Message'
                    }
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
            </>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
