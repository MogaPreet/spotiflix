import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Sections extends StatefulWidget {
  final String title;
  final int sectionCount;
  final bool showRanking;
  final VoidCallback? onSeeAllTap;

  const Sections({
    Key? key,
    required this.title,
    required this.sectionCount,
    this.showRanking = false,
    this.onSeeAllTap,
  }) : super(key: key);

  @override
  State<Sections> createState() => _SectionsState();
}

class _SectionsState extends State<Sections>
    with SingleTickerProviderStateMixin {
  final List<String> imageUrls = [
    'https://www.indiewire.com/wp-content/uploads/2017/09/imperial-dreams-2014.jpg?w=426',
    'https://www.indiewire.com/wp-content/uploads/2017/09/barry-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/crouching-tiger-hidden-dragon-sword-of-destiny-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/the-fundamentals-of-caring-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/pee-wees-big-holiday-2016.jpg?w=674',
    'https://www.indiewire.com/wp-content/uploads/2017/09/imperial-dreams-2014.jpg?w=426',
    'https://www.indiewire.com/wp-content/uploads/2017/09/barry-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/crouching-tiger-hidden-dragon-sword-of-destiny-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/the-fundamentals-of-caring-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/pee-wees-big-holiday-2016.jpg?w=674',
  ];

  final List<String> titles = [
    'Imperial Dreams',
    'Barry',
    'Crouching Tiger, Hidden Dragon',
    'The Fundamentals of Caring',
    'Pee-wee\'s Big Holiday',
    'Stranger Things',
    'The Queen\'s Gambit',
    'Breaking Bad',
    'Money Heist',
    'Dark',
  ];

  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showScrollIndicator = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  void _scrollListener() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll > 0 &&
        currentScroll < maxScroll - 20 &&
        !_showScrollIndicator) {
      setState(() {
        _showScrollIndicator = true;
      });
      _animationController.forward();
    } else if ((currentScroll <= 0 || currentScroll >= maxScroll - 20) &&
        _showScrollIndicator) {
      setState(() {
        _showScrollIndicator = false;
      });
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
              ),
              GestureDetector(
                onTap: widget.onSeeAllTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('See all ${widget.title}')));
                    },
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180, // Increased height for better visuals
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // Use this to track scroll metrics if needed
                  if (notification is ScrollEndNotification) {
                    // Optional: track end of scrolling
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.sectionCount,
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, index);
                  },
                ),
              ),
              // Scroll indicators
              if (_showScrollIndicator)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, int index) {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                // Main image container with Material for ink effects
                Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 37, 35, 35),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      splashColor: Colors.white.withOpacity(0.1),
                      onTap: () {
                        print('Navigating to movie detail: ${titles[index % titles.length]}');
                        // Navigate to movie detail page
                        Navigator.of(context).pushNamed(
                          '/movie-detail',
                          arguments: {
                            'id': 'movie_${index + 1}',
                            'title': titles[index % titles.length],
                            'imageUrl': imageUrls[index % imageUrls.length],
                            'index': index,
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrls[index % imageUrls.length],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.8, end: 1.0),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: child,
                              );
                            }
                        
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[800]!,
                              highlightColor: Colors.grey[700]!,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.grey[800],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Gradient overlay (on top of the image but below the ranking)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Ranking number (for Top 10)
                if (widget.showRanking)
                  Positioned(
                    bottom: 4,
                    right: 8,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                // Optional: Play icon overlay that appears on hover/tap
                Positioned.fill(
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: 0.0, // Set to 1.0 on hover/tap
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
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
