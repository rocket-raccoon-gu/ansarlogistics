import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';

class FilterByType extends StatefulWidget {
  Function(int index)? onTapSubmit;
  List<Map<String, dynamic>> statuslist;
  int selectedindex;
  FilterByType({
    super.key,
    required this.onTapSubmit,
    required this.statuslist,
    required this.selectedindex,
  });

  @override
  State<FilterByType> createState() => _FilterByTypeState();
}

class _FilterByTypeState extends State<FilterByType> {
  // int selectedindexed = UserController().selectedindex;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select the Filter Status",
                style: customTextStyle(fontStyle: FontStyle.BodyL_Bold),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 2.0, right: 2.0),
          child: Row(
            children: [
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: widget.statuslist.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.7,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.selectedindex = index;

                            UserController().selectedindex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color:
                                widget.selectedindex == index
                                    ? customColors().green3
                                    : customColors().backgroundPrimary,
                            border: Border.all(
                              color: customColors().fontPrimary,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.statuslist[index]['name'],
                              textAlign: TextAlign.center,
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyM_Bold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 35.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: BasketButton(
                    text: "Submit",
                    onpress: () {
                      UserController().selectedindex = widget.selectedindex;

                      widget.onTapSubmit!(widget.selectedindex);
                    },
                    bgcolor: customColors().green600,
                    textStyle: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.White,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
