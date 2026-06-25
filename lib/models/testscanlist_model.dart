// To parse this JSON data, do
//
//     final testScanList = testScanListFromJson(jsonString);

import 'dart:convert';

TestScanList testScanListFromJson(String str) => TestScanList.fromJson(json.decode(str));

String testScanListToJson(TestScanList data) => json.encode(data.toJson());

class TestScanList {
    Data data;
    dynamic error;
    bool success;

    TestScanList({
        required this.data,
        this.error,
        required this.success,
    });

    factory TestScanList.fromJson(Map<String, dynamic> json) => TestScanList(
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
    String? reportLink;
    dynamic consolidatedReportLink;
    String externalSampleId;
    String internalSampleId;
    String sampleStatus;
    String sampleStatusCode;
    String sampleId;
    String? kitCode;
    String testGroup;
    String testGroupCode;
    String key;
    String deviceName;
    String? requestedBy;
    String? patientId;
    String? patientName;
    String sampleRequestedAt;
    String sampleUpdatedAt;
    List<Child> childs;
    List<dynamic> action;
    dynamic message;
    bool inSleep;
    int waitingPeriod;
    int sleepStarted;
    List<dynamic> instructions;
    String? nextStepName;
    String? nextVesselCode;
    String? nextStepCode;
    String? nextStepNumber;
    String deviceStatus;
    bool isAudible;
    bool showTimer;

    Row({
        required this.reportLink,
        required this.consolidatedReportLink,
        required this.externalSampleId,
        required this.internalSampleId,
        required this.sampleStatus,
        required this.sampleStatusCode,
        required this.sampleId,
        required this.kitCode,
        required this.testGroup,
        required this.testGroupCode,
        required this.key,
        required this.deviceName,
        required this.requestedBy,
        required this.patientId,
        required this.patientName,
        required this.sampleRequestedAt,
        required this.sampleUpdatedAt,
        required this.childs,
        required this.action,
        this.message,
        required this.inSleep,
        required this.waitingPeriod,
        required this.sleepStarted,
        required this.instructions,
        required this.nextStepName,
        required this.nextVesselCode,
        this.nextStepCode,
        required this.nextStepNumber,
        required this.deviceStatus,
        required this.isAudible,
        required this.showTimer,
    });

    factory Row.fromJson(Map<String, dynamic> json) => Row(
        reportLink: json["report_link"],
        consolidatedReportLink: json["consolidated_report_link"],
        externalSampleId: json["external_sample_id"],
        internalSampleId: json["internal_sample_id"],
        sampleStatus: json["sample_status"],
        sampleStatusCode: json["sample_status_code"],
        sampleId: json["sample_id"],
        kitCode: json["kit_code"],
        testGroup: json["test_group"],
        testGroupCode: json["test_group_code"],
        key: json["key"],
        deviceName: json["device_name"],
        requestedBy: json["requested_by"],
        patientId: json["patient_id"],
        patientName: json["patient_name"],
        sampleRequestedAt: json["sample_requested_at"],
        sampleUpdatedAt: json["sample_updated_at"],
        childs: List<Child>.from(json["childs"].map((x) => Child.fromJson(x))),
        action: List<dynamic>.from(json["action"].map((x) => x)),
        message: json["message"],
        inSleep: json["in_sleep"],
        waitingPeriod: json["waiting_period"],
        sleepStarted: json["sleep_started"],
        instructions: List<dynamic>.from(json["instructions"].map((x) => x)),
        nextStepName: json["next_step_name"],
        nextVesselCode: json["next_vessel_code"],
        nextStepCode: json["next_step_code"],
        nextStepNumber: json["next_step_number"],
        deviceStatus: json["device_status"],
        isAudible: json["is_audible"],
        showTimer: json["show_timer"],
    );

    Map<String, dynamic> toJson() => {
        "report_link": reportLink,
        "consolidated_report_link": consolidatedReportLink,
        "external_sample_id": externalSampleId,
        "internal_sample_id": internalSampleId,
        "sample_status": sampleStatus,
        "sample_status_code": sampleStatusCode,
        "sample_id": sampleId,
        "kit_code": kitCode,
        "test_group": testGroup,
        "test_group_code": testGroupCode,
        "key": key,
        "device_name": deviceName,
        "requested_by": requestedBy,
        "patient_id": patientId,
        "patient_name": patientName,
        "sample_requested_at": sampleRequestedAt,
        "sample_updated_at": sampleUpdatedAt,
        "childs": List<dynamic>.from(childs.map((x) => x.toJson())),
        "action": List<dynamic>.from(action.map((x) => x)),
        "message": message,
        "in_sleep": inSleep,
        "waiting_period": waitingPeriod,
        "sleep_started": sleepStarted,
        "instructions": List<dynamic>.from(instructions.map((x) => x)),
        "next_step_name": nextStepName,
        "next_vessel_code": nextVesselCode,
        "next_step_code": nextStepCode,
        "next_step_number": nextStepNumber,
        "device_status": deviceStatus,
        "is_audible": isAudible,
        "show_timer": showTimer
    };
}

class Child {
    String? sampleProtocolId;
    String? key;
    int? chamberNumber;
    String updatedOn;
    String statusRaw;
    String? status;
    String protocolName;
    String protocolCode;
    String protocolId;
    String? error;
    String? statusCode;
    String? statusName;
    double? currentStepNumber;
    Metadata? metadata;
    String? vesselNumber;
    List<dynamic> action;

    Child({
        required this.sampleProtocolId,
        required this.key,
        required this.chamberNumber,
        required this.updatedOn,
        required this.statusRaw,
        required this.status,
        required this.protocolName,
        required this.protocolCode,
        required this.protocolId,
        this.error,
        this.statusCode,
        this.statusName,
        this.currentStepNumber,
        this.metadata,
        required this.vesselNumber,
        required this.action,
    });

    factory Child.fromJson(Map<String, dynamic> json) => Child(
        sampleProtocolId: json["sample_protocol_id"],
        key: json["key"],
        chamberNumber: json["chamber_number"],
        updatedOn: json["updated_on"],
        statusRaw: json["status_raw"],
        status: json["status"],
        protocolName: json["protocol_name"],
        protocolCode: json["protocol_code"],
        protocolId: json["protocol_id"],
        error: json["error"],
        statusCode: json["status_code"],
        statusName: json["status_name"],
        currentStepNumber: json["current_step_number"]?.toDouble(),
        metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
        vesselNumber: json["vessel_number"],
        action: List<dynamic>.from(json["action"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "sample_protocol_id": sampleProtocolId,
        "key": key,
        "chamber_number": chamberNumber,
        "updated_on": updatedOn,
        "status_raw": statusRaw,
        "status": status,
        "protocol_name": protocolName,
        "protocol_code": protocolCode,
        "protocol_id": protocolId,
        "error": error,
        "status_code": statusCode,
        "status_name": statusName,
        "current_step_number": currentStepNumber,
        "metadata": metadata?.toJson(),
        "vessel_number": vesselNumber,
        "action": List<dynamic>.from(action.map((x) => x)),
    };
}

class Metadata {
    double? stepExecutionStartedAt;

    Metadata({
        required this.stepExecutionStartedAt,
    });

    factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        stepExecutionStartedAt: json["step_execution_started_at"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "step_execution_started_at": stepExecutionStartedAt,
    };
}
