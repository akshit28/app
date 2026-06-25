// To parse this JSON data, do
//
//     final scanQueueModel = scanQueueModelFromJson(jsonString);

import 'dart:convert';

ScanQueueModel scanQueueModelFromJson(String str) => ScanQueueModel.fromJson(json.decode(str));

String scanQueueModelToJson(ScanQueueModel data) => json.encode(data.toJson());

class ScanQueueModel {
    List<Datum> data;
    dynamic error;
    bool success;

    ScanQueueModel({
        required this.data,
        this.error,
        required this.success,
    });

    factory ScanQueueModel.fromJson(Map<String, dynamic> json) => ScanQueueModel(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        error: json["error"],
        success: json["success"],
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "error": error,
        "success": success,
    };
}

class Datum {
    String requestId;
    String protocolName;
    String protocolCode;
    String protocolId;
    int chamberNumber;
    String requestType;
    String patientCode;
    String sampleCode;
    String extraParams;

    Datum({
        required this.requestId,
        required this.protocolName,
        required this.protocolCode,
        required this.protocolId,
        required this.chamberNumber,
        required this.requestType,
        required this.patientCode,
        required this.sampleCode,
        required this.extraParams,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        requestId: json["request_id"],
        protocolName: json["protocol_name"],
        protocolCode: json["protocol_code"],
        protocolId: json["protocol_id"],
        chamberNumber: json["chamber_number"],
        requestType: json["request_type"],
        patientCode: json["patient_code"],
        sampleCode: json["sample_code"],
        extraParams: json["extra_params"],
    );

    Map<String, dynamic> toJson() => {
        "request_id": requestId,
        "protocol_name": protocolName,
        "protocol_code": protocolCode,
        "protocol_id": protocolId,
        "chamber_number": chamberNumber,
        "request_type": requestType,
        "patient_code": patientCode,
        "sample_code": sampleCode,
        "extra_params": extraParams,
    };
}
