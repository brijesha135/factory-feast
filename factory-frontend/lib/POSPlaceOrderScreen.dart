import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:ui';
import 'config.dart';


class AppColors {
  static const Color primaryNavy = Color(0xFF071013); // Darker Navy
  static const Color industrialGray = Color(0xFF141E22); // Near Black
  static const Color accentGold = Color(0xFFB08D1A); // Deeper Gold
  static const Color successGreen = Color(0xFF1E8449); // Darker Green
  static const Color errorRed = Color(0xFFC0392B); // Darker Red
  static const Color scaffoldBg = Color(0xFFE8ECEF); // Darker background
  static const Color textWhite = Colors.white;
  static const Color textMain = Color(0xFF000000); // Pure Black
  static const Color textSecondary = Color(0xFF2C3E50); // Deep Blue-Gray
}

class TaxRule {
  final String label;
  final double percentage;
  TaxRule({required this.label, required this.percentage});
  factory TaxRule.fromJson(Map<String, dynamic> j) =>
      TaxRule(label: j['label'] ?? 'TAX', percentage: (j['percentage'] ?? 0.0).toDouble());
}

class Category {
  final String code;
  final String name;
  Category({required this.code, required this.name});
  factory Category.fromJson(Map<String, dynamic> j) =>
      Category(code: j['categoryCode'] ?? '', name: j['categoryName'] ?? '');
}

class Modifier {
  final String code;
  final String name;
  final double price;
  Modifier({required this.code, required this.name, required this.price});
  factory Modifier.fromJson(Map<String, dynamic> j) =>
      Modifier(code: j['modifierCode'] ?? '0', name: j['modifierName'] ?? '', price: (j['price'] ?? 0.0).toDouble());
}

class Variant {
  final int id;
  final String name;
  final double price;
  Variant({required this.id, required this.name, required this.price});
  factory Variant.fromJson(Map<String, dynamic> j) =>
      Variant(id: j['variantId'] ?? 0, name: j['variantName'] ?? '', price: (j['additionalPrice'] ?? 0.0).toDouble());
}

class Product {
  final int sku;
  final String name;
  final String catCode;
  final double price;
  final String taxGroup;
  Product({required this.sku, required this.name, required this.catCode, required this.price, required this.taxGroup});
  factory Product.fromMap(Map<String, dynamic> j) => Product(
    sku: j['skuCode'] ?? 0,
    name: j['productName'] ?? j['product_display_name'] ?? 'ITEM',
    catCode: j['categoryCode'] ?? j['category_code'] ?? '',
    price: (j['baseFactoryPrice'] ?? j['base_factory_price'] ?? 0.0).toDouble(),
    taxGroup: j['taxIndicator'] ?? 'A',
  );
}

class CartItem {
  final Product product;
  Variant? variant;
  List<Modifier> modifiers;
  List<TaxRule> taxes;
  CartItem({required this.product, this.variant, required this.modifiers, required this.taxes});

  double get unitBasePrice => product.price + (variant?.price ?? 0.0) + modifiers.fold(0.0, (s, m) => s + m.price);
  double get totalTax => taxes.fold(0.0, (sum, t) => sum + (unitBasePrice * (t.percentage / 100)));
  double get totalWithTax => unitBasePrice + totalTax;
}




class FactoryPOSScreen extends StatefulWidget {
  const FactoryPOSScreen({super.key});
  @override
  _FactoryPOSScreenState createState() => _FactoryPOSScreenState();
}

