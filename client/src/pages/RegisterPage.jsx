import { useState } from 'react';
import { Link, Navigate, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext.jsx';

export default function RegisterPage() {
  const { user, register } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ full_name: '', email: '', password: '' });
  const [error, setError] = useState(''); const [busy, setBusy] = useState(false);
  if (user) return <Navigate to="/" replace />;

  const submit = async (event) => {
    event.preventDefault(); setError(''); setBusy(true);
    try { await register(form); navigate('/'); } catch (err) { setError(err.message); } finally { setBusy(false); }
  };

  return <main className="auth-shell"><form className="card auth-card" onSubmit={submit}>
    <div className="brand">TRIAGE<span>LEARN</span></div><h1>Create your account</h1>
    <p className="muted">Student accounts are created with the STUDENT role.</p>
    {error && <div className="alert error">{error}</div>}
    <label>Full name<input required minLength="2" maxLength="150" value={form.full_name} onChange={e => setForm({ ...form, full_name: e.target.value })} /></label>
    <label>Email<input type="email" required value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} /></label>
    <label>Password<input type="password" required minLength="8" value={form.password} onChange={e => setForm({ ...form, password: e.target.value })} /><small>At least 8 characters.</small></label>
    <button disabled={busy}>{busy ? 'Creating…' : 'Create account'}</button>
    <p className="muted center">Already registered? <Link to="/login">Sign in</Link></p>
  </form></main>;
}
