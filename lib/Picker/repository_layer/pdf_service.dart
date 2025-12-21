// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:picker_driver_api/responses/stock_update.dart';
// import 'package:picker_driver_api/responses/section_item_response.dart';
// import 'package:picker_driver_api/responses/check_section_status_list.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as img;
// import 'package:ansarlogistics/constants/texts.dart';
// import 'package:intl/intl.dart';

// class PdfService {
//   static Future<File> generatePdf(List<StockUpdate> data) async {
//     // TODO: Implement PDF generation logic
//     final pdf = pw.Document();

//     // Debug: Print all image URLs
//     log('=== Processing ${data.length} items for PDF ===');
//     for (int i = 0; i < data.length; i++) {
//       log('Item $i: SKU=${data[i].sku}, ImageURL=${data[i].imageUrl}');
//     }
//     log('=== End of debug info ===');

//     // Pre-load all image data
//     final tableData = await Future.wait(
//       data.map((item) async {
//         final image = await _loadAndResizeImage(item.imageUrl);

//         return [
//           image != null
//               ? pw.Image(pw.MemoryImage(image), width: 50, height: 50)
//               : pw.Text('No Image'),
//           item.sku,
//           item.name,
//           item.isEnabled ? 'Enabled' : 'Disabled',
//           DateFormat('MM/dd HH:mm').format(item.updatedAt),
//         ];
//       }).toList(),
//     );

//     // Add a page with the report
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         maxPages: 500,
//         build:
//             (context) => [
//               pw.Header(
//                 level: 0,
//                 child: pw.Text(
//                   'Stock Update Report',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Text(
//                 'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
//                 style: pw.TextStyle(fontSize: 10),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Table.fromTextArray(
//                 headers: ['Image', 'SKU', 'Name', 'Status', 'Updated At'],
//                 data: tableData,
//                 cellAlignment: pw.Alignment.center,
//                 headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                 headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
//                 cellPadding: pw.EdgeInsets.all(5),
//               ),
//             ],
//       ),
//     );

//     // Save the PDF to a temporary file
//     final output = await getTemporaryDirectory();
//     final file = File(
//       '${output.path}/stock_update_${DateTime.now().millisecondsSinceEpoch}.pdf',
//     );
//     await file.writeAsBytes(await pdf.save());

//     return file;
//   }

//   static Future<Uint8List?> _loadAndResizeImage(String imageUrl) async {
//     try {
//       print('Loading image from: $imageUrl');

//       // Construct full URL using mainimageurl base path
//       String fullImageUrl;
//       if (imageUrl.startsWith('http')) {
//         // If imageUrl is already a full URL, use it as is
//         fullImageUrl = imageUrl;
//       } else if (imageUrl.startsWith('/catalog/product/')) {
//         // Remove /catalog/product/ prefix and prepend mainimageurl
//         String imagePath = imageUrl.replaceFirst('/catalog/product', '');
//         fullImageUrl = '$mainimageurl$imagePath';
//       } else {
//         // If imageUrl is a relative path, prepend mainimageurl
//         fullImageUrl = '$mainimageurl$imageUrl';
//       }

//       print('Full image URL: $fullImageUrl');

//       final response = await http.get(Uri.parse(fullImageUrl));
//       // print('Image response status: ${response.statusCode}');

//       if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
//         // print('Image bytes length: ${response.bodyBytes.length}');

//         // Try to decode and resize using the image package
//         final image = img.decodeImage(response.bodyBytes);
//         if (image != null) {
//           print(
//             'Image decoded successfully, original size: ${image.width}x${image.height}',
//           );
//           final resized = img.copyResize(image, width: 100);
//           final processedBytes = Uint8List.fromList(
//             img.encodeJpg(resized, quality: 70),
//           );
//           // print('Image resized and encoded');
//           return processedBytes;
//         } else {
//           // If decoding fails, treat this as "no image" and let the caller
//           // render the placeholder instead of crashing the PDF engine.
//           print(
//             'Failed to decode image, returning null so placeholder is used',
//           );
//           return null;
//         }
//       } else {
//         print('Failed to load image: status ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error loading image: $e');
//     }
//     return null;
//   }

//   static Future<void> sharePdf(File file) async {
//     await Share.shareXFiles(
//       [XFile(file.path)],
//       text: 'Stock Update Report - ${DateTime.now().toString().split(' ')[0]}',
//     );
//   }

