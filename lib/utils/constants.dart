import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/**
 * Created by RajPrudhviMarella on 11/Feb/2021.
 */

class Constants {
  // Strings
  static const String app_name = "Zeemart Supplier";
  static const String txt_change_password = "Change password";
  static const String txt_help = "Help";
  static const String txt_ask_zeemart = "Ask Zeemart";
  static const String txt_send_feed_back = "Send feedback";
  static const String txt_terms_of_use = "Terms of use";
  static const String txt_privacy_policy = "Privacy policy";
  static const String txt_log_out = "Sign out";
  static const String txt_support = "Support";
  static const String txt_account = "Account";
  static const String txt_ok = "OK";
  static const String txt_cancel = "Cancel";
  static const String txt_confirm_logout = "Are you sure you want to sign out?";
  static const String txt_select_from = "Change profile photo";
  static const String txt_take_photo = "Take photo";
  static const String txt_select_library = "Select from library";

  static const String txt_login = "Login";
  static const String txt_reset_password = "Reset Password";
  static const String txt_alert_message = "please enter valid email/password";
  static const String txt_alert_email_message = "please enter valid email";
  static const String login_Info = "loginInfo";
  static const String PASSWORD_ENCRYPTED = "PASSWORD_ENCRYPTED";
  static const String specific_user_info = "specificUserInfo";

  static const String txt_current_password = "Current password";
  static const String txt_enter_current_password = "Enter current password";
  static const String txt_new_password_min = "New password (min. 8 characters)";
  static const String txt_enter_new_password = "Enter new password";
  static const String txt_enter_new_password_again = "Enter new password again";
  static const String txt_invalid_password = "Invalid password";
  static const String txt_password_updated = "Password updated";
  static const String txt_for_security_login_again = "For security reasons, please login again";
  static const String txt_incorrect_current_password =
      "Incorrect current password";
  static const String txt_password_requirements =
      "Include at least 1 lowercase and uppercase letters, 1 number, and 1 symbol/special character.";

  static const String is_logged = "isLogged";
  static const String status_success = "Success";
  static const String txt_new_password_didnt_match =
      "New password does not match Confirm password.";
  static const String txt_resend_otp = "Resend OTP";
  static const String txt_something_wrong = "Something went wrong. please try again";

  static const String termsUrl = "https://www.zeemart.asia/terms";
  static const String privacyUrl = "https://www.zeemart.asia/privacy-policy";
  static const String txt_orders = "Orders";
  static const String txt_deliveries = "Deliveries";
}

class SharedPref {
  saveData(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(key));
  }
}
