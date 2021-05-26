import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mass_text_flutter/services/purchase_handler.dart';
import 'package:mass_text_flutter/shared/bouncing_button.dart';
import 'package:provider/provider.dart';

import '../styles.dart';

class PremiumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _premiumViewModel = Provider.of<PremiumViewModel>(context, listen: false);
    ProductDetails premiumProduct = _premiumViewModel.productForPremium();

    return _premiumViewModel.isPremium()
        ? null
        : Center(
            child: myContainer(
              Column(
                children: [
                  Text("Be a Gold User to unlock full potential!", style: TextStyles.medium.bold),
                  SizedBox(height: 16),
                  Text("Bypass 300 contact limit on import", style: TextStyles.medium.colour(Colors.white70)),
                  SizedBox(height: 4),
                  Text("Disable Character Limit", style: TextStyles.medium.colour(Colors.white70)),
                  SizedBox(height: 4),
                  Text("Merge multiple groups", style: TextStyles.medium.colour(Colors.white70)),
                  SizedBox(height: 4),
                  SizedBox(height: 16),
                  BouncingButton(
                    "   BUY PREMIUM",
                    () => PurchaseHandler.buyProduct(premiumProduct),
                    labelSize: 14.0,
                    logo: "assets/diamond.png",
                    width: 180,
                  ),
                  SizedBox(height: 4),
                  Text("${premiumProduct != null ? premiumProduct.price : "Php 199.99"} / One-time Purchase",
                      style: TextStyles.small.colour(Colors.white70)),
                ],
              ),
            ),
          );
  }

  // Private methods go here

}
