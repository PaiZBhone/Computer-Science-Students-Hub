import { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient';
import { Trash2, Search, ExternalLink } from 'lucide-react';

export default function CommentsTable() {
  const [comments, setComments] = useState([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchComments();
  }, []);

  async function fetchComments() {
    setLoading(true);
    const { data, error } = await supabase
      .from('comments')
      .select(`
        *,
        profiles ( display_name, role, email ),
        posts ( id, content )
      `)
      .order('created_at', { ascending: false });

    if (!error && data) {
      setComments(data);
    }
    setLoading(false);
  }

  async function handleDeleteComment(commentId) {
    const confirmed = window.confirm(
      'Are you sure you want to permanently delete this comment?'
    );
    if (!confirmed) return;

    const { error } = await supabase.from('comments').delete().eq('id', commentId);
    if (error) {
      alert('Delete failed: ' + error.message);
    } else {
      setComments((prev) => prev.filter((c) => c.id !== commentId));
    }
  }

  const filteredComments = comments.filter((com) => {
    const query = search.toLowerCase();
    return (
      (com.content || '').toLowerCase().includes(query) ||
      (com.profiles?.display_name || '').toLowerCase().includes(query) ||
      (com.posts?.content || '').toLowerCase().includes(query)
    );
  });

  if (loading) return <div className="panel-loading">Loading comments...</div>;

  return (
    <div className="panel">
      <div className="panel-header">
        <div>
          <h1>Comment Moderation</h1>
          <p>Monitor community discussions and remove inappropriate comments</p>
        </div>
        <button className="btn-secondary" onClick={fetchComments}>
          Refresh
        </button>
      </div>

      <div className="toolbar">
        <div className="search-box">
          <Search size={18} />
          <input
            type="text"
            placeholder="Search comment text, author, or post content..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>Author</th>
              <th>Comment Content</th>
              <th>Parent Post Context</th>
              <th>Date</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {filteredComments.length === 0 ? (
              <tr>
                <td colSpan="5" className="empty-cell">
                  No matching comments found.
                </td>
              </tr>
            ) : (
              filteredComments.map((com) => (
                <tr key={com.id}>
                  <td>
                    <div className="user-cell">
                      <strong>{com.profiles?.display_name || 'Unknown'}</strong>
                      <span>{com.profiles?.role || 'Student'}</span>
                    </div>
                  </td>
                  <td className="content-cell">{com.content}</td>
                  <td className="content-cell text-muted">
                    {com.posts?.content ? `"${com.posts.content}"` : 'Post deleted'}
                  </td>
                  <td className="date-cell">
                    {new Date(com.created_at).toLocaleDateString()}
                  </td>
                  <td>
                    <button
                      className="btn-danger"
                      onClick={() => handleDeleteComment(com.id)}
                      title="Delete Comment"
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