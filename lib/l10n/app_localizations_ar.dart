// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'المهام';

  @override
  String get tasks => 'المهام';

  @override
  String get tasksUnit => 'مهام';

  @override
  String get ideasUnit => 'أفكار';

  @override
  String get lists => 'القوائم';

  @override
  String get today => 'اليوم';

  @override
  String get completedTasks => 'المهام المكتملة';

  @override
  String get menu => 'القائمة';

  @override
  String get search => 'بحث';

  @override
  String get moreOptions => 'خيارات أخرى';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get myLists => 'قوائمي';

  @override
  String get syncedJustNow => 'تمت المزامنة الآن';

  @override
  String get syncing => 'جاري المزامنة…';

  @override
  String get velocityDashboard => 'لوحة الإنجاز';

  @override
  String get plusThisWeek => '+14٪ هذا الأسبوع';

  @override
  String get activeTasks => 'المهام النشطة';

  @override
  String get completed => 'مكتملة';

  @override
  String get dayStreak => 'أيام متتالية';

  @override
  String get pullDownToRefresh => 'اسحب لأسفل للتحديث';

  @override
  String get swipeRightToComplete => 'اسحب يمينًا للإكمال';

  @override
  String get newList => 'قائمة جديدة';

  @override
  String get addTask => 'إضافة مهمة';

  @override
  String get searchLists => 'البحث في القوائم';

  @override
  String get searchTasks => 'البحث في المهام';

  @override
  String get createNewList => 'إنشاء قائمة جديدة';

  @override
  String get clearCompletedTasks => 'مسح المهام المكتملة';

  @override
  String get clearCompleted => 'مسح المكتمل';

  @override
  String clearCompletedConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مهام',
      one: 'مهمة',
    );
    return 'حذف $count $_temp0 مكتملة؟';
  }

  @override
  String get clearCompletedConfirmationPermanent =>
      'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get completedTasksCleared => 'تم مسح المهام المكتملة.';

  @override
  String get noCompletedTasks => 'لا توجد مهام مكتملة بعد.';

  @override
  String get backToLists => 'العودة إلى القوائم';

  @override
  String activeTaskCount(int count) {
    return '$count مهام نشطة';
  }

  @override
  String taskCountLabel(int count) {
    return '$count مهام';
  }

  @override
  String tasksCount(int count) {
    return '$count';
  }

  @override
  String get createYourFirstList => 'أنشئ قائمتك الأولى';

  @override
  String get keepEveryPart => 'احتفظ بكل أجزاء يومك في مكان واحد.';

  @override
  String get nothingUrgentHere => 'لا توجد مهام عاجلة هنا';

  @override
  String addTaskToList(String listName) {
    return 'أضف مهمة إلى $listName عندما تكون مستعدًا.';
  }

  @override
  String get tapToEditDragToReorder => 'اضغط للتعديل · اسحب لإعادة الترتيب';

  @override
  String get typeToSearch => 'اكتب للبحث';

  @override
  String get noMatchesFound => 'لا توجد نتائج مطابقة';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get back => 'رجوع';

  @override
  String get close => 'إغلاق';

  @override
  String get newListTitle => 'قائمة جديدة';

  @override
  String get editListTitle => 'تعديل القائمة';

  @override
  String get listPurpose => 'امنح هذه المساحة غرضًا واضحًا.';

  @override
  String get listName => 'اسم القائمة';

  @override
  String get listNameHint => 'مثال: الشخصية';

  @override
  String get shortDescription => 'وصف مختصر';

  @override
  String get shortDescriptionHint => 'مثال: تم التحديث منذ 10 دقائق';

  @override
  String get accent => 'اللون';

  @override
  String get chooseListColor => 'اختر لون القائمة';

  @override
  String get taskPreview => 'معاينة المهمة';

  @override
  String get taskPreviewHint => 'س يشير إلى المهمة التالية';

  @override
  String get newListDescription => 'قائمة جديدة';

  @override
  String get addTaskPreview => 'أضف معاينة مهمة';

  @override
  String get createList => 'إنشاء القائمة';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get addTaskTitle => 'إضافة مهمة';

  @override
  String get editTaskTitle => 'تعديل المهمة';

  @override
  String get taskDescription => 'اجعلها واضحة وقابلة للتنفيذ.';

  @override
  String get taskTitle => 'عنوان المهمة';

  @override
  String get taskTitleHint => 'ما الذي يجب إنجازه؟';

  @override
  String get when => 'الموعد';

  @override
  String get whenHint => 'مثال: اليوم، نهاية الأسبوع';

  @override
  String get priority => 'الأولوية';

  @override
  String get priorityUrgent => 'الأولوية ١';

  @override
  String get priorityToday => 'اليوم';

  @override
  String get priorityUpcoming => 'قريبًا';

  @override
  String get priorityLow => 'منخفضة';

  @override
  String get prioritySomeday => 'يومًا ما';

  @override
  String get addTaskAction => 'إضافة مهمة';

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String get deleteList => 'حذف القائمة';

  @override
  String get editList => 'تعديل القائمة';

  @override
  String get deleteListQuestion => 'حذف القائمة؟';

  @override
  String deleteListMessage(String listName) {
    return 'هل تريد إزالة «$listName» ومهامها؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get taskTitleRequired => 'أضف عنوانًا لهذه المهمة.';

  @override
  String get listNameRequired => 'أدخل اسم القائمة أولًا.';

  @override
  String get complete => 'إكمال';

  @override
  String get completedTask => 'مهمة مكتملة';

  @override
  String get priorityBadge => 'الأولوية';

  @override
  String get todayLabel => 'اليوم';

  @override
  String get somedayLabel => 'يومًا ما';

  @override
  String get settings => 'الإعدادات';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get systemTheme => 'سمة النظام';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get account => 'الحساب';

  @override
  String get localOnly => 'العمل دون اتصال';

  @override
  String get connectAccount => 'ربط الحساب';

  @override
  String get signInAnonymously => 'تسجيل الدخول';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get accountConnected => 'تم ربط الحساب';

  @override
  String get dataAndPrivacy => 'البيانات والخصوصية';

  @override
  String get cloudSync => 'المزامنة السحابية';

  @override
  String get connectedToCloud => 'متصل بـ Firebase';

  @override
  String get guestMode => 'وضع الضيف';

  @override
  String get localCache => 'التخزين المحلي';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت. بياناتك المحلية متاحة.';

  @override
  String get permissionDenied => 'ليس لديك إذن للوصول إلى هذه البيانات.';

  @override
  String get unexpectedError => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جارٍ التحميل';

  @override
  String get emptyListsTitle => 'قوائمك فارغة';

  @override
  String get emptyListsMessage => 'أنشئ قائمة لتنظيم يومك.';

  @override
  String get emptyTasksTitle => 'لا توجد مهام هنا';

  @override
  String get emptyTasksMessage => 'أضف مهمة عندما تكون مستعدًا.';

  @override
  String get closeMenu => 'إغلاق القائمة';

  @override
  String get openMenu => 'فتح القائمة';

  @override
  String get openSearch => 'فتح البحث';

  @override
  String get openMoreOptions => 'فتح خيارات أخرى';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get selectTheme => 'اختر السمة';

  @override
  String get privacyNote =>
      ' يتم تخزين قوائمك على هذا الجهاز للاستخدام دون اتصال.';

  @override
  String get taskDeleted => 'تم حذف المهمة';

  @override
  String get listDeleted => 'تم حذف القائمة';

  @override
  String get clearTodays => 'مسح اليوم';

  @override
  String clearTodaysConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مهام',
      one: 'مهمة',
    );
    return 'حذف $count $_temp0 اليوم؟';
  }

  @override
  String get clearTodaysConfirmationPermanent =>
      'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get todaysTasksCleared => 'تم مسح مهام اليوم.';

  @override
  String get noTasksForToday => 'لا توجد مهام مجدولة لليوم.';
}
