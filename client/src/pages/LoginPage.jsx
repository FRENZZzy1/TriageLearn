import { useState } from 'react';
import { Link, Navigate, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext.jsx';

export default function LoginPage() {
  const { user, login } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ email: '', password: '' });
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  if (user) return <Navigate to="/" replace />;

  const submit = async (event) => {
    event.preventDefault(); setError(''); setBusy(true);
    try { await login(form); navigate('/'); } catch (err) { setError(err.message); } finally { setBusy(false); }
  };

  return <main className="auth-shell"><form className="card auth-card" onSubmit={submit}>
    <div className="brand">TRIAGE<span>LEARN</span></div>
    <h1>Welcome back</h1><p className="muted">Sign in to continue your triage learning journey.</p>
    {error && <div className="alert error">{error}</div>}
    <label>Email<input type="email" autoComplete="email" required value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} /></label>
    <label>Password<input type="password" autoComplete="current-password" required value={form.password} onChange={e => setForm({ ...form, password: e.target.value })} /></label>
    <button disabled={busy}>{busy ? 'Signing in…' : 'Sign in'}</button>
    <p className="muted center">No account? <Link to="/register">Create one</Link></p>
  </form></main>;
}
