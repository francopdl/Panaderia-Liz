import 'package:panaderia_liz/models/index.dart';
import 'package:panaderia_liz/services/firestore_service.dart';

class SalesServiceDB {
  static SalesServiceDB? _instance;
  final FirestoreService _fs = FirestoreService();

  SalesServiceDB._internal();

  factory SalesServiceDB() {
    _instance ??= SalesServiceDB._internal();
    return _instance!;
  }

  Future<Sale?> saveSaleWithTransaction(
    String userId,
    List<CartItem> cartItems,
    double total, {
    String paymentMethod = 'cash',
  }) async {
    return _fs.saveSaleWithTransaction(userId, cartItems, total,
        paymentMethod: paymentMethod);
  }

  Future<List<Sale>> getAllSales() async {
    return _fs.getAllSales();
  }

  Future<Sale?> getSaleById(String saleId) async {
    return _fs.getSaleById(saleId);
  }

  Future<int> getSalesCount() async {
    return _fs.getSalesCount();
  }

  Future<double> getTotalSalesAmount() async {
    return _fs.getTotalSalesAmount();
  }

  Future<double> getDailyTotal() async {
    return _fs.getDailyTotal();
  }
}
