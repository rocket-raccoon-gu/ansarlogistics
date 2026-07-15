import 'package:ansarlogistics/Driver/features/feature_payment_collection/bloc/payment_collection_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_payment_collection/bloc/payment_collection_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picker_driver_api/responses/order_response.dart';

void main() {
  group('PaymentCollectionCubit', () {
    test('initializes payment method from the order response', () {
      final order = Order.fromJson({
        'entity_id': '1',
        'subgroup_identifier': 'SG-1',
        'status': 'delivered',
        'type': 'EXP',
        'delivery_from': '2026-07-14T10:00:00.000Z',
        'delivery_to': '2026-07-14T11:00:00.000Z',
        'grand_total': '250.00',
        'shipped_amount': 0,
        'status_type': null,
        'delivery_timerange': null,
        'customer_firstname': 'Test',
        'customer_lastname': 'User',
        'billing_street': 'Street',
        'customer_email': 'test@example.com',
        'postcode': '12345',
        'building_number': '',
        'telephone': '123456789',
        'latitude': '0',
        'longitude': '0',
        'payment_method': 'Card On Delivery',
        'delivery_note': '',
        'address_label': '',
        'building_name': null,
        'flat_number': null,
        'floor_number': null,
        'items': {'end_picking': []},
        'item_count': 1,
        'shipping_charge': '0',
        'created_at': '2026-07-14T09:00:00.000Z',
      });

      final cubit = PaymentCollectionCubit(
        serviceLocator: ServiceLocator('', ''),
        data: {'orderResponse': order},
      );

      final state = cubit.state;
      expect(state, isA<PaymentCollectionLoaded>());

      final loaded = state as PaymentCollectionLoaded;
      expect(loaded.paymentMethod, 'card');
      expect(loaded.orderPaymentMethod, 'card');
      expect(loaded.cashAmount, 0.0);
      expect(loaded.cardAmount, 250.0);
    });

    test('initializes split payment method with default order method', () {
      final order = Order.fromJson({
        'entity_id': '2',
        'subgroup_identifier': 'SG-2',
        'status': 'delivered',
        'type': 'EXP',
        'delivery_from': '2026-07-14T10:00:00.000Z',
        'delivery_to': '2026-07-14T11:00:00.000Z',
        'grand_total': '300.00',
        'shipped_amount': 0,
        'status_type': null,
        'delivery_timerange': null,
        'customer_firstname': 'Split',
        'customer_lastname': 'Test',
        'billing_street': 'Street',
        'customer_email': 'split@example.com',
        'postcode': '12345',
        'building_number': '',
        'telephone': '123456789',
        'latitude': '0',
        'longitude': '0',
        'payment_method': 'Split Payment',
        'delivery_note': '',
        'address_label': '',
        'building_name': null,
        'flat_number': null,
        'floor_number': null,
        'items': {'end_picking': []},
        'item_count': 1,
        'shipping_charge': '0',
        'created_at': '2026-07-14T09:00:00.000Z',
      });

      final cubit = PaymentCollectionCubit(
        serviceLocator: ServiceLocator('', ''),
        data: {'orderResponse': order},
      );

      final state = cubit.state;
      expect(state, isA<PaymentCollectionLoaded>());

      final loaded = state as PaymentCollectionLoaded;
      expect(loaded.paymentMethod, 'split');
      expect(loaded.orderPaymentMethod, 'split');
      expect(loaded.cashAmount, 0.0);
      expect(loaded.cardAmount, 0.0);
    });

    test(
      'updates cash amount in split mode and adjusts card amount automatically',
      () {
        final order = Order.fromJson({
          'entity_id': '3',
          'subgroup_identifier': 'SG-3',
          'status': 'delivered',
          'type': 'EXP',
          'delivery_from': '2026-07-14T10:00:00.000Z',
          'delivery_to': '2026-07-14T11:00:00.000Z',
          'grand_total': '300.00',
          'shipped_amount': 0,
          'status_type': null,
          'delivery_timerange': null,
          'customer_firstname': 'Split',
          'customer_lastname': 'Test',
          'billing_street': 'Street',
          'customer_email': 'split@example.com',
          'postcode': '12345',
          'building_number': '',
          'telephone': '123456789',
          'latitude': '0',
          'longitude': '0',
          'payment_method': 'Split Payment',
          'delivery_note': '',
          'address_label': '',
          'building_name': null,
          'flat_number': null,
          'floor_number': null,
          'items': {'end_picking': []},
          'item_count': 1,
          'shipping_charge': '0',
          'created_at': '2026-07-14T09:00:00.000Z',
        });

        final cubit = PaymentCollectionCubit(
          serviceLocator: ServiceLocator('', ''),
          data: {'orderResponse': order},
        );

        cubit.updateCashAmount(200);
        final state = cubit.state as PaymentCollectionLoaded;
        expect(state.cashAmount, 200.0);
        expect(state.cardAmount, 100.0);
        expect(state.balanceRemaining, 0.0);
      },
    );

    test(
      'updates card amount in split mode and adjusts cash amount automatically',
      () {
        final order = Order.fromJson({
          'entity_id': '4',
          'subgroup_identifier': 'SG-4',
          'status': 'delivered',
          'type': 'EXP',
          'delivery_from': '2026-07-14T10:00:00.000Z',
          'delivery_to': '2026-07-14T11:00:00.000Z',
          'grand_total': '300.00',
          'shipped_amount': 0,
          'status_type': null,
          'delivery_timerange': null,
          'customer_firstname': 'Split',
          'customer_lastname': 'Test',
          'billing_street': 'Street',
          'customer_email': 'split@example.com',
          'postcode': '12345',
          'building_number': '',
          'telephone': '123456789',
          'latitude': '0',
          'longitude': '0',
          'payment_method': 'Split Payment',
          'delivery_note': '',
          'address_label': '',
          'building_name': null,
          'flat_number': null,
          'floor_number': null,
          'items': {'end_picking': []},
          'item_count': 1,
          'shipping_charge': '0',
          'created_at': '2026-07-14T09:00:00.000Z',
        });

        final cubit = PaymentCollectionCubit(
          serviceLocator: ServiceLocator('', ''),
          data: {'orderResponse': order},
        );

        cubit.updateCardAmount(150);
        final state = cubit.state as PaymentCollectionLoaded;
        expect(state.cardAmount, 150.0);
        expect(state.cashAmount, 150.0);
        expect(state.balanceRemaining, 0.0);
      },
    );

    test('stores secondary payment details for split payment selections', () {
      final order = Order.fromJson({
        'entity_id': '5',
        'subgroup_identifier': 'SG-5',
        'status': 'delivered',
        'type': 'EXP',
        'delivery_from': '2026-07-14T10:00:00.000Z',
        'delivery_to': '2026-07-14T11:00:00.000Z',
        'grand_total': '300.00',
        'shipped_amount': 0,
        'status_type': null,
        'delivery_timerange': null,
        'customer_firstname': 'Split',
        'customer_lastname': 'Test',
        'billing_street': 'Street',
        'customer_email': 'split@example.com',
        'postcode': '12345',
        'building_number': '',
        'telephone': '123456789',
        'latitude': '0',
        'longitude': '0',
        'payment_method': 'Cash On Delivery',
        'delivery_note': '',
        'address_label': '',
        'building_name': null,
        'flat_number': null,
        'floor_number': null,
        'items': {'end_picking': []},
        'item_count': 1,
        'shipping_charge': '0',
        'created_at': '2026-07-14T09:00:00.000Z',
      });

      final cubit = PaymentCollectionCubit(
        serviceLocator: ServiceLocator('', ''),
        data: {'orderResponse': order},
      );

      cubit.updatePaymentMethod('split');
      cubit.updateCardAmount(150);

      final state = cubit.state as PaymentCollectionLoaded;
      expect(state.paymentMethod, 'split');
      expect(state.secondaryPaymentMethod, 'card');
      expect(state.secondaryPaymentAmount, '150.00');
    });

    test(
      'stores secondary payment details when switching to a single method',
      () {
        final order = Order.fromJson({
          'entity_id': '6',
          'subgroup_identifier': 'SG-6',
          'status': 'delivered',
          'type': 'EXP',
          'delivery_from': '2026-07-14T10:00:00.000Z',
          'delivery_to': '2026-07-14T11:00:00.000Z',
          'grand_total': '300.00',
          'shipped_amount': 0,
          'status_type': null,
          'delivery_timerange': null,
          'customer_firstname': 'Single',
          'customer_lastname': 'Test',
          'billing_street': 'Street',
          'customer_email': 'single@example.com',
          'postcode': '12345',
          'building_number': '',
          'telephone': '123456789',
          'latitude': '0',
          'longitude': '0',
          'payment_method': 'Card On Delivery',
          'delivery_note': '',
          'address_label': '',
          'building_name': null,
          'flat_number': null,
          'floor_number': null,
          'items': {'end_picking': []},
          'item_count': 1,
          'shipping_charge': '0',
          'created_at': '2026-07-14T09:00:00.000Z',
        });

        final cubit = PaymentCollectionCubit(
          serviceLocator: ServiceLocator('', ''),
          data: {'orderResponse': order},
        );

        cubit.updatePaymentMethod('cash');

        final state = cubit.state as PaymentCollectionLoaded;
        expect(state.paymentMethod, 'cash');
        expect(state.secondaryPaymentMethod, '');
        expect(state.secondaryPaymentAmount, '');
      },
    );
  });
}
