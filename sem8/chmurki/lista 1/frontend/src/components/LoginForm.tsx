import { FormEvent, useState } from "react";

import type { LoginRequest, RegisterRequest } from "../types";

type Props = {
  onLogin: (payload: LoginRequest) => Promise<void>;
  onRegister: (payload: RegisterRequest) => Promise<void>;
  isLoading: boolean;
  error: string;
};

export default function LoginForm({ onLogin, onRegister, isLoading, error }: Props) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [mode, setMode] = useState<"login" | "register">("login");
  const [localError, setLocalError] = useState("");

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!username.trim() || !password) {
      setLocalError("Provide username and password");
      return;
    }

    if (mode === "register") {
      if (password !== confirmPassword) {
        setLocalError("Passwords do not match");
        return;
      }

      await onRegister({
        username: username.trim(),
        password,
      });
      return;
    }

    setLocalError("");
    await onLogin({
      username: username.trim(),
      password,
    });
  }

  return (
    <form className="login-form" onSubmit={onSubmit}>
      <div className="auth-mode-switch">
        <button
          type="button"
          className={mode === "login" ? "is-active" : ""}
          onClick={() => {
            setMode("login");
            setLocalError("");
          }}
        >
          Sign in
        </button>
        <button
          type="button"
          className={mode === "register" ? "is-active" : ""}
          onClick={() => {
            setMode("register");
            setLocalError("");
          }}
        >
          Register
        </button>
      </div>

      <h2>{mode === "login" ? "Sign in" : "Create account"}</h2>

      <label>
        Username
        <input
          value={username}
          onChange={(event) => setUsername(event.target.value)}
          placeholder="Username"
          autoComplete="username"
          required
        />
      </label>

      <label>
        Password
        <input
          type="password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          placeholder="Password"
          autoComplete={mode === "login" ? "current-password" : "new-password"}
          minLength={mode === "register" ? 8 : undefined}
          required
        />
      </label>

      {mode === "register" ? (
        <p className="auth-hint">Hasło musi mieć co najmniej 8 znaków, w tym małą literę, wielką literę i cyfrę.</p>
      ) : null}

      {mode === "register" ? (
        <label>
          Confirm password
          <input
            type="password"
            value={confirmPassword}
            onChange={(event) => setConfirmPassword(event.target.value)}
            placeholder="Repeat password"
            autoComplete="new-password"
            required
          />
        </label>
      ) : null}

      <button disabled={isLoading} type="submit">
        {isLoading ? (mode === "login" ? "Signing in..." : "Creating account...") : (mode === "login" ? "Sign in" : "Register and sign in")}
      </button>

      {localError ? <p className="error">{localError}</p> : null}
      {error ? <p className="error">{error}</p> : null}
    </form>
  );
}
