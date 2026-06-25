import 'package:flutter/material.dart';
import 'package:aap/screens/add_patient.dart';
import 'package:aap/screens/home.dart';
import 'package:aap/screens/protocol.dart';
import 'package:aap/services/auth_service.dart';
// import 'package:aap/services/scan_service.dart';
// import 'package:aap/screens/report_kit_damage.dart';
// import 'package:aap/screens/kit_bulk_update.dart';
// import 'package:aap/models/menuitem_modal.dart';
// import 'package:aap/screens/statement.dart';
import 'package:aap/screens/side_menu.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:aap/util/defaulttestGroupDialog.dart';
import 'package:aap/util/snackbar.dart';

class BottomNav extends StatefulWidget {
  int routeIndex;

  BottomNav({super.key, required this.routeIndex});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<NavigationItem> bottomNav = [];
  List<Widget> pages = [
    const Home(),
    const AddPatient(),
    const Protocol(),
    // const ReportKitDamage(),
    // const KitBulkUpdate(),
    // const AccountStatement()
  ];
  // Future<List<NavigationItem>>? _navigationItems;
  late List<BottomNavigationBarItem> navVal = [];
  late List<String> menuItem = [];

  int currentIndex = 1;

  void onTap(int index) {
    setState(() {
      currentIndex = index;
      widget.routeIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    registerFcm();
    // if(navVal.isEmpty){
    //   getMenu();
    // }
    currentIndex = widget.routeIndex;

    FBroadcast.instance().register(
      "scroll_to_protocol", 
      (value, callback) {
        setState(() {
          currentIndex = 2;
        });
      },
      more: {
        'genric': (value, callback) {
          CustomSnackBar(seconds: 30, text: value, type: "notification").show(context);
        }

      }
    );
  }

  registerFcm() async {
    final service = AuthService();
    // final scanService = ScanService();
    await service.saveFcmToken();
    await service.verifyToken();
    // await scanService.getDefaultTestGroup();
    // setDefaultTestGroup();
  }

  setDefaultTestGroup() async{
    var sharedIns = SharedPref();
    final defaultTG = await sharedIns.getValueFromSharedPreferences("defaultTestGroupId");

    if(defaultTG == ''){
      if(mounted){
        showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (BuildContext context) {
          return const DefaultTestGroupDialog();
        });
      }
      
    }else{
      
    }

  }

  // Future<List<BottomNavigationBarItem>> getMenu() async {
  //   if (navVal.isNotEmpty) {
  //     return navVal;
  //   }
  //   final service = AuthService();
  //   final data = await service.fetchMenu();
  //   // print(data);
  //   if (data.success) {
  //     List menu = data.data;
  //     menu.forEach((item) {
  //       menuItem.add(item.code);
  //     });

  //     if (menuItem.contains("KIT")) {
  //       navVal.add(const BottomNavigationBarItem(
  //           icon: Icon(Icons.person_search_outlined), label: 'Search'));
  //       navVal.add(const BottomNavigationBarItem(
  //           icon: Icon(Icons.person_add_alt_outlined), label: 'Add Patient'));
  //       navVal.add(const BottomNavigationBarItem(
  //           icon: Icon(Icons.functions_outlined), label: 'Protocols'));
  //       navVal.add(const BottomNavigationBarItem(
  //           icon: Icon(Icons.build_outlined), label: 'Kit Management'));
  //       navVal.add(const BottomNavigationBarItem(
  //           icon: Icon(Icons.difference_outlined), label: 'Kit Bulk Op'));
  //       navVal.add(const BottomNavigationBarItem(
  //           icon: Icon(Icons.summarize_outlined), label: 'Account'));
  //       pages.addAll([
  //         const ReportKitDamage(),
  //         const KitBulkUpdate(),
  //         const AccountStatement()
  //       ]);
  //     } else {
  //       if (menuItem.contains("ACCOUNTS")) {
  //         navVal.add(const BottomNavigationBarItem(
  //             icon: Icon(Icons.person_search_outlined), label: 'Search'));
  //         navVal.add(const BottomNavigationBarItem(
  //             icon: Icon(Icons.person_add_alt_outlined), label: 'Add Patient'));
  //         navVal.add(const BottomNavigationBarItem(
  //             icon: Icon(Icons.functions_outlined), label: 'Protocols'));
  //         navVal.add(const BottomNavigationBarItem(
  //             icon: Icon(Icons.summarize_outlined), label: 'Account'));
  //         pages.addAll([const AccountStatement()]);
  //       } else {
  //         navVal.add(const BottomNavigationBarItem(
  //             icon: Icon(Icons.person_search_outlined), label: 'Search'));
  //         navVal.add(const BottomNavigationBarItem(
  //             icon: Icon(Icons.person_add_alt_outlined), label: 'Add Patient'));
  //         navVal.add(const BottomNavigationBarItem(
  //             icon: Icon(Icons.functions_outlined), label: 'Protocols'));
  //       }
  //     }
  //   } else {
  //     navVal.add(const BottomNavigationBarItem(
  //         icon: Icon(Icons.person_search_outlined), label: 'Search'));
  //     navVal.add(const BottomNavigationBarItem(
  //         icon: Icon(Icons.person_add_alt_outlined), label: 'Add Patient'));
  //     navVal.add(const BottomNavigationBarItem(
  //         icon: Icon(Icons.functions_outlined), label: 'Protocols'));
  //   }
  //   // print(navVal);
  //   // setState(() {});
  //   return navVal;
  // }

  Future<Widget> loadPage(int index) async {
    // Simulate loading content from an API
    // await Future.delayed(Duration(seconds: 2));
    return pages[index];
  }

  openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(
        onDrawerItemTapped: (index) {
          setState(() {
            currentIndex = index;
            widget.routeIndex = index;
            Navigator.pop(context); // Close the drawer after selecting an item
          });
          // onTap(index);
        },
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomAppBar(
        height: 70,
        child: Row(
          // mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => {  
                _scaffoldKey.currentState!.openDrawer()
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(6, 12, 6, 0),
                child: Column(
                  children: [
                    SizedBox(
                        width: 70,
                        height: 30,
                        child: Icon(Icons.menu)
                      ),
                      Text(
                              'Menu',
                              textAlign: TextAlign.center,)
                  ],
                ),
              ),
            ),
            Expanded(
              child: BottomNavigationBar(
                elevation: 0,
                items: [
                    // BottomNavigationBarItem(
                    // icon: Column(
                    //   // mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //       SizedBox(
                    //         width: 40,
                    //         height: 35, 
                    //         child: IconButton(
                    //           onPressed: () => {
                    //             onTap(10)
                    //           },
                    //           icon: const Icon(Icons.science_outlined),
                    //           ),
                    //       ),
                    //   ],
                    // ),
                    // label: 'Set TG',
                    // ),
                    BottomNavigationBarItem(
                    icon: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          SizedBox(
                            width: 40,
                            height: 35, 
                            child: IconButton(
                              onPressed: () => {
                                onTap(0)
                              },
                              icon: const Icon(Icons.person_search_outlined),
                              ),
                          ),
                      ],
                    ),
                    label: 'Search',
                    ),
                    BottomNavigationBarItem(
                    icon: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 35,
                          child: IconButton(
                            onPressed: () => {
                              onTap(1)
                            },
                            icon: const Icon(Icons.person_add_alt_outlined),
                            ),
                        ),
                      ],
                    ),
                    label: 'Add Patient',
                    ),
                     BottomNavigationBarItem(
                    icon: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 35,
                          child: IconButton(
                            onPressed: () => {
                              onTap(2)
                            },
                            icon: const Icon(Icons.list_alt_outlined),
                            ),
                        ),
                      ],
                    ),
                    label: 'Scan List',
                    )
                ],
                currentIndex: currentIndex,
                onTap: onTap,
                type: BottomNavigationBarType.fixed,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final String label;
  final IconData icon;

  NavigationItem(this.label, this.icon);
}
