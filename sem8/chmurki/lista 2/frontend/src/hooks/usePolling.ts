import { useEffect } from "react";

export function usePolling(callback: () => void, intervalMs: number): void {
  useEffect(() => {
    callback();
    const timer = window.setInterval(callback, intervalMs);
    return () => {
      window.clearInterval(timer);
    };
  }, [callback, intervalMs]);
}
