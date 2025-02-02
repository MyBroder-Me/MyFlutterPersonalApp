import 'package:flutter/material.dart';
import 'package:myapp/controller/pages/login_page.dart';
import 'package:myapp/controller/pages/sign_up_page.dart';
import 'package:myapp/view/menu.dart';

class NavigationService {
  NavigationService._privateConstructor();

  static final NavigationService _instance =
      NavigationService._privateConstructor();

  factory NavigationService() {
    return _instance;
  }

  void navigateToLogin(context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void navigateToSignUp(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  void navigateToMain(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => Menu()),
    );
  }
}
