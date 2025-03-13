import 'package:event_bus/event_bus.dart';

// Create a global event bus instance
EventBus eventBus = EventBus();

class DataChangedEvent {
  final String newData;
  DataChangedEvent(this.newData);
}
