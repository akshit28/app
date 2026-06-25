// To parse this JSON data, do
//
//     final menuItems = menuItemsFromJson(jsonString);

import 'dart:convert';

MenuItems menuItemsFromJson(String str) => MenuItems.fromJson(json.decode(str));

String menuItemsToJson(MenuItems data) => json.encode(data.toJson());

class MenuItems {
    bool success;
    List<Datum> data;

    MenuItems({
        required this.success,
        required this.data,
    });

    factory MenuItems.fromJson(Map<String, dynamic> json) => MenuItems(
        success: json["success"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    int createdBy;
    int updatedBy;
    String menu;
    String code;
    String name;
    String url;
    dynamic icon;
    String description;
    String status;
    List<dynamic> permissions;

    Datum({
        required this.createdBy,
        required this.updatedBy,
        required this.menu,
        required this.code,
        required this.name,
        required this.url,
        required this.icon,
        required this.description,
        required this.status,
        required this.permissions,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        menu: json["menu"],
        code: json["code"],
        name: json["name"],
        url: json["url"],
        icon: json["icon"],
        description: json["description"],
        status: json["status"],
        permissions: List<dynamic>.from(json["permissions"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "created_by": createdBy,
        "updated_by": updatedBy,
        "menu": menu,
        "code": code,
        "name": name,
        "url": url,
        "icon": icon,
        "description": description,
        "status": status,
        "permissions": List<dynamic>.from(permissions.map((x) => x)),
    };
}
