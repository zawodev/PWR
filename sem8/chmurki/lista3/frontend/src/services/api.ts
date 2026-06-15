import type {
  AuthConfig,
  AuthUser,
  Chat,
  ChatCreate,
  ChatMember,
  LoginRequest,
  LoginResponse,
  MediaItem,
  Message,
  MessageCreate,
  NotificationItem,
  RegisterRequest,
} from "../types";

/**
 * VITE_API_URL   → ALB (auth, media, notifications)
 * VITE_CHAT_API_URL → API Gateway (chats, messages, Lambda)
 *
 * When both are the same (e.g. local dev behind a single proxy) this still
 * works — the split only matters in production where chat traffic goes
 * through API Gateway while other services stay behind the ALB.
 */
const API_URL = (import.meta.env.VITE_API_URL || "http://localhost:8000").replace(/\/$/, "");
const CHAT_API_URL = (import.meta.env.VITE_CHAT_API_URL || API_URL).replace(/\/$/, "");
const ACCESS_TOKEN_KEY = "chat_access_token";

function getToken(): string | null {
  return localStorage.getItem(ACCESS_TOKEN_KEY);
}

function buildHeaders(init?: RequestInit, includeAuth = true): Headers {
  const headers = new Headers(init?.headers);
  if (includeAuth) {
    const token = getToken();
    if (token) {
      headers.set("Authorization", `Bearer ${token}`);
    }
  }
  return headers;
}

function getUsername(): string {
  // Store username alongside token so Lambda can identify the caller
  return localStorage.getItem("chat_username") || "guest";
}

async function fetchJson<T>(input: RequestInfo, init?: RequestInit, includeAuth = true): Promise<T> {
  const headers = buildHeaders(init, includeAuth);

  // Always send x-username so the Lambda handler can identify the user
  if (!headers.has("x-username")) {
    headers.set("x-username", getUsername());
  }

  const response = await fetch(input, {
    ...init,
    headers,
  });
  if (!response.ok) {
    let message = "Request failed";
    try {
      const data = (await response.json()) as { detail?: unknown; message?: unknown };
      if (typeof data.detail === "string") {
        message = data.detail;
      } else if (Array.isArray(data.detail)) {
        const details = data.detail
          .map((item) => {
            if (typeof item === "string") {
              return item;
            }
            if (item && typeof item === "object" && "msg" in item) {
              const msg = (item as { msg?: unknown }).msg;
              return typeof msg === "string" ? msg : "Invalid input";
            }
            return "Invalid input";
          })
          .filter(Boolean);
        message = details.length ? details.join("; ") : message;
      } else if (data.detail && typeof data.detail === "object") {
        message = JSON.stringify(data.detail);
      } else if (typeof data.message === "string") {
        message = data.message;
      }
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

// ── Auth ──────────────────────────────────────────────────────────────

export function hasAuthToken(): boolean {
  return Boolean(getToken());
}

export function setAuthToken(token: string): void {
  localStorage.setItem(ACCESS_TOKEN_KEY, token);
}

export function clearAuthToken(): void {
  localStorage.removeItem(ACCESS_TOKEN_KEY);
  localStorage.removeItem("chat_username");
}

export function setStoredUsername(name: string): void {
  localStorage.setItem("chat_username", name);
}

export async function getAuthConfig(): Promise<AuthConfig> {
  return fetchJson<AuthConfig>(`${API_URL}/api/auth/config`, undefined, false);
}

export async function login(payload: LoginRequest): Promise<LoginResponse> {
  return fetchJson<LoginResponse>(
    `${API_URL}/api/auth/login`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    },
    false
  );
}

export async function register(payload: RegisterRequest): Promise<LoginResponse> {
  return fetchJson<LoginResponse>(
    `${API_URL}/api/auth/register`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    },
    false
  );
}

export async function getMe(): Promise<AuthUser> {
  return fetchJson<AuthUser>(`${API_URL}/api/auth/me`);
}

// ── Chats (API Gateway / Lambda) ─────────────────────────────────────

export async function getChats(): Promise<Chat[]> {
  return fetchJson<Chat[]>(`${CHAT_API_URL}/api/chats`);
}

export async function createChat(payload: ChatCreate): Promise<Chat> {
  return fetchJson<Chat>(`${CHAT_API_URL}/api/chats`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export async function getChat(chatId: number): Promise<Chat> {
  return fetchJson<Chat>(`${CHAT_API_URL}/api/chats/${chatId}`);
}

export async function getMyChats(): Promise<Chat[]> {
  return fetchJson<Chat[]>(`${CHAT_API_URL}/api/chats/my`);
}

export async function joinChat(chatId: number): Promise<void> {
  await fetchJson(`${CHAT_API_URL}/api/chats/${chatId}/join`, { method: "POST" });
}

export async function leaveChat(chatId: number): Promise<void> {
  await fetchJson(`${CHAT_API_URL}/api/chats/${chatId}/leave`, { method: "POST" });
}

export async function getChatMembers(chatId: number): Promise<ChatMember[]> {
  return fetchJson<ChatMember[]>(`${CHAT_API_URL}/api/chats/${chatId}/members`);
}

// ── Messages (API Gateway / Lambda) ──────────────────────────────────

export async function getChatMessages(chatId: number, afterId?: number): Promise<Message[]> {
  const params = new URLSearchParams();
  if (afterId !== undefined) {
    params.set("after_id", String(afterId));
  }
  const qs = params.size ? `?${params}` : "";
  return fetchJson<Message[]>(`${CHAT_API_URL}/api/chats/${chatId}/messages${qs}`);
}

export async function postChatMessage(chatId: number, payload: MessageCreate): Promise<Message> {
  return fetchJson<Message>(`${CHAT_API_URL}/api/chats/${chatId}/messages`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

/** Legacy – default (global) chat messages */
export async function getMessages(afterId?: number): Promise<Message[]> {
  const params = new URLSearchParams();
  if (afterId !== undefined) {
    params.set("after_id", String(afterId));
  }
  const qs = params.size ? `?${params}` : "";
  return fetchJson<Message[]>(`${CHAT_API_URL}/api/messages${qs}`);
}

export async function postMessage(payload: MessageCreate): Promise<Message> {
  return fetchJson<Message>(`${CHAT_API_URL}/api/messages`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

// ── Notifications ────────────────────────────────────────────────────

export async function getNotifications(limit = 25): Promise<NotificationItem[]> {
  const params = new URLSearchParams();
  params.set("limit", String(limit));
  return fetchJson<NotificationItem[]>(`${API_URL}/api/notifications?${params.toString()}`);
}

// ── Media ────────────────────────────────────────────────────────────

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
