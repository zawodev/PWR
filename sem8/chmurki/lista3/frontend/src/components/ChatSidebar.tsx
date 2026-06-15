import type { Chat } from "../types";

type Props = {
  chats: Chat[];
  myChats: Chat[];
  activeChatId: number | null;
  onSelect: (chatId: number) => void;
  onJoin: (chatId: number) => void;
  onLeave: (chatId: number) => void;
};

export default function ChatSidebar({
  chats,
  myChats,
  activeChatId,
  onSelect,
  onJoin,
  onLeave,
}: Props) {
  const myIds = new Set(myChats.map((c) => c.id));

  return (
    <aside className="chat-sidebar">
      <div className="sidebar-section">
        <h3>My chats</h3>
        {myChats.length === 0 ? (
          <p className="sidebar-empty">No chats yet</p>
        ) : (
          <ul className="chat-list">
            {myChats.map((chat) => (
              <li
                key={chat.id}
                className={`chat-list-item${chat.id === activeChatId ? " is-active" : ""}`}
              >
                <button
                  type="button"
                  className="chat-select-btn"
                  onClick={() => onSelect(chat.id)}
                >
                  <span className="chat-name">{chat.name}</span>
                  <span className="chat-slug">#{chat.slug}</span>
                </button>
                <button
                  type="button"
                  className="chat-action-btn leave-btn"
                  onClick={() => onLeave(chat.id)}
                  title="Leave chat"
                >
                  ✕
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>

      <div className="sidebar-section">
        <h3>Browse chats</h3>
        <ul className="chat-list">
          {chats
            .filter((c) => !myIds.has(c.id))
            .map((chat) => (
              <li key={chat.id} className="chat-list-item">
                <span className="chat-info">
                  <span className="chat-name">{chat.name}</span>
                  <span className="chat-slug">#{chat.slug}</span>
                </span>
                <button
                  type="button"
                  className="chat-action-btn join-btn"
                  onClick={() => onJoin(chat.id)}
                  title="Join chat"
                >
                  +
                </button>
              </li>
            ))}
          {chats.filter((c) => !myIds.has(c.id)).length === 0 ? (
            <li className="sidebar-empty">No more chats</li>
          ) : null}
        </ul>
      </div>
    </aside>
  );
}
