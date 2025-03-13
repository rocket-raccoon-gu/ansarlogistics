abstract class DocumentUploadPageState {}

class DocumentUploadInitialPageState extends DocumentUploadPageState {
  List<Map<String, dynamic>> optionslist = [];

  DocumentUploadInitialPageState(this.optionslist);
}

class UploadDocumentsPageLoadingState extends DocumentUploadPageState {}

class UploadDocumentsSuccessState extends DocumentUploadPageState {
  List<Map<String, dynamic>> optionslist = [];

  UploadDocumentsSuccessState(this.optionslist);
}

class UploadDocumentsErrorState extends DocumentUploadPageState {
  List<Map<String, dynamic>> optionslist = [];

  UploadDocumentsErrorState(this.optionslist);
}
