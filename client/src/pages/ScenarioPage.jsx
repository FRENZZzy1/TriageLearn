import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { api } from '../services/api.js';

export default function ScenarioPage() {
  const { id } = useParams();
  const [scenario, setScenario] = useState(null); const [attempt, setAttempt] = useState(null); const [error, setError] = useState('');
  useEffect(() => { api.scenario(id).then(d => setScenario(d.scenario)).catch(e => setError(e.message)); }, [id]);
  const start = async () => { try { const data = await api.startScenario(id); setAttempt(data.attempt); } catch (e) { setError(e.message); } };
  if (error) return <main className="page-center"><div className="card"><h1>Unable to load scenario</h1><p>{error}</p><Link to="/">Back to dashboard</Link></div></main>;
  if (!scenario) return <div className="page-center">Loading scenario…</div>;
  return <main className="app-shell"><header className="topbar"><Link className="brand" to="/">TRIAGE<span>LEARN</span></Link><Link to="/">Dashboard</Link></header>
    <section className="card scenario-intro"><p className="eyebrow">TIER {scenario.tier}</p><h1>{scenario.title}</h1><p className="muted">{scenario.description}</p><div className="stats inline"><Stat label="Time limit" value={`${scenario.time_limit}s`} /><Stat label="Maximum XP" value={scenario.max_xp} /></div>
      <div className="patient-preview"><h2>Patient arrival</h2><p><b>{scenario.patient.name}</b> · {scenario.patient.age} · {scenario.patient.sex}</p><p>{scenario.patient.visit_type}</p><p><b>Chief complaint:</b> {scenario.patient.chief_complaint}</p></div>
      {!attempt ? <button onClick={start}>Approach patient & start</button> : <div className="alert success"><b>Attempt started.</b> Server timestamp: {new Date(attempt.scenario_start_time).toLocaleString()}<p className="muted">Week 1 establishes the reusable scenario shell. Interview, vitals, assessment, ESI, routing, scoring, and feedback actions are added in subsequent P0 slices.</p></div>}
    </section></main>;
}
function Stat({ label, value }) { return <div className="card stat"><span className="muted">{label}</span><strong>{value}</strong></div>; }
