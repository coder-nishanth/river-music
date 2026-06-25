part of 'home_cubit.dart';

@immutable
sealed class HomeState {
  const HomeState();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeError extends HomeState {
  final String? message;
  final String? stackTrace;
  const HomeError([this.message, this.stackTrace]);
}

final class HomeSuccess extends HomeState {
  final List chips;
  final List sections;
  final bool loadingMore;
  final String? continuation;
  final Map<String, dynamic>? repoOfTheDay;
  const HomeSuccess({
    required this.chips,
    required this.sections,
    required this.continuation,
    required this.loadingMore,
    this.repoOfTheDay,
  });

  HomeSuccess copyWith({
    List? chips,
    List? sections,
    String? continuation,
    bool? loadingMore,
    Map<String, dynamic>? repoOfTheDay,
  }) {
    return HomeSuccess(
      chips: chips ?? this.chips,
      sections: sections ?? this.sections,
      continuation: continuation ?? this.continuation,
      loadingMore: loadingMore ?? this.loadingMore,
      repoOfTheDay: repoOfTheDay ?? this.repoOfTheDay,
    );
  }
}
