import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
      ),
      backgroundColor: customColors().backgroundPrimary,
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: HexColor('#F9FBFF'),
              border: Border(
                bottom: BorderSide(
                  width: 2.0,
                  color: customColors().backgroundTertiary,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: customColors().backgroundTertiary.withOpacity(1.0),
                  spreadRadius: 3,
                  blurRadius: 5,
                  // offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(top: mheight * .012),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              bottom: 16.0,
                              top: 8.0,
                            ),
                            child: Text(
                              "My Products ",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "No Data Available...!",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.FontPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
