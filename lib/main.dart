import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:zm_supplier/utils/constants.dart';
import 'login/login_page.dart';
import 'home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user.dart';
import 'utils/constants.dart';

void main() async {
  Constants.setEnvironment(Environment.PROD);
  WidgetsFlutterBinding.ensureInitialized();
  await Intercom.initialize('lzmzad7p',
      iosApiKey: '"ios_sdk-3089316353932af1f13250c1743f44f1df7db154',
      androidApiKey: 'android_sdk-8489ca5c3a3f6865ef14e664df8dd2e738bdece4');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  LoginResponse loginResponse = LoginResponse.fromJson(
      json.decode(prefs.getString(Constants.login_Info)));
  print(loginResponse.mudra);
  bool isLogged = false;
  final isLoggedIn = prefs.getBool(Constants.is_logged);
  if (isLoggedIn != null) {
    await Intercom.registerIdentifiedUser(userId: loginResponse.mudra);
    print(loginResponse.mudra);
    isLogged = isLoggedIn;
  }
  final ZmApp myApp = ZmApp(
    initialRoute: isLogged ? '/home' : '/login',
  );
  runApp(myApp);
}

class ZmApp extends StatelessWidget {
  final String initialRoute;

  ZmApp({this.initialRoute});

  @override
  Widget build(BuildContext context) {
    Constants.setEnvironment(Environment.PROD);
    print(initialRoute);

    return MaterialApp(
      title: 'Supplier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
