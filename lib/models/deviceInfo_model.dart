// To parse this JSON data, do
//
//     final deviceInfo = deviceInfoFromJson(jsonString);

import 'dart:convert';

DeviceInfo deviceInfoFromJson(String str) => DeviceInfo.fromJson(json.decode(str));

String deviceInfoToJson(DeviceInfo data) => json.encode(data.toJson());

class DeviceInfo {
    String origin;
    String clientType;
    String version;
    String environment;

    DeviceInfo({
        required this.origin,
        required this.clientType,
        required this.version,
        required this.environment,
    });

    factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
        origin: json["origin"],
        clientType: json["client_type"],
        version: json["version"],
        environment: json["environment"],
    );

    Map<String, dynamic> toJson() => {
        "origin": origin,
        "client_type": clientType,
        "version": version,
        "environment": environment,
    };
}
