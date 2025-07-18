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
  String get appTitle => translate('appTitle');
  String get viewMenu => translate('viewMenu');
  String get menuNotification => translate('menuNotification');
  String get writeReview => translate('writeReview');
  String get selectRating => translate('selectRating');
  String get writeYourReview => translate('writeYourReview');
  String get pleaseWriteReview => translate('pleaseWriteReview');
  String get pleaseSelectRating => translate('pleaseSelectRating');
  String get submit => translate('submit');
  String get cancel => translate('cancel');
  String get reviews => translate('reviews');
  String get noReviewsYet => translate('noReviewsYet');
  String get viewAllReviews => translate('viewAllReviews');
  String get reviewSubmitted => translate('reviewSubmitted');
  String get minutesAgo => translate('minutesAgo');
  String get hoursAgo => translate('hoursAgo');
  String get yesterday => translate('yesterday');
  String get daysAgo => translate('daysAgo');
  String get canteenDescriptionSummit => translate('canteenDescriptionSummit');
  String get canteenDescriptionFrontier => translate('canteenDescriptionFrontier');
  String get canteenDescriptionTechno => translate('canteenDescriptionTechno');
  String get canteenDescriptionPGP => translate('canteenDescriptionPGP');
  String get canteenDescriptionDeck => translate('canteenDescriptionDeck');
  String get canteenDescriptionTerrace => translate('canteenDescriptionTerrace');
  String get canteenDescriptionYIH => translate('canteenDescriptionYIH');
  String get canteenDescriptionFineFood => translate('canteenDescriptionFineFood');
  String get funInteraction => translate('funInteraction');
  String get funInteractionDescription => translate('funInteractionDescription');
  String get tryFunInteraction => translate('tryFunInteraction');
  String get selectMode => translate('selectMode');
  String get wheel => translate('wheel');
  String get dice => translate('dice');
  String get selectType => translate('selectType');
  String get custom => translate('custom');
  String get defaultOption => translate('defaultOption');
  String get customFoods => translate('customFoods');
  String get noCustomFoods => translate('noCustomFoods');
  String get addCustomFood => translate('addCustomFood');
  String get enterFoodName => translate('enterFoodName');
  String get add => translate('add');
  String get spinWheel => translate('spinWheel');
  String get spinning => translate('spinning');
  String get rollDice => translate('rollDice');
  String get rolling => translate('rolling');
  String get result => translate('result');
  String get ok => translate('ok');
  String get sortByDistance => translate('sortByDistance');
  String get sortByRating => translate('sortByRating');
  String get sortByName => translate('sortByName');
  String get searchByDish => translate('searchByDish');
  String get noCanteenFound => translate('noCanteenFound');
  String get queueCrowded => translate('queueCrowded');
  String get queueMedium => translate('queueMedium');
  String get queueFew => translate('queueFew');
  String get queueEstimationButton => translate('queueEstimationButton');
  String get favoriteOnly => translate('favoriteOnly');
  String get queueEstimationTitle => translate('queueEstimationTitle');
  String get distance => translate('distance');
  String get vendorReply => translate('vendorReply');
  // 新增退出登录
  String get logout => translate('logout');
  String get addDish => translate('addDish');
  String get editDish => translate('editDish');
  String get dishName => translate('dishName');
  String get description => translate('description');
  String get price => translate('price');
  String get replyToReview => translate('replyToReview');
  String get reply => translate('reply');
  String get english => translate('english');
  String get chinese => translate('chinese');
  String get canteenDescription => translate('canteenDescription');
  String get editCanteenDescription => translate('editCanteenDescription');
  String get enterCanteenDescription => translate('enterCanteenDescription');
  String get noDescription => translate('noDescription');
  String get enterAnnouncementContent => translate('enterAnnouncementContent');
  String get canteenEnvironmentImages => translate('canteenEnvironmentImages');
  String get uploadEnvironmentImages => translate('uploadEnvironmentImages');
  String get openingHours => translate('openingHours');
  String get address => translate('address');
  String get canteenId => translate('canteenId');
  String get updated => translate('updated');
}