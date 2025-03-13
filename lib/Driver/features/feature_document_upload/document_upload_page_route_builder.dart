import 'package:ansarlogistics/Driver/features/feature_document_upload/bloc/document_upload_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_document_upload/document_upload_page.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentUploadPageRouteBuilder {
  final ServiceLocator serviceLocator;
  Map<String, dynamic> data;

  DocumentUploadPageRouteBuilder(this.serviceLocator, this.data);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (conetxt) => DocumentUploadPageCubit(
                serviceLocator: serviceLocator,
                context: context,
                data: data,
              ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: serviceLocator.navigationService),
          RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
        ],
        child: DocumentUploadPage(orderResponseItem: data['order']),
      ),
    );
  }
}
