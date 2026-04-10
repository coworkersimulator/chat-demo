import { useState } from 'react';
import type { Channel, Dm, User } from '../types';

export function Sidebar({
  channels,
  channelId,
  dms,
  dmId,
  userId,
  users,
  onSelectChannel,
  onSelectDm,
  onCreateChannel,
  onCreateDm,
}: {
  channels: Channel[];
  channelId: string | null;
  dms: Record<string, Dm[]>;
  dmId: string | null;
  userId: string;
  users: User[];
  onSelectChannel: (id: string) => void;
  onSelectDm: (id: string) => void;
  onCreateChannel: (title: string) => Promise<void>;
  onCreateDm: (userIds: string[]) => Promise<void>;
}) {
  const [newChannel, setNewChannel] = useState(false);
  const [newChannelTitle, setNewChannelTitle] = useState('');
  const [newDm, setNewDm] = useState(false);
  const [newDmSelected, setNewDmSelected] = useState<string[]>([]);
  const [newDmQuery, setNewDmQuery] = useState('');

  async function handleCreateChannel() {
    if (!newChannelTitle.trim()) return;
    await onCreateChannel(newChannelTitle.trim());
    setNewChannel(false);
    setNewChannelTitle('');
  }

  async function handleCreateDm() {
    if (newDmSelected.length === 0) return;
    await onCreateDm(newDmSelected);
    setNewDm(false);
    setNewDmSelected([]);
  }

  return (
    <div className={`sidebar${newDm ? ' dm-composing' : ''}`}>
      <div className="sidebar-section">
        <div className="sidebar-section-header">
          Channels
          <button
            className="sidebar-new-btn"
            onClick={() => setNewChannel((v) => !v)}
          >
            +
          </button>
        </div>
        {newChannel && (
          <div className="sidebar-new-channel">
            <input
              className="sidebar-new-channel-input"
              value={newChannelTitle}
              onChange={(e) => setNewChannelTitle(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') void handleCreateChannel();
                if (e.key === 'Escape') {
                  setNewChannel(false);
                  setNewChannelTitle('');
                }
              }}
              placeholder="Channel name"
              autoFocus
            />
            <button
              className={`dm-start-btn ${newChannelTitle.trim() ? 'dm-start-btn-active' : ''}`}
              disabled={!newChannelTitle.trim()}
              onClick={() => void handleCreateChannel()}
            >
              Create
            </button>
          </div>
        )}
        <ul className="sidebar-list">
          {channels.map((t) => (
            <li
              key={t.id}
              onClick={() => onSelectChannel(t.id)}
              className={t.id === channelId ? 'active' : undefined}
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
                          setNewDmSelected((prev) => prev.filter((x) => x !== id))
                        }
                      >
                        ×
                      </button>
                    </span>
                  );
                })}
                <input
                  className="dm-composer-input"
                  placeholder={newDmSelected.length === 0 ? 'Search people' : ''}
                  value={newDmQuery}
                  onChange={(e) => setNewDmQuery(e.target.value)}
                  autoFocus
                />
              </div>
            </div>
            <ul className="sidebar-list dm-suggestions">
              {users
                .filter((u) => u.id !== userId && !newDmSelected.includes(u.id))
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
              onClick={() => void handleCreateDm()}
            >
              Open
            </button>
          </div>
        )}
        <ul className={`sidebar-list${newDm ? ' dm-list-hidden' : ''}`}>
          {Object.entries(dms).map(([noteId, rows]) => (
            <li
              key={noteId}
              onClick={() => onSelectDm(noteId)}
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
  );
}
