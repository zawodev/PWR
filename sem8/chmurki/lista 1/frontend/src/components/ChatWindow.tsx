import { useMemo } from "react";

import MessageItem from "./MessageItem";
import type { Message } from "../types";

type Props = {
  messages: Message[];
};

export default function ChatWindow({ messages }: Props) {
  const sortedMessages = useMemo(
    () => [...messages].sort((a, b) => a.id - b.id),
    [messages]
  );

  return (
    <section className="chat-window">
      {sortedMessages.map((message) => (
        <MessageItem key={message.id} message={message} />
      ))}
    </section>
  );
}
