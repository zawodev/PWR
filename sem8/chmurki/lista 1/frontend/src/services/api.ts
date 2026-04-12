import type {
  AuthConfig,
  AuthUser,
  LoginRequest,
  LoginResponse,
  MediaItem,
  Message,
  MessageCreate,
  RegisterRequest,
} from "../types";

const API_URL = import.meta.env.VITE_API_URL ?? "http://localhost:8000";
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

async function fetchJson<T>(input: RequestInfo, init?: RequestInit, includeAuth = true): Promise<T> {
  const response = await fetch(input, {
    ...init,
    headers: buildHeaders(init, includeAuth),
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

export function hasAuthToken(): boolean {
  return Boolean(getToken());
}

export function setAuthToken(token: string): void {
  localStorage.setItem(ACCESS_TOKEN_KEY, token);
}

export function clearAuthToken(): void {
  localStorage.removeItem(ACCESS_TOKEN_KEY);
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
