import type { PGlite } from '@electric-sql/pglite';
import { PGliteWorker } from '@electric-sql/pglite/worker';
import { useCallback, useEffect, useRef, useState } from 'react';
import './App.css';
import { AppHeader } from './components/AppHeader';
import { ChannelView } from './components/ChannelView';
import { Sidebar } from './components/Sidebar';
import PgSharedWorker from './db/pglite-shared-worker.ts?sharedworker';
import { createPrismaPglite } from './db/prisma-pglite';
import type { Channel, Dm, Message, User } from './types';

type Db = ReturnType<typeof createPrismaPglite>;

function App() {
  const [users, setUsers] = useState<User[]>([]);
  const [userId, setUserId] = useState('');
  const [channels, setChannels] = useState<Channel[]>([]);
  const [dms, setDms] = useState<Record<string, Dm[]>>({});
  const [channelId, setChannelId] = useState<string | null>(null);
  const [drafts, setDrafts] = useState<Record<string, string>>({});
  const [dmId, setDmId] = useState<string | null>(null);
  const dmTitle =
    dmId && dms[dmId]
      ? dms[dmId]
          .filter((r) => r.userId !== userId)
          .map((r) => r.userName ?? r.username)
          .sort()
          .join(', ')
      : '';
  const [messages, setMessages] = useState<Message[]>([]);
  const [reactions, setReactions] = useState<
    Record<string, { emoji: string; count: number; mine: boolean }[]>
  >({});
  const [allReactions, setAllReactions] = useState<
    { id: string; emoji: string; name: string }[]
  >([]);
  const [ready, setReady] = useState(false);
  const userIdRef = useRef('');
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

  const syncBc = useRef<BroadcastChannel | null>(null);
  const onSyncRef = useRef<() => void>(() => {});
  const activeId = channelId ?? dmId;
  onSyncRef.current = () => {
    void loadChannels();
    if (activeId) void loadMessages(activeId);
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

    let db: Db | null = null;
    pgWorker.waitReady.then(() => {
      db = createPrismaPglite(pgWorker as unknown as PGlite, () => userIdRef.current);
      setDb(db);
    });

    return () => {
      db?.$disconnect();
      pgWorker.close();
    };
  }, []);

  useEffect(() => {
    if (!db) return;
    db.user
      .findMany({
        where: { username: { not: 'root' } },
        select: { id: true, username: true, name: true },
        orderBy: { username: 'asc' },
      })
      .then((rows) => {
        setUsers(rows);
        const saved = sessionStorage.getItem('chat-username');
        const initial = (saved && rows.find((r) => r.username === saved)) || rows[0];
        if (initial) {
          sessionStorage.setItem('chat-username', initial.username);
          setUserId(initial.id);
          userIdRef.current = initial.id;
          setChannelId(null);
          setDmId(null);
          setMessages([]);
          setDrafts({});
          setSidebarOpen(true);
        }
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
      const rows = await db.noteReaction.findMany({
        where: { noteId: { in: messageIds } },
        select: {
          noteId: true,
          createdBy: true,
          reaction: { select: { emoji: true } },
        },
      });
      const grouped: Record<string, { emoji: string; count: number; mine: boolean }[]> =
        {};
      for (const row of rows) {
        const existing = (grouped[row.noteId] ??= []);
        const slot = existing.find((e) => e.emoji === row.reaction.emoji);
        if (slot) {
          slot.count++;
          if (row.createdBy === userId) slot.mine = true;
        } else
          existing.push({
            emoji: row.reaction.emoji,
            count: 1,
            mine: row.createdBy === userId,
          });
      }
      setReactions(grouped);
    },
    [db, userId],
  );

  const loadChannels = useCallback(async () => {
    if (!db || !userId) return;
    const rows = await db.noteTag.findMany({
      where: { tag: { name: ':channel:' } },
      select: { note: { select: { id: true, title: true } } },
    });
    setChannels(
      rows
        .map((r) => ({ id: r.note.id, title: r.note.title }))
        .sort((a, b) =>
          (a.title ?? '').toLowerCase().localeCompare((b.title ?? '').toLowerCase()),
        ),
    );
  }, [db, userId]);

  useEffect(() => {
    void loadChannels();
  }, [loadChannels]);

  const loadDms = useCallback(
    async (selectId?: string, navigate = true) => {
      if (!db || !userId) return;
      const dmNotes = await db.note.findMany({
        where: {
          noteTag: { some: { tag: { name: ':dm:' } } },
          noteUser: { some: { userId } },
        },
        select: {
          id: true,
          asParent: { select: { note: { select: { createdAt: true } } } },
          noteUser: {
            select: { member: { select: { id: true, username: true, name: true } } },
          },
        },
      });

      const grouped: Record<string, Dm[]> = {};
      for (const dmNote of dmNotes) {
        const noteId = dmNote.id;
        const times = dmNote.asParent.map((nn) => nn.note.createdAt);
        const lastAt =
          times.length > 0
            ? new Date(Math.max(...times.map((t) => t.getTime())))
            : new Date(0);
        for (const { member: u } of dmNote.noteUser) {
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
      }
    },
    [db, userId],
  );

  useEffect(() => {
    if (!userId) return;
    loadDms().then(() => setReady(true));
  }, [loadDms, userId]);

  const loadMessages = useCallback(
    async (cId: string) => {
      if (!db) return;
      const rows = await db.noteNote.findMany({
        where: { parentId: cId },
        select: {
          note: {
            select: {
              id: true,
              body: true,
              createdAt: true,
              meta: true,
              user: { select: { id: true, username: true, name: true } },
            },
          },
        },
        orderBy: { note: { createdAt: 'asc' } },
      });
      const msgs: Message[] = rows.map((r) => {
        const meta = r.note.meta as { changes?: { new?: Record<string, unknown> }[] } | null;
        return {
          id: r.note.id,
          body: r.note.body,
          createdAt: r.note.createdAt,
          authorId: r.note.user.id,
          username: r.note.user.username,
          userName: r.note.user.name,
          isEdited: !!(meta?.changes?.some((c) => c?.new && 'body' in c.new)),
        };
      });
      setMessages(msgs);
      await loadReactions(msgs.map((m) => m.id));
    },
    [db, loadReactions],
  );

  useEffect(() => {
    if (!activeId) return;
    void loadMessages(activeId);
  }, [activeId, loadMessages]);

  useEffect(() => {
    const bc = new BroadcastChannel('chat-sync');
    syncBc.current = bc;
    bc.onmessage = () => onSyncRef.current();
    return () => {
      bc.close();
      syncBc.current = null;
    };
  }, []);

  async function handleCreateChannel(title: string) {
    if (!db) return;
    const tag = await db.tag.findFirst({ where: { name: ':channel:' }, select: { id: true } });
    if (!tag) return;
    const note = await db.note.create({
      data: { title, createdBy: userId },
      select: { id: true },
    });
    await db.noteTag.create({ data: { noteId: note.id, tagId: tag.id, createdBy: userId } });
    await loadChannels();
    setChannelId(note.id);
    setDmId(null);
    setSidebarOpen(false);
    syncBc.current?.postMessage({});
  }

  async function handleCreateDm(userIds: string[]) {
    if (!db) return;
    const tag = await db.tag.findFirst({ where: { name: ':dm:' }, select: { id: true } });
    if (!tag) return;
    const note = await db.note.create({
      data: { body: '', createdBy: userId },
      select: { id: true },
    });
    await db.noteTag.create({ data: { noteId: note.id, tagId: tag.id, createdBy: userId } });
    await db.noteUser.createMany({
      data: [
        { noteId: note.id, userId, createdBy: userId },
        ...userIds.map((id) => ({ noteId: note.id, userId: id, createdBy: userId })),
      ],
    });
    setChannelId(null);
    setSidebarOpen(false);
    await loadDms(note.id);
    syncBc.current?.postMessage({});
  }

  async function handleSend(body: string) {
    if (!db || !activeId) return;
    const note = await db.note.create({
      data: { body, createdBy: userId },
      select: { id: true },
    });
    await db.noteNote.create({
      data: { noteId: note.id, parentId: activeId, createdBy: userId },
    });
    await loadMessages(activeId);
    if (dmId) await loadDms(dmId);
    syncBc.current?.postMessage({});
  }

  async function handleToggleReaction(noteId: string, reactionId: string) {
    if (!db) return;
    const existing = await db.noteReaction.findFirst({
      where: { noteId, reactionId, createdBy: userId },
      select: { id: true, deletedAt: true },
    });
    if (existing) {
      if (!existing.deletedAt) {
        await db.noteReaction.update({
          where: { id: existing.id, createdBy: userId },
          data: { deletedAt: new Date() },
        });
      }
    } else {
      await db.noteReaction.create({ data: { noteId, reactionId, createdBy: userId } });
    }
    await loadReactions(messages.map((m) => m.id));
    syncBc.current?.postMessage({});
  }

  async function handleDeleteMessage(noteId: string) {
    if (!db) return;
    await db.note.delete({ where: { id: noteId } });
    if (activeId) await loadMessages(activeId);
    syncBc.current?.postMessage({});
  }

  async function handleEditMessage(noteId: string, body: string) {
    if (!db) return;
    await db.note.update({ where: { id: noteId }, data: { body } });
    if (activeId) await loadMessages(activeId);
    syncBc.current?.postMessage({});
  }

  function handleUserChange(id: string) {
    const user = users.find((u) => u.id === id);
    if (user) sessionStorage.setItem('chat-username', user.username);
    setUserId(id);
    userIdRef.current = id;
    setChannelId(null);
    setDmId(null);
    setMessages([]);
    setDrafts({});
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
      <AppHeader users={users} userId={userId} onUserChange={handleUserChange} />
      <div className={`app-body${sidebarOpen ? '' : ' channel-open'}`}>
        <Sidebar
          channels={channels}
          channelId={channelId}
          dms={dms}
          dmId={dmId}
          userId={userId}
          users={users}
          onSelectChannel={(id) => {
            setChannelId(id);
            setDmId(null);
            setSidebarOpen(false);
          }}
          onSelectDm={(id) => {
            setDmId(id);
            setChannelId(null);
            setSidebarOpen(false);
          }}
          onCreateChannel={handleCreateChannel}
          onCreateDm={handleCreateDm}
        />
        <ChannelView
          activeId={activeId}
          channelId={channelId}
          dmId={dmId}
          dmTitle={dmTitle}
          channels={channels}
          dms={dms}
          userId={userId}
          messages={messages}
          reactions={reactions}
          allReactions={allReactions}
          draft={activeId ? (drafts[activeId] ?? '') : ''}
          onDraftChange={(value) => activeId && setDrafts((d) => ({ ...d, [activeId]: value }))}
          isMobile={isMobile}
          sidebarOpen={sidebarOpen}
          onBack={() => setSidebarOpen(true)}
          onSend={handleSend}
          onToggleReaction={handleToggleReaction}
          onEditMessage={handleEditMessage}
          onDeleteMessage={handleDeleteMessage}
        />
      </div>
    </div>
  );
}

export default App;
