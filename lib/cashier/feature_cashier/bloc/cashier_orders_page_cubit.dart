import 'package:ansarlogistics/cashier/feature_cashier/bloc/cashier_orders_page_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/cashier_order_response.dart';

class CashierOrdersPageCubit extends Cubit<CashierOrdersPageState> {
  final ServiceLocator serviceLocator;
  final BuildContext context;

  // pagination state
  int _page = 1;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasNext = true;
  final List<Datum> _items = [];
  int _totalCount = 0;

  CashierOrdersPageCubit({required this.serviceLocator, required this.context})
    : super(CashierOrdersPageStateInitial()) {
    loadOrders(reset: true);
  }

  Future<void> loadOrders({bool reset = false}) async {
    if (_isLoading) return;

    if (reset) {
      _page = 1;
      _hasNext = true;
      _items.clear();
      _totalCount = 0;
      emit(CashierOrdersPageStateLoading());
    }

    if (!_hasNext) {
      // nothing more to load; still emit latest success state
      emit(
        CashierOrdersPageStateSuccess(
          cashierOrders: CashierOrders(
            success: true,
            count: _items.length,
            totalCount: _totalCount,
            pagination: Pagination(
              currentPage: _page,
              totalPages: _page,
              totalItems: _totalCount,
              itemsPerPage: _limit,
              hasNext: _hasNext,
              hasPrev: _page > 1,
            ),
            data: _items,
          ),
        ),
      );
      return;
    }

    _isLoading = true;
    try {
      final response = await serviceLocator.tradingApi.getCashierOrders(
        page: _page,
        limit: _limit,
        token: UserController.userController.app_token,
      );

      if (response == null ||
          !(response is dynamic && response.statusCode != null)) {
        emit(CashierOrdersPageStateError(message: 'Failed to load orders'));
        _isLoading = false;
        return;
      }

      if (response.statusCode != 200) {
        emit(
          CashierOrdersPageStateError(
            message: response.body?.toString() ?? 'Unknown error',
          ),
        );
        _isLoading = false;
        return;
      }

      final CashierOrders cashierOrders = cashierOrdersFromJson(response.body);

      // Update pagination flags
      _totalCount = cashierOrders.totalCount;
      _hasNext = cashierOrders.pagination.hasNext;

      // Append items
      _items.addAll(cashierOrders.data);

      emit(
        CashierOrdersPageStateSuccess(
          cashierOrders: CashierOrders(
            success: true,
            count: _items.length,
            totalCount: _totalCount,
            pagination: Pagination(
              currentPage: _page,
              totalPages: _page,
              totalItems: _totalCount,
              itemsPerPage: _limit,
              hasNext: _hasNext,
              hasPrev: _page > 1,
            ),
            data: _items,
          ),
        ),
      );
    } catch (e) {
      emit(CashierOrdersPageStateError(message: e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasNext) return;

    // Emit loading-more state using current data
    emit(
      CashierOrdersPageStateSuccess(
        cashierOrders: CashierOrders(
          success: true,
          count: _items.length,
          totalCount: _totalCount,
          pagination: Pagination(
            currentPage: _page,
            totalPages: _page,
            totalItems: _totalCount,
            itemsPerPage: _limit,
            hasNext: _hasNext,
            hasPrev: _page > 1,
          ),
          data: List<Datum>.unmodifiable(_items),
        ),
        isLoadingMore: true,
      ),
    );

    _isLoading = true;
    _page += 1;

    try {
      final response = await serviceLocator.tradingApi.getCashierOrders(
        page: _page,
        limit: _limit,
        token: UserController.userController.app_token,
      );

      if (response == null ||
          !(response is dynamic && response.statusCode != null)) {
        // revert page on failure
        _page -= 1;
        emit(
          CashierOrdersPageStateError(message: 'Failed to load more orders'),
        );
        return;
      }

      if (response.statusCode != 200) {
        _page -= 1;
        emit(
          CashierOrdersPageStateError(
            message: response.body?.toString() ?? 'Unknown error',
          ),
        );
        return;
      }

      final CashierOrders cashierOrders = cashierOrdersFromJson(response.body);

      _hasNext = cashierOrders.pagination.hasNext;
      _totalCount = cashierOrders.totalCount;
      _items.addAll(cashierOrders.data);

      emit(
        CashierOrdersPageStateSuccess(
          cashierOrders: CashierOrders(
            success: true,
            count: _items.length,
            totalCount: _totalCount,
            pagination: Pagination(
              currentPage: _page,
              totalPages: _page,
              totalItems: _totalCount,
              itemsPerPage: _limit,
              hasNext: _hasNext,
              hasPrev: _page > 1,
            ),
            data: List<Datum>.unmodifiable(_items),
          ),
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      _page -= 1;
      emit(CashierOrdersPageStateError(message: e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    await loadOrders(reset: true);
  }

  Future<void> searchOrders(String key) async {
    final term = key.trim();
    if (term.isEmpty) return;

    // 1) Try local match first
    final Set<int> seenSuborderIds = {};
    final List<Datum> localMatches = [];
    for (final d in _items) {
      final idMatch =
          d.orderId.toString() == term || d.suborderId.toString() == term;
      final subgroupMatch = d.subgroupIdentifier.toLowerCase().contains(
        term.toLowerCase(),
      );
      if ((idMatch || subgroupMatch) && seenSuborderIds.add(d.suborderId)) {
        localMatches.add(d);
      }
    }

    if (localMatches.isNotEmpty) {
      emit(
        CashierOrdersPageStateSuccess(
          cashierOrders: CashierOrders(
            success: true,
            count: localMatches.length,
            totalCount: localMatches.length,
            pagination: Pagination(
              currentPage: 1,
              totalPages: 1,
              totalItems: localMatches.length,
              itemsPerPage: localMatches.length,
              hasNext: false,
              hasPrev: false,
            ),
            data: List<Datum>.unmodifiable(localMatches),
          ),
        ),
      );
      return;
    }

    // 2) Fallback to API search
    emit(CashierOrdersPageStateLoading());
    try {
      final response = await serviceLocator.tradingApi.getCashierOrdersSearch(
        key: term,
        token: UserController.userController.app_token,
      );

      if (response == null ||
          !(response is dynamic && response.statusCode != null)) {
        emit(CashierOrdersPageStateError(message: 'Failed to search orders'));
        return;
      }

      if (response.statusCode != 200) {
        emit(
          CashierOrdersPageStateError(
            message: response.body?.toString() ?? 'Unknown error',
          ),
        );
        return;
      }

      final CashierOrders result = cashierOrdersFromJson(response.body);
      emit(CashierOrdersPageStateSuccess(cashierOrders: result));
    } catch (e) {
      emit(CashierOrdersPageStateError(message: e.toString()));
    }
  }
}
