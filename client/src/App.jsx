import { Navigate, Route, Routes } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext.jsx';
import { ProtectedRoute } from './components/ProtectedRoute.jsx';
import LoginPage from './pages/LoginPage.jsx';
import RegisterPage from './pages/RegisterPage.jsx';
import DashboardPage from './pages/DashboardPage.jsx';
import ScenarioPage from './pages/ScenarioPage.jsx';
import './styles/global.css';

export default function App() {
  return <AuthProvider><Routes>
    <Route path="/login" element={<LoginPage />} />
    <Route path="/register" element={<RegisterPage />} />
    <Route element={<ProtectedRoute roles={['STUDENT', 'FACULTY']} />}><Route path="/" element={<DashboardPage />} /></Route>
    <Route element={<ProtectedRoute roles={['STUDENT', 'FACULTY']} />}><Route path="/scenarios/:id" element={<ScenarioPage />} /></Route>
    <Route path="*" element={<Navigate to="/" replace />} />
  </Routes></AuthProvider>;
}
