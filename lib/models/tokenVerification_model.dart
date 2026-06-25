// To parse this JSON data, do
//
//     final tokenVerificationModel = tokenVerificationModelFromJson(jsonString);

import 'dart:convert';

TokenVerificationModel tokenVerificationModelFromJson(String str) => TokenVerificationModel.fromJson(json.decode(str));

String tokenVerificationModelToJson(TokenVerificationModel data) => json.encode(data.toJson());

class TokenVerificationModel {
    Data data;
    dynamic error;
    bool success;

    TokenVerificationModel({
        required this.data,
        required this.error,
        required this.success,
    });

    factory TokenVerificationModel.fromJson(Map<String, dynamic> json) => TokenVerificationModel(
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
    List<Organization> organizations;
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
        organizations: List<Organization>.from(json["organizations"].map((x) => Organization.fromJson(x))),
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
    List<BatchType> batchTypes;
    dynamic defaultTestGroup;

    Facility({
        required this.id,
        required this.name,
        required this.code,
        required this.batchTypes,
        required this.defaultTestGroup
    });

    factory Facility.fromJson(Map<String, dynamic> json) => Facility(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        batchTypes: List<BatchType>.from(json["batch_types"].map((x) => BatchType.fromJson(x))),
        defaultTestGroup: json["default_test_group"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "batch_types": List<dynamic>.from(batchTypes.map((x) => x.toJson())),
        "default_test_group": defaultTestGroup,
    };
}

class BatchType {
    String code;
    String name;
    String description;
    String status;
    String createdAt;
    String updatedAt;
    dynamic createdBy;
    dynamic updatedBy;

    BatchType({
        required this.code,
        required this.name,
        required this.description,
        required this.status,
        required this.createdAt,
        required this.updatedAt,
        required this.createdBy,
        required this.updatedBy,
    });

    factory BatchType.fromJson(Map<String, dynamic> json) => BatchType(
        code: json["code"],
        name: json["name"],
        description: json["description"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "description": description,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
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

class Organization {
    String id;
    String name;
    String code;
    String referralCode;

    Organization({
        required this.id,
        required this.name,
        required this.code,
        required this.referralCode,
    });

    factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        referralCode: json["referral_code"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "referral_code": referralCode,
    };
}
