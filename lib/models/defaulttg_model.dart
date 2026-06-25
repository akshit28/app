import 'dart:convert';

class DefaultTG {
  String tgName;
  String tgId;
  String deviceName;
  String facilityId;

  DefaultTG({required this.tgName, required this.tgId, required this.deviceName, required this.facilityId});

  Map<String, dynamic> toJson() {
    return {
      'tgName': tgName,
      'tgId': tgId,
      'deviceName': deviceName,
      'facilityId': facilityId
    };
  }

  factory DefaultTG.fromJson(Map<String, dynamic> json) {
    return DefaultTG(
      tgName: json['tgName'],
      tgId: json['tgId'],
      deviceName: json['deviceName'],
      facilityId: json['facilityId']
    );
  }
}
