// To parse this JSON data, do
//
//     final commandModel = commandModelFromJson(jsonString);

import 'dart:convert';

CommandModel commandModelFromJson(String str) => CommandModel.fromJson(json.decode(str));

String commandModelToJson(CommandModel data) => json.encode(data.toJson());

class CommandModel {
    Data data;
    dynamic error;
    bool success;

    CommandModel({
        required this.data,
        required this.error,
        required this.success,
    });

    factory CommandModel.fromJson(Map<String, dynamic> json) => CommandModel(
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
    List<DeviceCommand> deviceCommands;

    Data({
        required this.deviceCommands,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        deviceCommands: List<DeviceCommand>.from(json["device-commands"].map((x) => DeviceCommand.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "device-commands": List<dynamic>.from(deviceCommands.map((x) => x.toJson())),
    };
}

class DeviceCommand {
    String deviceCommandId;
    String deviceCommandName;
    String deviceCommandCode;
    String deviceCommandPayload;

    DeviceCommand({
        required this.deviceCommandId,
        required this.deviceCommandName,
        required this.deviceCommandCode,
        required this.deviceCommandPayload,
    });

    factory DeviceCommand.fromJson(Map<String, dynamic> json) => DeviceCommand(
        deviceCommandId: json["device_command_id"],
        deviceCommandName: json["device_command_name"],
        deviceCommandCode: json["device_command_code"],
        deviceCommandPayload: json["device_command_payload"],
    );

    Map<String, dynamic> toJson() => {
        "device_command_id": deviceCommandId,
        "device_command_name": deviceCommandName,
        "device_command_code": deviceCommandCode,
        "device_command_payload": deviceCommandPayload,
    };
}
