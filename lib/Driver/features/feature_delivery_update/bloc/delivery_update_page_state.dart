abstract class DeliveryUpdatePageState {}

class DeliveryUpdatePageInitial extends DeliveryUpdatePageState {}

class DeliveryBillUpdatedState extends DeliveryUpdatePageState {
  bool uploaded;

  DeliveryBillUpdatedState(this.uploaded);
}

class DeliveryBillUpdateErrorState extends DeliveryUpdatePageState {
  DeliveryBillUpdateErrorState();
}

class DeliveryStatusUpdateState extends DeliveryUpdatePageState {
  DeliveryStatusUpdateState();
}
