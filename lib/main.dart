import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './ui/pages/calculator_page.dart';
import './ui/pages/settings_page.dart';

void _saveTheme(String theme) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("theme", theme);
}

final _store = Store<AppState>(
    combineReducers<AppState>([
      TypedReducer<AppState, ChangeTheme>((state, action) {
        state.theme = action.theme;
        _saveTheme(action.theme.toString());
        return state;
      })
    ]),
    initialState: AppState.initial());

void main() => runApp(StoreProvider<AppState>(
      store: _store,
      child: App(),
    ));

const Color primary = const Color(0xff1F3169);
const Color accent = const Color(0xffE3AAAA);

const String title = "Computer Algebra System";

enum AppTheme { Light, Dark, Amoled }

class AppState {
  AppTheme theme;
  final Color primary;
  final Color accent;
  AppState(this.theme, this.primary, this.accent);

  factory AppState.initial() => AppState(
      AppTheme.Light, const Color(0xff1F3169), const Color(0xffe3aaaa));
}

Map<String, ThemeData> themes = {
  AppTheme.Light.toString():
      ThemeData(primaryColor: primary, accentColor: accent),
  AppTheme.Dark.toString(): ThemeData(brightness: Brightness.dark),
  AppTheme.Amoled.toString(): ThemeData(
      brightness: Brightness.dark,
      canvasColor: Color(0xff000000),
      primaryColor: primary,
      accentColor: accent),
};

class ChangeTheme {
  final AppTheme theme;
  ChangeTheme(this.theme);
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, store) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: title,
            theme: themes[store.theme.toString()] ??
                themes[AppTheme.Light.toString()],
            home: MyHomePage(),
          ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentTab = 1;

  List<Widget> _children = [CalculatorPage(), CalculatorPage(), SettingsPage()];

  _onChangeTab(int tab) {
    print(tab);
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _children[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: _onChangeTab,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.view_module), title: Text("Manual")),
            BottomNavigationBarItem(
                icon: Icon(Icons.keyboard), title: Text("Calculator")),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), title: Text("Settings")),
          ]),
    );
  }
}
