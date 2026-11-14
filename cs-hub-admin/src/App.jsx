import { useState, useEffect } from 'react';
import { supabase } from './supabaseClient';
import Login from './components/Login';
import Overview from './components/Overview';
import PostsTable from './components/PostsTable';
import UsersTable from './components/UserTable';
import { LayoutDashboard, FileText, Users, LogOut, ShieldCheck } from 'lucide-react';
import './App.css';
export default function App() {
  const [session, setSession] = useState(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('overview');

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      checkAdminAccess(session);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      checkAdminAccess(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  async function checkAdminAccess(currentSession) {
    if (!currentSession) {
      setSession(null);
      setIsAdmin(false);
      setLoading(false);
      return;
    }

    const { data } = await supabase
      .from('profiles')
      .select('is_admin')
      .eq('id', currentSession.user.id)
      .single();

    if (data?.is_admin) {
      setSession(currentSession);
      setIsAdmin(true);
    } else {
      await supabase.auth.signOut();
      alert('Access Denied: Admin privileges required.');
      setSession(null);
      setIsAdmin(false);
    }
    setLoading(false);
  }

  if (loading) {
    return <div className="center-screen">Loading CS Hub Admin...</div>;
  }

  if (!session || !isAdmin) {
    return <Login />;
  }

  return (
    <div className="dashboard-layout">
      <aside className="sidebar">
        <div className="brand">
          <div className="brand-logo">
            <ShieldCheck size={24} />
          </div>
          <div>
            <h2>CS Hub</h2>
            <span>Admin Portal</span>
          </div>
        </div>

        <nav className="nav-links">
          <button
            className={activeTab === 'overview' ? 'active' : ''}
            onClick={() => setActiveTab('overview')}
          >
            <LayoutDashboard size={18} /> Overview
          </button>
          <button
            className={activeTab === 'posts' ? 'active' : ''}
            onClick={() => setActiveTab('posts')}
          >
            <FileText size={18} /> Manage Posts
          </button>
          <button
            className={activeTab === 'users' ? 'active' : ''}
            onClick={() => setActiveTab('users')}
          >
            <Users size={18} /> Manage Users
          </button>
        </nav>

        <div className="sidebar-footer">
          <button className="logout-btn" onClick={() => supabase.auth.signOut()}>
            <LogOut size={18} /> Log Out
          </button>
        </div>
      </aside>

      <main className="main-content">
        {activeTab === 'overview' && <Overview />}
        {activeTab === 'posts' && <PostsTable />}
        {activeTab === 'users' && <UsersTable />}
      </main>
    </div>
  );
}