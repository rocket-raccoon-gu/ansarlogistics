abstract class SelectRegionPageState {}

class SelectRegionInitialState extends SelectRegionPageState {}

class SelectRegionLoadingState extends SelectRegionPageState {}

class SelectRegionReadyState extends SelectRegionPageState {
  final String? selectedRegion;
  SelectRegionReadyState({this.selectedRegion});
}