//   // Generate comprehensive PDF for stock updates, section items, and NEW status items
//   static Future<File> generateComprehensivePdf(
//     List<StockUpdate> stockUpdates,
//     List<Sectionitem> sectionItems,
//     List<StatusHistory> statusHistories,
//   ) async {
//     final pdf = pw.Document();

//     log('=== Generating comprehensive PDF ===');
//     log('Stock updates: ${stockUpdates.length}');
//     log('Section items: ${sectionItems.length}');
//     log('Status history records: ${statusHistories.length}');

//     // Add stock updates section if there are any
//     if (stockUpdates.isNotEmpty) {
//       log('=== Processing ${stockUpdates.length} stock updates for PDF ===');
//       for (int i = 0; i < stockUpdates.length; i++) {
//         log(
//           'Stock Update $i: SKU=${stockUpdates[i].sku}, ImageURL=${stockUpdates[i].imageUrl}',
//         );
//       }

//       final stockTableData = await Future.wait(
//         stockUpdates.map((item) async {
//           final image = await _loadAndResizeImage(item.imageUrl);

//           return [
//             image != null
//                 ? pw.Image(pw.MemoryImage(image), width: 50, height: 50)
//                 : pw.Container(
//                   width: 50,
//                   height: 50,
//                   child: pw.Text('No Image', style: pw.TextStyle(fontSize: 8)),
//                 ),
//             item.sku,
//             item.name,
//             item.isEnabled ? 'Enabled' : 'Disabled',
//             DateFormat('MM/dd HH:mm').format(item.updatedAt),
//           ];
//         }).toList(),
//       );

