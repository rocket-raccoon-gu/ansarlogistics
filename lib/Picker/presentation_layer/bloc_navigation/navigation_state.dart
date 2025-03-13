part of 'navigation_cubit.dart';

abstract class NavigationState {}

class WatchlistIndexState extends NavigationState {
  int index;
  Map<String, dynamic> args;
  WatchlistIndexState({this.index = 0, this.args = const {}});
}
