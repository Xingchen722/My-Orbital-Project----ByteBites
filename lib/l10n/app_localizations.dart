import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String>? _localizedStrings;

  Future<bool> load() async {
    String jsonContent = await rootBundle
        .loadString('assets/l10n/intl_${locale.languageCode}.arb');
    _localizedStrings = Map<String, String>.from(json.decode(jsonContent));
    return true;
  }

  String translate(String key) {
    return _localizedStrings?[key] ?? key;
  }

  // 添加常用文本的便捷访问方法
  String get login => translate('login');
  String get register => translate('register');
  String get username => translate('username');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get invalidCredentials => translate('invalidCredentials');
  String get noUsersRegistered => translate('noUsersRegistered');
  String get passwordsNotMatch => translate('passwordsNotMatch');
  String get usernameExists => translate('usernameExists');
  String get registeredSuccessfully => translate('registeredSuccessfully');
  String get studentUser => translate('studentUser');
  String get vendorUser => translate('vendorUser');
  String get registeringAs => translate('registeringAs');
  String get canteen => translate('canteen');
  String get explore => translate('explore');
  String get profile => translate('profile');
  String get dashboard => translate('dashboard');
  String get noMatchingUsers => translate('noMatchingUsers');
  String get loading => translate('loading');
  String get viewProfile => translate('viewProfile');
  String get nickname => translate('nickname');
  String get dietaryPreference => translate('dietaryPreference');
  String get language => translate('language');
  String get canteenName => translate('canteenName');
  String get manageCanteenOrders => translate('manageCanteenOrders');
  String get viewOrderCanteens => translate('viewOrderCanteens');
  String get languageChanged => translate('languageChanged');
}