class _FactoryPOSScreenState extends State<FactoryPOSScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool isLoad = true;
  List<Product> prods = [];
  List<Category> cats = [];
  List<CartItem> cart = [];
  String selCat = "";

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _sync();
  }

  Future<void> _sync() async {
    debugPrint("[DEBUG] STARTING CATALOG SYNC...");

    final String productUrl = "${Config.apiUrl}products/getAll?DB=${Config.db}";
    final String categoryUrl = "${Config.apiUrl}category/getAll?DB=${Config.db}";

    debugPrint("[DEBUG] TARGET PRODUCT URL: $productUrl");
    debugPrint("[DEBUG] TARGET CATEGORY URL: $categoryUrl");

    try {
      final pR = await http.get(Uri.parse(productUrl));
      final cR = await http.get(Uri.parse(categoryUrl));

      debugPrint("[DEBUG] PRODUCT STATUS: ${pR.statusCode}");
      debugPrint("[DEBUG] CATEGORY STATUS: ${cR.statusCode}");

      if (pR.statusCode == 200 && cR.statusCode == 200) {
        debugPrint("[DEBUG] RAW PRODUCT BODY: ${pR.body}");
        debugPrint("[DEBUG] RAW CATEGORY BODY: ${cR.body}");

        final List pData = json.decode(pR.body);
        final List cData = json.decode(cR.body);

        debugPrint("[DEBUG] RECEIVED ${cData.length} CATEGORIES");
        debugPrint("[DEBUG] RECEIVED ${pData.length} PRODUCTS");

        setState(() {
          cats = cData.map((e) => Category.fromJson(e)).toList();
          prods = pData.map((e) => Product.fromMap(e)).toList();

          if (cats.isNotEmpty) {
            selCat = cats.first.code;
            debugPrint("[DEBUG] AUTO-SELECTED CATEGORY CODE: $selCat");

            final matchCount = prods.where((p) => p.catCode == selCat).length;
            debugPrint("[DEBUG] PRODUCTS MATCHING '$selCat': $matchCount");

            if(matchCount == 0 && prods.isNotEmpty) {
              debugPrint("[DEBUG] WARNING: Products exist but none match category '$selCat'. Check catCode spelling!");
            }
          } else {
            debugPrint("[DEBUG] WARNING: No categories found. Grid will remain empty.");
          }
          isLoad = false;
        });
      } else {
        debugPrint("[DEBUG] SERVER ERROR: Products(${pR.statusCode}) Categories(${cR.statusCode})");
        setState(() => isLoad = false);
      }
    } catch (e) {
      debugPrint("[DEBUG] FATAL SYNC ERROR: $e");
      setState(() => isLoad = false);
    }
  }

  Future<void> _pushOrder(String type, {List<Map<String, dynamic>>? mock}) async {
    debugPrint("[DEBUG] CREATING ORDER FOR TYPE: $type");
    final url = "${Config.apiUrl}factory/orders/create?DB=${Config.db}";

    final payload = {
      "manifestNo": "F-${DateTime.now().millisecondsSinceEpoch}",
      "fulfillmentType": type,
      "licenseKey": "LIC-FACTORY-FEAST-2026",
      "manifestDate": DateTime.now().toIso8601String().split('T')[0],
      "manifestTime": TimeOfDay.now().format(context),
      "outletBrand": Config.brand,
      "workflowStatus": "PLACED",
      "items": mock ?? cart.map((e) => {
        "productSku": e.product.sku.toString(),
        "itemDescription": e.product.name,
        "receiveQty": 1,
        "unitBasePrice": e.unitBasePrice,
        "grossLineTotal": e.totalWithTax,
      }).toList(),
    };

    debugPrint("[DEBUG] PAYLOAD: ${jsonEncode(payload)}");

    try {
      final res = await http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: jsonEncode(payload));
      debugPrint("[DEBUG] SERVER RESPONSE: ${res.statusCode} - ${res.body}");
      if (res.statusCode == 201) {
        if (mock == null) setState(() => cart.clear());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("MANIFEST CREATED SUCCESSFULLY")));
      }
    } catch (e) {
      debugPrint("[DEBUG] POST ERROR: $e");
    }
  }
  void _configure(Product p) async {
    final vR = await http.get(Uri.parse("${Config.apiUrl}variants/${p.sku}?DB=${Config.db}"));
    final mR = await http.get(Uri.parse("${Config.apiUrl}modifiers/getAll?DB=${Config.db}"));
    final tR = await http.get(Uri.parse("${Config.apiUrl}taxes/${p.taxGroup}?DB=${Config.db}"));

    List<Variant> vs = (vR.statusCode == 200) ? (json.decode(vR.body) as List).map((e) => Variant.fromJson(e)).toList() : [];
    List<Modifier> ms = (mR.statusCode == 200) ? (json.decode(mR.body) as List).map((e) => Modifier.fromJson(e)).toList() : [];
    List<TaxRule> ts = (tR.statusCode == 200) ? (json.decode(tR.body) as List).map((e) => TaxRule.fromJson(e)).toList() : [];

    Variant? sv; List<Modifier> sm = [];
    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (c, st) => AlertDialog(
        insetPadding: const EdgeInsets.all(20), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Container(color: AppColors.primaryNavy, padding: const EdgeInsets.all(15), child: Text(p.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.accentGold, fontSize: 16))),
        content: SizedBox(width: MediaQuery.of(context).size.width * 0.7, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(padding: EdgeInsets.all(15), child: Text("SELECT VARIANT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ...vs.map((v) => RadioListTile<Variant>(activeColor: AppColors.primaryNavy, title: Text(v.name), value: v, groupValue: sv, onChanged: (x) => st(() => sv = x))),
          const Divider(),
          const Padding(padding: EdgeInsets.all(15), child: Text("SELECT MODIFIERS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ...ms.map((m) => CheckboxListTile(activeColor: AppColors.primaryNavy, title: Text(m.name), value: sm.contains(m), onChanged: (x) => st(() { if(x!) sm.add(m); else sm.remove(m); })))
        ]))),
        actions: [ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy), onPressed: () { setState(() => cart.add(CartItem(product: p, variant: sv, modifiers: List.from(sm), taxes: ts))); Navigator.pop(c); }, child: const Text("COMMIT TO ORDER", style: TextStyle(color: AppColors.accentGold)))]
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(Config.brand, style: const TextStyle(color: AppColors.accentGold, letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 20)),
          bottom: TabBar(controller: _tabs, indicatorColor: AppColors.accentGold, tabs: const [
            Tab(child: Text("NEW SALE", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 11))),
            Tab(child: Text("ADVANCE", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 11))),
            Tab(child: Text("URGENT", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 11))),
          ],)
      ),
      body: isLoad ? const Center(child: CircularProgressIndicator()) : TabBarView(controller: _tabs, children: [_buildPos(), _buildQ("ADVANCE"), _buildQ("URGENT")]),
    );
  }

  Widget _buildPos() => Row(children: [
    Expanded(flex: 3, child: Column(children: [
      Container(height: 60, color: Colors.white, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: cats.length, itemBuilder: (c, i) => Padding(padding: const EdgeInsets.all(8), child: ChoiceChip(label: Text(cats[i].name), selected: selCat == cats[i].code, onSelected: (v) => setState(() => selCat = cats[i].code))))),
      Expanded(child: GridView.builder(padding: const EdgeInsets.all(15), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: prods.where((p) => p.catCode == selCat).length, itemBuilder: (c, i) {
        final p = prods.where((x) => x.catCode == selCat).toList()[i];
        return InkWell(onTap: () => _configure(p), child: Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[200]!)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(p.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.primaryNavy)), Text("₹${p.price}", style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.w900))])));
      }))
    ])),
    const VerticalDivider(width: 1),
    Expanded(flex: 2, child: _buildBillingSidebar())
  ]);

  Widget _buildBillingSidebar() {
    return Column(children: [
      // Header remains dark but text is boosted
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          color: AppColors.industrialGray,
          child: const Text(
              "ORDER AUDIT SUMMARY",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)
          )
      ),
      Expanded(child: ListView.builder(
        itemCount: cart.length,
        itemBuilder: (c, i) {
          final item = cart[i];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                // Darkened border from grey[200] to a much more visible black12/black26
                border: Border.all(color: Colors.black26, width: 1.5)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  dense: true,
                  title: Text(
                      item.product.name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textMain)
                  ),
                  trailing: Text(
                      "₹${item.product.price}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain)
                  ),
                  leading: IconButton(
                      icon: const Icon(Icons.remove_circle, color: AppColors.errorRed, size: 24),
                      onPressed: () => setState(() => cart.removeAt(i))
                  ),
                ),
                // Variants: Moved from blueGrey to textSecondary (Much Darker)
                if (item.variant != null)
                  Padding(
                      padding: const EdgeInsets.only(left: 70, bottom: 4),
                      child: Text(
                          "+ ${item.variant!.name} (₹${item.variant!.price})",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary)
                      )
                  ),
                // Modifiers: Darker and bold
                ...item.modifiers.map((m) => Padding(
                    padding: const EdgeInsets.only(left: 70, bottom: 2),
                    child: Text(
                        "+ ${m.name} (₹${m.price})",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: AppColors.textSecondary)
                    )
                )),
                const Divider(thickness: 1, color: Colors.black12),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("TAX & SURCHARGE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMain)),
                          Text("₹${item.totalTax.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textMain))
                        ]
                    )
                ),
              ],
            ),
          );
        },
      )),
      // Bottom Summary Section
      Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.primaryNavy, width: 3)) // Stronger visual separation
          ),
          child: Column(children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("GRAND TOTAL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textMain)),
                  Text(
                      "₹${cart.fold(0.0, (s, i) => s + i.totalWithTax).toStringAsFixed(2)}",
                      style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w900, fontSize: 28) // Increased size
                  )
                ]
            ),
            const SizedBox(height: 15),
            SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                    onPressed: () => _pushOrder("SALE"),
                    child: const Text(
                        "CONFIRM & SAVE TRANSACTION",
                        style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.1)
                    )
                )
            )
          ])
      ),
    ]);
  }

  Widget _buildQ(String type) {
    // Logic to get current date formatted for the mock data
    final String todayStr = DateFormat('MMM dd').format(DateTime.now()); // Jan 11

    final mockData = type == "URGENT" ? [
      {"id": "URG-401", "loc": "South Point Mall", "items": "15x Croissant", "amt": 2700.0, "time": "18:45"},
      {"id": "URG-402", "loc": "Railway Hub", "items": "20x Baguette", "amt": 3000.0, "time": "19:00"},
      {"id": "URG-403", "loc": "Airport Wing A", "items": "5x Choco Cake", "amt": 6000.0, "time": "19:15"},
      {"id": "URG-404", "loc": "Main City Cafe", "items": "10x Sourdough", "amt": 1800.0, "time": "19:30"},
      {"id": "URG-405", "loc": "Corporate Park", "items": "12x Pastry", "amt": 1440.0, "time": "19:45"},
    ] : [
      {"id": "ADV-701", "loc": "North Side Shop", "items": "25x Baguette", "amt": 3750.0, "time": todayStr},
      {"id": "ADV-702", "loc": "East Coast Hub", "items": "10x Sourdough", "amt": 1800.0, "time": todayStr},
      {"id": "ADV-703", "loc": "Green Valley", "items": "5x Wedding Cake", "amt": 15000.0, "time": "Jan 12"},
      {"id": "ADV-704", "loc": "High Street Cafe", "items": "50x Cookies", "amt": 4750.0, "time": "Jan 12"},
      {"id": "ADV-705", "loc": "River Side Hub", "items": "30x Croissant", "amt": 3600.0, "time": "Jan 13"},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockData.length,
      itemBuilder: (c, i) => Card(
        // Background made deep black-navy
        color: AppColors.primaryNavy,
        elevation: 4,
        // Border darkened and thickened to Accent Gold for high contrast
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.accentGold, width: 2.0)
        ),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Order ID in Gold
                Text(
                    mockData[i]['id'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.accentGold, letterSpacing: 1.2)
                ),
                const SizedBox(height: 4),
                // Location in Bold White
                Text(
                    mockData[i]['loc'] as String,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)
                ),
                // Items in Bold White
                Text(
                    mockData[i]['items'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w900)
                ),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                // Due time in bright red for urgency
                Text(
                    "DUE: ${mockData[i]['time']}",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.redAccent)
                ),
                // Price in large bold white
                Text(
                    "₹${(mockData[i]['amt'] as double).toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)
                ),
                const SizedBox(height: 10),
                // Action button made larger and more contrasty
                SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => _pushOrder(type, mock: [{
                        "productSku": "MOCK",
                        "itemDescription": mockData[i]['items'] as String,
                        "receiveQty": 1,
                        "unitBasePrice": mockData[i]['amt'] as double,
                        "grossLineTotal": mockData[i]['amt'] as double
                      }]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                          "PUSH TO KITCHEN",
                          style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w900)
                      ),
                    )
                )
              ])
            ])),
      ),

    );
  }
}