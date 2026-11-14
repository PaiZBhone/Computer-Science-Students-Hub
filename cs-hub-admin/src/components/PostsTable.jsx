import { useState, useEffect } from "react";
import { supabase } from "../supabaseClient";
import { Trash2, Search, ExternalLink } from "lucide-react";

export default function PostsTable() {
  const [posts, setPosts] = useState([]);
  const [search, setSearch] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("All");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchPosts();
  }, []);

  async function fetchPosts() {
    setLoading(true);
    const { data, error } = await supabase
      .from("posts")
      .select(
        `
        *,
        profiles!posts_author_id_fkey ( display_name, role, email )
      `,
      )
      .order("created_at", { ascending: false });

    if (!error && data) {
      setPosts(data);
    }
    setLoading(false);
  }

  async function handleDeletePost(postId) {
    const confirmed = window.confirm(
      "Are you sure you want to permanently delete this post?",
    );
    if (!confirmed) return;

    const { error } = await supabase.from("posts").delete().eq("id", postId);
    if (error) {
      alert("Delete failed: " + error.message);
    } else {
      setPosts((prev) => prev.filter((p) => p.id !== postId));
    }
  }

  const categories = [
    "All",
    ...new Set(posts.map((p) => p.category).filter(Boolean)),
  ];

  const filteredPosts = posts.filter((post) => {
    const matchesCategory =
      categoryFilter === "All" || post.category === categoryFilter;
    const query = search.toLowerCase();
    const matchesSearch =
      (post.content || "").toLowerCase().includes(query) ||
      (post.profiles?.display_name || "").toLowerCase().includes(query);
    return matchesCategory && matchesSearch;
  });

  if (loading) return <div className="panel-loading">Loading posts...</div>;

  return (
    <div className="panel">
      <div className="panel-header">
        <div>
          <h1>Content Moderation</h1>
          <p>Monitor all community posts and remove policy violations</p>
        </div>
        <button className="btn-secondary" onClick={fetchPosts}>
          Refresh
        </button>
      </div>

      <div className="toolbar">
        <div className="search-box">
          <Search size={18} />
          <input
            type="text"
            placeholder="Search by post text or author..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
          className="filter-select"
        >
          {categories.map((cat) => (
            <option key={cat} value={cat}>
              {cat}
            </option>
          ))}
        </select>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>Author</th>
              <th>Category</th>
              <th>Content</th>
              <th>Media</th>
              <th>Posted</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {filteredPosts.length === 0 ? (
              <tr>
                <td colSpan="6" className="empty-cell">
                  No matching posts found.
                </td>
              </tr>
            ) : (
              filteredPosts.map((post) => (
                <tr key={post.id}>
                  <td>
                    <div className="user-cell">
                      <strong>
                        {post.profiles?.display_name || "Unknown"}
                      </strong>
                      <span>{post.profiles?.role || "Student"}</span>
                    </div>
                  </td>
                  <td>
                    <span className="badge">{post.category || "General"}</span>
                  </td>
                  <td className="content-cell">{post.content}</td>
                  <td>
                    {post.image_url ? (
                      <a
                        href={post.image_url}
                        target="_blank"
                        rel="noreferrer"
                        className="media-link"
                      >
                        View <ExternalLink size={14} />
                      </a>
                    ) : (
                      <span className="muted">—</span>
                    )}
                  </td>
                  <td className="date-cell">
                    {new Date(post.created_at).toLocaleDateString()}
                  </td>
                  <td>
                    <button
                      className="btn-danger"
                      onClick={() => handleDeletePost(post.id)}
                      title="Delete Post"
                    >
                      <Trash2 size={16} /> Delete
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
