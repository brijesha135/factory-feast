import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'main.dart';
import 'config.dart';
import 'order_service.dart';
import 'kot_print_service.dart';

class AppColors {
  static const Color primaryNavy = Color(0xFF0F2027);
  static const Color industrialBlue = Color(0xFF23395D);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color scaffoldBg = Color(0xFFF4F7F9);
  static const Color cardBg = Colors.white;
  static const Color statusPending = Color(0xFFE74C3C);
  static const Color statusProcessing = Color(0xFFF39C12);
  static const Color statusShipped = Color(0xFF3498DB);
  static const Color statusDone = Color(0xFF27AE60);
}

enum DateFilterType { all, today, yesterday, custom }

int _getItemDisplayQuantity(Map<String, dynamic> item) {
  return (item['receiveQty'] ?? item['receivequantity'] ?? item['quantity'] ?? 0) as int;
}

int _getItemSendQuantity(Map<String, dynamic> item) {
  return (item['dispatchQty'] ?? _getItemDisplayQuantity(item)) as int;
}

String _getModifierString(Map<String, dynamic> item, {bool includePrice = true}) {
  List<dynamic> mods = item['modifiers'] ?? item['addons'] ?? [];
  if (mods.isEmpty) return "";
  return mods.map((m) {
    String name = m['modifierLabel'] ?? m['modifierName'] ?? '';
    double price = (m['upchargePrice'] ?? m['price'] ?? 0.0).toDouble();
    return includePrice ? "--> $name (${price.toStringAsFixed(2)})" : "--> $name";
  }).where((s) => s.trim() != ">").join('\n');
}

String _convertNumberToWords(double number) {
  const List<String> ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
  const List<String> tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninty'];
  String convertUnderThousand(int n) {
    if (n == 0) return '';
    if (n < 20) return ones[n];
    if (n < 100) return '${tens[n ~/ 10]}${n % 10 != 0 ? ' ' + ones[n % 10] : ''}';
    return '${ones[n ~/ 100]} Hundred ${convertUnderThousand(n % 100)}';
  }
  String convert(int n) {
    if (n == 0) return 'Zero';
    if (n < 0 || n > 99999999) return 'NUMBER TOO LARGE';
    String words = '';
    int crore = n ~/ 10000000; n %= 10000000;
    int lakh = n ~/ 100000; n %= 100000;
    int thousand = n ~/ 1000; n %= 1000;
    if (crore > 0) words += '${convertUnderThousand(crore)} Crore ';
    if (lakh > 0) words += '${convertUnderThousand(lakh)} Lakh ';
    if (thousand > 0) words += '${convertUnderThousand(thousand)} Thousand ';
    if (n > 0) words += convertUnderThousand(n);
    return words.trim();
  }
  final int rupees = number.floor();
  final int paisa = ((number - rupees) * 100).round();
  String result = '${convert(rupees).isEmpty ? 'ZERO' : convert(rupees)} RUPEES';
  if (paisa > 0) result += ' AND ${convert(paisa).isEmpty ? 'ZERO' : convert(paisa)} PAISA';
  return result.toUpperCase();
}

void _recalculateItemPriceAndTaxes(Map<String, dynamic> item, int newQuantity) {
  double unitPrice = (item['unitBasePrice'] ?? 0).toDouble();
  item['dispatchQty'] = newQuantity;
  item['grossLineTotal'] = unitPrice * newQuantity;
}

class AllOrdersScreen extends StatefulWidget {
  @override
  _AllOrdersScreenState createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> with SingleTickerProviderStateMixin {
  late final OrderService _orderService;
  final KotPrintService _kotPrintService = KotPrintService();
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  TabController? _tabController;
  DateTime? _customStartDate, _customEndDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _orderService = OrderService();
    _orderService.pendingOrders.addListener(_onDataChanged);
    _orderService.completedOrders.addListener(_onDataChanged);
    _orderService.isLoading.addListener(_onDataChanged);
    _orderService.startPolling();
  }

