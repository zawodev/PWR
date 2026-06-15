import { FormEvent, useState } from "react";

import type { ChatCreate } from "../types";

type Props = {
  onCreate: (payload: ChatCreate) => Promise<void>;
};

export default function CreateChatForm({ onCreate }: Props) {
  const [name, setName] = useState("");
  const [isCreating, setIsCreating] = useState(false);
  const [error, setError] = useState("");

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!name.trim()) {
      setError("Provide a chat name");
      return;
    }
    setError("");
    setIsCreating(true);
    try {
      await onCreate({ name: name.trim() });
      setName("");
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : "Failed to create chat");
    } finally {
      setIsCreating(false);
    }
  }

  return (
    <form className="create-chat-form" onSubmit={onSubmit}>
      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="New chat name…"
        maxLength={120}
      />
      <button disabled={isCreating} type="submit">
        {isCreating ? "…" : "+"}
      </button>
      {error ? <p className="error">{error}</p> : null}
    </form>
  );
}
