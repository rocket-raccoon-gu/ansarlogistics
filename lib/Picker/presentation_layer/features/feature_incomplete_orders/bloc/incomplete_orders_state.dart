abstract class IncompleteOrdersState {}

class IncompleteOrdersInitial extends IncompleteOrdersState {}

class IncompleteOrdersLoading extends IncompleteOrdersState {}

class IncompleteOrdersLoaded extends IncompleteOrdersState {
  // final List<Order> orders;
  IncompleteOrdersLoaded();
}

class IncompleteOrdersError extends IncompleteOrdersState {
  final String message;
  IncompleteOrdersError({required this.message});
}
