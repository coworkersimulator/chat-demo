import { useEffect, useLayoutEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';

export function ReactionPicker({
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
    // Don't auto-focus on touch devices — it reopens the keyboard over the picker
    if (window.matchMedia('(hover: hover)').matches) {
      inputRef.current?.focus();
    }
  }, []);

  useLayoutEffect(() => {
    if (!anchor || !pickerRef.current) return;
    const el = pickerRef.current;
    const btn = anchor.getBoundingClientRect();
    const pw = el.offsetWidth;
    const ph = el.offsetHeight;
    const vv = window.visualViewport;
    const vw = window.innerWidth;
    // Use visual viewport bounds so the picker stays above the keyboard on iOS
    const visTop = vv ? vv.offsetTop : 0;
    const visBottom = vv ? vv.offsetTop + vv.height : window.innerHeight;
    let top = btn.top - ph - 6;
    if (top < visTop + 8) top = btn.bottom + 6;
    if (top + ph > visBottom - 8) top = visBottom - ph - 8;
    if (top < visTop + 8) top = visTop + 8;
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
