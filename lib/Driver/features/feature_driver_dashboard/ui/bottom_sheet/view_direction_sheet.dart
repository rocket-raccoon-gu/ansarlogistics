import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewDirectionSheet extends StatelessWidget {
  String destinationlat;
  String destinationlong;
  ViewDirectionSheet({
    super.key,
    required this.destinationlat,
    required this.destinationlong,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Tracker Options",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await launchUrl(
                      Uri.parse(
                        'http://maps.google.com/maps?q=${destinationlat},${destinationlong}',
                      ),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  },
                  child: Container(
                    child: Column(
                      children: [
                        Image.asset("assets/gmap.png", height: 60.0),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Google Map",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await launchUrl(
                      Uri.parse(
                        'https://ul.waze.com/ul?ll=${destinationlat},${destinationlong}',
                      ),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  },
                  child: Container(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40.0),
                          child: Image.asset("assets/waze.png", height: 60.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Waze",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await launchUrl(
                      Uri.parse(
                        'https://wain.qmic.com/share/Location?type=101&lat=${destinationlat}&lng=${destinationlong}',
                      ),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  },
                  child: Container(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset('assets/wain.png', height: 60.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Wain",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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

class ViewDirectionRouteSheet extends StatelessWidget {
  String gurl;
  String waseurl;
  ViewDirectionRouteSheet({
    super.key,
    required this.gurl,
    required this.waseurl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Options",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await launchUrl(
                      Uri.parse('${gurl}'),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  },
                  child: Container(
                    child: Column(
                      children: [
                        Image.asset("assets/gmap.png", height: 60.0),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Google Map",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await launchUrl(
                      Uri.parse('${waseurl}'),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  },
                  child: Container(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40.0),
                          child: Image.asset("assets/waze.png", height: 60.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Waze",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
