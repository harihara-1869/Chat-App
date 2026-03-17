import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
            trailing: friend.isOnline
                ? Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
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
              ref.read(searchProvider.notifier).search(value);
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
}