// To parse this JSON data, do
//
//     final scanModel = scanModelFromJson(jsonString);

import 'dart:convert';

ScanModel scanModelFromJson(String str) => ScanModel.fromJson(json.decode(str));

String scanModelToJson(ScanModel data) => json.encode(data.toJson());

class ScanModel {
    Data data;
    dynamic error;
    bool success;

    ScanModel({
        required this.data,
        this.error,
        required this.success,
    });

    factory ScanModel.fromJson(Map<String, dynamic> json) => ScanModel(
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
    int rowCount;
    List<Row> rows;

    Data({
        required this.rowCount,
        required this.rows,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        rowCount: json["row_count"],
        rows: List<Row>.from(json["rows"].map((x) => Row.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "row_count": rowCount,
        "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
    };
}

class Row {
    String externalPatientId;
    String patientId;
    String name;
    DateTime dateOfBirth;
    String gender;
    String email;
    String mobile;
    String isSmsEnabled;

    Row({
        required this.externalPatientId,
        required this.patientId,
        required this.name,
        required this.dateOfBirth,
        required this.gender,
        required this.email,
        required this.mobile,
        required this.isSmsEnabled,
    });

    factory Row.fromJson(Map<String, dynamic> json) => Row(
        externalPatientId: json["external_patient_id"],
        patientId: json["patient_id"],
        name: json["name"],
        dateOfBirth: DateTime.parse(json["date_of_birth"]),
        gender: json["gender"],
        email: json["email"],
        mobile: json["mobile"],
        isSmsEnabled: json["is_sms_enabled"],
    );

    Map<String, dynamic> toJson() => {
        "external_patient_id": externalPatientId,
        "patient_id": patientId,
        "name": name,
        "date_of_birth": "${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}",
        "gender": gender,
        "email": email,
        "mobile": mobile,
        "is_sms_enabled": isSmsEnabled,
    };
}
