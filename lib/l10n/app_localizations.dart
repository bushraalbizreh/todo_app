import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get appTitle;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @tasksUnit.
  ///
  /// In en, this message translates to:
  /// **'tasks'**
  String get tasksUnit;

  /// No description provided for @ideasUnit.
  ///
  /// In en, this message translates to:
  /// **'ideas'**
  String get ideasUnit;

  /// No description provided for @lists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get lists;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @completedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get completedTasks;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @myLists.
  ///
  /// In en, this message translates to:
  /// **'My Lists'**
  String get myLists;

  /// No description provided for @syncedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Synced just now'**
  String get syncedJustNow;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @velocityDashboard.
  ///
  /// In en, this message translates to:
  /// **'Velocity Dashboard'**
  String get velocityDashboard;

  /// No description provided for @plusThisWeek.
  ///
  /// In en, this message translates to:
  /// **'+14% this week'**
  String get plusThisWeek;

  /// No description provided for @activeTasks.
  ///
  /// In en, this message translates to:
  /// **'Active Tasks'**
  String get activeTasks;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// No description provided for @pullDownToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;

  /// No description provided for @swipeRightToComplete.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to complete'**
  String get swipeRightToComplete;

  /// No description provided for @newList.
  ///
  /// In en, this message translates to:
  /// **'New List'**
  String get newList;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @searchLists.
  ///
  /// In en, this message translates to:
  /// **'Search lists'**
  String get searchLists;

  /// No description provided for @searchTasks.
  ///
  /// In en, this message translates to:
  /// **'Search tasks'**
  String get searchTasks;

  /// No description provided for @createNewList.
  ///
  /// In en, this message translates to:
  /// **'Create a new list'**
  String get createNewList;

  /// No description provided for @clearCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'Clear completed tasks'**
  String get clearCompletedTasks;

  /// No description provided for @clearCompleted.
  ///
  /// In en, this message translates to:
  /// **'Clear Completed'**
  String get clearCompleted;

  /// No description provided for @clearCompletedConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} completed {count, plural, one{task} other{tasks}}?'**
  String clearCompletedConfirmation(int count);

  /// No description provided for @clearCompletedConfirmationPermanent.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get clearCompletedConfirmationPermanent;

  /// No description provided for @completedTasksCleared.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks cleared.'**
  String get completedTasksCleared;

  /// No description provided for @noCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'No completed tasks yet.'**
  String get noCompletedTasks;

  /// No description provided for @backToLists.
  ///
  /// In en, this message translates to:
  /// **'Back to lists'**
  String get backToLists;

  /// No description provided for @activeTaskCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active tasks'**
  String activeTaskCount(int count);

  /// No description provided for @taskCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String taskCountLabel(int count);

  /// No description provided for @tasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String tasksCount(int count);

  /// No description provided for @createYourFirstList.
  ///
  /// In en, this message translates to:
  /// **'Create your first list'**
  String get createYourFirstList;

  /// No description provided for @keepEveryPart.
  ///
  /// In en, this message translates to:
  /// **'Keep every part of your day in one place.'**
  String get keepEveryPart;

  /// No description provided for @nothingUrgentHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing urgent here'**
  String get nothingUrgentHere;

  /// No description provided for @addTaskToList.
  ///
  /// In en, this message translates to:
  /// **'Add a task to {listName} when you are ready.'**
  String addTaskToList(String listName);

  /// No description provided for @tapToEditDragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit · Drag to reorder'**
  String get tapToEditDragToReorder;

  /// No description provided for @typeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search'**
  String get typeToSearch;

  /// No description provided for @noMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get noMatchesFound;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @newListTitle.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get newListTitle;

  /// No description provided for @editListTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get editListTitle;

  /// No description provided for @listPurpose.
  ///
  /// In en, this message translates to:
  /// **'Give this space a clear purpose.'**
  String get listPurpose;

  /// No description provided for @listName.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listName;

  /// No description provided for @listNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Personal'**
  String get listNameHint;

  /// No description provided for @shortDescription.
  ///
  /// In en, this message translates to:
  /// **'Short description'**
  String get shortDescription;

  /// No description provided for @shortDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Updated 10m ago'**
  String get shortDescriptionHint;

  /// No description provided for @accent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get accent;

  /// No description provided for @chooseListColor.
  ///
  /// In en, this message translates to:
  /// **'Choose list color'**
  String get chooseListColor;

  /// No description provided for @taskPreview.
  ///
  /// In en, this message translates to:
  /// **'Task preview'**
  String get taskPreview;

  /// No description provided for @taskPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'A line that hints at the next task'**
  String get taskPreviewHint;

  /// No description provided for @newListDescription.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get newListDescription;

  /// No description provided for @addTaskPreview.
  ///
  /// In en, this message translates to:
  /// **'Add a task preview'**
  String get addTaskPreview;

  /// No description provided for @createList.
  ///
  /// In en, this message translates to:
  /// **'Create list'**
  String get createList;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @addTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTaskTitle;

  /// No description provided for @editTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTaskTitle;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep it actionable and easy to scan.'**
  String get taskDescription;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitle;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What needs to be done?'**
  String get taskTitleHint;

  /// No description provided for @when.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get when;

  /// No description provided for @whenHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Today, This weekend'**
  String get whenHint;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Priority 1'**
  String get priorityUrgent;

  /// No description provided for @priorityToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get priorityToday;

  /// No description provided for @priorityUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get priorityUpcoming;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @prioritySomeday.
  ///
  /// In en, this message translates to:
  /// **'Someday'**
  String get prioritySomeday;

  /// No description provided for @addTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTaskAction;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @deleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get deleteList;

  /// No description provided for @editList.
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get editList;

  /// No description provided for @deleteListQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete list?'**
  String get deleteListQuestion;

  /// No description provided for @deleteListMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove “{listName}” and its tasks?'**
  String deleteListMessage(String listName);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @taskTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a title for this task.'**
  String get taskTitleRequired;

  /// No description provided for @listNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your list a name first.'**
  String get listNameRequired;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @completedTask.
  ///
  /// In en, this message translates to:
  /// **'Completed task'**
  String get completedTask;

  /// No description provided for @priorityBadge.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityBadge;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @somedayLabel.
  ///
  /// In en, this message translates to:
  /// **'Someday'**
  String get somedayLabel;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get systemTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @localOnly.
  ///
  /// In en, this message translates to:
  /// **'Working offline'**
  String get localOnly;

  /// No description provided for @connectAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect account'**
  String get connectAccount;

  /// No description provided for @signInAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInAnonymously;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @accountConnected.
  ///
  /// In en, this message translates to:
  /// **'Account connected'**
  String get accountConnected;

  /// No description provided for @dataAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & privacy'**
  String get dataAndPrivacy;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get cloudSync;

  /// No description provided for @connectedToCloud.
  ///
  /// In en, this message translates to:
  /// **'Connected to Firebase'**
  String get connectedToCloud;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest mode'**
  String get guestMode;

  /// No description provided for @localCache.
  ///
  /// In en, this message translates to:
  /// **'Local cache'**
  String get localCache;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Your local data is still available.'**
  String get noInternet;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this data.'**
  String get permissionDenied;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened. Please try again.'**
  String get unexpectedError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @emptyListsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your lists are empty'**
  String get emptyListsTitle;

  /// No description provided for @emptyListsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a list to start organizing your day.'**
  String get emptyListsMessage;

  /// No description provided for @emptyTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks here'**
  String get emptyTasksTitle;

  /// No description provided for @emptyTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a task when you are ready.'**
  String get emptyTasksMessage;

  /// No description provided for @closeMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get closeMenu;

  /// No description provided for @openMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get openMenu;

  /// No description provided for @openSearch.
  ///
  /// In en, this message translates to:
  /// **'Open search'**
  String get openSearch;

  /// No description provided for @openMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'Open more options'**
  String get openMoreOptions;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get selectTheme;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your lists are cached on this device for offline use.'**
  String get privacyNote;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeleted;

  /// No description provided for @listDeleted.
  ///
  /// In en, this message translates to:
  /// **'List deleted'**
  String get listDeleted;

  /// No description provided for @clearTodays.
  ///
  /// In en, this message translates to:
  /// **'Clear Today'**
  String get clearTodays;

  /// No description provided for @clearTodaysConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} today\'s {count, plural, one{task} other{tasks}}?'**
  String clearTodaysConfirmation(int count);

  /// No description provided for @clearTodaysConfirmationPermanent.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get clearTodaysConfirmationPermanent;

  /// No description provided for @todaysTasksCleared.
  ///
  /// In en, this message translates to:
  /// **'Today\'s tasks cleared.'**
  String get todaysTasksCleared;

  /// No description provided for @noTasksForToday.
  ///
  /// In en, this message translates to:
  /// **'No tasks scheduled for today.'**
  String get noTasksForToday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
