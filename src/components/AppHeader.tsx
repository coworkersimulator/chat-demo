import { useEffect, useRef, useState } from 'react';
import type { User } from '../types';

const githubSvg = '/chat-demo/github.svg';

export function AppHeader({
  users,
  userId,
  onUserChange,
}: {
  users: User[];
  userId: string;
  onUserChange: (id: string) => void;
}) {
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!dropdownOpen) return;
    const handler = (e: MouseEvent) => {
      if (!dropdownRef.current?.contains(e.target as Node))
        setDropdownOpen(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, [dropdownOpen]);

  const currentUser = users.find((u) => u.id === userId);

  return (
    <div className="app-header">
      <a
        className="app-header-github"
        href="https://github.com/coworkersimulator/chat-demo"
        target="_blank"
        rel="noopener noreferrer"
      >
        <img src={githubSvg} width={14} height={14} alt="" aria-hidden="true" />
        <span className="app-header-github-label">View Source</span>
      </a>
      <span className="app-title">Chat Demo</span>
      <div className="app-header-right">
        <div className="switch-user-wrapper" ref={dropdownRef}>
          <button
            className="switch-user-label"
            onClick={() => setDropdownOpen((v) => !v)}
          >
            Switch user:{' '}
            <span className="switch-user-current">
              {currentUser?.name ?? currentUser?.username}
            </span>
          </button>
          {dropdownOpen && (
            <div className="switch-user-dropdown">
              {users.map((u) => (
                <div
                  key={u.id}
                  className={`switch-user-option${u.id === userId ? ' active' : ''}`}
                  onClick={() => {
                    onUserChange(u.id);
                    setDropdownOpen(false);
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
  );
}
