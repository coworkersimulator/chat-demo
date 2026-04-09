import type { PGlite } from '@electric-sql/pglite';
import { PGliteWorker } from '@electric-sql/pglite/worker';
import multiavatar from '@multiavatar/multiavatar';
import { PrismaClient } from '@prisma/client/edge';
import type { SqlMigrationAwareDriverAdapterFactory } from '@prisma/driver-adapter-utils';
import { format, isToday, isYesterday } from 'date-fns';
import { PrismaPGlite } from 'pglite-prisma-adapter';
import {
  Fragment,
  useCallback,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
} from 'react';
import { createPortal } from 'react-dom';
import './App.css';
import PgSharedWorker from './db/pglite-shared-worker.ts?sharedworker';
import { softDeleteExtension } from './db/prisma-soft-delete';
const githubSvg = '/chat-demo/github.svg';

function createDb(pgliteWorker: PGlite, getUserId: () => string) {
  const factory = new PrismaPGlite(pgliteWorker);
  const adapter: SqlMigrationAwareDriverAdapterFactory = {
    provider: factory.provider,
    adapterName: factory.adapterName,
    async connect() {
      const conn = await factory.connect();
      const origStartTransaction = conn.startTransaction.bind(conn);
      conn.startTransaction = async (
        isolationLevel?: Parameters<typeof origStartTransaction>[0],
      ) => {
        const tx = await origStartTransaction(isolationLevel);
        const userId = getUserId();
        if (userId) {
          await tx.executeRaw({
            sql: `SET LOCAL app.user_id = '${userId}'`,
            args: [],
            argTypes: [],
          });
        }
        return tx;
      };
      return conn;
    },
    connectToShadowDb: () => factory.connectToShadowDb(),
  };
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

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  useLayoutEffect(() => {
    if (!anchor || !pickerRef.current) return;
    const el = pickerRef.current;
    const btn = anchor.getBoundingClientRect();
    const pw = el.offsetWidth;
    const ph = el.offsetHeight;
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    let top = btn.top - ph - 6;
    if (top < 8) top = btn.bottom + 6;
    if (top + ph > vh - 8) top = vh - ph - 8;
    let left = btn.left;
    if (left + pw > vw - 8) left = vw - pw - 8;
    if (left < 8) left = 8;
    el.style.top = `${top}px`;
    el.style.left = `${left}px`;
    el.style.visibility = 'visible';
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
    <div ref={pickerRef} className="reaction-picker">
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
  const [addBtnEl, setAddBtnEl] = useState<HTMLButtonElement | null>(null);
  const addBtnRef = useCallback(
    (el: HTMLButtonElement | null) => setAddBtnEl(el),
    [],
  );
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
          anchor={addBtnEl}
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
  const dmTitle = dmId && dms[dmId]
    ? dms[dmId].filter((r) => r.userId !== userId).map((r) => r.userName ?? r.username).sort().join(', ')
    : '';
  const [messages, setMessages] = useState<Message[]>([]);
  const [reactions, setReactions] = useState<
    Record<string, { emoji: string; count: number; mine: boolean }[]>
  >({});
  const [allReactions, setAllReactions] = useState<
    { id: string; emoji: string; name: string }[]
  >([]);
  const [pickerFor, setPickerFor] = useState<string | null>(null);
  const [activeMsg, setActiveMsg] = useState<string | null>(null);
  const [draft, setDraft] = useState('');
  const [newDm, setNewDm] = useState(false);
  const [newDmSelected, setNewDmSelected] = useState<string[]>([]);
  const [newDmQuery, setNewDmQuery] = useState('');
  const [newTopic, setNewTopic] = useState(false);
  const [newTopicTitle, setNewTopicTitle] = useState('');
  const [ready, setReady] = useState(false);
  const messagesRef = useRef<HTMLDivElement>(null);
  const userIdRef = useRef('');
  const [userDropdownOpen, setUserDropdownOpen] = useState(false);
  const userDropdownRef = useRef<HTMLDivElement>(null);
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [isMobile, setIsMobile] = useState(
    () => window.matchMedia('(max-width: 680px)').matches,
  );

  useEffect(() => {
    const mq = window.matchMedia('(max-width: 680px)');
    const handler = (e: MediaQueryListEvent) => setIsMobile(e.matches);
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);

  // Track visible viewport height and scroll offset so the app stays above the
  // keyboard on iOS Safari. offsetTop is safe here because interactive-widget=
  // resizes-content makes Chrome Android resize rather than scroll (offsetTop=0).
  useEffect(() => {
    const vv = window.visualViewport;
    if (!vv) return;
    const update = () => {
      document.documentElement.style.setProperty('--vvh', `${vv.height}px`);
      document.documentElement.style.setProperty('--vv-offset', `${vv.offsetTop}px`);
    };
    vv.addEventListener('resize', update);
    vv.addEventListener('scroll', update);
    update();
    return () => {
      vv.removeEventListener('resize', update);
      vv.removeEventListener('scroll', update);
    };
  }, []);

  const [db, setDb] = useState<Db | null>(null);

  // Cross-tab sync: post here after any write; listen to reload the current view
  const syncBc = useRef<BroadcastChannel | null>(null);
  const onSyncRef = useRef<() => void>(() => {});
  // Keep the callback current on every render so the channel handler never captures stale state
  onSyncRef.current = () => {
    void loadTopics();
    if (channelId) void loadMessages(channelId);
    void loadDms(undefined, false);
  };

  useEffect(() => {
    const sw = new PgSharedWorker({ name: 'pglite' });
    sw.port.start();
    const workerAdapter = {
      postMessage: sw.port.postMessage.bind(sw.port),
      addEventListener: sw.port.addEventListener.bind(sw.port),
      removeEventListener: sw.port.removeEventListener.bind(sw.port),
      terminate: () => sw.port.close(),
    } as unknown as Worker;
    const pgWorker = new PGliteWorker(workerAdapter, { id: 'pglite' });

    const dbRef = { current: null as Db | null };
    pgWorker.waitReady.then(() => {
      dbRef.current = createDb(
        pgWorker as unknown as PGlite,
        () => userIdRef.current,
      );
      setDb(dbRef.current);
    });

    return () => {
      dbRef.current?.$disconnect();
      pgWorker.close();
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

  const loadReactions = useCallback(
    async (messageIds: string[]) => {
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
    },
    [db, userId],
  );

  async function toggleReaction(noteId: string, reactionId: string) {
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
    syncBc.current?.postMessage({});
  }

  const loadTopics = useCallback(async () => {
    if (!db || !userId) return;
    const rels = await db.rel.findMany({
      where: { asTag: { name: ':topic:' } },
      select: { onNote: { select: { id: true, title: true } } },
    });
    setTopics(
      rels
        .flatMap((r) =>
          r.onNote ? [{ id: r.onNote.id, title: r.onNote.title }] : [],
        )
        .sort((a, b) =>
          (a.title ?? '').toLowerCase().localeCompare((b.title ?? '').toLowerCase()),
        ),
    );
  }, [db, userId]);

  useEffect(() => {
    void loadTopics();
  }, [loadTopics]);

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
    setSidebarOpen(false);
    syncBc.current?.postMessage({});
  }

  const loadDms = useCallback(
    async (selectId?: string, navigate = true) => {
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
      if (navigate) {
        const nextDmId = selectId ?? Object.keys(sorted)[0] ?? null;
        setDmId(nextDmId);
        setTopicId(null);
      }
    },
    [db, userId],
  );

  useEffect(() => {
    if (!userId) return;
    loadDms().then(() => setReady(true));
  }, [loadDms, userId]);

  async function handleNewDm() {
    if (!db || newDmSelected.length === 0) return;
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
    setSidebarOpen(false);
    await loadDms(note.id);
    syncBc.current?.postMessage({});
  }

  const channelId = topicId ?? dmId;

  const loadMessages = useCallback(
    async (cId: string) => {
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
    },
    [db, loadReactions],
  );

  useEffect(() => {
    if (!channelId) return;
    void loadMessages(channelId);
  }, [channelId, loadMessages]);

  useEffect(() => {
    if (messagesRef.current) {
      messagesRef.current.scrollTop = messagesRef.current.scrollHeight;
    }
  }, [messages, sidebarOpen]);




  useEffect(() => {
    const bc = new BroadcastChannel('chat-sync');
    syncBc.current = bc;
    bc.onmessage = () => onSyncRef.current();
    return () => {
      bc.close();
      syncBc.current = null;
    };
  }, []);

  useEffect(() => {
    if (!userDropdownOpen) return;
    const handler = (e: MouseEvent) => {
      if (!userDropdownRef.current?.contains(e.target as Node))
        setUserDropdownOpen(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, [userDropdownOpen]);

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
    syncBc.current?.postMessage({});
  }

  function handleUserChange(id: string) {
    setUserId(id);
    userIdRef.current = id;
    setTopicId(null);
    setDmId(null);
    setMessages([]);
    setSidebarOpen(true);
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
        <a
          className="app-header-github"
          href="https://github.com/coworkersimulator/chat-demo"
          target="_blank"
          rel="noopener noreferrer"
        >
          <img
            src={githubSvg}
            width={14}
            height={14}
            alt=""
            aria-hidden="true"
          />
          <span className="app-header-github-label">View Source</span>
        </a>
        <span className="app-title">Chat Demo</span>
        <div className="app-header-right">
          <div className="switch-user-wrapper" ref={userDropdownRef}>
            <button
              className="switch-user-label"
              onClick={() => setUserDropdownOpen((v) => !v)}
            >
              Switch user:{' '}
              <span className="switch-user-current">
                {users.find((u) => u.id === userId)?.name ??
                  users.find((u) => u.id === userId)?.username}
              </span>
            </button>
            {userDropdownOpen && (
              <div className="switch-user-dropdown">
                {users.map((u) => (
                  <div
                    key={u.id}
                    className={`switch-user-option${u.id === userId ? ' active' : ''}`}
                    onClick={() => {
                      handleUserChange(u.id);
                      setUserDropdownOpen(false);
                    }}
                  >
                    {u.name ? `${u.name} (${u.username})` : u.username}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
      <div className={`app-body${sidebarOpen ? '' : ' channel-open'}`}>
        <div className={`sidebar${newDm ? ' dm-composing' : ''}`}>
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
                    setSidebarOpen(false);
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
            <ul className={`sidebar-list${newDm ? ' dm-list-hidden' : ''}`}>
              {Object.entries(dms).map(([noteId, rows]) => (
                <li
                  key={noteId}
                  onClick={() => {
                    setDmId(noteId);
                    setTopicId(null);
                    setSidebarOpen(false);
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
        {(!isMobile || !sidebarOpen) && <div className="channel">
          {!channelId ? (
            <div className="empty-state">
              <div className="empty-state-title">Chat Demo</div>
              <div className="empty-state-body">
                Select a topic or direct message to start chatting.
              </div>
            </div>
          ) : (
            <>
              <div className="channel-header">
                <button
                  className="channel-back-btn"
                  onClick={() => setSidebarOpen(true)}
                >
                  ‹
                </button>
                {dmId && (
                  <div className="channel-header-text">
                    <span className="channel-title">{dmTitle}</span>
                    {(dms[dmId]?.length ?? 0) > 2 && (
                      <span className="channel-subtitle">
                        {dms[dmId].length} members
                      </span>
                    )}
                  </div>
                )}
                {topicId && (
                  <div className="channel-header-text">
                    <span className="channel-title">
                      # {topics.find((t) => t.id === topicId)?.title}
                    </span>
                    <span className="channel-subtitle">Topic</span>
                  </div>
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
                        <div
                          className={`message message-continuation${activeMsg === m.id ? ' message-active' : ''}`}
                          onClick={() => setActiveMsg(activeMsg === m.id ? null : m.id)}
                        >
                          <div className="message-continuation-time">
                            {formatAt(at)}
                          </div>
                          <p className="message-body">{m.body}</p>
                          {reactionBar}
                        </div>
                      ) : (
                        <div
                          className={`message${activeMsg === m.id ? ' message-active' : ''}`}
                          onClick={() => setActiveMsg(activeMsg === m.id ? null : m.id)}
                        >
                          <img
                            src={`data:image/svg+xml;utf8,${encodeURIComponent(multiavatar(m.username))}`}
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
                    placeholder={(() => {
                      const text = topicId
                        ? `Message #${topics.find((t) => t.id === topicId)?.title ?? ''}`
                        : dmTitle
                          ? `Message ${dmTitle}`
                          : 'Message';
                      return text.length > 50 ? text.slice(0, 47) + '…' : text;
                    })()}
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
        </div>}
      </div>
    </div>
  );
}

export default App;