//       pdf.addPage(
//         pw.MultiPage(
//           pageFormat: PdfPageFormat.a4,
//           maxPages: 500,
//           build:
//               (context) => [
//                 pw.Header(
//                   level: 0,
//                   child: pw.Text(
//                     'Stock Updates Report',
//                     style: pw.TextStyle(
//                       fontSize: 24,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Text(
//                   'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
//                   style: pw.TextStyle(fontSize: 10),
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Container(
//                   padding: pw.EdgeInsets.all(8),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.blue100,
//                     borderRadius: pw.BorderRadius.circular(4),
//                   ),
//                   child: pw.Text(
//                     'Total Stock Updates: ${stockUpdates.length}',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColors.blue800,
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Table.fromTextArray(
//                   headers: ['Image', 'SKU', 'Name', 'Status', 'Updated At'],
//                   data: stockTableData,
//                   cellAlignment: pw.Alignment.center,
//                   headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                   headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
//                   cellPadding: pw.EdgeInsets.all(5),
//                 ),
//               ],
//         ),
//       );
//     }

//     // Add NEW status items section based on status history (status == 3)
//     final newStatusItems = statusHistories.where((s) => s.status == 3).toList();

//     if (newStatusItems.isNotEmpty) {
//       pdf.addPage(
//         pw.MultiPage(
//           pageFormat: PdfPageFormat.a4,
//           maxPages: 500,
//           build:
//               (context) => [
//                 pw.Header(
//                   level: 0,
//                   child: pw.Text(
//                     'New Items',
//                     style: pw.TextStyle(
//                       fontSize: 24,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Text(
//                   'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
//                   style: pw.TextStyle(fontSize: 10),
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Container(
//                   padding: pw.EdgeInsets.all(8),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.orange100,
//                     borderRadius: pw.BorderRadius.circular(4),
//                   ),
//                   child: pw.Text(
//                     'Total New Items: ${newStatusItems.length}',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColors.orange800,
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Table.fromTextArray(
//                   headers: ['SKU', 'Product Name', 'Status'],
//                   data:
//                       newStatusItems
//                           .map((item) => [item.sku, item.productName, 'NEW'])
//                           .toList(),
//                   cellAlignment: pw.Alignment.center,
//                   headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                   headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
//                   cellPadding: pw.EdgeInsets.all(5),
//                 ),
//               ],
//         ),
//       );
//     }

//     // Add section items section if there are any
//     if (sectionItems.isNotEmpty) {
//       log('=== Processing ${sectionItems.length} section items for PDF ===');
//       for (int i = 0; i < sectionItems.length; i++) {
//         log(
//           'Section Item $i: SKU=${sectionItems[i].sku}, Name=${sectionItems[i].productName}, ImageURL=${sectionItems[i].imageUrl}',
//         );
//       }

//       final sectionTableData = await Future.wait(
//         sectionItems.map((item) async {
//           final image = await _loadAndResizeImage(item.imageUrl);

//           return [
//             image != null
//                 ? pw.Image(pw.MemoryImage(image), width: 50, height: 50)
//                 : pw.Container(
//                   width: 50,
//                   height: 50,
//                   child: pw.Text('No Image', style: pw.TextStyle(fontSize: 8)),
//                 ),
//             item.sku,
//             item.productName,
//             item.stockQty,
//             item.isInStock == 1 ? 'In Stock' : 'Out of Stock',
//           ];
//         }).toList(),
//       );

//       pdf.addPage(
//         pw.MultiPage(
//           pageFormat: PdfPageFormat.a4,
//           maxPages: 500,
//           build:
//               (context) => [
//                 pw.Header(
//                   level: 0,
//                   child: pw.Text(
//                     'Section Items Report',
//                     style: pw.TextStyle(
//                       fontSize: 24,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Text(
//                   'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
//                   style: pw.TextStyle(fontSize: 10),
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Container(
//                   padding: pw.EdgeInsets.all(8),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.green100,
//                     borderRadius: pw.BorderRadius.circular(4),
//                   ),
//                   child: pw.Text(
//                     'Total Section Items: ${sectionItems.length}',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColors.green800,
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Table.fromTextArray(
//                   headers: [
//                     'Image',
//                     'SKU',
//                     'Product Name',
//                     'Stock Qty',
//                     'Status',
//                   ],
//                   data: sectionTableData,
//                   cellAlignment: pw.Alignment.center,
//                   headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                   headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
//                   cellPadding: pw.EdgeInsets.all(5),
//                 ),
//               ],
//         ),
//       );
//     }

//     // Add summary page if both sections have data
//     if (stockUpdates.isNotEmpty && sectionItems.isNotEmpty) {
//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           build:
//               (context) => pw.Column(
//                 children: [
//                   pw.Header(
//                     level: 0,
//                     child: pw.Text(
//                       'Report Summary',
//                       style: pw.TextStyle(
//                         fontSize: 24,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   pw.SizedBox(height: 40),
//                   pw.Container(
//                     padding: pw.EdgeInsets.all(16),
//                     decoration: pw.BoxDecoration(
//                       color: PdfColors.grey100,
//                       borderRadius: pw.BorderRadius.circular(8),
//                       border: pw.Border.all(color: PdfColors.grey400),
//                     ),
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(
//                           'Comprehensive Report Summary',
//                           style: pw.TextStyle(
//                             fontSize: 18,
//                             fontWeight: pw.FontWeight.bold,
//                           ),
//                         ),
//                         pw.SizedBox(height: 20),
//                         pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Container(
//                               width: 200,
//                               padding: pw.EdgeInsets.all(12),
//                               decoration: pw.BoxDecoration(
//                                 color: PdfColors.blue50,
//                                 borderRadius: pw.BorderRadius.circular(6),
//                                 border: pw.Border.all(color: PdfColors.blue200),
//                               ),
//                               child: pw.Column(
//                                 crossAxisAlignment:
//                                     pw.CrossAxisAlignment.center,
//                                 children: [
//                                   pw.Text(
//                                     '${stockUpdates.length}',
//                                     style: pw.TextStyle(
//                                       fontSize: 24,
//                                       fontWeight: pw.FontWeight.bold,
//                                       color: PdfColors.blue800,
//                                     ),
//                                   ),
//                                   pw.SizedBox(height: 4),
//                                   pw.Text(
//                                     'Stock Updates',
//                                     style: pw.TextStyle(
//                                       fontSize: 12,
//                                       color: PdfColors.blue600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             pw.Container(
//                               width: 200,
//                               padding: pw.EdgeInsets.all(12),
//                               decoration: pw.BoxDecoration(
//                                 color: PdfColors.green50,
//                                 borderRadius: pw.BorderRadius.circular(6),
//                                 border: pw.Border.all(
//                                   color: PdfColors.green200,
//                                 ),
//                               ),
//                               child: pw.Column(
//                                 crossAxisAlignment:
//                                     pw.CrossAxisAlignment.center,
//                                 children: [
//                                   pw.Text(
//                                     '${sectionItems.length}',
//                                     style: pw.TextStyle(
//                                       fontSize: 24,
//                                       fontWeight: pw.FontWeight.bold,
//                                       color: PdfColors.green800,
//                                     ),
//                                   ),
//                                   pw.SizedBox(height: 4),
//                                   pw.Text(
//                                     'Section Items',
//                                     style: pw.TextStyle(
//                                       fontSize: 12,
//                                       color: PdfColors.green600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 20),
//                         pw.Container(
//                           width: double.infinity,
//                           padding: pw.EdgeInsets.all(12),
//                           decoration: pw.BoxDecoration(
//                             color: PdfColors.orange50,
//                             borderRadius: pw.BorderRadius.circular(6),
//                             border: pw.Border.all(color: PdfColors.orange200),
//                           ),
//                           child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.center,
//                             children: [
//                               pw.Text(
//                                 '${stockUpdates.length + sectionItems.length}',
//                                 style: pw.TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: pw.FontWeight.bold,
//                                   color: PdfColors.orange800,
//                                 ),
//                               ),
//                               pw.SizedBox(height: 4),
//                               pw.Text(
//                                 'Total Items in Report',
//                                 style: pw.TextStyle(
//                                   fontSize: 14,
//                                   color: PdfColors.orange600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//         ),
//       );
//     }

//     // Save the PDF to a temporary file
//     final output = await getTemporaryDirectory();
//     final file = File(
//       '${output.path}/comprehensive_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
//     );
//     await file.writeAsBytes(await pdf.save());

//     return file;
//   }

//   // Share comprehensive PDF
//   static Future<void> shareComprehensivePdf(File file) async {
//     await Share.shareXFiles(
//       [XFile(file.path)],
//       text: 'Comprehensive Report - ${DateTime.now().toString().split(' ')[0]}',
//     );
//   }

//   // Generate PDF for existing section items (kept for backward compatibility)
//   static Future<File> generateSectionItemsPdf(List<Sectionitem> data) async {
//     final pdf = pw.Document();

//     // Debug: Print all image URLs
//     log('=== Processing ${data.length} section items for PDF ===');
//     for (int i = 0; i < data.length; i++) {
//       log(
//         'Item $i: SKU=${data[i].sku}, Name=${data[i].productName}, ImageURL=${data[i].imageUrl}',
//       );
//     }
//     log('=== End of debug info ===');

//     // Pre-load all image data
//     final tableData = await Future.wait(
//       data.map((item) async {
//         final image = await _loadAndResizeImage(item.imageUrl);

//         return [
//           image != null
//               ? pw.Image(pw.MemoryImage(image), width: 50, height: 50)
//               : pw.Container(
//                 width: 50,
//                 height: 50,
//                 child: pw.Text('No Image', style: pw.TextStyle(fontSize: 8)),
//               ),
//           item.sku,
//           item.productName,
//           item.stockQty,
//           item.isInStock == 1 ? 'In Stock' : 'Out of Stock',
//         ];
//       }).toList(),
//     );

//     // Add a page with the report
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         maxPages: 500,
//         build:
//             (context) => [
//               pw.Header(
//                 level: 0,
//                 child: pw.Text(
//                   'Section Items Report',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Text(
//                 'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
//                 style: pw.TextStyle(fontSize: 10),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Table.fromTextArray(
//                 headers: [
//                   'Image',
//                   'SKU',
//                   'Product Name',
//                   'Stock Qty',
//                   'Status',
//                 ],
//                 data: tableData,
//                 cellAlignment: pw.Alignment.center,
//                 headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                 headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
//                 cellPadding: pw.EdgeInsets.all(5),
//               ),
//             ],
//       ),
//     );

//     // Save the PDF to a temporary file
//     final output = await getTemporaryDirectory();
//     final file = File(
//       '${output.path}/section_items_${DateTime.now().millisecondsSinceEpoch}.pdf',
//     );
//     await file.writeAsBytes(await pdf.save());

//     return file;
//   }

//   // Share section items PDF
//   static Future<void> shareSectionItemsPdf(File file) async {
//     await Share.shareXFiles(
//       [XFile(file.path)],
//       text: 'Section Items Report - ${DateTime.now().toString().split(' ')[0]}',
//     );
//   }
// }
