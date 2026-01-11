import 'dart:convert';
import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'config.dart';

class KotPrintService {

  Future<String> printKot(Map<String, dynamic> order) async {
    try {
      final List<dynamic> costCenterConfigs = await _fetchCostCenterConfigs();

      Map<String, Map<String, String>> printerMap = {};
      for (var config in costCenterConfigs) {
        String code = config['code']?.toString() ?? '';
        String name = config['name']?.toString() ?? '';
        String ip = config['printerIp1']?.toString() ?? '';
        if (code.isNotEmpty) {
          printerMap[code] = {'ip': ip, 'name': name};
        }
      }

      final items = order['items'] as List<dynamic>? ?? [];
      Map<String, List<dynamic>> groupedByCategory = {};

      for (var item in items) {
        String category = item['categoryName']?.toString()
            ?? item['category']?.toString()
            ?? 'General';

        if (!groupedByCategory.containsKey(category)) groupedByCategory[category] = [];
        groupedByCategory[category]!.add(item);
      }

      List<String> errors = [];

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);

      for (var entry in groupedByCategory.entries) {
        String categoryName = entry.key;
        List<dynamic> currentItems = entry.value;

        if (currentItems.isEmpty) continue;

        String ccCode = currentItems.first['costcenterCode']?.toString() ?? '';
        final config = printerMap[ccCode];
        String targetIp = config?['ip'] ?? '';
        String printerName = config?['name'] ?? ccCode;

        print("Group: $categoryName | Target IP: $targetIp");

        if (targetIp.isEmpty) {
          errors.add("No IP for $printerName");
          continue;
        }

        try {
          List<int> bytes = _generateKotBytes(generator, currentItems, order, printerName, categoryName);

          final socket = await Socket.connect(targetIp, 9100, timeout: Duration(seconds: 5));
          socket.add(bytes);
          await socket.flush();
          socket.destroy();

        } catch (e) {
          print(" Print Error: $e");
          errors.add("Fail: $categoryName ($targetIp)");
        }
      }

      if (errors.isNotEmpty) return "Errors: ${errors.join(', ')}";
      return "Success";

    } catch (e) {
      return "Error: $e";
    }
  }

  Future<List<dynamic>> _fetchCostCenterConfigs() async {
    try {
      final String urlStr = '${Config.apiUrl}placeordercostcenter/getAll?DB=${Config.clientCode}';
      final response = await http.get(Uri.parse(urlStr));
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print(" Error fetching config: $e");
      return [];
    }
  }

  List<int> _generateKotBytes(Generator generator, List<dynamic> items, Map<String, dynamic> order, String printerName, String categoryName) {
    List<int> bytes = [];

    bytes += generator.reset();

    bytes += generator.text(
      printerName,
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.text(
      '($categoryName)',
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.hr();

    final placeOrderNo = order['placeorderNo'] ?? 'N/A';
    final brandName = order['brandName'] ?? 'N/A';
    String formattedDate = 'N/A';
    if (order['placeorderDate'] != null) {
      try {
        formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(order['placeorderDate']));
      } catch (_) {}
    }
    String timeStr = order['placeorderTime'] ?? '';

    bytes += generator.row([
      PosColumn(text: 'Order No', width: 3),
      PosColumn(text: ': $placeOrderNo', width: 9),
    ]);
    bytes += generator.row([
      PosColumn(text: 'User', width: 3),
      PosColumn(text: ': $brandName', width: 9),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Date', width: 3),
      PosColumn(text: ': $formattedDate $timeStr', width: 9),
    ]);

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Qty', width: 2, styles: PosStyles(bold: true)),
      PosColumn(text: 'Item Name', width: 10, styles: PosStyles(bold: true)),
    ]);

    bytes += generator.hr();
    for (var item in items) {
      final qty = (item['quantity'] ?? 0).toString();
      final rawName = item['itemName'] ?? 'Unknown';
      final PosStyles itemStyle = PosStyles(
        fontType: PosFontType.fontA,
        height: PosTextSize.size1,
        width: PosTextSize.size2,
      );
      final PosStyles modifierStyle = PosStyles(
        fontType: PosFontType.fontA,
      );
      if (rawName.contains('*')) {
        int splitIndex = rawName.indexOf('*');
        String mainName = rawName.substring(0, splitIndex).trim();
        String variantName = rawName.substring(splitIndex).trim();

        bytes += generator.row([
          PosColumn(text: qty, width: 2, styles: itemStyle),
          PosColumn(text: mainName, width: 10, styles: itemStyle),
        ]);

        bytes += generator.row([
          PosColumn(text: '', width: 2),
          PosColumn(text: variantName, width: 10, styles: itemStyle),
        ]);
      } else {
        bytes += generator.row([
          PosColumn(text: qty, width: 2, styles: itemStyle),
          PosColumn(text: rawName, width: 10, styles: itemStyle),
        ]);
      }

      if (item['modifiers'] != null && item['modifiers'] is List) {
        List<dynamic> modifiers = item['modifiers'];
        for (var mod in modifiers) {
          String modName = mod['modifierName']?.toString() ?? '';
          if (modName.isNotEmpty) {
            bytes += generator.row([
              PosColumn(text: '', width: 2),
              PosColumn(text: '--> $modName', width: 10, styles: modifierStyle),
            ]);
          }
        }
      }
    }

    bytes += generator.hr();

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}