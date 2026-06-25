// To parse this JSON data, do
//
//     final kitStatus = kitStatusFromJson(jsonString);

import 'dart:convert';

KitStatus kitStatusFromJson(String str) => KitStatus.fromJson(json.decode(str));

String kitStatusToJson(KitStatus data) => json.encode(data.toJson());

class KitStatus {
    bool success;
    List<Datum> data;

    KitStatus({
        required this.success,
        required this.data,
    });

    factory KitStatus.fromJson(Map<String, dynamic> json) => KitStatus(
        success: json["success"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String id;
    String createdAt;
    String updatedAt;
    String code;
    String name;
    String type;
    String description;
    String status;
    int createdBy;
    int updatedBy;
    List<int> groups;

    Datum({
        required this.id,
        required this.createdAt,
        required this.updatedAt,
        required this.code,
        required this.name,
        required this.type,
        required this.description,
        required this.status,
        required this.createdBy,
        required this.updatedBy,
        required this.groups,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        code: json["code"],
        name: json["name"],
        type: json["type"],
        description: json["description"],
        status: json["status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        groups: List<int>.from(json["groups"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "code": code,
        "name": name,
        "type": type,
        "description": description,
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "groups": List<dynamic>.from(groups.map((x) => x)),
    };
}
