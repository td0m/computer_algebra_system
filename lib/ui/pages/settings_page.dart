import 'package:computer_algebra_system/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

InputDecoration outlinedTextField = InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    labelText: 'Equation / Expression',
    hintText: "Type a math problem");

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _showDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return SelectThemeDialog();
        });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (context, store) => Container(
            margin: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.palette),
                  title: Text("Theme"),
                  subtitle: Text(store.state.theme.toString().split(".").last),
                  onTap: () => _showDialog(),
                ),
              ],
            )));
  }
}

class SelectThemeDialog extends StatefulWidget {
  @override
  _SelectThemeDialogState createState() => _SelectThemeDialogState();
}

class _SelectThemeDialogState extends State<SelectThemeDialog> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (context, store) => AlertDialog(
            title: Text("Select Your Theme"),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(AppTheme.values.length, (i) => i)
                    .map((i) => RadioListTile(
                          value: i,
                          groupValue: store.state.theme == AppTheme.values[i]
                              ? i
                              : i + 1,
                          title: Text(
                              AppTheme.values[i].toString().split(".").last),
                          onChanged: (name) {
                            store.dispatch(ChangeTheme(AppTheme.values[i]));
                          },
                        ))
                    .toList())));
  }
}
