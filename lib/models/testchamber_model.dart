// To parse this JSON data, do
//
//     final testChamber = testChamberFromJson(jsonString);

import 'dart:convert';

List<TestChamber> testChamberFromJson(String str) => List<TestChamber>.from(json.decode(str).map((x) => TestChamber.fromJson(x)));

String testChamberToJson(List<TestChamber> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TestChamber {
    String protocolId;
    String chamberNumber;

    TestChamber({
        required this.protocolId,
        required this.chamberNumber,
    });

    factory TestChamber.fromJson(Map<String, dynamic> json) => TestChamber(
        protocolId: json["protocol_id"],
        chamberNumber: json["chamber_number"],
    );

    Map<String, dynamic> toJson() => {
        "protocol_id": protocolId,
        "chamber_number": chamberNumber,
    };
}
