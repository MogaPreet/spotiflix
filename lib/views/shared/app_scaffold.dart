import 'dart:ui';
import 'package:expproj/controllers/auth_controller.dart';
import 'package:expproj/controllers/bottom_nav_provider.dart';
import 'package:expproj/screens/homeScreen.dart';
import 'package:expproj/screens/library_screen.dart';
import 'package:expproj/screens/reels_screen.dart';
import 'package:expproj/screens/search.dart';
import 'package:expproj/services/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({Key? key}) : super(key: key);

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  // Animation controllers
  late AnimationController _navAnimationController;
  late AnimationController _appBarAnimationController;
  late AnimationController _fabAnimationController;

  // Animations
  late Animation<double> _navSlideAnimation;
  late Animation<double> _appBarOpacityAnimation;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _navSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.easeInOut,
    ));

    _appBarOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.easeOut,
    ));

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _appBarAnimationController.forward();
    _fabAnimationController.forward();
    // FIX: Start nav animation to slide it into view on load
    _navAnimationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await SessionManager.getUser();
      if (mounted) {
        setState(() {
          userData = user;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Failed to load user data: $e',
            backgroundColor: Colors.red[600]);
      }
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: backgroundColor ?? Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildLoadingDialog(),
      );

      final authController =
          Provider.of<AuthController>(context, listen: false);
      final success = await authController.logout();

      Navigator.of(context).pop(); // Close loading dialog

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        _showSnackBar('Failed to logout. Please try again.',
            backgroundColor: Colors.red[600]);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      if (mounted) {
        _showSnackBar('Logout error: ${e.toString()}',
            backgroundColor: Colors.red[600]);
      }
      print("Logout error: $e");
    }
  }

  Widget _buildLoadingDialog() {
    return BackdropFilter(
      filter: ImageFilter.blur(
          sigmaX: 5, sigmaY: 5), // FIX: Reduced sigma for better performance
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .scaffoldBackgroundColor
                .withOpacity(0.9), // FIX: Use theme color instead of hardcoded
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Signing out...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navAnimationController.dispose();
    _appBarAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = Provider.of<BottomNavProvider>(context);
    final List<Widget> _pages = [
      const HomePage(),
      const ReelsScreen(),
      const SearchPage(),
      const LibraryPage(),
    ];

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,

        // Enhanced AppBar with animations
       // Enhanced AppBar with animations
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(40),
  child: AnimatedBuilder(
    animation: _appBarOpacityAnimation,
    builder: (context, child) {
      return Opacity(
        opacity: _appBarOpacityAnimation.value,
        child: ClipRect(
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(240, 18, 18, 18),    // Strong at top
                    Color.fromARGB(200, 18, 18, 18),    // Medium fade
                    Color.fromARGB(160, 18, 18, 18),    // Light fade
                    Color.fromARGB(120, 18, 18, 18),    // Very light fade
                    Color.fromARGB(80, 18, 18, 18),     // Ultra light fade
                    Color.fromARGB(40, 18, 18, 18),     // Barely visible
                    Color.fromARGB(20, 18, 18, 18),     // Almost transparent
                    Color.fromARGB(10, 18, 18, 18),     // Nearly gone
                    Colors.transparent,                  // Completely transparent
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.15, 0.25, 0.35, 0.45, 0.60, 0.75, 0.90, 1.0],
                ),
                // Removed the bottom border completely
              ),
            ),
            title: _buildEnhancedTitle(context, bottomNavProvider),
          ),
        ),
      );
    },
  ),
),

        // FIX: Added AnimatedSwitcher for smooth page transitions
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _pages[bottomNavProvider.currentIndex],
        ),

        // Enhanced Bottom Navigation with animations
        bottomNavigationBar: AnimatedBuilder(
          animation: _navSlideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _navSlideAnimation.value * 100),
              child: Stack(
                children: [
                  // Enhanced backdrop blur effect
                  Positioned.fill(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                            sigmaX: 10, sigmaY: 10), // FIX: Reduced sigma
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.05),
                                Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.15),
                                Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.4),
                                Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.7),
                                Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.9),
                                Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.95),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.1, 0.25, 0.4, 0.6, 0.8, 1.0],
                            ),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withOpacity(0.08),
                                width: 0.5,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Navigation Bar Content with enhanced design
                  Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 24,
                      top: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEnhancedNavItem(
                          icon: Icons.home_rounded,
                          iconOutlined: Icons.home_outlined,
                          label: 'Home',
                          index: 0,
                          isSelected: bottomNavProvider.currentIndex == 0,
                          onTap: () => _onNavItemTapped(bottomNavProvider, 0),
                        ),
                        _buildEnhancedNavItem(
                          icon: Icons.movie_rounded,
                          iconOutlined: Icons.movie_outlined,
                          label: 'Trailers',
                          index: 1,
                          isSelected: bottomNavProvider.currentIndex == 1,
                          onTap: () => _onNavItemTapped(bottomNavProvider, 1),
                        ),
                        _buildEnhancedNavItem(
                          icon: Icons.search_rounded,
                          iconOutlined: Icons.search_outlined,
                          label: 'Search',
                          index: 2,
                          isSelected: bottomNavProvider.currentIndex == 2,
                          onTap: () => _onNavItemTapped(bottomNavProvider, 2),
                        ),
                        _buildEnhancedNavItem(
                          icon: Icons.video_library_rounded,
                          iconOutlined: Icons.video_library_outlined,
                          label: 'Library',
                          index: 3,
                          isSelected: bottomNavProvider.currentIndex == 3,
                          onTap: () => _onNavItemTapped(bottomNavProvider, 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onNavItemTapped(BottomNavProvider provider, int index) {
    HapticFeedback.lightImpact();
    provider.updateIndex(index);
  }

  // Enhanced navigation item with better animations and effects
  Widget _buildEnhancedNavItem({
    required IconData icon,
    required IconData iconOutlined,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? icon : iconOutlined,
              key: ValueKey('${index}_${isSelected}'),
              size: isSelected ? 26 : 24,
              color: isSelected ? Colors.white : Colors.grey.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.withOpacity(0.6),
                fontSize: isSelected
                    ? 12
                    : 11, // FIX: Slightly larger for readability
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced title with improved animations and effects
  Widget _buildEnhancedTitle(BuildContext context, BottomNavProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side with greeting and name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  provider.appBarTitle,
                  key: ValueKey(provider.appBarTitle),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
              ),
              // FIX: Made greeting visible on all tabs for consistency, with fade
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - value)),
                      child: Text(
                        _getGreeting(),
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Right side with enhanced notifications and profile
        Row(
          children: [
            _buildEnhancedNotificationButton(),
            const SizedBox(width: 12),
            _buildEnhancedProfileAvatar(),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedNotificationButton() {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.15), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showNotifications(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        size: 22,
                        color: Colors.white,
                      ),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedProfileAvatar() {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: isLoading
              ? _buildShimmeringAvatar()
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showProfileMenu(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Colors.purpleAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      // FIX: Fallback to icon if userData is null after loading
                      child: userData != null
                          ? Center(
                              child: Text(
                                _getInitials(userData!['name'] ?? 'Unknown'),
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
                ),
        );
      },
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildNotificationsSheet(),
    );
  }

  Widget _buildNotificationsSheet() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // FIX: Reduced sigma
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .scaffoldBackgroundColor
              .withOpacity(0.95), // FIX: Theme-aware
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced profile menu with better animations
  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // FIX: Reduced sigma
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .scaffoldBackgroundColor
                .withOpacity(0.95), // FIX: Theme-aware
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              _buildProfileHeader(),
              const SizedBox(height: 32),

              _buildMenuOption(
                context,
                icon: Icons.person_outline_rounded,
                title: 'My Profile',
                onTap: () {
                  Navigator.pop(context);
                  // FIX: Added placeholder action (navigate to profile screen)
                  _showSnackBar('Navigating to profile...');
                },
              ),
              _buildDivider(),
              _buildMenuOption(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  // FIX: Added placeholder action
                  _showSnackBar('Opening settings...');
                },
              ),
              _buildDivider(),
              _buildMenuOption(
                context,
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () {
                  Navigator.pop(context);
                  // FIX: Added placeholder action
                  _showSnackBar('Opening help...');
                },
              ),
              _buildDivider(),
              _buildMenuOption(
                context,
                icon: Icons.logout_rounded,
                title: 'Logout',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                  _logout(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Colors.purpleAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: userData != null
                ? Text(
                    _getInitials(userData!['name'] ?? 'Unknown'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  )
                : const Icon(Icons.person, size: 35, color: Colors.white),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userData != null
                  ? Text(
                      userData!['name'] ?? 'Unknown User',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    )
                  : const Text('Guest'), // FIX: Fallback if loading fails
              const SizedBox(height: 6),
              userData != null
                  ? Text(
                      userData!['email'] ?? 'No email',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[400],
                          ),
                    )
                  : const Text('guest@example.com'), // FIX: Fallback
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.withOpacity(0.2),
      height: 1,
      thickness: 0.5,
      indent: 0,
      endIndent: 0,
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (color ?? Colors.white).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color ?? Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color ?? Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmeringAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          shape: BoxShape.circle,
        ),
      ),
    );
  }

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
}
