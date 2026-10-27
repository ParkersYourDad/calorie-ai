import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  bool get isArabic => locale.languageCode == 'ar';

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings)!;

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  String get appName => 'Calorie AI';
  String get today => isArabic ? 'اليوم' : 'Today';
  String get yesterday => isArabic ? 'أمس' : 'Yesterday';
  String get dailyOverview => isArabic ? 'ملخص يومك' : 'Daily overview';
  String get meals => isArabic ? 'الوجبات' : 'Meals';
  String get addMeal => isArabic ? 'إضافة وجبة' : 'Add meal';
  String get addFirstMeal => isArabic ? 'سجّل أول وجبة' : 'Log your first meal';
  String get noMealsYet => isArabic ? 'لا توجد وجبات بعد' : 'No meals yet';
  String get emptyMealsHint => isArabic
      ? 'أضف وجبتك الأولى لبدء متابعة يومك.'
      : 'Add your first meal to start tracking your day.';
  String get caloriesConsumed =>
      isArabic ? 'السعرات المستهلكة' : 'Calories consumed';
  String get kcal => 'kcal';
  String get dailyGoal =>
      isArabic ? 'هدف السعرات اليومي' : 'Daily calorie goal';
  String get setGoal => isArabic ? 'تحديد الهدف' : 'Set goal';
  String get editGoal => isArabic ? 'تعديل الهدف' : 'Edit goal';
  String get goalNotSet => isArabic
      ? 'حدّد هدفًا يوميًا لمتابعة تقدمك.'
      : 'Set a daily goal to track your progress.';
  String get remaining => isArabic ? 'متبقي' : 'remaining';
  String get overGoal => isArabic ? 'تجاوزت الهدف بمقدار' : 'over goal';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get caloriesPerDay =>
      isArabic ? 'السعرات في اليوم' : 'Calories per day';
  String get goalHint => isArabic ? 'مثال: 2000' : 'e.g. 2000';
  String get enterValidGoal => isArabic
      ? 'أدخل رقمًا بين 1 و100000'
      : 'Enter a number between 1 and 100,000';
  String get foodName => isArabic ? 'اسم الطعام' : 'Food name';
  String get foodNameHint => isArabic ? 'مثال: شوفان بالحليب' : 'e.g. Oatmeal';
  String get calories => isArabic ? 'السعرات (kcal)' : 'Calories (kcal)';
  String get caloriesHint => isArabic ? 'مثال: 320' : 'e.g. 320';
  String get mealType => isArabic ? 'نوع الوجبة' : 'Meal type';
  String get enterFoodName =>
      isArabic ? 'اكتب اسم الطعام' : 'Enter a food name';
  String get enterValidCalories => isArabic
      ? 'أدخل سعرات صحيحة من 0 إلى 100000'
      : 'Enter a valid amount from 0 to 100,000';
  String get breakfast => isArabic ? 'الإفطار' : 'Breakfast';
  String get lunch => isArabic ? 'الغداء' : 'Lunch';
  String get dinner => isArabic ? 'العشاء' : 'Dinner';
  String get snack => isArabic ? 'وجبة خفيفة' : 'Snack';
  String get removeMeal => isArabic ? 'حذف الوجبة' : 'Remove meal';
  String get undo => isArabic ? 'تراجع' : 'Undo';
  String get mealRemoved => isArabic ? 'تم حذف الوجبة' : 'Meal removed';
  String get saveFailed => isArabic
      ? 'تعذّر حفظ التغيير على الجهاز.'
      : 'Could not save this change on your device.';
  String get storedDataWarning => isArabic
      ? 'تعذّرت قراءة بعض البيانات المحفوظة. قد لا تظهر السجلات التالفة.'
      : 'Some saved data could not be read. Damaged entries may be missing.';
  String get previousDay => isArabic ? 'اليوم السابق' : 'Previous day';
  String get nextDay => isArabic ? 'اليوم التالي' : 'Next day';
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get appearance => isArabic ? 'المظهر' : 'Appearance';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get system => isArabic ? 'النظام' : 'System';
  String get light => isArabic ? 'فاتح' : 'Light';
  String get dark => isArabic ? 'داكن' : 'Dark';
  String get deviceLanguage => isArabic ? 'تلقائي' : 'Device';
  String get settingsHint => isArabic
      ? 'يُحفظ اختيارك على هذا الجهاز.'
      : 'Your choices are saved on this device.';
  String get loading => isArabic ? 'جارٍ تحميل البيانات' : 'Loading your data';
  String get loadFailed => isArabic
      ? 'تعذّر تحميل البيانات المحفوظة.'
      : 'Could not load your saved data.';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Try again';

  String mealTypeLabel(String type) => switch (type) {
        'breakfast' => breakfast,
        'lunch' => lunch,
        'dinner' => dinner,
        _ => snack,
      };

  String dateLabel(DateTime date, DateTime todayDate) {
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(todayDate.year, todayDate.month, todayDate.day);
    if (day == today) return this.today;
    if (day == today.subtract(const Duration(days: 1))) return yesterday;

    if (isArabic) {
      final weekday = _arabicWeekdays[date.weekday - 1];
      final dayNumber = _arabicDigits(date.day);
      final month = _arabicMonths[date.month - 1];
      return '$weekday، $dayNumber $month';
    }
    final weekday = _weekdays[date.weekday - 1];
    final month = _months[date.month - 1];
    return '$weekday, $month ${date.day}';
  }

  String number(int value) => _digits(value);

  String caloriesValue(int value) => '${_digits(value)} $kcal';

  String remainingLabel(int value, {required bool exceeded}) {
    final amount = _digits(value.abs());
    if (isArabic) {
      return exceeded
          ? 'تجاوزت الهدف بمقدار $amount kcal'
          : 'متبقي $amount kcal';
    }
    return exceeded ? '$amount kcal $overGoal' : '$amount kcal $remaining';
  }

  String percentage(int value) => '${_digits(value)}%';

  String _digits(int value) {
    final text = value.toString();
    return isArabic ? _arabicDigitsText(text) : text;
  }

  static String _arabicDigits(int value) => _arabicDigitsText(value.toString());

  static String _arabicDigitsText(String value) {
    const western = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return value.split('').map((character) {
      final index = western.indexOf(character);
      return index < 0 ? character : arabic[index];
    }).join();
  }

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _arabicWeekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const _arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'ar';

  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture(AppStrings(locale));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
