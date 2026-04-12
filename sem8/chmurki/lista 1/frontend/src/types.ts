export type MediaItem = {
  id: number;
  original_name: string;
  content_type: string;
  size: number;
  created_at: string;
  content_url: string;
};

export type Message = {
  id: number;
  nickname: string;
  text: string;
  created_at: string;
  media: MediaItem | null;
};

export type MessageCreate = {
  nickname?: string;
  text: string;
  media_id?: number;
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
