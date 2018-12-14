import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/util/functional_interfaces.dart';

/// The login form provides text fields for entering the login data.
class LoginForm extends StatefulWidget {
  /// Callback to check whether the provided username and password are correct.
  final BiFunc<Future<bool>, String, String> _onLoginAttempt;

  /// Callback deciding on what to do in case the form finished.
  final Runnable _onSuccess;

  /// Create login form.
  LoginForm({@required BiFunc<Future<bool>, String, String> onLoginAttempt, @required Runnable onSuccess})
      : _onLoginAttempt = onLoginAttempt,
        _onSuccess = onSuccess;

  @override
  State<StatefulWidget> createState() => _LoginFormState(_onLoginAttempt, _onSuccess);
}

/// State of the login form.
class _LoginFormState extends State<LoginForm> {
  /// Key of this form used to validate the form later.
  final _formKey = GlobalKey<FormState>();

  /// Callback to check provided username and password.
  final BiFunc<Future<bool>, String, String> _onLoginAttempt;

  /// Callback which will run when the form finishes.
  final Runnable _onSuccess;

  /// Controller managing username text field contents.
  final TextEditingController _usernameController = TextEditingController();

  /// Controller managing password text field contents.
  final TextEditingController _passwordController = TextEditingController();

  /// Create the login form state.
  _LoginFormState(this._onLoginAttempt, this._onSuccess);

  @override
  Widget build(BuildContext context) {
    return Form(key: _formKey, child: Column(children: _buildFormContents()));
  }

  /// Build contents of the form (input fields, buttons, ...).
  List<Widget> _buildFormContents() => <Widget>[
        TextFormField(
          decoration: InputDecoration(hintText: "Benutzername", icon: Icon(Icons.person)),
          validator: (value) {
            if (value.isEmpty) {
              return "Bitte geben Sie einen Benutzernamen an";
            }
          },
          controller: _usernameController,
        ),
        TextFormField(
          decoration: InputDecoration(hintText: "Passwort", icon: Icon(Icons.lock)),
          validator: (value) {
            if (value.isEmpty) {
              return "Bitte geben Sie ein Password an";
            }
          },
          obscureText: true,
          controller: _passwordController,
        ),
        _buildSubmitButton()
      ];

  /// Build button for submitting form data.
  Widget _buildSubmitButton() => Center(
        child: RaisedButton(onPressed: () => _submitForm()),
      );

  /// Submit the form and validate input fields.
  void _submitForm() async {
    if (_formKey.currentState.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      // Show a snack bar until the credentials have been checked.
      var snackBarController = Scaffold.of(context).showSnackBar(SnackBar(content: Text("Überprüfe Anmeldedaten...")));

      bool success = await _onLoginAttempt(username, password);

      // Close snack bar.
      snackBarController.close();

      if (success) {
        _onSuccess();
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Anmeldeversuch fehlgeschlagen. :(")));
      }
    }
  }
}
