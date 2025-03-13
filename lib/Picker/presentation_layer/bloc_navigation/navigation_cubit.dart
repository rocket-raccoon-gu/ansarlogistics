import 'dart:async';

import 'package:bloc/bloc.dart';

part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  int preIndex = -1;
  late Stream timer;
  DateTime current = DateTime.now();
  NavigationCubit() : super(WatchlistIndexState()) {
    timer = Stream.periodic(Duration(seconds: 1), (i) {
      current = current.add(Duration(seconds: 1));
      return current;
    });
  }

  StreamController<NavIndex> adcontroller =
      StreamController<NavIndex>.broadcast();

  updateWatchList(int index, {Map<String, dynamic>? args}) {
    adcontroller.add(NavIndex(prevIndex: preIndex, currIndex: index));

    emit(WatchlistIndexState(index: index, args: args!));

    // preIndex = index;
  }

  // updatestream() {
  //   timer.listen((event) {
  //     adcontroller.add(event);
  //     // tim = event.toString();
  //   });
  //   // getstreamdata();
  // }
}

class NavIndex {
  final int prevIndex;
  final int currIndex;
  NavIndex({required this.prevIndex, required this.currIndex});
}
