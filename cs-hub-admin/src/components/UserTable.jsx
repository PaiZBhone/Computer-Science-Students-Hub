import { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient';
import { Search, Shield, Edit3, X } from 'lucide-react';

export default function UsersTable() {
  const [users, setUsers] = useState([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);

  // Modal editing state
  const [editingUser, setEditingUser] = useState(null);
  const [formData, setFormData] = useState({
    display_name: '',
    institutional_id: '',
    faculty: '',
    department: '',
    role: 'Student',
    is_admin: false,
  });

  const roles = ['Student', 'Lecturer', 'Staff', 'Official Account'];

  useEffect(() => {
    fetchUsers();
  }, []);

  async function fetchUsers() {
    setLoading(true);
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .order('display_name', { ascending: true });

    if (!error && data) {
      setUsers(data);
    }
    setLoading(false);
  }

  function openEditModal(user) {
    setEditingUser(user);
    setFormData({
      display_name: user.display_name || '',
      institutional_id: user.institutional_id || '',
      faculty: user.faculty || '',
      department: user.department || '',
      role: user.role || 'Student',
      is_admin: user.is_admin || false,
    });
  }

  async function handleSaveEdit(e) {
    e.preventDefault();
    if (!editingUser) return;

    const { error } = await supabase
      .from('profiles')
      .update({
        display_name: formData.display_name,
        institutional_id: formData.institutional_id,
        faculty: formData.faculty,
        department: formData.department,
        role: formData.role,
        is_admin: formData.is_admin,
      })
      .eq('id', editingUser.id);

    if (error) {
      alert('Failed to update user details: ' + error.message);
    } else {
      // Update local state
      setUsers((prev) =>
        prev.map((u) => (u.id === editingUser.id ? { ...u, ...formData } : u))
      );
      setEditingUser(null);
    }
  }

  const filteredUsers = users.filter((u) => {
    const q = search.toLowerCase();
    return (
      (u.display_name || '').toLowerCase().includes(q) ||
      (u.full_name || '').toLowerCase().includes(q) ||
      (u.email || '').toLowerCase().includes(q) ||
      (u.institutional_id || '').toLowerCase().includes(q)
    );
  });

  if (loading) return <div className="panel-loading">Loading members...</div>;

  return (
    <div className="panel">
      <div className="panel-header">
        <div>
          <h1>User Directory & Details</h1>
          <p>View and edit complete user profiles, institutional IDs, and roles</p>
        </div>
        <button className="btn-secondary" onClick={fetchUsers}>
          Refresh
        </button>
      </div>

      <div className="toolbar">
        <div className="search-box">
          <Search size={18} />
          <input
            type="text"
            placeholder="Search by name, email, or Student/Staff ID..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>Member</th>
              <th>ID</th>
              <th>Faculty / Dept</th>
              <th>Role</th>
              <th>Admin Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredUsers.map((user) => (
              <tr key={user.id}>
                <td>
                  <div className="user-cell">
                    <strong>{user.display_name || 'No Display Name'}</strong>
                    <span>{user.email}</span>
                  </div>
                </td>
                <td>{user.institutional_id || 'N/A'}</td>
                <td>
                  <div className="user-cell">
                    <span>{user.faculty || 'N/A'}</span>
                    {user.department && <small>{user.department}</small>}
                  </div>
                </td>
                <td>
                  <span className="badge">{user.role || 'Student'}</span>
                </td>
                <td>
                  {user.is_admin ? (
                    <span className="admin-pill">
                      <Shield size={13} /> Admin
                    </span>
                  ) : (
                    <span className="muted">Member</span>
                  )}
                </td>
                <td>
                  <button
                    className="btn-secondary"
                    onClick={() => openEditModal(user)}
                    style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', padding: '6px 12px', fontSize: '13px' }}
                  >
                    <Edit3 size={15} /> Edit Details
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* EDIT USER MODAL */}
      {editingUser && (
        <div className="modal-overlay">
          <div className="modal-card">
            <div className="modal-header">
              <h3>Edit User: {editingUser.email}</h3>
              <button className="modal-close" onClick={() => setEditingUser(null)}>
                <X size={20} />
              </button>
            </div>

            <form onSubmit={handleSaveEdit} className="modal-form">
              <div className="input-group">
                <label>Display Name</label>
                <input
                  type="text"
                  value={formData.display_name}
                  onChange={(e) => setFormData({ ...formData, display_name: e.target.value })}
                  required
                />
              </div>

              <div className="input-group">
                <label>Institutional ID (Student/Staff ID)</label>
                <input
                  type="text"
                  value={formData.institutional_id}
                  onChange={(e) => setFormData({ ...formData, institutional_id: e.target.value })}
                />
              </div>

              <div className="input-group">
                <label>Faculty</label>
                <input
                  type="text"
                  value={formData.faculty}
                  onChange={(e) => setFormData({ ...formData, faculty: e.target.value })}
                />
              </div>

              <div className="input-group">
                <label>Department</label>
                <input
                  type="text"
                  value={formData.department}
                  onChange={(e) => setFormData({ ...formData, department: e.target.value })}
                />
              </div>

              <div className="input-group">
                <label>Role</label>
                <select
                  className="role-select"
                  style={{ width: '100%', padding: '10px' }}
                  value={formData.role}
                  onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                >
                  {roles.map((r) => (
                    <option key={r} value={r}>
                      {r}
                    </option>
                  ))}
                </select>
              </div>

              <div className="input-group checkbox-group" style={{ display: 'flex', alignItems: 'center', gap: '10px', marginTop: '10px' }}>
                <input
                  type="checkbox"
                  id="isAdminCheckbox"
                  checked={formData.is_admin}
                  onChange={(e) => setFormData({ ...formData, is_admin: e.target.checked })}
                  style={{ width: '18px', height: '18px', cursor: 'pointer' }}
                />
                <label htmlFor="isAdminCheckbox" style={{ cursor: 'pointer', margin: 0, fontWeight: 600 }}>
                  Grant Admin Privileges
                </label>
              </div>

              <div className="modal-actions" style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
                <button type="button" className="btn-secondary" style={{ flex: 1 }} onClick={() => setEditingUser(null)}>
                  Cancel
                </button>
                <button type="submit" className="btn-primary" style={{ flex: 1, marginTop: 0 }}>
                  Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}