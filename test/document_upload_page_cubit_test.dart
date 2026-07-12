import 'package:ansarlogistics/Driver/features/feature_document_upload/bloc/document_upload_page_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocumentUploadPageCubit', () {
    test(
      'uses the larger size when the signature bounds exceed the requested export size',
      () {
        expect(
          DocumentUploadPageCubit.resolveSignatureExportDimension(300, 400),
          400,
        );
      },
    );

    test('keeps the requested size when the signature bounds are smaller', () {
      expect(
        DocumentUploadPageCubit.resolveSignatureExportDimension(300, 180),
        300,
      );
    });
  });
}
