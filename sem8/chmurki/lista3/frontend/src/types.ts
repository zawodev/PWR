export type MediaItem = {
  id: string;
  original_name: string;
  content_type: string;
  size: number;
  created_at: string;
  content_url: string;
};

export type Message = {
  id: number;
  chat_id: number;
  nickname: string;
  text: string;
  created_at: string;
  media: MediaItem | null;
  media_id?: string | null;
};

export type MessageCreate = {
  nickname?: string;
  text: string;
  media_id?: string;
};

export type Chat = {
  id: number;
  name: string;
  slug: string;
  created_by?: string | null;
  created_at: string;
};

export type ChatCreate = {
  name: string;
  slug?: string;
};

export type ChatMember = {
  username: string;
  joined_at: string;
};

export type AuthConfig = {
  enabled: boolean;
};

export type LoginRequest = {
  username: string;
  password: string;
};

export type RegisterRequest = {
  username: string;
  password: string;
};

export type LoginResponse = {
  access_token: string;
  refresh_token?: string;
  id_token?: string;
  token_type: string;
  expires_in: number;
  username: string;
};

export type AuthUser = {
  username: string;
};

export type NotificationItem = {
  id: string;
  title: string;
  message: string;
  created_at: string;
  chat_id?: number | null;
  sender?: string | null;
  recipient?: string | null;
  status: string;
};
