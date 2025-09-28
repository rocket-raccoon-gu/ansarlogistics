import 'dart:developer';

import 'package:ansarlogistics/utils/utils.dart';

class PriceWeightCalculator {
  // Calculate price from weight
  static String getPriceFromWeight(
    String sellingPrice,
    String weightGrams,
    String itemName,
  ) {
    double selling = double.parse(sellingPrice);
    double weight = double.parse(weightGrams);
    double uomGrams = getUomWeightInGrams(extractUomFromItemName(itemName));

    double pricePerGram = selling / uomGrams;

    log("pricePerGram: $pricePerGram");

    log("weight: $weight");

    log("uomGrams: $uomGrams");

    log("selling: $selling");

    log("pricePerGram: ${pricePerGram.toStringAsFixed(2)}");

    return (weight * pricePerGram).toStringAsFixed(2);
  }

  // Calculate weight from price
  static String getWeightFromPrice(
    String sellingPrice,
    String targetPrice,
    String itemName,
  ) {
    double selling = double.parse(sellingPrice);
    double target = double.parse(targetPrice);
    double uomGrams = getUomWeightInGrams(extractUomFromItemName(itemName));

    double pricePerGram = selling / uomGrams;
    return (target / pricePerGram).toStringAsFixed(2);
  }

  // Calculate actual weight from scaled price (your original need)
  static String getActualWeight(
    String sellingPrice,
    String scaledPrice,
    String itemName,
  ) {
    double selling = double.parse(sellingPrice);
    double scaled = double.parse(scaledPrice);
    double uomGrams = getUomWeightInGrams(extractUomFromItemName(itemName));

    double pricePerGram = selling / uomGrams;
    return (scaled / pricePerGram).toStringAsFixed(2);
  }
}
