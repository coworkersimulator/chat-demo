import multiavatar from '@multiavatar/multiavatar';
import { Fragment, useEffect, useRef, useState } from 'react';
import { formatAt, formatDivider, isSameDay } from '../lib/format';
import type { Channel, Dm, Message } from '../types';
import { ReactionBar } from './ReactionBar';

export function ChannelView({
  activeId,
  channelId,
  dmId,
  dmTitle,
  channels,
  dms,
  messages,
  reactions,
  allReactions,
  isMobile,
  sidebarOpen,
  onBack,
  onSend,
  onToggleReaction,
}: {
  activeId: string | null;
  channelId: string | null;
  dmId: string | null;
  dmTitle: string;
  channels: Channel[];
  dms: Record<string, Dm[]>;
  messages: Message[];
  reactions: Record<string, { emoji: string; count: number; mine: boolean }[]>;
  allReactions: { id: string; emoji: string; name: string }[];
  isMobile: boolean;
  sidebarOpen: boolean;
  onBack: () => void;
  onSend: (body: string) => Promise<void>;
  onToggleReaction: (noteId: string, reactionId: string) => Promise<void>;
}) {
  const [pickerFor, setPickerFor] = useState<string | null>(null);
  const [activeMsg, setActiveMsg] = useState<string | null>(null);
  const [draft, setDraft] = useState('');
  const messagesRef = useRef<HTMLDivElement>(null);
  const messageInputRef = useRef<HTMLTextAreaElement>(null);

  useEffect(() => {
    if (messagesRef.current) {
      messagesRef.current.scrollTop = messagesRef.current.scrollHeight;
    }
  }, [messages, sidebarOpen]);

  useEffect(() => {
    if (pickerFor === null) setActiveMsg(null);
  }, [pickerFor]);

  async function handleSend() {
    if (!draft.trim() || !activeId) return;
    const body = draft.trim();
    setDraft('');
    messageInputRef.current?.focus();
    await onSend(body);
  }

  async function handleToggleReaction(noteId: string, reactionId: string, _emoji: string) {
    setActiveMsg(null);
    await onToggleReaction(noteId, reactionId);
    setPickerFor(null);
  }

  if (isMobile && sidebarOpen) return null;

  const placeholder = (() => {
    const text = channelId
      ? `Message #${channels.find((t) => t.id === channelId)?.title ?? ''}`
      : dmTitle
        ? `Message ${dmTitle}`
        : 'Message';
    return text.length > 50 ? text.slice(0, 47) + '…' : text;
  })();

  return (
    <div className="channel">
      {!activeId ? (
        <div className="empty-state">
          <div className="empty-state-title">Chat Demo</div>
          <div className="empty-state-body">
            Select a channel or direct message to start chatting.
          </div>
        </div>
      ) : (
        <>
          <div className="channel-header">
            <button className="channel-back-btn" onClick={onBack}>
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
            {channelId && (
              <div className="channel-header-text">
                <span className="channel-title">
                  # {channels.find((t) => t.id === channelId)?.title}
                </span>
                <span className="channel-subtitle">Channel</span>
              </div>
            )}
          </div>
          <div className="messages" ref={messagesRef}>
            {messages.map((m, i) => {
              const name = m.userName ?? m.username;
              const prev = messages[i - 1];
              const at = new Date(m.createdAt);
              const showDivider = !prev || !isSameDay(new Date(prev.createdAt), at);
              const isContinuation =
                !showDivider &&
                prev &&
                prev.authorId === m.authorId &&
                at.getTime() - new Date(prev.createdAt).getTime() < 5 * 60 * 1000;
              const reactionBar = (
                <ReactionBar
                  noteId={m.id}
                  reactions={reactions[m.id] ?? []}
                  allReactions={allReactions}
                  pickerFor={pickerFor}
                  setPickerFor={setPickerFor}
                  onToggle={handleToggleReaction}
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
                      <div className="message-continuation-time">{formatAt(at)}</div>
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
                          <span className="message-time">{formatAt(at)}</span>
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
                ref={messageInputRef}
                className="message-input"
                value={draft}
                onChange={(e) => setDraft(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    void handleSend();
                  }
                }}
                placeholder={placeholder}
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
  );
}
