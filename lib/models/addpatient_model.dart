// To parse this JSON data, do
//
//     final addPatientModel = addPatientModelFromJson(jsonString);

import 'dart:convert';

AddPatientModel addPatientModelFromJson(String str) => AddPatientModel.fromJson(json.decode(str));

String addPatientModelToJson(AddPatientModel data) => json.encode(data.toJson());

class AddPatientModel {
    String data;
    dynamic error;
    bool success;

    AddPatientModel({
        required this.data,
        this.error,
        required this.success,
    });

    factory AddPatientModel.fromJson(Map<String, dynamic> json) => AddPatientModel(
        data: json["data"],
        error: json["error"],
        success: json["success"],
    );

    Map<String, dynamic> toJson() => {
        "data": data,
        "error": error,
        "success": success,
    };
}
