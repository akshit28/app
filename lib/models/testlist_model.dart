// To parse this JSON data, do
//
//     final testListModel = testListModelFromJson(jsonString);

import 'dart:convert';

TestListModel testListModelFromJson(String str) => TestListModel.fromJson(json.decode(str));

String testListModelToJson(TestListModel data) => json.encode(data.toJson());

class TestListModel {
    Data data;
    dynamic error;
    bool success;

    TestListModel({
        required this.data,
        this.error,
        required this.success,
    });

    factory TestListModel.fromJson(Map<String, dynamic> json) => TestListModel(
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
    List<Test> tests;
    List<Protocol> protocols;

    Data({
        required this.tests,
        required this.protocols,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        tests: List<Test>.from(json["tests"].map((x) => Test.fromJson(x))),
        protocols: List<Protocol>.from(json["protocols"].map((x) => Protocol.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "tests": List<dynamic>.from(tests.map((x) => x.toJson())),
        "protocols": List<dynamic>.from(protocols.map((x) => x.toJson())),
    };
}

class Protocol {
    String protocolId;
    String protocolCode;
    String protocolName;
    bool isMicroscopy;
    bool isColorimeter;
    dynamic chamberNumber;

    Protocol({
        required this.protocolId,
        required this.protocolCode,
        required this.protocolName,
        required this.isMicroscopy,
        required this.isColorimeter,
        required this.chamberNumber,
    });

    factory Protocol.fromJson(Map<String, dynamic> json) => Protocol(
        protocolId: json["protocol_id"],
        protocolCode: json["protocol_code"],
        protocolName: json["protocol_name"],
        isMicroscopy: json["is_microscopy"],
        isColorimeter: json["is_colorimeter"],
        chamberNumber: json["chamber_number"],
    );

    Map<String, dynamic> toJson() => {
        "protocol_id": protocolId,
        "protocol_code": protocolCode,
        "protocol_name": protocolName,
        "is_microscopy": isMicroscopy,
        "is_colorimeter": isColorimeter,
        "chamber_number": chamberNumber,
    };
}

class Test {
    String testId;
    String testName;
    String testGroupId;
    String testGroupCode;
    String testGroupName;

    Test({
        required this.testId,
        required this.testName,
        required this.testGroupId,
        required this.testGroupCode,
        required this.testGroupName,
    });

    factory Test.fromJson(Map<String, dynamic> json) => Test(
        testId: json["test_id"],
        testName: json["test_name"],
        testGroupId: json["test_group_id"],
        testGroupCode: json["test_group_code"],
        testGroupName: json["test_group_name"],
    );

    Map<String, dynamic> toJson() => {
        "test_id": testId,
        "test_name": testName,
        "test_group_id": testGroupId,
        "test_group_code": testGroupCode,
        "test_group_name": testGroupName,
    };
}
