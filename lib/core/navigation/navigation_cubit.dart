import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationState {
  const NavigationState({
    this.selectedIndex = 0,
    this.selectedListId = 'personal',
    this.isListOpened = false,
  });

  final int selectedIndex;
  final String selectedListId;
  final bool isListOpened;

  NavigationState copyWith({
    int? selectedIndex,
    String? selectedListId,
    bool? isListOpened,
  }) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedListId: selectedListId ?? this.selectedListId,
      isListOpened: isListOpened ?? this.isListOpened,
    );
  }
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit({String initialListId = 'personal'})
      : super(NavigationState(selectedListId: initialListId));

  void selectDestination(int index) {
    if (index < 0 || index > 2 || index == state.selectedIndex) return;
    emit(state.copyWith(selectedIndex: index, isListOpened: false));
  }

  void openList(String listId) {
    emit(
      state.copyWith(
        selectedListId: listId,
        isListOpened: true,
      ),
    );
  }

  void showLists() {
    if (state.selectedIndex == 0 && !state.isListOpened) return;
    emit(state.copyWith(selectedIndex: 0, isListOpened: false));
  }

  void showToday({String? listId}) {
    emit(
      state.copyWith(
        selectedIndex: 1,
        selectedListId: listId ?? state.selectedListId,
        isListOpened: false,
      ),
    );
  }

  void showCompleted() => selectDestination(2);
}