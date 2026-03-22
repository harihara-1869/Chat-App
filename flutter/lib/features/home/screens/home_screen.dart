import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../friends/providers/friend_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load friends on init
    Future.microtask(() {
      ref.read(friendsProvider.notifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final pendingCount = ref.watch(pendingRequestsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Chats' : _currentIndex == 1 ? 'Friends' : 'Settings'),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search
              },
            ),
          if (_currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                context.push(RoutePaths.friends);
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildChatsTab(),
          _buildFriendsTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text(pendingCount.toString()),
              child: const Icon(Icons.people_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text(pendingCount.toString()),
              child: const Icon(Icons.people),
            ),
            label: 'Friends',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildChatsTab() {
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
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add friends to start chatting',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.push(RoutePaths.friends);
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
              friend.isOnline ? 'Online' : friend.lastSeen != null
                  ? 'Last seen ${_formatLastSeen(friend.lastSeen!)}'
                  : 'Offline',
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
              context.go('/home/chat/${friend.id}');
            },
          );
        },
      ),
    );
  }

  Widget _buildFriendsTab() {
    return const FriendsListContent();
  }

  Widget _buildSettingsTab() {
    final user = ref.watch(currentUserProvider);

    return ListView(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: user?.profilePicture != null
                ? NetworkImage(user!.profilePicture!)
                : null,
            child: user?.profilePicture == null
                ? Text(user?.username[0].toUpperCase() ?? 'U')
                : null,
          ),
          title: Text(user?.username ?? 'User'),
          subtitle: Text(user?.email ?? ''),
          onTap: () {
            context.push(RoutePaths.profile);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Edit Profile'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push(RoutePaths.profile);
          },
        ),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Theme'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push(RoutePaths.settings);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push(RoutePaths.privacyPolicy);
          },
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Terms & Conditions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push(RoutePaths.termsConditions);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) {
              context.go(RoutePaths.login);
            }
          },
        ),
      ],
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Friends list content widget
class FriendsListContent extends ConsumerWidget {
  const FriendsListContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsState = ref.watch(friendsProvider);
    final pendingRequests = friendsState.pendingRequests;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(friendsProvider.notifier).refresh();
      },
      child: CustomScrollView(
        slivers: [
          // Pending requests section
          if (pendingRequests.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Friend Requests (${pendingRequests.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final request = pendingRequests[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: request.senderProfilePicture != null
                          ? NetworkImage(request.senderProfilePicture!)
                          : null,
                      child: request.senderProfilePicture == null
                          ? Text(request.senderUsername[0].toUpperCase())
                          : null,
                    ),
                    title: Text(request.senderUsername),
                    subtitle: const Text('Wants to be your friend'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            ref
                                .read(friendsProvider.notifier)
                                .acceptFriendRequest(request.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            ref
                                .read(friendsProvider.notifier)
                                .rejectFriendRequest(request.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
                childCount: pendingRequests.length,
              ),
            ),
            const SliverToBoxAdapter(child: Divider()),
          ],

          // All friends section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Friends (${friendsState.friends.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (friendsState.friends.isEmpty)
            SliverFillRemaining(
              child: Center(
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
                        context.push(RoutePaths.friends);
                      },
                      child: const Text('Find Friends'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
                      context.go('/home/chat/${friend.id}');
                    },
                  );
                },
                childCount: friendsState.friends.length,
              ),
            ),
        ],
      ),
    );
  }
}