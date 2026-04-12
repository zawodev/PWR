import { useCallback, useEffect, useMemo, useState } from "react";

import ChatWindow from "./components/ChatWindow";
import LoginForm from "./components/LoginForm";
import MessageForm from "./components/MessageForm";
import { usePolling } from "./hooks/usePolling";
import { clearAuthToken, getAuthConfig, getMe, getMessages, hasAuthToken, login, register, setAuthToken } from "./services/api";
import type { LoginRequest, Message, RegisterRequest } from "./types";

export default function App() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [error, setError] = useState("");
  const [authEnabled, setAuthEnabled] = useState<boolean>(false);
  const [authReady, setAuthReady] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentUser, setCurrentUser] = useState("");
  const [authError, setAuthError] = useState("");
  const [isSigningIn, setIsSigningIn] = useState(false);

  const lastMessageId = useMemo(
    () => messages.reduce((max, item) => (item.id > max ? item.id : max), 0),
    [messages]
  );

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
        if (cancelled) {
          return;
        }

        setAuthEnabled(config.enabled);
        if (!config.enabled) {
          setIsAuthenticated(true);
          setCurrentUser("guest");
          return;
        }

        if (!hasAuthToken()) {
          setIsAuthenticated(false);
          return;
        }

        const me = await getMe();
        if (cancelled) {
          return;
        }

        setCurrentUser(me.username);
        setIsAuthenticated(true);
      } catch {
        if (!cancelled) {
          setAuthEnabled(true);
          setIsAuthenticated(false);
        }
      } finally {
        if (!cancelled) {
          setAuthReady(true);
        }
      }
    }

    bootstrapAuth();
    return () => {
      cancelled = true;
    };
  }, []);

  const handleLogin = useCallback(async (payload: LoginRequest) => {
    setIsSigningIn(true);
    setAuthError("");
    try {
      const response = await login(payload);
      setAuthToken(response.access_token);
      setCurrentUser(response.username);
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

  const loadNewMessages = useCallback(async () => {
    if (!authReady) {
      return;
    }

    if (authEnabled && !isAuthenticated) {
      return;
    }

    try {
      const fresh = await getMessages(lastMessageId > 0 ? lastMessageId : undefined);
      if (fresh.length === 0) {
        return;
      }

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
      if (normalized.includes("not authenticated") || normalized.includes("token") || normalized.includes("unauthorized")) {
        forceLogout("Session expired. Sign in again.");
        return;
      }
      setError(message);
    }
  }, [authEnabled, authReady, forceLogout, isAuthenticated, lastMessageId]);

  usePolling(loadNewMessages, 2500);

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
          <h1>Discord 2.0</h1>
          <p>Zaloguj się passami innymi niż: test/TestPass123 oraz demo_user/DemoPass123 - ci użytkownicy są już zajęci</p>
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
        <h1>Discord 2.0</h1>
        <p>"Wow! Nigdy nie pisałem tylu wiadomości! Ta aplikacja to rewolucja!" - Elon Bezos, CEO & CTO at Discord 2.0</p>
        {authEnabled ? (
          <div className="auth-topbar">
            <span>Signed in as: {currentUser}</span>
            <button type="button" onClick={handleLogout}>Sign out</button>
          </div>
        ) : null}
      </header>

      {error ? <p className="error">{error}</p> : null}

      <section className="chat-layout">
        <div className="chat-pane">
          <h2>Chat history</h2>
          <ChatWindow messages={messages} />
        </div>

        <div className="composer-pane">
          <h2>New message</h2>
          <MessageForm
            username={currentUser}
            onMessageCreated={(msg) => setMessages((prev) => [...prev, msg])}
          />
        </div>
      </section>
    </main>
  );
}
