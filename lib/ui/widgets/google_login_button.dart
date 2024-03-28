import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sample/services/signInHandler.dart';
import 'package:sign_in_button/sign_in_button.dart';

class GoogleLoginButton extends StatefulWidget {
  const GoogleLoginButton({super.key});

  @override
  State<GoogleLoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<GoogleLoginButton> {
  late SignInHandler _signInHandler;

  @override
  void initState() {
    super.initState();
    _signInHandler = SignInHandler(context);
  }

  @override
  Widget build(BuildContext context) {
    return SignInButton(
      Buttons.googleDark,
      text: "Login with Google",
      onPressed: _signInHandler.signInWithGoogle,
    );
  }
}
