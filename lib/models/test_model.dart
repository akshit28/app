// To parse this JSON data, do
//
//     final testModel = testModelFromJson(jsonString);

import 'dart:convert';

TestModel testModelFromJson(String str) => TestModel.fromJson(json.decode(str));

String testModelToJson(TestModel data) => json.encode(data.toJson());

class TestModel {
    Data data;
    dynamic error;
    bool success;

    TestModel({
        required this.data,
        this.error,
        required this.success,
    });

    factory TestModel.fromJson(Map<String, dynamic> json) => TestModel(
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
    List<TestGroup> testGroups;

    Data({
        required this.testGroups,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        testGroups: List<TestGroup>.from(json["test-groups"].map((x) => TestGroup.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "test-groups": List<dynamic>.from(testGroups.map((x) => x.toJson())),
    };
}

class TestGroup {
    String testGroupId;
    String testGroupName;
    String testGroupCode;

    TestGroup({
        required this.testGroupId,
        required this.testGroupName,
        required this.testGroupCode,
    });

    factory TestGroup.fromJson(Map<String, dynamic> json) => TestGroup(
        testGroupId: json["test_group_id"],
        testGroupName: json["test_group_name"],
        testGroupCode: json["test_group_code"],
    );

    Map<String, dynamic> toJson() => {
        "test_group_id": testGroupId,
        "test_group_name": testGroupName,
        "test_group_code": testGroupCode,
    };
}
