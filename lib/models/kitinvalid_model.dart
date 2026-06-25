// To parse this JSON data, do
//
//     final kitInvalidModel = kitInvalidModelFromJson(jsonString);

import 'dart:convert';

KitInvalidModel kitInvalidModelFromJson(String str) => KitInvalidModel.fromJson(json.decode(str));

String kitInvalidModelToJson(KitInvalidModel data) => json.encode(data.toJson());

class KitInvalidModel {
    bool success;
    List<Datum> data;

    KitInvalidModel({
        required this.success,
        required this.data,
    });

    factory KitInvalidModel.fromJson(Map<String, dynamic> json) => KitInvalidModel(
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
    bool isProtocolNeeded;
    String status;
    int createdBy;
    int updatedBy;

    Datum({
        required this.id,
        required this.createdAt,
        required this.updatedAt,
        required this.code,
        required this.name,
        required this.type,
        required this.description,
        required this.isProtocolNeeded,
        required this.status,
        required this.createdBy,
        required this.updatedBy,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        code: json["code"],
        name: json["name"],
        type: json["type"],
        description: json["description"],
        isProtocolNeeded: json["is_protocol_needed"],
        status: json["status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "code": code,
        "name": name,
        "type": type,
        "description": description,
        "is_protocol_needed": isProtocolNeeded,
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
    };
}
