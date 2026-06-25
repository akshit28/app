// To parse this JSON data, do
//
//     final commandHistoryModal = commandHistoryModalFromJson(jsonString);

import 'dart:convert';

CommandHistoryModal commandHistoryModalFromJson(String str) => CommandHistoryModal.fromJson(json.decode(str));

String commandHistoryModalToJson(CommandHistoryModal data) => json.encode(data.toJson());

class CommandHistoryModal {
    Data data;
    dynamic error;
    bool success;

    CommandHistoryModal({
        required this.data,
        required this.error,
        required this.success,
    });

    factory CommandHistoryModal.fromJson(Map<String, dynamic> json) => CommandHistoryModal(
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
    String deviceCommandId;
    String requestedBy;
    String requestedOn;
    String updatedOn;
    String deviceCommandName;
    String status;
    String payLoad;
    String? response;
    String deviceName;
    bool isCancelledAllowed;

    Row({
        required this.deviceCommandId,
        required this.requestedBy,
        required this.requestedOn,
        required this.updatedOn,
        required this.deviceCommandName,
        required this.status,
        required this.payLoad,
        required this.response,
        required this.deviceName,
        required this.isCancelledAllowed,
    });

    factory Row.fromJson(Map<String, dynamic> json) => Row(
        deviceCommandId: json["device_command_id"],
        requestedBy: json["requested_by"],
        requestedOn: json["requested_on"],
        updatedOn: json["updated_on"],
        deviceCommandName: json["device_command_name"],
        status: json["status"],
        payLoad: json["pay_load"],
        response: json["response"],
        deviceName: json["device_name"],
        isCancelledAllowed: json["is_cancelled_allowed"],
    );

    Map<String, dynamic> toJson() => {
        "device_command_id": deviceCommandId,
        "requested_by": requestedBy,
        "requested_on": requestedOn,
        "updated_on": updatedOn,
        "device_command_name": deviceCommandName,
        "status": status,
        "pay_load": payLoad,
        "response": response,
        "device_name": deviceName,
        "is_cancelled_allowed": isCancelledAllowed,
    };
}
