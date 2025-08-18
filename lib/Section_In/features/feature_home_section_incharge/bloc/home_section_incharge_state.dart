import 'package:picker_driver_api/responses/branch_section_data_response.dart';
import 'package:picker_driver_api/responses/section_item_response.dart';

abstract class HomeSectionInchargeState {}

class HomeSectionInchargeInitial extends HomeSectionInchargeState {
  List<Sectionitem> sectionitems = [];
  List<Branchdatum> branchdata = [];
  bool isSearching = false;
  HomeSectionInchargeInitial({
    required this.sectionitems,
    required this.branchdata,
    this.isSearching = false,
  });
}

class HomeSectionInchargeLoading extends HomeSectionInchargeState {}
