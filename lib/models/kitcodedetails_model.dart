// To parse this JSON data, do
//
//     final kitCodeDetailsModel = kitCodeDetailsModelFromJson(jsonString);

import 'dart:convert';

KitCodeDetailsModel kitCodeDetailsModelFromJson(String str) => KitCodeDetailsModel.fromJson(json.decode(str));

String kitCodeDetailsModelToJson(KitCodeDetailsModel data) => json.encode(data.toJson());

class KitCodeDetailsModel {
    bool success;
    Data data;

    KitCodeDetailsModel({
        required this.success,
        required this.data,
    });

    factory KitCodeDetailsModel.fromJson(Map<String, dynamic> json) => KitCodeDetailsModel(
        success: json["success"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
    };
}

class Data {
    Rows rows;

    Data({
        required this.rows,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        rows: Rows.fromJson(json["rows"]),
    );

    Map<String, dynamic> toJson() => {
        "rows": rows.toJson(),
    };
}

class Rows {
    String kitId;
    String kitCode;
    dynamic kitExpiryDate;
    String kitCreatedAt;
    String kitStatus;
    String kitMasterId;
    String kitMasterCode;
    String kitMasterName;
    List<dynamic> facilities;
    List<dynamic> devices;
    List<dynamic> testGroups;

    Rows({
        required this.kitId,
        required this.kitCode,
        required this.kitExpiryDate,
        required this.kitCreatedAt,
        required this.kitStatus,
        required this.kitMasterId,
        required this.kitMasterCode,
        required this.kitMasterName,
        required this.facilities,
        required this.devices,
        required this.testGroups,
    });

    factory Rows.fromJson(Map<String, dynamic> json) => Rows(
        kitId: json["kit_id"],
        kitCode: json["kit_code"],
        kitExpiryDate: json["kit_expiry_date"],
        kitCreatedAt: json["kit_created_at"],
        kitStatus: json["kit_status"],
        kitMasterId: json["kit_master_id"],
        kitMasterCode: json["kit_master_code"],
        kitMasterName: json["kit_master_name"],
        facilities: List<dynamic>.from(json["facilities"].map((x) => x)),
        devices: List<dynamic>.from(json["devices"].map((x) => x)),
        testGroups: List<dynamic>.from(json["test_groups"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "kit_id": kitId,
        "kit_code": kitCode,
        "kit_expiry_date": kitExpiryDate,
        "kit_created_at": kitCreatedAt,
        "kit_status": kitStatus,
        "kit_master_id": kitMasterId,
        "kit_master_code": kitMasterCode,
        "kit_master_name": kitMasterName,
        "facilities": List<dynamic>.from(facilities.map((x) => x)),
        "devices": List<dynamic>.from(devices.map((x) => x)),
        "test_groups": List<dynamic>.from(testGroups.map((x) => x)),
    };
}
