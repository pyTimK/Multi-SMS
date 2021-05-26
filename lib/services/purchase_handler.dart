import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mass_text_flutter/styles.dart';

class PremiumViewModel extends ChangeNotifier {
  PremiumViewModel() {
    loadData();
  }
  final String _myProductID = 'premium_content';
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  List<ProductDetails> get products => _products;
  List<PurchaseDetails> get purchases => _purchases;

  bool isPremium() {
    for (var prod in products) {
      if (PurchaseHandler.hasPurchased(prod.id, purchases) != null) {
        if (prod.id == _myProductID) return true;
      }
    }
    return false;
  }

  ProductDetails productForPremium() {
    for (var prod in products) {
      if (prod.id == _myProductID) return prod;
    }
    return null;
  }

  Future<void> loadData() async {
    _products = await PurchaseHandler.getProducts();
    _purchases = await PurchaseHandler.getPastPurchases();
    notifyListeners();
  }

  set purchases(List<PurchaseDetails> _newPurchases) {
    _purchases = _newPurchases;
    notifyListeners();
  }
}

class PurchaseHandler {
  static final _iap = InAppPurchaseConnection.instance;

  static final String _myProductID = 'premium_content';

  static Future<List<PurchaseDetails>> getPastPurchases() async {
    final QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    if (response.error != null) {
      MyToast.show("Error loading past purchases");
      return [];
    }
    return verifyPurchases(response.pastPurchases);
  }

  static List<PurchaseDetails> verifyPurchases(List<PurchaseDetails> purchases) {
    List<PurchaseDetails> list = [];
    for (PurchaseDetails purchase in purchases) {
      //VERIFY PURCHASE
      if (purchase != null && purchase.status == PurchaseStatus.purchased) {
        list.add(purchase);
        _iap.completePurchase(purchase);
      }
    }
    return list;
  }

  /// Get all products available for sale
  static Future<List<ProductDetails>> getProducts() async {
    Set<String> ids = {_myProductID};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    print("is available:");
    print(response.productDetails);
    return response.productDetails;
  }

  static PurchaseDetails hasPurchased(String productID, List<PurchaseDetails> purchases) =>
      purchases.firstWhere((purchase) => purchase.productID == productID, orElse: () => null);

  static buyProduct(ProductDetails prod) async {
    if (prod == null) {
      MyToast.show("Invalid Product");
      return;
    }
    bool available = await _iap.isAvailable();
    if (!available) {
      MyToast.show("Problem occured while connecting to Play Store.");
      return;
    }
    PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
    // _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
  }
}
