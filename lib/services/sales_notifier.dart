import 'package:flutter/material.dart';
import 'package:panaderia_liz/models/index.dart';
import 'package:panaderia_liz/services/sales_service_db.dart';

class SalesNotifier extends ChangeNotifier {
  final SalesServiceDB _salesService;
  List<Sale> _sales = [];
  bool _isLoading = false;

  SalesNotifier(this._salesService);

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;

  Future<void> loadSales() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sales = await _salesService.getAllSales();
    } catch (e) {
      print('Error loading sales in notifier: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Called after a successful sale from TPV - adds to the top and notifies
  void addSale(Sale sale) {
    _sales.insert(0, sale);
    notifyListeners();
  }
}
