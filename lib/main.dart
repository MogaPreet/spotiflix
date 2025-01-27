import 'package:expproj/screens/homeScreen.dart';
import 'package:expproj/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          scaffoldBackgroundColor: const Color.fromARGB(255, 18, 18, 18),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color.fromARGB(255, 18, 18, 18),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 18, 18, 18),
          )),
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
        leadingWidth: 56,
        leading: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                  BorderSide(color: Colors.yellowAccent.withOpacity(.5))),
              color: Colors.purple),
          child: const Text(
            "P",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        title: Text(bottomNavProvider.appBarTitle),
        actions: const [
          Padding(
              padding: EdgeInsets.only(right: 15), child: Icon(Icons.settings))
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