  void _onDataChanged() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    _tabController?.dispose(); _searchController.dispose();
    _orderService.pendingOrders.removeListener(_onDataChanged);
    _orderService.completedOrders.removeListener(_onDataChanged);
    _orderService.isLoading.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<pw.MemoryImage> imageFromAsset(String path) async {
    final data = await rootBundle.load(Config.logoPath);
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  Future<void> printChallan(Map<String, dynamic> order) async {
    try {
      final pdf = pw.Document();
      final logo = await imageFromAsset(Config.logoPath);
      pdf.addPage(pw.MultiPage(build: (context) => [
        pw.Row(children: [pw.Image(logo, width: 100), pw.Spacer(), pw.Text("CHALLAN", style: pw.TextStyle(fontSize: 20))]),
        pw.Divider(),
        pw.Text("Manifest No: ${order['manifestNo']}"),
        pw.Text("Brand: ${order['outletBrand']}"),
        pw.Table.fromTextArray(headers: ['Item', 'Qty'], data: (order['items'] as List).map((i) => [i['itemDescription'], _getItemSendQuantity(i)]).toList()),
      ]));
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/Challan_${order['manifestNo']}.pdf");
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> printInvoice(Map<String, dynamic> order) async {
    try {
      final pdf = pw.Document();
      final logo = await imageFromAsset(Config.logoPath);
      double grandTotal = 0;
      for (var item in (order['items'] as List)) {
        grandTotal += (item['grossLineTotal'] ?? 0).toDouble();
      }
      pdf.addPage(pw.MultiPage(build: (context) => [
        pw.Row(children: [pw.Image(logo, width: 100), pw.Spacer(), pw.Text("TAX INVOICE")]),
        pw.Divider(),
        pw.Table.fromTextArray(headers: ['Description', 'Qty', 'Line Total'],
            data: (order['items'] as List).map((i) => [i['itemDescription'], _getItemSendQuantity(i), i['grossLineTotal'].toStringAsFixed(2)]).toList()),
        pw.Divider(),
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("Grand Total: ${grandTotal.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 10),
        pw.Text("In Words: ${_convertNumberToWords(grandTotal)}"),
      ]));
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/Inv_${order['manifestNo']}.pdf");
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> updateOrderStatus(Map<String, dynamic> order, String newStatus) async {
    showDialog(context: context, barrierDismissible: false, builder: (c) => Center(child: CircularProgressIndicator(color: AppColors.accentGold)));
    try {
      final id = order['manifestId'];
      final url = Uri.parse('${Config.apiUrl}factory/orders/update/$id?DB=${Config.clientCode}');
      order['workflowStatus'] = newStatus;
      final res = await http.put(url, headers: {"Content-Type": "application/json"}, body: jsonEncode(order));
      Navigator.pop(context);
      if (res.statusCode == 200) {
        _orderService.fetchOrders();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Manifest moved to $newStatus"), backgroundColor: AppColors.statusDone));
      }
    } catch (e) { Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildTabBar(),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _orderService.isLoading,
              builder: (context, loading, _) {
                if (loading) return Center(child: CircularProgressIndicator(color: AppColors.primaryNavy));
                return TabBarView(
                  controller: _tabController,
                  children: List.generate(4, (index) => _buildOrderListView(index)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primaryNavy,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              "COMMAND CENTER",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 16)
          ),
          Text(
              Config.posTitle.toUpperCase(),
              style: const TextStyle(color: AppColors.accentGold, fontSize: 10, letterSpacing: 2)
          ),
        ],
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _orderService.fetchOrders
        ),
        IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => Navigator.pop(context)
        ),
      ],
    );
  }
  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
      child: Row(children: [
        Expanded(flex: 4, child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(icon: Icon(Icons.search, color: AppColors.industrialBlue), hintText: "Search Manifests...", border: InputBorder.none),
          ),
        )),
        SizedBox(width: 8),
        _buildDateChip("FROM", _customStartDate, _selectStartDate),
        SizedBox(width: 4),
        _buildDateChip("TO", _customEndDate, _selectEndDate),
      ]),
    );
  }

  Widget _buildDateChip(String l, DateTime? d, VoidCallback t) {
    return Expanded(child: InkWell(onTap: t, child: Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(l, style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.w900)),
        Text(d == null ? "SELECT" : DateFormat('dd/MM').format(d), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    )));
  }

  Widget _buildTabBar() {
    return Container(color: Colors.white, child: TabBar(
      controller: _tabController,
      indicatorColor: AppColors.accentGold,
      indicatorWeight: 4,
      labelColor: AppColors.primaryNavy,
      unselectedLabelColor: Colors.grey,
      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      tabs: [Tab(text: "PENDING"), Tab(text: "PROCESS"), Tab(text: "READY"), Tab(text: "DONE")],
    ));
  }

  Widget _buildOrderListView(int tabIndex) {
    final orders = _getOrdersForTab(tabIndex);
    if (orders.isEmpty) return Center(child: Opacity(opacity: 0.2, child: Icon(Icons.inventory_2_outlined, size: 80)));
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(orders[index], tabIndex),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, int tabIndex) {
    String status = (order['workflowStatus'] ?? 'PLACED').toString().toUpperCase();
    Color sCol = _getStatusColor(status);
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))]),
      child: InkWell(
        onTap: () => _showOrderDetails(order, tabIndex),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("MANIFEST #${order['manifestNo']}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryNavy)),
                Text(order['outletBrand'] ?? 'Feast Outlet', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: sCol.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(status == 'PLACED' ? 'PENDING' : status, style: TextStyle(color: sCol, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ]),
            Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _rowIcon(Icons.calendar_today, DateFormat('dd MMM').format(DateTime.parse(order['manifestDate'] ?? '2026-01-01'))),
              _rowIcon(Icons.access_time, order['manifestTime'] ?? '--:--'),
              _rowIcon(Icons.layers, order['fulfillmentType'] ?? 'STD'),
              Icon(Icons.chevron_right, color: Colors.grey[300]),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _rowIcon(IconData i, String t) {
    return Row(children: [Icon(i, size: 12, color: AppColors.accentGold), SizedBox(width: 4), Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]);
  }

  List<dynamic> _getOrdersForTab(int tabIndex) {
    final all = [..._orderService.pendingOrders.value, ..._orderService.completedOrders.value];
    List<dynamic> target;
    switch (tabIndex) {
      case 0: target = all.where((o) => (o['workflowStatus'] ?? 'PLACED').toUpperCase() == 'PLACED').toList(); break;
      case 1: target = all.where((o) => (o['workflowStatus'] ?? '').toUpperCase() == 'PROCESSING').toList(); break;
      case 2: target = all.where((o) => (o['workflowStatus'] ?? '').toUpperCase() == 'READY').toList(); break;
      case 3: target = all.where((o) => (o['workflowStatus'] ?? '').toUpperCase() == 'COMPLETED').toList(); break;
      default: target = [];
    }
    return _filterOrders(target);
  }

  List<dynamic> _filterOrders(List<dynamic> orders) {
    var filtered = orders.where((o) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return o['manifestNo'].toString().toLowerCase().contains(q) || o['outletBrand'].toString().toLowerCase().contains(q);
    }).toList();
    if (_customStartDate != null && _customEndDate != null) {
      filtered = filtered.where((o) {
        final d = DateTime.parse(o['manifestDate']);
        return !d.isBefore(_customStartDate!) && !d.isAfter(_customEndDate!.add(Duration(days: 1)));
      }).toList();
    }
    filtered.sort((a, b) => (b['manifestId'] ?? 0).compareTo(a['manifestId'] ?? 0));
    return filtered;
  }

  void _showOrderDetails(Map<String, dynamic> order, int tabIndex) {
    Map<String, dynamic> localOrder = json.decode(json.encode(order));
    bool edited = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setMState) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(children: [
          Container(margin: EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: EdgeInsets.all(24),
            child: Row(children: [
              CircleAvatar(backgroundColor: AppColors.primaryNavy, child: Icon(Icons.receipt_long, color: AppColors.accentGold)),
              SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Manifest #${localOrder['manifestNo']}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                Text(localOrder['outletBrand'] ?? '', style: TextStyle(color: Colors.grey)),
              ])
            ]),
          ),
          Expanded(child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: (localOrder['items'] as List).length,
            itemBuilder: (c, i) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(localOrder['items'][i]['itemDescription'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Order Qty: ${_getItemDisplayQuantity(localOrder['items'][i])}"),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text("DISPATCH: ${_getItemSendQuantity(localOrder['items'][i])}", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
                  if (tabIndex < 3) IconButton(icon: Icon(Icons.edit, size: 18), onPressed: () async {
                    bool res = await _showQuantityUpdateDialog(localOrder);
                    if (res) setMState(() => edited = true);
                  })
                ]),
              ),
            ),
          )),
          _buildActionPanel(localOrder, tabIndex, edited),
        ]),
      )),
    );
  }

  Widget _buildActionPanel(Map<String, dynamic> order, int tabIndex, bool edited) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          _actBtn("Invoice", Icons.receipt, () => printInvoice(order)),
          _actBtn("KOT", Icons.print, () => Navigator.push(context, MaterialPageRoute(builder: (c) => KotPreviewScreen(order: order)))),
          _actBtn("Challan", Icons.description, () => printChallan(order)),
        ])),
        SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            Navigator.pop(context);
            String nxt = tabIndex == 0 ? "PROCESSING" : tabIndex == 1 ? "READY" : "COMPLETED";
            if (tabIndex < 3) updateOrderStatus(order, nxt);
          },
          child: Text("PROCEED TO NEXT STAGE", style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
        ))
      ]),
    );
  }

  Widget _actBtn(String l, IconData i, VoidCallback t) {
    return Padding(padding: const EdgeInsets.only(right: 8), child: OutlinedButton.icon(onPressed: t, icon: Icon(i, size: 16), label: Text(l, style: TextStyle(fontSize: 11))));
  }

  Color _getStatusColor(String s) {
    if (s == 'PLACED') return AppColors.statusPending;
    if (s == 'PROCESSING') return AppColors.statusProcessing;
    if (s == 'READY') return AppColors.statusShipped;
    return AppColors.statusDone;
  }

  Future<void> _selectStartDate() async {
    final p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
    if (p != null) setState(() { _customStartDate = p; });
  }

  Future<void> _selectEndDate() async {
    final p = await showDatePicker(context: context, initialDate: _customStartDate ?? DateTime.now(), firstDate: _customStartDate ?? DateTime(2020), lastDate: DateTime.now());
    if (p != null) { setState(() { _customEndDate = p; }); _orderService.fetchOrders(); }
  }

  Future<bool> _showQuantityUpdateDialog(Map<String, dynamic> order) async {
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final ctrls = items.map((i) => TextEditingController(text: _getItemSendQuantity(i).toString())).toList();
    bool changed = false;
    await showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("Adjust Dispatch Quantities"),
      content: Container(width: 300, child: ListView.builder(shrinkWrap: true, itemCount: items.length, itemBuilder: (cc, ii) => ListTile(
        title: Text(items[ii]['itemDescription']),
        trailing: SizedBox(width: 50, child: TextField(controller: ctrls[ii], keyboardType: TextInputType.number)),
      ))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text("Cancel")),
        ElevatedButton(onPressed: () {
          for (int x=0; x<items.length; x++) {
            _recalculateItemPriceAndTaxes(items[x], int.tryParse(ctrls[x].text) ?? _getItemSendQuantity(items[x]));
          }
          changed = true; Navigator.pop(c);
        }, child: Text("Save"))
      ],
    ));
    return changed;
  }
}

class KotPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  KotPreviewScreen({required this.order});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("KOT PREVIEW"), backgroundColor: AppColors.primaryNavy),
      body: Center(child: Container(
        width: 300, padding: EdgeInsets.all(20), color: Colors.white,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("KOT", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Courier', color: AppColors.primaryNavy)),
          Divider(),
          Text("MANIFEST: ${order['manifestNo']}", style: TextStyle(fontFamily: 'Courier', fontSize: 12, color: AppColors.primaryNavy,fontWeight: FontWeight.bold)),
          ...(order['items'] as List).map((i) => Text("${_getItemSendQuantity(i)} x ${i['itemDescription']}", style: TextStyle(fontFamily: 'Courier', fontSize: 12, color: AppColors.primaryNavy,fontWeight: FontWeight.bold))).toList(),
          Divider(),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("PRINT"))
        ]),
      )),
    );
  }
}