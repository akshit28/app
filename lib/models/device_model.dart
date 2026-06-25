// To parse this JSON data, do
//
//     final deviceModel = deviceModelFromJson(jsonString);

import 'dart:convert';

DeviceModel deviceModelFromJson(String str) => DeviceModel.fromJson(json.decode(str));

String deviceModelToJson(DeviceModel data) => json.encode(data.toJson());

class DeviceModel {
    Data data;
    dynamic error;
    bool success;

    DeviceModel({
        required this.data,
        this.error,
        required this.success,
    });

    factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
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
    List<Device> devices;
    List<MasterDevice> masterDevices;

    Data({
        required this.devices,
        required this.masterDevices,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        devices: List<Device>.from(json["devices"].map((x) => Device.fromJson(x))),
        masterDevices: List<MasterDevice>.from(json["master_devices"].map((x) => MasterDevice.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "devices": List<dynamic>.from(devices.map((x) => x.toJson())),
        "master_devices": List<dynamic>.from(masterDevices.map((x) => x.toJson())),
    };
}

class Device {
    String deviceId;
    String deviceName;
    String isOnline;
    String facilityId;
    String status;
    String masterDeviceId;

    Device({
        required this.deviceId,
        required this.deviceName,
        required this.isOnline,
        required this.facilityId,
        required this.status,
        required this.masterDeviceId,
    });

    factory Device.fromJson(Map<String, dynamic> json) => Device(
        deviceId: json["device_id"],
        deviceName: json["device_name"],
        isOnline: json["is_online"],
        facilityId: json["facility_id"],
        status: json["status"],
        masterDeviceId: json["master_device_id"],
    );

    Map<String, dynamic> toJson() => {
        "device_id": deviceId,
        "device_name": deviceName,
        "is_online": isOnline,
        "facility_id": facilityId,
        "status": status,
        "master_device_id": masterDeviceId,
    };
}

class MasterDevice {
    String masterDeviceId;
    String deviceModel;
    String deviceName;

    MasterDevice({
        required this.masterDeviceId,
        required this.deviceModel,
        required this.deviceName,
    });

    factory MasterDevice.fromJson(Map<String, dynamic> json) => MasterDevice(
        masterDeviceId: json["master_device_id"],
        deviceModel: json["device_model"],
        deviceName: json["device_name"],
    );

    Map<String, dynamic> toJson() => {
        "master_device_id": masterDeviceId,
        "device_model": deviceModel,
        "device_name": deviceName,
    };
}
