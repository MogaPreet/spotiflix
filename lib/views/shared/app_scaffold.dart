import 'dart:ui';
import 'package:expproj/controllers/auth_controller.dart';
import 'package:expproj/controllers/bottom_nav_provider.dart';
import 'package:expproj/screens/homeScreen.dart';
import 'package:expproj/screens/library_screen.dart';
import 'package:expproj/screens/reels_screen.dart'; // Import the ReelsScreen
import 'package:expproj/screens/search.dart';
import 'package:expproj/services/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({Key? key}) : super(key: key);

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await SessionManager.getUser();
    if (mounted) {
      setState(() {
        userData = user;
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      final success = await authController.logout();

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        _showSnackBar('Failed to logout. Please try again.');
      }
    } catch (e) {
      // Only try to show a snackbar if we're still mounted
      if (mounted) {
        _showSnackBar('Logout error: ${e.toString()}');
      }
      print("Logout error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = Provider.of<BottomNavProvider>(context);
    final List<Widget> _pages = [
      const HomePage(),
      const ReelsScreen(), // Add ReelsScreen as the second page
      const SearchPage(),
      const LibraryPage(),
    ];

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: PreferredSize(
          // Make the AppBar slightly taller to accommodate the gradient
          preferredSize: const Size.fromHeight(60),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    // More subtle gradient
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff121212).withOpacity(0.7), // Semi-transparent at top
                        const Color(0xff121212).withOpacity(0.8),
                        const Color(0xff121212).withOpacity(0.9),
                        const Color(0xff121212).withOpacity(0.95),
                        const Color(0xff121212), // Solid at bottom
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                    // Optional: Add subtle bottom border
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
                title: _buildEnhancedTitle(context, bottomNavProvider),
              ),
            ),
          ),
        ),
        body: _pages[bottomNavProvider.currentIndex],
          resizeToAvoidBottomInset: false,

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(
                    0xff121212), // Full opacity black (completely solid)
                const Color(0xff121212)
                    .withOpacity(0.95), // Almost completely solid
                const Color(0xff121212)
                    .withOpacity(0.85), // Slightly more transparent
                const Color(0xff121212).withOpacity(0.6), // More transparent
                Colors.transparent // Fully transparent
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),
          // Add padding for iOS devices with home indicator
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom > 0
                ? 20 // For devices with home indicator like newer iPhones
                : 10, // For devices without home indicator
          ),
          // The updated BottomNavigationBar with Reels
          child: BottomNavigationBar(
            currentIndex: bottomNavProvider.currentIndex,
            onTap: (index) {
              bottomNavProvider.updateIndex(index);
            },
            elevation: 0, // Remove default shadow
            backgroundColor:
                Colors.transparent, // Fully transparent to show gradient
            selectedItemColor: Colors.white,
            unselectedItemColor:
                Colors.grey.withOpacity(0.7), // Slightly more transparent
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            type: BottomNavigationBarType.fixed,
            items: [
              // Home item with custom icon and indicator
              BottomNavigationBarItem(
                icon: bottomNavProvider.currentIndex == 0
                    ? _buildSelectedIcon(Icons.home)
                    : const Icon(Icons.home_outlined, size: 26),
                label: 'Home',
              ),
              // Reels item - NEW!
              BottomNavigationBarItem(
                icon: bottomNavProvider.currentIndex == 1
                    ? _buildSelectedIcon(Icons.movie)
                    : const Icon(Icons.movie_outlined, size: 26),
                label: 'Trailers',
              ),
              // Search item with custom icon and indicator
              BottomNavigationBarItem(
                icon: bottomNavProvider.currentIndex == 2
                    ? _buildSelectedIcon(Icons.search)
                    : const Icon(Icons.search, size: 26),
                label: 'Search',
              ),
              // Library item with custom icon and indicator
              BottomNavigationBarItem(
                icon: bottomNavProvider.currentIndex == 3
                    ? _buildSelectedIcon(Icons.library_music)
                    : const Icon(Icons.library_music_outlined, size: 26),
                label: 'Library',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced title with user greeting and profile
  Widget _buildEnhancedTitle(BuildContext context, BottomNavProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side with greeting and name
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.appBarTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (provider.currentIndex == 0) // Only show greeting on home page
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
          ],
        ),

        // Right side with user profile and notifications
        Row(
          children: [
            // Notification bell
            IconButton(
              onPressed: () {
                // Show what's new dialog or navigate to notifications
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined, size: 26),
                  // Red dot for new notifications
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),

            // Profile avatar
            isLoading
                ? _buildShimmeringAvatar()
                : GestureDetector(
                    onTap: () {
                      // Show profile menu
                      _showProfileMenu(context);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Colors.purpleAccent
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: userData != null
                          ? Center(
                              child: Text(
                                _getInitials(userData!['name']),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  // Show profile menu with user info and options
  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff121212).withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Colors.purpleAccent
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: userData != null
                          ? Text(
                              _getInitials(userData!['name']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          : const Icon(Icons.person,
                              size: 30, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        userData != null
                            ? Text(
                                userData!['name'],
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              )
                            : const Text('Loading...'),
                        const SizedBox(height: 4),
                        userData != null
                            ? Text(
                                userData!['email'] ?? 'No email',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[400],
                                    ),
                              )
                            : const Text('...'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Menu options
              _buildMenuOption(
                context,
                icon: Icons.person_outline,
                title: 'My Profile',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile page
                },
              ),
              const Divider(color: Colors.grey, height: 1, thickness: 0.2),
              _buildMenuOption(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings
                },
              ),
              const Divider(color: Colors.grey, height: 1, thickness: 0.2),
              _buildMenuOption(
                context,
                icon: Icons.logout,
                title: 'Logout',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                  _logout(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build menu options
  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.white),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  // Shimmer loading effect for avatar
  Widget _buildShimmeringAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // Get appropriate greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  // Get initials from full name
  String _getInitials(String fullName) {
    List<String> names = fullName.split(' ');
    String initials = '';

    if (names.isNotEmpty) {
      initials += names[0][0];

      if (names.length > 1) {
        initials += names[names.length - 1][0];
      }
    }

    return initials.toUpperCase();
  }

  // Add this helper method to your class
  Widget _buildSelectedIcon(IconData icon) {
    return Icon(
      icon,
      size: 26,
      color: Colors.white,
    );
  }
}
