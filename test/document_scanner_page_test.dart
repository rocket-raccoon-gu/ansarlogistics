import 'package:ansarlogistics/cashier/feature_cashier/components/document_scanner_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldUseNormalCameraForBranch', () {
    test('uses normal camera for Rayyan branch Q008', () {
      expect(shouldUseNormalCameraForBranch('Q008'), isTrue);
    });

    test('uses document scanner for other branches', () {
      expect(shouldUseNormalCameraForBranch('Q001'), isFalse);
      expect(shouldUseNormalCameraForBranch('Q019'), isFalse);
    });

    test('handles null and empty values safely', () {
      expect(shouldUseNormalCameraForBranch(null), isFalse);
      expect(shouldUseNormalCameraForBranch('   '), isFalse);
    });
  });
}
