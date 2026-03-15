import { useCallback, useMemo, useState } from "react";

import ChatWindow from "./components/ChatWindow";
import MessageForm from "./components/MessageForm";
import { usePolling } from "./hooks/usePolling";
import { getMessages } from "./services/api";
import type { Message } from "./types";

export default function App() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [error, setError] = useState("");

  const lastMessageId = useMemo(
    () => messages.reduce((max, item) => (item.id > max ? item.id : max), 0),
    [messages]
  );

  const loadNewMessages = useCallback(async () => {
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
      setError(caught instanceof Error ? caught.message : "Failed to fetch messages");
    }
  }, [lastMessageId]);

  usePolling(loadNewMessages, 2500);

  return (
    <main className="app-shell">
      <header>
        <h1>Discord 2.0</h1>
        <p>"Wow! Nigdy nie pisałem tylu wiadomości! Ta aplikacja to rewolucja!" - Elon Bezos, CEO & CTO at Discord 2.0</p>
      </header>

      {error ? <p className="error">{error}</p> : null}

      <section className="chat-layout">
        <div className="chat-pane">
          <h2>Chat history</h2>
          <ChatWindow messages={messages} />
        </div>

        <div className="composer-pane">
          <h2>New message</h2>
          <MessageForm onMessageCreated={(msg) => setMessages((prev) => [...prev, msg])} />
        </div>
      </section>
    </main>
  );
}
