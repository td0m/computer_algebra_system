import 'package:flutter/material.dart';
import './ui/pages/calculator_page.dart';

// run the application
void main() => runApp(
      App(),
    );

// define colours and app title
const Color primary = const Color(0xff1F3169);
const Color accent = const Color(0xffE3AAAA);
const String title = "Computer Algebra System";

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // defines a material design app
    return MaterialApp(
      // disable a message showing that the app is in debug mode
      debugShowCheckedModeBanner: false,
      // define the theme
      theme: ThemeData(
        primaryColor: primary,
        accentColor: accent,
      ),
      // set the title of the app
      title: title,
      // scaffold is required as a root component for material components to function properly
      home: Scaffold(
        // define the top bar and its title
        appBar: AppBar(
          title: Text(title),
        ),
        // define the page to display
        body: CalculatorPage(),
      ),
    );
  }
}
