import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class License {
  final List<String> packs;
  final List<String> paras;

  License({required this.packs, required this.paras});
}

class LicensesPage extends StatefulWidget {
  final Function([String]) exit;
  const LicensesPage({super.key, required this.exit});

  @override
  State<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends State<LicensesPage> {
  Future<List<License>> getLicenses() async {
    final List<License> licenses;

    final licensesList = await LicenseRegistry.licenses.toList();
    // print("Total ${licensesList.length} licenses");

    licenses = licensesList
        .map((license) => License(
            packs: license.packages.toList(),
            paras: license.paragraphs.map((p) => p.text).toList()))
        .toList();

    return licenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              alignment: Alignment.center,
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => widget.exit(),
              density: ButtonDensity.icon,
            )
          ],
          title: Text("Licenses"),
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image(
              image: AssetImage("lib/assets/splash.png"),
              width: 80,
              height: 80,
            ),
            Gap(16),
            Text("ChronoSync Productivity").sans().large().semiBold(),
            Gap(12),
            Text("Version 1.0.0").sans().small(),
            Text("© Araf A., 2025").sans().small().muted(),
            FutureBuilder<List<License>>(
              future: getLicenses(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<License>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      size: 32,
                    ),
                  ).withMargin(top: 32);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}').sans());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No licenses available.').sans());
                }

                Map<String, Set<List<String>>> licenses = {};
                final licensesData = snapshot.data!;
                for (var lData in licensesData) {
                  for (var pack in lData.packs) {
                    licenses.update(
                      pack,
                      (curParas) {
                        curParas.add(lData.paras);
                        return curParas;
                      },
                      ifAbsent: () => {lData.paras},
                    );
                  }
                }

                List<String> licenseKeys = licenses.keys.toList();
                licenseKeys.sort();

                return Accordion(
                  items: [
                    for (var lKey in licenseKeys)
                      AccordionItem(
                        expanded: false,
                        trigger: AccordionTrigger(
                            child: Text(lKey).sans()),
                        content: licenses[lKey] != null
                            ? Column(
                                children: [
                                  for (var lParasList in licenses[lKey]!)
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Divider(),
                                          Gap(8),
                                          for (var lPara in lParasList)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Gap(4),
                                                Text(lPara)
                                                    .sans()
                                                    .small()
                                                    .muted(),
                                                Gap(4),
                                              ],
                                            )
                                        ])
                                ],
                              )
                            : Text("No licenses for this package.").sans(),
                      )
                  ],
                );
              },
            ).withMargin(top: 32),
          ],
        ),
      ),
    );
  }
}
