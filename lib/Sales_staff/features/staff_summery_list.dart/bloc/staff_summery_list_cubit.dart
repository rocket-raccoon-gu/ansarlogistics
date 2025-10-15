import 'dart:convert';

import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'staff_summery_list_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';

class StaffSummeryListCubit extends Cubit<StaffSummeryListState> {
  final ServiceLocator serviceLocator;
  BuildContext context;
  StaffSummeryListCubit({required this.serviceLocator, required this.context})
    : super(StaffSummeryListInitialState()) {
    loadpage();
  }

  final int _limit = 10;
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final List<Map<String, dynamic>> _items = [];
  Map<String, dynamic> _summary = {};

  Future<void> loadpage({DateTime? date}) async {
    _page = 1;
    _hasMore = true;
    _items.clear();
    emit(StaffSummeryListLoadingState());
    await _fetchPage(reset: true, date: date);
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _page += 1;
    await _fetchPage(reset: false);
  }

  Future<void> _fetchPage({required bool reset, DateTime? date}) async {
    try {
      _isLoading = true;
      final response = await serviceLocator.tradingApi.getStaffSummaryData(
        staffCode: UserController.userController.profile.empId,
        date: date,
        page: _page,
        limit: _limit,
      );

      if (response != null && response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          final List<Map<String, dynamic>> pageItems =
              ((decoded['data'] as List?) ?? [])
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e as Map),
                  )
                  .toList();
          _summary = Map<String, dynamic>.from(
            (decoded['summary'] ?? {}) as Map,
          );

          if (reset) {
            _items
              ..clear()
              ..addAll(pageItems);
          } else {
            _items.addAll(pageItems);
          }

          if (pageItems.length < _limit) {
            _hasMore = false;
          }

          emit(
            StaffSummeryListSuccessState(
              data: List<Map<String, dynamic>>.from(_items),
              summary: _summary,
            ),
          );
        } else {
          emit(
            StaffSummeryListErrorState(
              (decoded['message'] ?? 'Failed').toString(),
            ),
          );
        }
      }
    } catch (e) {
      emit(StaffSummeryListErrorState(e.toString()));
    } finally {
      _isLoading = false;
    }
  }
}
