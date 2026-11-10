import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'post_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final String id;
  final String uploaderName;
  final String? uploaderAvatar;
  final String role;
  final String category;
  final String timeAgo;
  final String content;
  final String? imageUrl;

  const PostDetailScreen({
    super.key,
    required this.id,
    required this.uploaderName,
    this.uploaderAvatar,
    required this.role,
    required this.category,
    required this.timeAgo,
    required this.content,
    this.imageUrl,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final provider = Provider.of<PostProvider>(context, listen: false);
    final comments = await provider.fetchComments(widget.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    await Provider.of<PostProvider>(
      context,
      listen: false,
    ).addComment(widget.id, text);

    _commentController.clear();
    await _loadComments();

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final postData = context.watch<PostProvider>().posts.firstWhere(
      (p) => p['id'] == widget.id,
      orElse: () => {},
    );

    final int upvotes = postData.isNotEmpty ? postData['upvotes'] : 0;
    final int commentsCount = postData.isNotEmpty
        ? postData['comments']
        : 0;
    final bool isUpvoted = Provider.of<PostProvider>(
      context,
    ).hasUpvoted(widget.id);
    final bool isSaved = Provider.of<PostProvider>(
      context,
    ).isSaved(widget.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color.fromARGB(
                          255,
                          41,
                          99,
                          165,
                        ),
                        backgroundImage:
                            widget.uploaderAvatar != null &&
                                widget.uploaderAvatar!.isNotEmpty
                            ? NetworkImage(widget.uploaderAvatar!)
                            : null,
                        child:
                            (widget.uploaderAvatar == null ||
                                widget.uploaderAvatar!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.uploaderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${widget.role} • ${widget.timeAgo}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  if (widget.imageUrl != null &&
                      widget.imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Provider.of<PostProvider>(
                            context,
                            listen: false,
                          ).upvotePost(widget.id);
                        },
                        icon: Icon(
                          isUpvoted
                              ? PhosphorIconsFill.heart
                              : PhosphorIconsRegular.heart,
                          size: 20,
                          color: isUpvoted
                              ? Colors.blue
                              : Colors.grey[700],
                        ),
                        label: Text(
                          '$upvotes',
                          style: TextStyle(
                            color: isUpvoted
                                ? Colors.blue
                                : Colors.grey[700],
                            fontWeight: isUpvoted
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            97,
                            97,
                            97,
                          ),
                        ),
                        icon: const Icon(
                          PhosphorIconsFill.chatCircleDots,
                          size: 20,
                        ),
                        label: Text(
                          '$commentsCount',
                          style: const TextStyle(),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Provider.of<PostProvider>(
                            context,
                            listen: false,
                          ).toggleSavePost(widget.id);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: isSaved
                              ? Colors.blue
                              : const Color.fromARGB(255, 97, 97, 97),
                        ),
                        icon: Icon(
                          isSaved
                              ? PhosphorIconsFill.bookmarkSimple
                              : PhosphorIconsRegular.bookmarkSimple,
                          size: 20,
                        ),
                        label: Text(
                          isSaved ? 'Saved' : 'Save',
                          style: TextStyle(
                            fontWeight: isSaved
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 12),

                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _isLoadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : _comments.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                          ),
                          child: Center(
                            child: Text(
                              'No comments yet. Be the first!',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            final profile = comment['profiles'] ?? {};
                            final avatarUrl = profile['avatar_url'];
                            final displayName =
                                comment['display_name'] ??
                                profile['display_name'] ??
                                'Unknown User';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      41,
                                      99,
                                      165,
                                    ),
                                    backgroundImage:
                                        avatarUrl != null &&
                                            avatarUrl.isNotEmpty
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    child:
                                        (avatarUrl == null ||
                                            avatarUrl.isEmpty)
                                        ? const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? const Color(0xFF1E1E1E)
                                            : Colors.grey[100],
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            comment['content'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            color: isDarkMode ? const Color(0xFF121212) : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? const Color.fromARGB(255, 34, 34, 34)
                              : const Color.fromARGB(255, 201, 198, 198),
                        ),
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? const Color.fromARGB(255, 34, 34, 34)
                          : Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 41, 99, 165),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _submitComment,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
