// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tasks';

  @override
  String get tasks => 'Tasks';

  @override
  String get tasksUnit => 'tasks';

  @override
  String get ideasUnit => 'ideas';

  @override
  String get lists => 'Lists';

  @override
  String get today => 'Today';

  @override
  String get completedTasks => 'Completed Tasks';

  @override
  String get menu => 'Menu';

  @override
  String get search => 'Search';

  @override
  String get moreOptions => 'More options';

  @override
  String get overview => 'Overview';

  @override
  String get myLists => 'My Lists';

  @override
  String get syncedJustNow => 'Synced just now';

  @override
  String get syncing => 'Syncing…';

  @override
  String get velocityDashboard => 'Velocity Dashboard';

  @override
  String get plusThisWeek => '+14% this week';

  @override
  String get activeTasks => 'Active Tasks';

  @override
  String get completed => 'Completed';

  @override
  String get dayStreak => 'Day Streak';

  @override
  String get pullDownToRefresh => 'Pull down to refresh';

  @override
  String get swipeRightToComplete => 'Swipe right to complete';

  @override
  String get newList => 'New List';

  @override
  String get addTask => 'Add Task';

  @override
  String get searchLists => 'Search lists';

  @override
  String get searchTasks => 'Search tasks';

  @override
  String get createNewList => 'Create a new list';

  @override
  String get clearCompletedTasks => 'Clear completed tasks';

  @override
  String get clearCompleted => 'Clear Completed';

  @override
  String clearCompletedConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tasks',
      one: 'task',
    );
    return 'Delete $count completed $_temp0?';
  }

  @override
  String get clearCompletedConfirmationPermanent =>
      'This action cannot be undone.';

  @override
  String get completedTasksCleared => 'Completed tasks cleared.';

  @override
  String get noCompletedTasks => 'No completed tasks yet.';

  @override
  String get backToLists => 'Back to lists';

  @override
  String activeTaskCount(int count) {
    return '$count active tasks';
  }

  @override
  String taskCountLabel(int count) {
    return '$count tasks';
  }

  @override
  String tasksCount(int count) {
    return '$count';
  }

  @override
  String get createYourFirstList => 'Create your first list';

  @override
  String get keepEveryPart => 'Keep every part of your day in one place.';

  @override
  String get nothingUrgentHere => 'Nothing urgent here';

  @override
  String addTaskToList(String listName) {
    return 'Add a task to $listName when you are ready.';
  }

  @override
  String get tapToEditDragToReorder => 'Tap to edit · Drag to reorder';

  @override
  String get typeToSearch => 'Type to search';

  @override
  String get noMatchesFound => 'No matches found';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get newListTitle => 'New list';

  @override
  String get editListTitle => 'Edit list';

  @override
  String get listPurpose => 'Give this space a clear purpose.';

  @override
  String get listName => 'List name';

  @override
  String get listNameHint => 'e.g. Personal';

  @override
  String get shortDescription => 'Short description';

  @override
  String get shortDescriptionHint => 'e.g. Updated 10m ago';

  @override
  String get accent => 'Accent';

  @override
  String get chooseListColor => 'Choose list color';

  @override
  String get taskPreview => 'Task preview';

  @override
  String get taskPreviewHint => 'A line that hints at the next task';

  @override
  String get newListDescription => 'New list';

  @override
  String get addTaskPreview => 'Add a task preview';

  @override
  String get createList => 'Create list';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get addTaskTitle => 'Add task';

  @override
  String get editTaskTitle => 'Edit task';

  @override
  String get taskDescription => 'Keep it actionable and easy to scan.';

  @override
  String get taskTitle => 'Task title';

  @override
  String get taskTitleHint => 'What needs to be done?';

  @override
  String get when => 'When';

  @override
  String get whenHint => 'e.g. Today, This weekend';

  @override
  String get priority => 'Priority';

  @override
  String get priorityUrgent => 'Priority 1';

  @override
  String get priorityToday => 'Today';

  @override
  String get priorityUpcoming => 'Upcoming';

  @override
  String get priorityLow => 'Low';

  @override
  String get prioritySomeday => 'Someday';

  @override
  String get addTaskAction => 'Add task';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get deleteList => 'Delete list';

  @override
  String get editList => 'Edit list';

  @override
  String get deleteListQuestion => 'Delete list?';

  @override
  String deleteListMessage(String listName) {
    return 'Remove “$listName” and its tasks?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get taskTitleRequired => 'Add a title for this task.';

  @override
  String get listNameRequired => 'Give your list a name first.';

  @override
  String get complete => 'Complete';

  @override
  String get completedTask => 'Completed task';

  @override
  String get priorityBadge => 'Priority';

  @override
  String get todayLabel => 'Today';

  @override
  String get somedayLabel => 'Someday';

  @override
  String get settings => 'Settings';

  @override
  String get preferences => 'Preferences';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get systemTheme => 'System theme';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get account => 'Account';

  @override
  String get localOnly => 'Working offline';

  @override
  String get connectAccount => 'Connect account';

  @override
  String get signInAnonymously => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get accountConnected => 'Account connected';

  @override
  String get dataAndPrivacy => 'Data & privacy';

  @override
  String get cloudSync => 'Cloud sync';

  @override
  String get connectedToCloud => 'Connected to Firebase';

  @override
  String get guestMode => 'Guest mode';

  @override
  String get localCache => 'Local cache';

  @override
  String get noInternet =>
      'No internet connection. Your local data is still available.';

  @override
  String get permissionDenied =>
      'You do not have permission to access this data.';

  @override
  String get unexpectedError =>
      'Something unexpected happened. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading';

  @override
  String get emptyListsTitle => 'Your lists are empty';

  @override
  String get emptyListsMessage => 'Create a list to start organizing your day.';

  @override
  String get emptyTasksTitle => 'No tasks here';

  @override
  String get emptyTasksMessage => 'Add a task when you are ready.';

  @override
  String get closeMenu => 'Close menu';

  @override
  String get openMenu => 'Open menu';

  @override
  String get openSearch => 'Open search';

  @override
  String get openMoreOptions => 'Open more options';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get selectTheme => 'Select theme';

  @override
  String get privacyNote =>
      'Your lists are cached on this device for offline use.';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get listDeleted => 'List deleted';

  @override
  String get clearTodays => 'Clear Today';

  @override
  String clearTodaysConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tasks',
      one: 'task',
    );
    return 'Delete $count today\'s $_temp0?';
  }

  @override
  String get clearTodaysConfirmationPermanent =>
      'This action cannot be undone.';

  @override
  String get todaysTasksCleared => 'Today\'s tasks cleared.';

  @override
  String get noTasksForToday => 'No tasks scheduled for today.';
}
