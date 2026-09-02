import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { api } from '../services/api.js';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [session, setSession] = useState({ loading: true, user: null, progress: null });

  const refresh = async () => {
    try {
      const data = await api.me();
      setSession({ loading: false, ...data });
    } catch {
      setSession({ loading: false, user: null, progress: null });
    }
  };

  useEffect(() => { refresh(); }, []);

  const value = useMemo(() => ({
    ...session,
    refresh,
    async login(body) { const data = await api.login(body); setSession({ loading: false, ...data }); return data; },
    async register(body) { const data = await api.register(body); setSession({ loading: false, ...data }); return data; },
    async logout() { await api.logout(); setSession({ loading: false, user: null, progress: null }); },
  }), [session]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export const useAuth = () => useContext(AuthContext);
