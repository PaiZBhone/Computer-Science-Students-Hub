import 'package:flutter/material.dart';
import 'package:flutter_helloworld/post.dart';
import 'package:provider/provider.dart';
import 'post_provider.dart';
import 'settting_screen.dart';
import 'theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class Myhome extends StatefulWidget {
  const Myhome({super.key});

  @override
  State<Myhome> createState() => _MyhomeState();
}

class _MyhomeState extends State<Myhome> {
  String selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> filters = [
    'All',
    '📌 Announcements',
    '📚 Academic',
    '🎮 Social',
    '🍔 Food',
    '🏫 Campus',
    '🎵 Music',
    '😂 Fun',
    '💻 Tech',
    '👽 Random',
    '🌧️ Weather',
  ];

  @override
  Widget build(BuildContext context) {
    final allPosts = Provider.of<PostProvider>(context).posts;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Filter by BOTH Category and Search Query
    final displayedPosts = allPosts.where((post) {
      final matchesCategory =
          selectedFilter == 'All' || post['category'] == selectedFilter;

      final matchesSearch =
          post['content'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          post['uploaderName'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      //backgroud feed color
      //backgroundColor: Colors.white,
      body: Provider.of<PostProvider>(context).isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // This triggers the fetch function when you pull down!
              onRefresh: () => Provider.of<PostProvider>(
                context,
                listen: false,
              ).fetchPosts(),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    toolbarHeight: 70, // Matches your previous height
                    floating: true, // Hides the bar when scrolling down
                    snap:
                        true, // Snaps it back into view when scrolling up
                    //backgroundColor: Colors.blue,
                    elevation: 0,
                    title: const Text(
                      'College of DIT\n Computer Science Club',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onChanged: (value) {
                          // Every time the user types a letter, the screen updates!
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search posts or users...',
                          prefixIcon: const Icon(
                            PhosphorIconsRegular.magnifyingGlass,
                            size: 22,
                            color: Colors.grey,
                          ),
                          // Show a clear 'X' button only if there is text
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDarkMode
                              //searchbar color
                              ? const Color.fromARGB(255, 34, 34, 34)
                              : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          //searchbar bordercolor
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: isDarkMode
                                  ? const Color.fromARGB(255, 34, 34, 34)
                                  : const Color.fromARGB(
                                      255,
                                      201,
                                      198,
                                      198,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 5. The new Filter Chips Section
                  SliverToBoxAdapter(
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        itemCount: filters.length,
                        itemBuilder: (context, index) {
                          final filter = filters[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: selectedFilter == filter,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedFilter = filter;
                                });
                              },
                              backgroundColor: isDarkMode
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.grey[200],
                              selectedColor: Colors.blue.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: selectedFilter == filter
                                    ? (isDarkMode
                                          ? Colors.blue[300]
                                          : Colors.blue[800])
                                    : (isDarkMode
                                          ? Colors.white70
                                          : Colors.black87),
                                fontWeight: selectedFilter == filter
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              // Optional: Remove the border for a cleaner modern look
                              side: BorderSide.none,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // 6. The Scrolling List of Filtered Posts
                  SliverList(
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      final post = displayedPosts[index];
                      return PostCard(
                        id: post['id'],
                        uploaderName: post['uploaderName'],
                        role: post['role'],
                        category: post['category'],
                        timeAgo: post['timeAgo'],
                        content: post['content'],
                        upvotes: post['upvotes'],
                        comments: post['comments'],
                        share: post['share'],
                      );
                    }, childCount: displayedPosts.length),
                  ),
                ],
              ),
            ),
    );
  }
}
