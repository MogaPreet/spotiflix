import 'dart:ui';

import 'package:expproj/screens/homeScreen.dart';
import 'package:expproj/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BottomNavProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'UI',
  debugShowCheckedModeBanner: false,
  theme: ThemeData.dark(
    useMaterial3: true,
  ).copyWith(
    scaffoldBackgroundColor: const Color(0xFF121212), // Deep Black
    primaryColor: const Color(0xFFBF3A34), // Deep Coral
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFBF3A34), // Deep Coral
      secondary: Color(0xFF1DB954), // Spotify Green
      error: Color(0xFFE50914), // Netflix Red
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFFBF3A34), // Cursor in Primary Color
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins().copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 32,
      ),
      displayMedium: GoogleFonts.poppins().copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      displaySmall: GoogleFonts.poppins().copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 20,
      ),
      bodyLarge: GoogleFonts.poppins().copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins().copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.poppins().copyWith(
        color: Color(0xFFB3B3B3),
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      titleLarge: GoogleFonts.poppins().copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      titleMedium: GoogleFonts.poppins().copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleSmall: GoogleFonts.poppins().copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      labelLarge: GoogleFonts.poppins().copyWith(
        color: const Color(0xFFBF3A34), // Primary for Emphasis
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      labelMedium: GoogleFonts.poppins().copyWith(
        color: const Color(0xFF1DB954), // Spotify Green for CTA
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelSmall: GoogleFonts.poppins().copyWith(
        color: const Color(0xFFE50914), // Netflix Red for Alerts
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    ),
  ),
  themeMode: ThemeMode.dark,
  home: const AppScaffold(),
);

  }
}

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = Provider.of<BottomNavProvider>(context);
    final List<Widget> _pages = [
      const HomePage(),
      const SearchPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Colors.transparent,
        elevation: 0,
       
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Frosted effect
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 0, 0, 0),
                    Color.fromARGB(180, 0, 0, 0),
                    Color.fromARGB(100, 0, 0, 0),
                    Color.fromARGB(30, 0, 0, 0),
                    Colors.transparent
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.0,
                    0.4,
                    0.65,
                    0.85,
                    1.0
                  ], // Adjusted for smoother fade
                ),
              ),
            ),
          ),
        ),
        leading: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.yellowAccent.withOpacity(.5)),
            ),
            color: Colors.purple,
          ),
          child: Text(
            "P",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
          ),
        ),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bottomNavProvider.appBarTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade700,
              highlightColor: Colors.grey.shade500,
              period: const Duration(seconds: 2),
              child: Text(
                "Your binge starts here",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            )
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 65,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(200, 0, 0, 0),
            Color.fromARGB(155, 0, 0, 0),
            Color.fromARGB(80, 0, 0, 0),
            Colors.transparent
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.0, 0.3, 0.50, 0.7, 1.0],
        )),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          currentIndex: bottomNavProvider.currentIndex,
          onTap: (index) => bottomNavProvider.updateIndex(index),
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_rounded),
              label: 'Library',
            ),
          ],
        ),
      ),
      body: _pages[bottomNavProvider.currentIndex],
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final void Function()? onTap;
  const BottomNavItem({super.key, this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            title,
            style: const TextStyle(
                color: Color(0xffababab),
                fontWeight: FontWeight.w500,
                fontSize: 11),
          )
        ],
      ),
    ));
  }
}

class BottomNavProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void updateIndex(int newIndex) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  String get appBarTitle {
    switch (_currentIndex) {
      case 0:
        return 'Good Afternoon!';
      case 1:
        return 'Search';
      case 2:
        return 'Library';
      default:
        return 'SNT';
    }
  }
}
