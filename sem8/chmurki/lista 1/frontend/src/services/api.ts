import type { MediaItem, Message, MessageCreate } from "../types";

const API_URL = import.meta.env.VITE_API_URL ?? "http://localhost:8000";

async function fetchJson<T>(input: RequestInfo, init?: RequestInit): Promise<T> {
  const response = await fetch(input, init);
  if (!response.ok) {
    let message = "Request failed";
    try {
      const data = (await response.json()) as { detail?: string };
      message = data.detail || message;
    } catch {
      const fallback = await response.text();
      if (fallback) {
        message = fallback;
      }
    }
    throw new Error(message);
  }
  return (await response.json()) as T;
}

export async function getMessages(afterId?: number): Promise<Message[]> {
  const params = new URLSearchParams();
  if (afterId !== undefined) {
    params.set("after_id", String(afterId));
  }

  const url = `${API_URL}/api/messages${params.size ? `?${params}` : ""}`;
  return fetchJson<Message[]>(url);
}

export async function postMessage(payload: MessageCreate): Promise<Message> {
  return fetchJson<Message>(`${API_URL}/api/messages`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export async function uploadMedia(file: File): Promise<MediaItem> {
  const formData = new FormData();
  formData.append("file", file);

  return fetchJson<MediaItem>(`${API_URL}/api/media`, {
    method: "POST",
    body: formData,
  });
}

export function mediaContentUrl(relativeUrl: string): string {
  return `${API_URL}${relativeUrl}`;
}
