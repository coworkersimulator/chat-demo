import { sql } from 'kysely';
import { useEffect, useState } from 'react';
import './App.css';
import db from './db';

interface User {
  id: string;
  username: string;
  name: string | null;
}

function App() {
  const [users, setUsers] = useState<User[]>([]);
  const [userId, setUserId] = useState('');

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

  async function handleUserChange(id: string) {
    setUserId(id);
    await sql`SET LOCAL app.user_id = ${sql.lit(id)}`.execute(db);
  }

  return (
    <select value={userId} onChange={(e) => handleUserChange(e.target.value)}>
      {users.map((u) => (
        <option key={u.id} value={u.id}>
          {u.name ? `${u.name} (${u.username})` : u.username}
        </option>
      ))}
    </select>
  );
}

export default App;
