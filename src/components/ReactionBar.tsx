import { useCallback, useState } from 'react';
import { ReactionPicker } from './ReactionPicker';

export function ReactionBar({
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
