import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/home/entities/home_data.dart';
import '../../domain/home/usecases/get_home.dart';

class HomeState {
  const HomeState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  final HomeData? data;
  final bool isLoading;
  final String? errorMessage;

  HomeState copyWith({
    HomeData? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  HomeController({required GetHome getHome})
      : _getHome = getHome,
        super(const HomeState());

  final GetHome _getHome;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _getHome();
      state = state.copyWith(data: data, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refresh() => load();
}
