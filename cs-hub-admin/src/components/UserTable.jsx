import { useState, useEffect } from "react";
import { supabase } from "../supabaseClient";
import { Search, Shield } from "lucide-react";

export default function UsersTable() {
  const [users, setUsers] = useState([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);

  const roles = ["Student", "Lecturer", "Staff", "Official Department"];

  useEffect(() => {
    fetchUsers();
  }, []);

  async function fetchUsers() {
    setLoading(true);
    const { data, error } = await supabase
      .from("profiles")
      .select("*")
      .order("display_name", { ascending: true });

    if (!error && data) {
      setUsers(data);
    }
    setLoading(false);
  }

  async function handleRoleChange(userId, newRole) {
    const { error } = await supabase
      .from("profiles")
      .update({ role: newRole })
      .eq("id", userId);

    if (error) {
      alert("Failed to update role: " + error.message);
    } else {
      setUsers((prev) =>
        prev.map((u) => (u.id === userId ? { ...u, role: newRole } : u)),
      );
    }
  }

  const filteredUsers = users.filter((u) => {
    const q = search.toLowerCase();
    return (
      (u.display_name || "").toLowerCase().includes(q) ||
      (u.full_name || "").toLowerCase().includes(q) ||
      (u.email || "").toLowerCase().includes(q) ||
      (u.institutional_id || "").toLowerCase().includes(q)
    );
  });

  if (loading) return <div className="panel-loading">Loading members...</div>;

  return (
    <div className="panel">
      <div className="panel-header">
        <div>
          <h1>User Directory & Roles</h1>
          <p>Verify Lecturer, Staff, and Official Account badges</p>
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
              <th>Admin</th>
            </tr>
          </thead>
          <tbody>
            {filteredUsers.map((user) => (
              <tr key={user.id}>
                <td>
                  <div className="user-cell">
                    <strong>{user.display_name || "No Display Name"}</strong>
                    <span>{user.email}</span>
                  </div>
                </td>
                <td>{user.institutional_id || "N/A"}</td>
                <td>
                  <div className="user-cell">
                    <span>{user.faculty || "N/A"}</span>
                    {user.department && <small>{user.department}</small>}
                  </div>
                </td>
                <td>
                  <select
                    className="role-select"
                    value={user.role || "Student"}
                    onChange={(e) => handleRoleChange(user.id, e.target.value)}
                  >
                    {roles.map((r) => (
                      <option key={r} value={r}>
                        {r}
                      </option>
                    ))}
                  </select>
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
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
