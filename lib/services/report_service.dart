import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportService {
  static const int _expiringSoonDays = 3;
  static const double _lowStockThreshold = 2.0;

  static Future<void> generateAndDownloadReport(BuildContext context, {
    required bool adminMode,
    required String userId,
    String timeRange = "All",
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    try {
      // 1. Fetch Data
      final QuerySnapshot snapshot = await (() {
        Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection("foods");
        if (!adminMode) {
          query = query.where("userId", isEqualTo: userId);
        }
        return query.get();
      })();

      final now = DateTime.now();
      final docs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = data['createdAt'];
        if (createdAt == null) return timeRange == "All";
        
        final createdDate = (createdAt as Timestamp).toDate();
        
        if (customStart != null && customEnd != null) {
          // Normalize to start of day for start and end of day for end
          final start = DateTime(customStart.year, customStart.month, customStart.day);
          final end = DateTime(customEnd.year, customEnd.month, customEnd.day, 23, 59, 59);
          return createdDate.isAfter(start.subtract(const Duration(seconds: 1))) && 
                 createdDate.isBefore(end.add(const Duration(seconds: 1)));
        }

        if (timeRange == "All") return true;
        
        final difference = now.difference(createdDate).inDays;
        if (timeRange == "7 Days") return difference <= 7;
        if (timeRange == "1 Month") return difference <= 30;
        if (timeRange == "4 Months") return difference <= 120;
        
        return true;
      }).toList();

      // 2. Process Data
      int totalItems = docs.length;
      List<Map<String, dynamic>> expiredItems = [];
      List<Map<String, dynamic>> expiringSoonItems = [];
      Map<String, double> bestAmountByName = {};
      List<Map<String, dynamic>> lowStockItems = [];

      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final expiry = _getExpiryDate(data);
        final amount = _getAmount(data);
        final name = (data['name'] as String?) ?? 'Unnamed Item';
        final unit = (data['unit'] as String?) ?? '';

        if (expiry != null) {
          final daysLeft = expiry.difference(now).inDays;
          if (daysLeft < 0) {
            if (amount > 0) {
              expiredItems.add({
                'name': name,
                'amount': amount,
                'unit': unit,
                'expiry': expiry,
              });
            }
          } else if (daysLeft <= _expiringSoonDays) {
            expiringSoonItems.add({
              'name': name,
              'amount': amount,
              'unit': unit,
              'expiry': expiry,
            });
          }
        }

        final effectiveAmount = (expiry != null && expiry.isBefore(now)) ? 0.0 : amount;
        final key = name.trim().toLowerCase();
        final currentBest = bestAmountByName[key];
        if (currentBest == null || effectiveAmount > currentBest) {
          bestAmountByName[key] = effectiveAmount;
        }
      }

      // Reiterate for low stock to match UI logic
      final Set<String> processedLowStock = {};
      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] as String?) ?? 'Item';
        final key = name.trim().toLowerCase();
        final amount = bestAmountByName[key] ?? 0;

        if (amount <= _lowStockThreshold && !processedLowStock.contains(key)) {
          lowStockItems.add({
            'name': name,
            'amount': amount,
            'unit': (data['unit'] as String?) ?? '',
            'section': (data['section'] as String?) ?? 'Others',
          });
          processedLowStock.add(key);
        }
      }

      // 3. Generate PDF
      final pdf = pw.Document();

      final double sustainabilityScore = totalItems == 0 ? 100 : ((totalItems - expiredItems.length) / totalItems) * 100;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          footer: (pw.Context context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: const pw.TextStyle(fontSize: 10)),
          ),
          build: (pw.Context context) => [
            _buildHeader(now, adminMode, timeRange, customStart, customEnd),
            pw.SizedBox(height: 20),
            _buildSustainabilitySection(sustainabilityScore),
            pw.SizedBox(height: 20),
            _buildSummaryCards(totalItems, expiringSoonItems.length, expiredItems.length, lowStockItems.length),
            pw.SizedBox(height: 30),
            if (expiredItems.isNotEmpty) ...[
              _buildSectionTitle("Expired Items"),
              _buildExpiredTable(expiredItems),
              pw.SizedBox(height: 20),
            ],
            if (lowStockItems.isNotEmpty) ...[
              _buildSectionTitle("Low Stock Items"),
              _buildLowStockTable(lowStockItems),
              pw.SizedBox(height: 20),
            ],
          ],
        ),
      );

      // 4. Download/Share
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'WasteLess_Analytics_${DateFormat('yyyyMMdd').format(now)}.pdf',
      );

    } catch (e) {
      debugPrint("Error generating report: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to generate report: $e")),
        );
      }
    }
  }

  static DateTime? _getExpiryDate(Map<String, dynamic> data) {
    final value = data["expiryDate"];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static double _getAmount(Map<String, dynamic> data) {
    final value = data["amount"];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static pw.Widget _buildHeader(DateTime now, bool adminMode, String timeRange, DateTime? start, DateTime? end) {
    String periodText = "Period: $timeRange";
    if (start != null && end != null) {
      periodText = "Period: ${DateFormat('yyyy-MM-dd').format(start)} to ${DateFormat('yyyy-MM-dd').format(end)}";
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("WASTELESS", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
            pw.Text("Analytics & Insights Report", style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
            pw.Text(periodText, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            if (adminMode) pw.Text("Global System Statistics", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text("Date: ${DateFormat('yyyy-MM-dd').format(now)}"),
            pw.Text("Time: ${DateFormat('HH:mm').format(now)}"),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSustainabilitySection(double score) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: const pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Kitchen Sustainability Score", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
              pw.Text(score >= 80 ? "Excellent Food Management" : score >= 50 ? "Good Progress" : "Needs Attention", style: const pw.TextStyle(fontSize: 12, color: PdfColors.green700)),
            ],
          ),
          pw.Text("${score.round()}%", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCards(int total, int soon, int expired, int low) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _summaryCard("Total Items", total.toString(), PdfColors.green700),
        _summaryCard("Expiring Soon", soon.toString(), PdfColors.orange700),
        _summaryCard("Expired", expired.toString(), PdfColors.red700),
        _summaryCard("Low Stock", low.toString(), PdfColors.blueGrey700),
      ],
    );
  }

  static pw.Widget _summaryCard(String title, String value, PdfColor color) {
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: color, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 5),
          pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.green800, width: 1))),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
    );
  }

  static pw.Widget _buildExpiredTable(List<Map<String, dynamic>> items) {
    return pw.TableHelper.fromTextArray(
      headers: ['Item Name', 'Amount', 'Unit', 'Expiry Date'],
      data: items.map((item) => [
        item['name'],
        item['amount'].toStringAsFixed(1),
        item['unit'],
        DateFormat('yyyy-MM-dd').format(item['expiry']),
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red700),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildLowStockTable(List<Map<String, dynamic>> items) {
    return pw.TableHelper.fromTextArray(
      headers: ['Item Name', 'Amount', 'Unit', 'Section'],
      data: items.map((item) => [
        item['name'],
        item['amount'].toStringAsFixed(1),
        item['unit'],
        item['section'],
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
      },
    );
  }
}
