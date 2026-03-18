import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/friend.dart';
import '../providers/friend_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchProvider.notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Friends'),
            Tab(text: 'Find Friends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllFriendsTab(),
          _buildFindFriendsTab(),
        ],
      ),
    );
  }

  Widget _buildAllFriendsTab() {
    final friendsState = ref.watch(friendsProvider);

    if (friendsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friendsState.friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No friends yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              child: const Text('Find Friends'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(friendsProvider.notifier).refresh();
      },
      child: ListView.builder(
        itemCount: friendsState.friends.length,
        itemBuilder: (context, index) {
          final friend = friendsState.friends[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: friend.profilePicture != null
                  ? NetworkImage(friend.profilePicture!)
                  : null,
              child: friend.profilePicture == null
                  ? Text(friend.username[0].toUpperCase())
                  : null,
            ),
            title: Text(friend.username),
            subtitle: Text(
              friend.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: friend.isOnline ? Colors.green : Colors.grey,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (friend.isOnline)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'unfriend') {
                      _showUnfriendConfirmation(context, friend);
                    } else if (value == 'block') {
                      _showBlockConfirmation(context, friend);
                    } else if (value == 'chat') {
                      context.push('/home/chat/${friend.id}');
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'chat',
                      child: Row(
                        children: [
                          Icon(Icons.chat),
                          SizedBox(width: 8),
                          Text('Chat'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'unfriend',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Unfriend'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(Icons.block, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Block'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              // Navigate to chat
            },
          );
        },
      ),
    );
  }

  Widget _buildFindFriendsTab() {
    final searchState = ref.watch(searchProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by username or email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchState.query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchProvider.notifier).clear();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              _onSearchChanged(value);
            },
          ),
        ),
        Expanded(
          child: searchState.isSearching
              ? const Center(child: CircularProgressIndicator())
              : searchState.results.isEmpty
                  ? Center(
                      child: Text(
                        searchState.query.isEmpty
                            ? 'Enter a username or email to search'
                            : 'No users found',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchState.results.length,
                      itemBuilder: (context, index) {
                        final user = searchState.results[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.profilePicture != null
                                ? NetworkImage(user.profilePicture!)
                                : null,
                            child: user.profilePicture == null
                                ? Text(user.username[0].toUpperCase())
                                : null,
                          ),
                          title: Text(user.username),
                          subtitle: Text(user.email),
                          trailing: _buildAddButton(user),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildAddButton(dynamic user) {
    if (user.isFriend) {
      return const Chip(
        label: Text('Friend'),
        backgroundColor: Colors.green,
      );
    }

    if (user.hasPendingRequest) {
      return const Chip(
        label: Text('Pending'),
        backgroundColor: Colors.orange,
      );
    }

    return TextButton(
      onPressed: () {
        ref.read(friendsProvider.notifier).sendFriendRequest(user.id);
      },
      child: const Text('Add'),
    );
  }

  void _showUnfriendConfirmation(BuildContext context, Friend friend) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Unfriend ${friend.username}?',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'You will no longer be able to message each other.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await ref.read(friendsProvider.notifier).removeFriend(friend.id);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Unfriend'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context, Friend friend) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Block ${friend.username}?',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'You will no longer be able to message each other or see their messages.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await ref.read(friendsProvider.notifier).blockUser(friend.id);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Block'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}