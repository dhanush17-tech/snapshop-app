import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:hack_princeton/screens/chat.dart';
import 'package:hack_princeton/screens/explore.dart';
import 'package:hack_princeton/screens/signin.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool checkIfLoggedIn() {
    if (FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  int _selectedIndex = 0; // Add this line

  @override
  Widget build(BuildContext context) {
    //checkIfLoggedIn() ? ChatPage() :
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: //SignupScreen()
            checkIfLoggedIn() ? nav() : SignupScreen());
  }

  final PageController _controller = PageController(initialPage: 0);
  Widget nav() {
    final iconSize = 30.0;
    final iconColor = Theme.of(context).primaryColor;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          child: PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [ChatPage(), Explore()],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Container(
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width - 90,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  left: _selectedIndex == 0
                      ? 0
                      : (MediaQuery.of(context).size.width - 110) / 2,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 240,
                    height: 40,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1),
                        BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1)
                      ],
                      borderRadius: BorderRadius.circular(10),
                      color: Color(4288452249).withOpacity(0.4),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      child: IconButton(
                        onPressed: () {
                          _controller.animateToPage(0,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut);
                          setState(() {
                            _selectedIndex = 0;
                          });
                        },
                        icon: Icon(
                          Icons.home_rounded,
                          color: _selectedIndex != 0 ? iconColor : Colors.grey,
                          size: iconSize,
                        ),
                      ),
                    ),
                    Container(
                      width: 120,
                      child: IconButton(
                        onPressed: () {
                          _controller.animateToPage(1,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut);
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                        icon: Icon(
                          Icons.local_fire_department_outlined,
                          color: _selectedIndex != 1 ? iconColor : Colors.grey,
                          size: iconSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
