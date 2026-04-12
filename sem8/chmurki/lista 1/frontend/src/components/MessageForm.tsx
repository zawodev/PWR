import { FormEvent, useState } from "react";

import { postMessage, uploadMedia } from "../services/api";
import type { Message } from "../types";

type Props = {
  username: string;
  onMessageCreated: (message: Message) => void;
};

export default function MessageForm({ username, onMessageCreated }: Props) {
  const [text, setText] = useState("");
  const [file, setFile] = useState<File | null>(null);
  const [isSending, setIsSending] = useState(false);
  const [error, setError] = useState("");

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!username.trim()) {
      setError("Missing authenticated username");
      return;
    }

    if (!text.trim() && !file) {
      setError("Write a message or attach media");
      return;
    }

    setError("");
    setIsSending(true);

    try {
      let mediaId: number | undefined;

      if (file) {
        const media = await uploadMedia(file);
        mediaId = media.id;
      }

      const created = await postMessage({
        nickname: username.trim(),
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
      <p className="signed-in-as">Signed in as: {username}</p>

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
