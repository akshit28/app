// To parse this JSON data, do
//
//     final facilityModel = facilityModelFromJson(jsonString);

import 'dart:convert';

FacilityModel facilityModelFromJson(String str) => FacilityModel.fromJson(json.decode(str));

String facilityModelToJson(FacilityModel data) => json.encode(data.toJson());

class FacilityModel {
    Data data;
    dynamic error;
    bool success;

    FacilityModel({
        required this.data,
        this.error,
        required this.success,
    });

    factory FacilityModel.fromJson(Map<String, dynamic> json) => FacilityModel(
        data: Data.fromJson(json["data"]),
        error: json["error"],
        success: json["success"],
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "error": error,
        "success": success,
    };
}

class Data {
    int userId;
    List<Facility> organizations;
    List<Facility> facilities;
    String username;
    MasterData masterData;

    Data({
        required this.userId,
        required this.organizations,
        required this.facilities,
        required this.username,
        required this.masterData,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["user_id"],
        organizations: List<Facility>.from(json["organizations"].map((x) => Facility.fromJson(x))),
        facilities: List<Facility>.from(json["facilities"].map((x) => Facility.fromJson(x))),
        username: json["username"],
        masterData: MasterData.fromJson(json["master_data"]),
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "organizations": List<dynamic>.from(organizations.map((x) => x.toJson())),
        "facilities": List<dynamic>.from(facilities.map((x) => x.toJson())),
        "username": username,
        "master_data": masterData.toJson(),
    };
}

class Facility {
    String id;
    String name;
    String code;
    List<BatchType>? batchTypes;
    String? referralCode;

    Facility({
        required this.id,
        required this.name,
        required this.code,
        this.batchTypes,
        this.referralCode,
    });

    factory Facility.fromJson(Map<String, dynamic> json) => Facility(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        batchTypes: json["batch_types"] == null ? [] : List<BatchType>.from(json["batch_types"]!.map((x) => BatchType.fromJson(x))),
        referralCode: json["referral_code"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "batch_types": batchTypes == null ? [] : List<dynamic>.from(batchTypes!.map((x) => x.toJson())),
        "referral_code": referralCode,
    };
}

class BatchType {
    String code;
    String name;
    String description;
    String status;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic createdBy;
    dynamic updatedBy;

    BatchType({
        required this.code,
        required this.name,
        required this.description,
        required this.status,
        required this.createdAt,
        required this.updatedAt,
        this.createdBy,
        this.updatedBy,
    });

    factory BatchType.fromJson(Map<String, dynamic> json) => BatchType(
        code: json["code"],
        name: json["name"],
        description: json["description"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "description": description,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "created_by": createdBy,
        "updated_by": updatedBy,
    };
}

class MasterData {
    String defaultStartDate;
    String defaultEndDate;

    MasterData({
        required this.defaultStartDate,
        required this.defaultEndDate,
    });

    factory MasterData.fromJson(Map<String, dynamic> json) => MasterData(
        defaultStartDate: json["default_start_date"],
        defaultEndDate: json["default_end_date"],
    );

    Map<String, dynamic> toJson() => {
        "default_start_date": defaultStartDate,
        "default_end_date": defaultEndDate,
    };
}
