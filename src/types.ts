export interface User {
  id: string;
  username: string;
  name: string | null;
}

export interface Channel {
  id: string;
  title: string | null;
}

export interface Dm {
  noteId: string;
  userId: string;
  username: string;
  userName: string | null;
  lastAt: Date;
}

export interface Message {
  id: string;
  body: string | null;
  createdAt: Date;
  authorId: string;
  username: string;
  userName: string | null;
  isEdited: boolean;
}
