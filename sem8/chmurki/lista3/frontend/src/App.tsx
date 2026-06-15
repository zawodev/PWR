import { useCallback, useEffect, useMemo, useRef, useState } from "react";

import ChatSidebar from "./components/ChatSidebar";
import ChatWindow from "./components/ChatWindow";
import CreateChatForm from "./components/CreateChatForm";
import LoginForm from "./components/LoginForm";
import MessageForm from "./components/MessageForm";
import { usePolling } from "./hooks/usePolling";
import {
  clearAuthToken,
  createChat,
  getAuthConfig,
  getChatMessages,
  getChats,
  getMe,
  getMyChats,
  getNotifications,
  hasAuthToken,
  joinChat,
  leaveChat,
  login,
  register,
  setAuthToken,
  setStoredUsername,
} from "./services/api";
import type {
  Chat,
  ChatCreate,
  LoginRequest,
  Message,
  NotificationItem,
  RegisterRequest,
} from "./types";

export default function App() {
  // ── Auth state ────────────────────────────────────────────────────
  const [authEnabled, setAuthEnabled] = useState<boolean>(false);
  const [authReady, setAuthReady] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentUser, setCurrentUser] = useState("");
  const [authError, setAuthError] = useState("");
  const [isSigningIn, setIsSigningIn] = useState(false);

  // ── Chat state ────────────────────────────────────────────────────
  const [allChats, setAllChats] = useState<Chat[]>([]);
  const [myChats, setMyChats] = useState<Chat[]>([]);
  const [activeChatId, setActiveChatId] = useState<number | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [error, setError] = useState("");

  // ── Notification state ────────────────────────────────────────────
  const [notifications, setNotifications] = useState<NotificationItem[]>([]);
  const seenNotifications = useRef(new Set<string>());
  const initialNotificationsLoaded = useRef(false);

  const lastMessageId = useMemo(
    () => messages.reduce((max, item) => (item.id > max ? item.id : max), 0),
    [messages]
  );

  const activeChat = useMemo(
    () => allChats.find((c) => c.id === activeChatId) || null,
    [allChats, activeChatId]
  );

  // ── Auth bootstrap ────────────────────────────────────────────────

  const forceLogout = useCallback((message: string) => {
    clearAuthToken();
    setIsAuthenticated(false);
    setCurrentUser("");
    setMessages([]);
    setAuthError(message);
  }, []);

  useEffect(() => {
    let cancelled = false;

    async function bootstrapAuth() {
      try {
        const config = await getAuthConfig();
        if (cancelled) return;

        setAuthEnabled(config.enabled);
        if (!config.enabled) {
          setIsAuthenticated(true);
          setCurrentUser("guest");
          setStoredUsername("guest");
          return;
        }

        if (!hasAuthToken()) {
          setIsAuthenticated(false);
          return;
        }

        const me = await getMe();
        if (cancelled) return;

        setCurrentUser(me.username);
        setStoredUsername(me.username);
        setIsAuthenticated(true);
      } catch {
        if (!cancelled) {
          setAuthEnabled(true);
          setIsAuthenticated(false);
        }
      } finally {
        if (!cancelled) setAuthReady(true);
      }
    }

    bootstrapAuth();
    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (typeof window === "undefined" || !("Notification" in window)) return;
    if (!window.isSecureContext && window.location.hostname !== "localhost") return;
    Notification.requestPermission().catch(() => {});
  }, []);

  // ── Auth handlers ─────────────────────────────────────────────────

  const handleLogin = useCallback(async (payload: LoginRequest) => {
    setIsSigningIn(true);
    setAuthError("");
    try {
      const response = await login(payload);
      setAuthToken(response.access_token);
      setCurrentUser(response.username);
      setStoredUsername(response.username);
      setIsAuthenticated(true);
      setError("");
    } catch (caught) {
      setAuthError(caught instanceof Error ? caught.message : "Login failed");
      setIsAuthenticated(false);
    } finally {
      setIsSigningIn(false);
    }
  }, []);

  const handleRegister = useCallback(async (payload: RegisterRequest) => {
    setIsSigningIn(true);
    setAuthError("");
    try {
      const response = await register(payload);
      setAuthToken(response.access_token);
      setCurrentUser(response.username);
      setStoredUsername(response.username);
      setIsAuthenticated(true);
      setError("");
    } catch (caught) {
      setAuthError(caught instanceof Error ? caught.message : "Registration failed");
      setIsAuthenticated(false);
    } finally {
      setIsSigningIn(false);
    }
  }, []);

  const handleLogout = useCallback(() => {
    forceLogout("");
  }, [forceLogout]);

  // ── Chat list polling ─────────────────────────────────────────────

  const loadChats = useCallback(async () => {
    if (!authReady || (authEnabled && !isAuthenticated)) return;
    try {
      const [all, mine] = await Promise.all([getChats(), getMyChats()]);
      setAllChats(all);
      setMyChats(mine);

      // Auto-select first of my chats if nothing selected
      if (activeChatId === null && mine.length > 0) {
        setActiveChatId(mine[0].id);
      }
    } catch {
      // ignore – will retry
    }
  }, [authReady, authEnabled, isAuthenticated, activeChatId]);

  usePolling(loadChats, 5000);

  // ── Message polling (active chat only) ────────────────────────────

  const loadNewMessages = useCallback(async () => {
    if (!authReady || (authEnabled && !isAuthenticated)) return;
    if (activeChatId === null) return;

    try {
      const fresh = await getChatMessages(activeChatId, lastMessageId > 0 ? lastMessageId : undefined);
      if (fresh.length === 0) return;

      setMessages((prev) => {
        const next = [...prev, ...fresh];
        const unique = new Map<number, Message>();
        for (const msg of next) {
          unique.set(msg.id, msg);
        }
        return Array.from(unique.values()).sort((a, b) => a.id - b.id);
      });
      setError("");
    } catch (caught) {
      const message = caught instanceof Error ? caught.message : "Failed to fetch messages";
      const normalized = message.toLowerCase();
      if (
        normalized.includes("not authenticated") ||
        normalized.includes("token") ||
        normalized.includes("unauthorized")
      ) {
        forceLogout("Session expired. Sign in again.");
        return;
      }
      setError(message);
    }
  }, [authEnabled, authReady, forceLogout, isAuthenticated, activeChatId, lastMessageId]);

  usePolling(loadNewMessages, 2500);

  // Reset messages when switching chats
  useEffect(() => {
    setMessages([]);
  }, [activeChatId]);

  // ── Notification polling ──────────────────────────────────────────

  const showSystemNotification = useCallback((item: NotificationItem) => {
    if (typeof window === "undefined" || !("Notification" in window)) return;
    if (Notification.permission !== "granted") return;
    new Notification(item.title, { body: item.message, tag: item.id });
  }, []);

  const loadNotifications = useCallback(async () => {
    if (!authReady || (authEnabled && !isAuthenticated)) return;

    try {
      const items = await getNotifications(10);
      if (!items.length) return;

      if (!initialNotificationsLoaded.current) {
        items.forEach((item) => seenNotifications.current.add(item.id));
        setNotifications(items);
        initialNotificationsLoaded.current = true;
        return;
      }

      const fresh = items.filter((item) => !seenNotifications.current.has(item.id));
      if (!fresh.length) return;

      fresh
        .slice()
        .reverse()
        .forEach((item) => showSystemNotification(item));

      setNotifications((prev) => [...fresh, ...prev].slice(0, 15));
      fresh.forEach((item) => seenNotifications.current.add(item.id));
    } catch {
      return;
    }
  }, [authEnabled, authReady, isAuthenticated, showSystemNotification]);

  usePolling(loadNotifications, 4000);

  // ── Chat actions ──────────────────────────────────────────────────

  const handleCreateChat = useCallback(
    async (payload: ChatCreate) => {
      const chat = await createChat(payload);
      setAllChats((prev) => [...prev, chat]);
      setMyChats((prev) => [...prev, chat]);
      setActiveChatId(chat.id);
      setMessages([]);
    },
    []
  );

  const handleJoinChat = useCallback(
    async (chatId: number) => {
      await joinChat(chatId);
      const chat = allChats.find((c) => c.id === chatId);
      if (chat) {
        setMyChats((prev) => (prev.some((c) => c.id === chatId) ? prev : [...prev, chat]));
      }
      setActiveChatId(chatId);
      setMessages([]);
    },
    [allChats]
  );

  const handleLeaveChat = useCallback(
    async (chatId: number) => {
      await leaveChat(chatId);
      setMyChats((prev) => prev.filter((c) => c.id !== chatId));
      if (activeChatId === chatId) {
        setActiveChatId(null);
        setMessages([]);
      }
    },
    [activeChatId]
  );

  const handleSelectChat = useCallback((chatId: number) => {
    setActiveChatId(chatId);
    setMessages([]);
  }, []);

  // ── Render ────────────────────────────────────────────────────────

  if (!authReady) {
    return (
      <main className="app-shell">
        <p>Loading...</p>
      </main>
    );
  }

  if (authEnabled && !isAuthenticated) {
    return (
      <main className="app-shell auth-shell">
        <header>
          <h1>Discord 3.0</h1>
          <p>Zaloguj się aby kontynuować :)</p>
        </header>
        <LoginForm
          onLogin={handleLogin}
          onRegister={handleRegister}
          isLoading={isSigningIn}
          error={authError}
        />
      </main>
    );
  }

  return (
    <main className="app-shell">
      <header>
        <h1>Discord 3.0</h1>
        <p>
          "Wowies! Teraz to już naprawdę REWOLUCJA! Nigdy nie pisałem ĄŻ tylu wiadomości! Ta
          aplikacja to absolutny przełom!" - Elon Bezos, CEO &amp; CTO at Discord 2.0 and Discord
          3.0
        </p>
        {authEnabled ? (
          <div className="auth-topbar">
            <span>Zalogowany jako: {currentUser}</span>
            <button type="button" onClick={handleLogout}>
              Wyloguj się
            </button>
          </div>
        ) : null}
      </header>

      {error ? <p className="error">{error}</p> : null}

      {notifications.length ? (
        <section className="notifications-panel">
          <h2>Powiadomienia</h2>
          <div className="notifications-list">
            {notifications.map((item) => (
              <article className="notification-item" key={item.id}>
                <div className="notification-top">
                  <strong>{item.title}</strong>
                  <span>{new Date(item.created_at).toLocaleTimeString()}</span>
                </div>
                <p className="notification-message">{item.message}</p>
              </article>
            ))}
          </div>
        </section>
      ) : null}

      <div className="main-layout">
        <div className="sidebar-container">
          <CreateChatForm onCreate={handleCreateChat} />
          <ChatSidebar
            chats={allChats}
            myChats={myChats}
            activeChatId={activeChatId}
            onSelect={handleSelectChat}
            onJoin={handleJoinChat}
            onLeave={handleLeaveChat}
          />
        </div>

        <section className="chat-layout">
          {activeChat ? (
            <>
              <div className="chat-pane">
                <h2>#{activeChat.slug} – {activeChat.name}</h2>
                <ChatWindow messages={messages} />
              </div>

              <div className="composer-pane">
                <h2>Nowa wiadomość</h2>
                <MessageForm
                  chatId={activeChat.id}
                  username={currentUser}
                  onMessageCreated={(msg) => setMessages((prev) => [...prev, msg])}
                />
              </div>
            </>
          ) : (
            <div className="chat-pane">
              <h2>Wybierz czat</h2>
              <p className="chat-empty-hint">
                Wybierz czat z listy po lewej lub utwórz nowy.
              </p>
            </div>
          )}
        </section>
      </div>
    </main>
  );
}
