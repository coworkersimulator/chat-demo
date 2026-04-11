import multiavatar from '@multiavatar/multiavatar';
import { Fragment, useCallback, useEffect, useRef, useState } from 'react';
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
  userId,
  messages,
  reactions,
  allReactions,
  draft,
  onDraftChange,
  isMobile,
  sidebarOpen,
  onBack,
  onSend,
  onToggleReaction,
  onEditMessage,
  onDeleteMessage,
}: {
  activeId: string | null;
  channelId: string | null;
  dmId: string | null;
  dmTitle: string;
  channels: Channel[];
  dms: Record<string, Dm[]>;
  userId: string;
  messages: Message[];
  reactions: Record<string, { emoji: string; count: number; mine: boolean }[]>;
  allReactions: { id: string; emoji: string; name: string }[];
  draft: string;
  onDraftChange: (value: string) => void;
  isMobile: boolean;
  sidebarOpen: boolean;
  onBack: () => void;
  onSend: (body: string) => Promise<void>;
  onToggleReaction: (noteId: string, reactionId: string) => Promise<void>;
  onEditMessage: (noteId: string, body: string) => Promise<void>;
  onDeleteMessage: (noteId: string) => Promise<void>;
}) {
  const [pickerFor, setPickerFor] = useState<string | null>(null);
  const [activeMsg, setActiveMsg] = useState<string | null>(null);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editingText, setEditingText] = useState('');
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const messagesRef = useRef<HTMLDivElement>(null);
  const messageInputRef = useRef<HTMLTextAreaElement>(null);
  // Stable ref callback: fires only when the textarea mounts/unmounts, not on
  // every re-render, so it won't steal focus back while the user types a draft.
  const editInputRef = useCallback((el: HTMLTextAreaElement | null) => {
    if (el) el.focus();
  }, []);

  useEffect(() => {
    if (messagesRef.current) {
      messagesRef.current.scrollTop = messagesRef.current.scrollHeight;
    }
  }, [messages, sidebarOpen]);

  useEffect(() => {
    if (!editingId || !messagesRef.current) return;
    const el = messagesRef.current.querySelector(`[data-message-id="${editingId}"]`);
    el?.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
  }, [editingId]);

  function handleSetPickerFor(id: string | null) {
    setPickerFor(id);
    if (id === null) setActiveMsg(null);
  }

  async function handleConfirmDelete(noteId: string) {
    setDeletingId(null);
    setActiveMsg(null);
    await onDeleteMessage(noteId);
  }

  async function handleSaveEdit() {
    if (!editingId || !editingText.trim()) return;
    await onEditMessage(editingId, editingText.trim());
    setEditingId(null);
    setEditingText('');
    setActiveMsg(null);
  }

  async function handleSend() {
    if (!draft.trim() || !activeId) return;
    const body = draft.trim();
    onDraftChange('');
    messageInputRef.current?.focus();
    await onSend(body);
  }

  async function handleToggleReaction(noteId: string, reactionId: string) {
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
              const isEditing = editingId === m.id;
              const isOwn = m.authorId === userId;
              const isDeleted = m.body === null;
              const reactionBar = !isDeleted ? (
                <ReactionBar
                  noteId={m.id}
                  reactions={reactions[m.id] ?? []}
                  allReactions={allReactions}
                  pickerFor={pickerFor}
                  setPickerFor={handleSetPickerFor}
                  onToggle={handleToggleReaction}
                />
              ) : null;
              const bodyEl = isEditing ? (
                <p className="message-body message-body-editing">{m.body}</p>
              ) : isDeleted ? (
                <p className="message-body message-deleted"><em>This message was deleted.</em></p>
              ) : (
                <p className="message-body">
                  {m.body}
                  {m.isEdited && <span className="message-edited-label"> (edited)</span>}
                </p>
              );
              const messageTools = isOwn && !isEditing && !isDeleted ? (
                <div className="message-actions" onClick={(e) => e.stopPropagation()}>
                  <button
                    className="message-edit-btn"
                    onClick={() => { setEditingId(m.id); setEditingText(m.body ?? ''); setActiveMsg(m.id); }}
                  >
                    ✏
                  </button>
                  {deletingId === m.id ? (
                    <>
                      <span className="message-delete-confirm-label">Delete?</span>
                      <button className="message-delete-yes-btn" onClick={() => void handleConfirmDelete(m.id)}>Yes</button>
                      <button className="message-delete-no-btn" onClick={() => setDeletingId(null)}>No</button>
                    </>
                  ) : (
                    <button
                      className="message-delete-btn"
                      onClick={() => { setDeletingId(m.id); setActiveMsg(m.id); }}
                    >
                      🗑
                    </button>
                  )}
                </div>
              ) : null;
              return (
                <Fragment key={m.id}>
                  {showDivider && (
                    <div className="date-divider">
                      <span>{formatDivider(at)}</span>
                    </div>
                  )}
                  {isContinuation ? (
                    <div
                      data-message-id={m.id}
                      className={`message message-continuation${activeMsg === m.id ? ' message-active' : ''}`}
                      onClick={() => setActiveMsg(activeMsg === m.id ? null : m.id)}
                    >
                      <div className="message-continuation-time">{formatAt(at)}</div>
                      {bodyEl}
                      {reactionBar}
                      {messageTools}
                    </div>
                  ) : (
                    <div
                      data-message-id={m.id}
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
                        {bodyEl}
                        {reactionBar}
                      </div>
                      {messageTools}
                    </div>
                  )}
                </Fragment>
              );
            })}
          </div>
          <div className="message-entry">
            {editingId ? (
              <>
                <div className="message-edit-context">
                  <span className="message-edit-context-label">✏ Editing message</span>
                  <button
                    className="message-edit-cancel-btn"
                    onClick={() => { setEditingId(null); setEditingText(''); setActiveMsg(null); }}
                  >
                    Cancel
                  </button>
                </div>
                <div className="message-entry-box">
                  <textarea
                    ref={editInputRef}
                    className="message-input"
                    value={editingText}
                    rows={1}
                    onChange={(e) => setEditingText(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); void handleSaveEdit(); }
                      if (e.key === 'Escape') { setEditingId(null); setEditingText(''); setActiveMsg(null); }
                    }}
                  />
                  <div className="message-entry-toolbar">
                    <button
                      className={`send-button ${editingText.trim() ? 'send-button-active' : ''}`}
                      disabled={!editingText.trim()}
                      onClick={() => void handleSaveEdit()}
                    >
                      &#10003;
                    </button>
                  </div>
                </div>
              </>
            ) : (
              <div className="message-entry-box">
                <textarea
                  ref={messageInputRef}
                  className="message-input"
                  value={draft}
                  onChange={(e) => onDraftChange(e.target.value)}
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
            )}
          </div>
        </>
      )}
    </div>
  );
}
