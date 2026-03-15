import { FormEvent, useState } from "react";

import { postMessage, uploadMedia } from "../services/api";
import type { Message } from "../types";

type Props = {
  onMessageCreated: (message: Message) => void;
};

export default function MessageForm({ onMessageCreated }: Props) {
  const [nickname, setNickname] = useState(localStorage.getItem("chat_nickname") || "");
  const [text, setText] = useState("");
  const [file, setFile] = useState<File | null>(null);
  const [isSending, setIsSending] = useState(false);
  const [error, setError] = useState("");

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!nickname.trim()) {
      setError("Provide nickname");
      return;
    }

    if (!text.trim() && !file) {
      setError("Write a message or attach media");
      return;
    }

    setError("");
    setIsSending(true);

    try {
      localStorage.setItem("chat_nickname", nickname.trim());
      let mediaId: number | undefined;

      if (file) {
        const media = await uploadMedia(file);
        mediaId = media.id;
      }

      const created = await postMessage({
        nickname: nickname.trim(),
        text: text.trim(),
        media_id: mediaId,
      });

      setText("");
      setFile(null);
      onMessageCreated(created);
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : "Unknown error");
    } finally {
      setIsSending(false);
    }
  }

  return (
    <form className="message-form" onSubmit={onSubmit}>
      <label>
        Nickname
        <input
          value={nickname}
          onChange={(event) => setNickname(event.target.value)}
          maxLength={40}
          placeholder="Your nickname"
          required
        />
      </label>

      <label>
        Message
        <textarea
          value={text}
          onChange={(event) => setText(event.target.value)}
          maxLength={2000}
          placeholder="Write a message"
          rows={3}
        />
      </label>

      <label>
        Media (image/video/audio)
        <input
          type="file"
          accept="image/*,video/*,audio/*"
          onChange={(event) => setFile(event.target.files?.[0] || null)}
        />
      </label>

      <button disabled={isSending} type="submit">
        {isSending ? "Sending..." : "Send"}
      </button>

      {error ? <p className="error">{error}</p> : null}
    </form>
  );
}
