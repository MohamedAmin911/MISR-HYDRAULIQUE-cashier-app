import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models/sale_transaction.dart';
import '../data/models/transaction_item.dart';
import '../services/currency_formatter.dart';
import 'pdf_assets.dart';

class PdfReceiptBuilder {
  static final _df = DateFormat('yyyy-MM-dd HH:mm');

  static Future<Uint8List> build({
    required SaleTx tx,
    required bool forAdmin,
  }) async {
    await PdfAssets.ensureLoaded();

    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final dateStr = _df.format(tx.date);

    pw.Widget buildHeader() {
      return pw.Align(
        alignment: pw.Alignment.topLeft,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.SizedBox(height: 10),
            pw.Text('Branche: ${tx.branchName}',
                style: pw.TextStyle(font: PdfAssets.regular, fontSize: 12)),
            pw.SizedBox(height: 6),
            pw.Text('Tel: ${tx.branchPhone}',
                style: pw.TextStyle(font: PdfAssets.regular, fontSize: 12)),
            pw.SizedBox(height: 6),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date: $dateStr',
                      style:
                          pw.TextStyle(font: PdfAssets.regular, fontSize: 12)),
                  pw.Text('Facture No: ${1001 + tx.id}',
                      style:
                          pw.TextStyle(font: PdfAssets.regular, fontSize: 12)),
                  if (tx.customerName.isNotEmpty)
                    pw.Text('Client: ${tx.customerName}',
                        style: pw.TextStyle(
                            font: PdfAssets.regular, fontSize: 12)),
                ])
          ],
        ),
      );
    }

    pw.Widget buildItemsTable() {
      // 1. Headers include Fabrication
      final headers = forAdmin
          ? [
              'Quantite',
              'Désignation',
              'Prix.Unitaire',
              'Fabrication',
              'Prix.Total',
            ]
          : [
              'Quantite',
              'Désignation',
              'Prix.Unitaire',
              'Fabrication',
              'Prix.Total',
            ];

      final data = <List<String>>[];

      for (int i = 0; i < tx.items.length; i++) {
        final it = tx.items[i];

        // 2. MATH FIX:
        // Item total is purely (Price * Qty).
        // We do NOT add craftPrice here.
        final totalItemSell = it.sellPriceAtSale * it.quantity;

        final productLabel = (it.categoryName?.isNotEmpty ?? false)
            ? it.categoryName!
            : it.productName;

        // 3. UNIFIED VISUALS:
        // Show Fabrication price only on the first row (i == 0).
        // It shows even if 0. Empty string for other rows.
        final fabDisplayText =
            (i == 0) ? CurrencyFormatter.format(tx.craftPrice) : '';

        if (forAdmin) {
          data.add([
            it.quantity.toString(),
            "(${it.productName}) - $productLabel",
            CurrencyFormatter.format(it.baseSellPriceAtSale!),
            fabDisplayText,
            CurrencyFormatter.format(totalItemSell),
          ]);
        } else {
          data.add([
            it.quantity.toString(),
            productLabel,
            CurrencyFormatter.format(it.sellPriceAtSale),
            fabDisplayText,
            CurrencyFormatter.format(totalItemSell),
          ]);
        }
      }

      final Map<int, pw.Alignment> alignments = {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
      };

      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Container(
            constraints: const pw.BoxConstraints(maxWidth: 550),
            child: pw.Table.fromTextArray(
              headers: headers,
              data: data,
              headerStyle: pw.TextStyle(font: PdfAssets.bold, fontSize: 12),
              cellStyle: pw.TextStyle(font: PdfAssets.regular, fontSize: 11),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.amber200),
              border: null,
              headerAlignments: alignments,
              cellAlignments: alignments,
            ),
          ),
        ],
      );
    }

    pw.Widget buildTotals() {
      // 4. GRAND TOTAL CALCULATION:
      // Sum of all items + The single Craft Price
      final totalGeneral = tx.totalSell + tx.craftPrice;

      return pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Divider(),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // This total includes the fabrication cost
                  pw.Text(
                      'Total Général: ${CurrencyFormatter.format(totalGeneral)}',
                      style: pw.TextStyle(font: PdfAssets.bold, fontSize: 12)),
                  pw.Text('Vendeur: ${tx.sellerUsername}',
                      style:
                          pw.TextStyle(font: PdfAssets.regular, fontSize: 12)),
                ]),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 24),
          textDirection: pw.TextDirection.rtl,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (PdfAssets.headerStrip != null)
              pw.Container(
                height: 70,
                width: double.infinity,
                child: pw.Image(
                  PdfAssets.headerStrip!,
                  fit: pw.BoxFit.fitWidth,
                ),
              ),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: buildHeader(),
            ),
            pw.SizedBox(height: 10),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  buildItemsTable(),
                  pw.SizedBox(height: 10),
                  buildTotals(),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
