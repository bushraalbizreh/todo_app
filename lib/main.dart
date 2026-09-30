import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/localization/localization.dart';
import 'core/navigation/navigation_cubit.dart';
import 'core/services/firebase_service.dart';
import 'core/settings/settings_cubit.dart';
import 'core/settings/settings_sheet.dart';
import 'core/storage/app_storage.dart';
import 'core/theme/app_theme.dart';
import 'data/todo_repository.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/todo/data/todo_local_data_source.dart';
import 'features/todo/data/todo_remote_data_source.dart';
import 'features/todo/presentation/todo_cubit.dart';
import 'screens/completed_tasks_screen.dart';
import 'screens/lists_overview_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/today_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await openAppStorage();
  final firebase = await FirebaseService.initialize();
  runApp(MyApp(storage: storage, firebase: firebase));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.storage, this.firebase});

  final AppStorage? storage;
  final FirebaseService? firebase;

  @override
  Widget build(BuildContext context) {
    final appStorage = storage ?? MemoryAppStorage();
    final firebaseService = firebase ?? const FirebaseService();
    final todoRepository = TodoRepository.seeded(
      localDataSource: TodoLocalDataSource(appStorage),
      remoteDataSource: TodoRemoteDataSource(firebaseService.firestore),
      userId: firebaseService.auth?.currentUser?.uid ?? 'guest',
    );
    final authRepository = AuthRepository(
      AuthRemoteDataSource(firebaseService.auth),
    );

    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(
            repository: SettingsRepository(appStorage),
          ),
        ),
        BlocProvider<NavigationCubit>(
          create: (_) => NavigationCubit(),
        ),
        BlocProvider<TodoCubit>(
          create: (_) => TodoCubit(todoRepository),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authRepository),
        ),
      ],
      child: _AuthScopedRepositories(
        todoRepository: todoRepository,
        child: const _AppView(),
      ),
    );
  }
}

/// Repositories namespace their Firestore data by user. When someone signs in
/// (or out) we retarget them so guest data stops being written to the account
/// path and vice versa.
class _AuthScopedRepositories extends StatelessWidget {
  const _AuthScopedRepositories({
    required this.todoRepository,
    required this.child,
  });

  final TodoRepository todoRepository;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.user?.uid != current.user?.uid,
      listener: (context, state) {
        final userId = state.user?.uid ?? 'guest';
        todoRepository.setUserId(userId);
      },
      child: child,
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp(
          title: 'Tasks',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale?.languageCode == 'ar') return const Locale('ar');
            return const Locale('en');
          },
          home: const HomeShell(),
        );
      },
    );
  }
}

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, todoState) {
        final repository = todoState.repository;
        return BlocBuilder<NavigationCubit, NavigationState>(
          builder: (context, navigation) {
            if (navigation.selectedIndex == 0 && !navigation.isListOpened) {
              return ListsOverviewScreen(
                repository: repository,
                onOpenList: (listId) =>
                    context.read<NavigationCubit>().openList(listId),
                onDestinationSelected: (index) =>
                    context.read<NavigationCubit>().selectDestination(index),
                onOpenSettings: () => showSettingsSheet(context),
              );
            }

            if (navigation.selectedIndex == 1 && !navigation.isListOpened) {
              // Today screen - shows tasks from all lists due today
              return TodayScreen(
                repository: repository,
                onDestinationSelected: (index) =>
                    context.read<NavigationCubit>().selectDestination(index),
                onOpenSettings: () => showSettingsSheet(context),
              );
            }

            if (navigation.selectedIndex == 1 && navigation.isListOpened ||
                navigation.selectedIndex == 0 && navigation.isListOpened) {
              final selectedList = repository.listById(navigation.selectedListId) ??
                  (repository.lists.isEmpty ? null : repository.lists.first);
              if (selectedList == null) {
                return ListsOverviewScreen(
                  repository: repository,
                  onOpenList: (listId) =>
                      context.read<NavigationCubit>().openList(listId),
                  onDestinationSelected: (index) =>
                      context.read<NavigationCubit>().selectDestination(index),
                  onOpenSettings: () => showSettingsSheet(context),
                );
              }
              return TasksScreen(
                repository: repository,
                list: selectedList,
                onBack: () => context.read<NavigationCubit>().showLists(),
                onDestinationSelected: (index) =>
                    context.read<NavigationCubit>().selectDestination(index),
                onOpenSettings: () => showSettingsSheet(context),
              );
            }

            // Completed Tasks (index 2)
            return CompletedTasksScreen(
              repository: repository,
              onDestinationSelected: (index) =>
                  context.read<NavigationCubit>().selectDestination(index),
              onOpenSettings: () => showSettingsSheet(context),
            );
          },
        );
      },
    );
  }
}