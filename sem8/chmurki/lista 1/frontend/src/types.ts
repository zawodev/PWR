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
  nickname: string;
  text: string;
  media_id?: number;
};
