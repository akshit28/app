import 'package:flutter/material.dart';
import 'package:aap/services/auth_service.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/screens/report_kit_damage.dart';
import 'package:aap/screens/kit_bulk_update.dart';
import 'package:aap/screens/accounts/account.dart';
import 'package:aap/screens/login.dart';
import 'package:aap/screens/system_command.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:aap/screens/command_history.dart';
import 'package:aap/util/confirmDialog.dart';
// import 'package:aap/util/defaulttestGroupDialog.dart';
import 'package:aap/screens/default_test_group.dart';

class SideMenu extends StatefulWidget {
  final Function(int) onDrawerItemTapped;
  const SideMenu({super.key, required this.onDrawerItemTapped});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late List<String> menuItem = [];
  String accountUser = "";
  String organization = "";
  String defaultTestGroup = "";
  bool isKitManagementVisible = false;
  bool isAccountVisible = false;
  String version = "";

  @override
  void initState() {
    super.initState();

    getUserData();
    getMenu();
  }

  Future getMenu() async {
    final service = AuthService();
    final data = await service.fetchMenu();

    if (data.success) {
      List menu = data.data;
      menu.forEach((item) {
        menuItem.add(item.code);
      });

      if (menuItem.contains("KIT")) {
        isKitManagementVisible = true;
      }

      if (menuItem.contains("ACCOUNTS")) {
        isAccountVisible = true;
      }
    }

    setState(() {});
  }

  getUserData() async {
    var sharedIns = SharedPref();
    final userName = await sharedIns.getValueFromSharedPreferences("username");
    final org = await sharedIns.getValueFromSharedPreferences("organization");
    // final defaultTg = await sharedIns.getValueFromSharedPreferences("defaultTestGroupName");

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;

    accountUser = userName.toString();
    organization = org.toString();
    // defaultTestGroup = defaultTg.toString();
    setState(() {});
  }

  showLogoutDialog(BuildContext context) {
    String title = "Logout";
    String content = "Are you sure you want to logout.";
    continueCallBack() =>
        {Navigator.of(context).pop(), logOutUser(context)};

    cancelCallBack() => {
          Navigator.of(context).pop(),
        };
    ConfirmBox alert = ConfirmBox(
        title: title,
        content: content,
        continueCallBack: continueCallBack,
        cancelCallBack: cancelCallBack);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  logOutUser(BuildContext context) async {
    var sharedIns = SharedPref();
    await sharedIns.clearAll();
    if (mounted) {
      Navigator.pop(context);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(accountUser,
                    style: const TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 18,
                      height: 1
                    )),
            accountEmail: Text(organization, style: const TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 16,
                      height: 1
                    )),
            currentAccountPicture: const Center(
                child: CircleAvatar(
                radius: 100.0,
                backgroundImage: AssetImage('assets/images/piiko_logo.png'),
            )),
            decoration: BoxDecoration(color: Colors.blue.shade900),
          ),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text("Set Test Group"),
            onTap: () {
              // setDefaultTestGroup(context);
              Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const DefaultTestGroup()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_outlined),
            title: const Text("Start Scan"),
            onTap: () {
              widget.onDrawerItemTapped(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.integration_instructions_outlined),
            title: const Text("Command Request"),
            onTap: () {
              Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SystemCommand()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_list_outlined),
            title: const Text("Commands List"),
            onTap: () {
              Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const CommandHistory()));
            },
          ),
          isKitManagementVisible
              ? ListTile(
                  leading: const Icon(Icons.build_outlined),
                  title: const Text("Kit Management"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ReportKitDamage()));
                  },
                )
              : const SizedBox.shrink(),
          isKitManagementVisible
              ? ListTile(
                  leading: const Icon(Icons.difference_outlined),
                  title: const Text("Kit Bulk Op"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const KitBulkUpdate()));
                  },
                )
              : const SizedBox.shrink(),
          isAccountVisible
              ? 
              ListTile(
                  leading: const Icon(Icons.summarize_outlined),
                  title: const Text("Accounts"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Account()));
                  },
                )
              : const SizedBox.shrink(),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text("Logout"),
            onTap: () {
              // logOutUser(context);
              showLogoutDialog(context);
            },
          ),
          ListTile(
            subtitle: Center(child: Text("Version: $version")),
          ),
        ],
      ),
    );
  }
}
