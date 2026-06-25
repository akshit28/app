// To parse this JSON data, do
//
//     final scanPayload = scanPayloadFromJson(jsonString);

import 'dart:convert';

ScanPayload scanPayloadFromJson(String str) => ScanPayload.fromJson(json.decode(str));

String scanPayloadToJson(ScanPayload data) => json.encode(data.toJson());

class ScanPayload {
    String facilityId;
    String deviceCode;
    String testGroupId;
    String externalPatientCode;
    String externalSampleCode;
    String patientId;
    String kitCode;
    String batchType;
    String testChamberNumber;

    ScanPayload({
        required this.facilityId,
        required this.deviceCode,
        required this.testGroupId,
        required this.externalPatientCode,
        required this.externalSampleCode,
        required this.patientId,
        required this.kitCode,
        required this.batchType,
        required this.testChamberNumber,
    });

    factory ScanPayload.fromJson(Map<String, dynamic> json) => ScanPayload(
        facilityId: json["facility_id"],
        deviceCode: json["device_code"],
        testGroupId: json["test_group_id"],
        externalPatientCode: json["external_patient_code"],
        externalSampleCode: json["external_sample_code"],
        patientId: json["patient_id"],
        kitCode: json["kit_code"],
        batchType: json["batch_type"],
        testChamberNumber: json["test_chamber_number"],
    );

    Map<String, dynamic> toJson() => {
        "facility_id": facilityId,
        "device_code": deviceCode,
        "test_group_id": testGroupId,
        "external_patient_code": externalPatientCode,
        "external_sample_code": externalSampleCode,
        "patient_id": patientId,
        "kit_code": kitCode,
        "batch_type": batchType,
        "test_chamber_number": testChamberNumber,
    };
}
