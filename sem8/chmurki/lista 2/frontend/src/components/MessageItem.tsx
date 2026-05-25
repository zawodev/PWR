import type { Message } from "../types";
import { mediaContentUrl } from "../services/api";

type Props = {
  message: Message;
};

function renderMedia(message: Message) {
  if (!message.media) {
    return null;
  }

  const src = mediaContentUrl(message.media.content_url);
  const type = message.media.content_type;

  if (type.startsWith("image/")) {
    return <img src={src} alt={message.media.original_name} className="media-preview" />;
  }

  if (type.startsWith("video/")) {
    return <video controls src={src} className="media-preview" />;
  }

  if (type.startsWith("audio/")) {
    return <audio controls src={src} className="audio-preview" />;
  }

  return (
    <a href={src} target="_blank" rel="noreferrer" className="download-link">
      Download file
    </a>
  );
}

export default function MessageItem({ message }: Props) {
  return (
    <div className="message-item">
      <div className="message-head">
        <strong>{message.nickname}</strong>
        <span>{new Date(message.created_at).toLocaleTimeString()}</span>
      </div>
      {message.text ? <p className="message-text">{message.text}</p> : null}
      {renderMedia(message)}
    </div>
  );
}
