// To parse this JSON data, do
//
//     final errorModel = errorModelFromJson(jsonString);

import 'dart:convert';

ErrorModel errorModelFromJson(String str) => ErrorModel.fromJson(json.decode(str));

String errorModelToJson(ErrorModel data) => json.encode(data.toJson());

class ErrorModel {
    dynamic data;
    dynamic error;
    bool success;

    ErrorModel({
        this.data,
        required this.error,
        required this.success,
    });

    factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
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
