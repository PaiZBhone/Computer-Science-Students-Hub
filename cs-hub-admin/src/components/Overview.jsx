import { useState, useEffect } from "react";
import { supabase } from "../supabaseClient";
import { Users, FileText, Heart, MessageSquare } from "lucide-react";

export default function Overview() {
  const [stats, setStats] = useState({
    users: 0,
    posts: 0,
    upvotes: 0,
    comments: 0,
    categories: {},
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  async function fetchStats() {
    setLoading(true);
    const [
      { count: usersCount },
      { data: postsData, count: postsCount },
      { count: upvotesCount },
      { count: commentsCount },
    ] = await Promise.all([
      supabase.from("profiles").select("*", { count: "exact", head: true }),
      supabase.from("posts").select("category", { count: "exact" }),
      supabase.from("upvotes").select("*", { count: "exact", head: true }),
      supabase.from("comments").select("*", { count: "exact", head: true }),
    ]);

    const categoryMap = {};
    (postsData || []).forEach((p) => {
      const cat = p.category || "General";
      categoryMap[cat] = (categoryMap[cat] || 0) + 1;
    });

    setStats({
      users: usersCount || 0,
      posts: postsCount || 0,
      upvotes: upvotesCount || 0,
      comments: commentsCount || 0,
      categories: categoryMap,
    });
    setLoading(false);
  }

  if (loading) return <div className="panel-loading">Loading analytics...</div>;

  const sortedCategories = Object.entries(stats.categories).sort(
    (a, b) => b[1] - a[1],
  );

  return (
    <div className="panel">
      <div className="panel-header">
        <div>
          <h1>Platform Overview</h1>
          <p>Real-time snapshot of CS Hub activity and engagement</p>
        </div>
        <button className="btn-secondary" onClick={fetchStats}>
          Refresh Data
        </button>
      </div>

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon blue">
            <Users size={24} />
          </div>
          <div>
            <span className="stat-label">Total Members</span>
            <h2 className="stat-value">{stats.users}</h2>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon purple">
            <FileText size={24} />
          </div>
          <div>
            <span className="stat-label">Total Posts</span>
            <h2 className="stat-value">{stats.posts}</h2>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon red">
            <Heart size={24} />
          </div>
          <div>
            <span className="stat-label">Total Upvotes</span>
            <h2 className="stat-value">{stats.upvotes}</h2>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon green">
            <MessageSquare size={24} />
          </div>
          <div>
            <span className="stat-label">Total Comments</span>
            <h2 className="stat-value">{stats.comments}</h2>
          </div>
        </div>
      </div>

      <div className="card">
        <h3>Posts by Category</h3>
        {sortedCategories.length === 0 ? (
          <p className="muted">No posts recorded yet.</p>
        ) : (
          <div className="category-bars">
            {sortedCategories.map(([category, count]) => {
              const pct =
                stats.posts > 0 ? Math.round((count / stats.posts) * 100) : 0;
              return (
                <div key={category} className="bar-row">
                  <div className="bar-info">
                    <span>{category}</span>
                    <span>
                      {count} posts ({pct}%)
                    </span>
                  </div>
                  <div className="bar-track">
                    <div className="bar-fill" style={{ width: `${pct}%` }} />
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
