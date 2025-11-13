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
    String sellingweight,
    String sellinguom,
  ) {
    double selling = double.parse(sellingPrice);
    double scaled = double.parse(scaledPrice);

    log("selling: $selling");

    log("scaled: $scaled");

    log("sellingweight: $sellingweight");

    log("sellinguom: $sellinguom");

    if (sellingweight.isEmpty || sellinguom.isEmpty) {
      return "";
    }

    double pricepergram =
        selling / convertWeightToGrams(sellingweight, sellinguom);
    double scaledgram = scaled / pricepergram;

    log("scaledgram: $scaledgram");

    return scaledgram.toStringAsFixed(2);
  }

  static double convertWeightToGrams(String weight, String uom) {
    switch (uom.toLowerCase()) {
      case 'g':
        return double.parse(weight);
      case 'kg':
        return double.parse(weight) * 1000;
      case 'lb':
        return double.parse(weight) * 453.592;
      case 'oz':
        return double.parse(weight) * 28.3495;
      default:
        return double.parse(weight);
    }
  }

  static String getPrice(
    String sellingPrice,
    String weightGrams,
    String uom,
    String pickedWeight,
  ) {
    double selling = double.parse(sellingPrice);
    double weight = convertWeightToGrams(weightGrams, uom);

    double pricePerGram = selling / weight;

    log("pricePerGram: $pricePerGram");

    log("weight: $weight");

    log("selling: $selling");

    log("pricePerGram: ${pricePerGram.toStringAsFixed(2)}");

    log("pickedWeight: $pickedWeight");

    double pickedWeightInGrams = convertWeightToGrams(pickedWeight, uom);

    log("pickedWeightInGrams: $pickedWeightInGrams");

    return (pickedWeightInGrams * pricePerGram).toStringAsFixed(2);
  }
}
