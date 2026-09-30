import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/todo_repository.dart';
import '../../../models/todo_models.dart';

enum TodoStatus { initial, loading, loaded, empty, error }

class TodoState {
  const TodoState({
    required this.repository,
    this.status = TodoStatus.initial,
    this.errorMessage,
  });

  final TodoRepository repository;
  final TodoStatus status;
  final String? errorMessage;

  bool get isLoading => status == TodoStatus.loading;

  TodoState copyWith({TodoStatus? status, String? errorMessage}) {
    return TodoState(
      repository: repository,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class TodoCubit extends Cubit<TodoState> {
  TodoCubit(this.repository) : super(TodoState(repository: repository)) {
    repository.addListener(_repositoryChanged);
    unawaited(load());
  }

  final TodoRepository repository;

  void _repositoryChanged() {
    if (isClosed) return;
    final isEmpty = repository.lists.isEmpty;
    emit(
      state.copyWith(
        status: isEmpty ? TodoStatus.empty : TodoStatus.loaded,
      ),
    );
  }

  Future<void> load() async {
    emit(state.copyWith(status: TodoStatus.loading));
    try {
      await repository.hydrate();
      emit(
        state.copyWith(
          status: repository.lists.isEmpty
              ? TodoStatus.empty
              : TodoStatus.loaded,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TodoStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refresh() => repository.sync();

  void addList(TodoList list) => repository.addList(list);

  void updateList(TodoList list) => repository.updateList(list);

  void removeList(String id) => repository.removeList(id);

  void addTask(TodoTask task) => repository.addTask(task);

  void updateTask(TodoTask task) => repository.updateTask(task);

  void toggleTask(String id) => repository.toggleTask(id);

  void removeTask(String id) => repository.removeTask(id);

  void clearCompleted({String? listId}) =>
      repository.clearCompleted(listId: listId);

  void reorderTasks(String listId, int oldIndex, int newIndex) =>
      repository.reorderTasks(listId, oldIndex, newIndex);

  @override
  Future<void> close() async {
    repository.removeListener(_repositoryChanged);
    return super.close();
  }
}
