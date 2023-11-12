import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  // Define the default brightness and colors.
  brightness: Brightness.light,
  backgroundColor: Color.fromARGB(255, 230, 229, 230),
  primaryColor: Color(4293123808),
  highlightColor: Color(4281959396),

  // Define the default font family.

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    displaySmall: GoogleFonts.poppins(
        fontSize: 15,
        color: Color(4288452249),
        fontWeight: FontWeight.w500), //For the user chat text,
    headlineSmall: GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 15,
      color: Colors.black,
    ), //for the ai chat text,

    headlineLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black), //for the ai Bold text,
  ),

  // Define the default `IconTheme`. Use this to specify the default
  // icon themes for `Icon` widgets.
  iconTheme: IconThemeData(
    color: Color(4281959396),
  ),

  // Define the default `AppBarTheme`. Use this to specify the default
  // AppBar theme if you used an AppBar in your screen.

  // Add more theme customization if needed, like button themes, card themes etc.
);

// Use this theme in your main.dart file by passing it to the MaterialApp constructor.
// MaterialApp(
//   theme: appTheme,
//   home: TextbookListScreen(),
// );
