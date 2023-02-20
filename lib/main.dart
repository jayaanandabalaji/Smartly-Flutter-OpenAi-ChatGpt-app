import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/code_generate.dart';
import 'screens/dashboard_screen.dart';
import 'screens/translate_screen.dart';
import 'utils/constants.dart';
import 'screens/image_generate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xff374DBC, colorMap),
      ),
      home: const NavBar(),
    );
  }
}

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      navBarStyle: NavBarStyle.style3,
      backgroundColor: Constants.backgroundColor,
      screens: const [
        Dashboard(),
        CodeScreen(),
        ImageGeneration(),
        TranslateScreen()
      ],
      items: [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.message),
          title: ("Chat"),
          activeColorPrimary: Constants.primaryColor,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.code),
          title: ("Code"),
          activeColorPrimary: Constants.primaryColor,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.image),
          title: ("Image"),
          activeColorPrimary: Constants.primaryColor,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.language),
          title: ("Translate"),
          activeColorPrimary: Constants.primaryColor,
          inactiveColorPrimary: Colors.grey,
        ),
      ],
    );
  }
}

Map<int, Color> colorMap = {
  50: const Color.fromRGBO(147, 205, 72, .1),
  100: const Color.fromRGBO(147, 205, 72, .2),
  200: const Color.fromRGBO(147, 205, 72, .3),
  300: const Color.fromRGBO(147, 205, 72, .4),
  400: const Color.fromRGBO(147, 205, 72, .5),
  500: const Color.fromRGBO(147, 205, 72, .6),
  600: const Color.fromRGBO(147, 205, 72, .7),
  700: const Color.fromRGBO(147, 205, 72, .8),
  800: const Color.fromRGBO(147, 205, 72, .9),
  900: const Color.fromRGBO(147, 205, 72, 1),
};
