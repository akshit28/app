// To parse this JSON data, do
//
//     final commandQueueModal = commandQueueModalFromJson(jsonString);

import 'dart:convert';

CommandQueueModal commandQueueModalFromJson(String str) => CommandQueueModal.fromJson(json.decode(str));

String commandQueueModalToJson(CommandQueueModal data) => json.encode(data.toJson());

class CommandQueueModal {
    List<Datum> data;
    dynamic error;
    bool success;

    CommandQueueModal({
        required this.data,
        required this.error,
        required this.success,
    });

    factory CommandQueueModal.fromJson(Map<String, dynamic> json) => CommandQueueModal(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        error: json["error"],
        success: json["success"],
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "error": error,
        "success": success,
    };
}

class Datum {
    String requestId;
    String commandPayload;
    ExtraArgs extraArgs;
    String deviceCommandId;
    String deviceCommandCode;

    Datum({
        required this.requestId,
        required this.commandPayload,
        required this.extraArgs,
        required this.deviceCommandId,
        required this.deviceCommandCode,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        requestId: json["request_id"],
        commandPayload: json["command_payload"],
        extraArgs: ExtraArgs.fromJson(json["extra_args"]),
        deviceCommandId: json["device_command_id"],
        deviceCommandCode: json["device_command_code"],
    );

    Map<String, dynamic> toJson() => {
        "request_id": requestId,
        "command_payload": commandPayload,
        "extra_args": extraArgs.toJson(),
        "device_command_id": deviceCommandId,
        "device_command_code": deviceCommandCode,
    };
}

class ExtraArgs {
    String id;
    String createdAt;
    String updatedAt;
    int version;
    String name;
    bool rollback;
    dynamic maintenanceWindowFrom;
    dynamic maintenanceWindowTo;
    String remark;
    String status;
    int createdBy;
    int updatedBy;
    dynamic deviceMaster;
    dynamic organization;
    dynamic facility;
    String device;
    String dockerCompose;
    String deviceSerial;
    bool startStoppedBeforeUpdate;
    String deploymentType;
    List<String> stopBeforeUpdate;
    bool startAfterUpdate;
    bool logContainerOutput;
    bool checkContainerStatus;
    int waitBeforeCheckContainerStatus;
    int waitBeforeLogContainerOutput;
    bool dockerSystemPruneAfterUpdate;

    ExtraArgs({
        required this.id,
        required this.createdAt,
        required this.updatedAt,
        required this.version,
        required this.name,
        required this.rollback,
        required this.maintenanceWindowFrom,
        required this.maintenanceWindowTo,
        required this.remark,
        required this.status,
        required this.createdBy,
        required this.updatedBy,
        required this.deviceMaster,
        required this.organization,
        required this.facility,
        required this.device,
        required this.dockerCompose,
        required this.deviceSerial,
        required this.startStoppedBeforeUpdate,
        required this.deploymentType,
        required this.stopBeforeUpdate,
        required this.startAfterUpdate,
        required this.logContainerOutput,
        required this.checkContainerStatus,
        required this.waitBeforeCheckContainerStatus,
        required this.waitBeforeLogContainerOutput,
        required this.dockerSystemPruneAfterUpdate,
    });

    factory ExtraArgs.fromJson(Map<String, dynamic> json) => ExtraArgs(
        id: json["id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        version: json["version"],
        name: json["name"],
        rollback: json["rollback"],
        maintenanceWindowFrom: json["maintenance_window_from"],
        maintenanceWindowTo: json["maintenance_window_to"],
        remark: json["remark"],
        status: json["status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        deviceMaster: json["device_master"],
        organization: json["organization"],
        facility: json["facility"],
        device: json["device"],
        dockerCompose: json["docker_compose"],
        deviceSerial: json["device_serial"],
        startStoppedBeforeUpdate: json["start_stopped_before_update"],
        deploymentType: json["deployment_type"],
        stopBeforeUpdate: List<String>.from(json["stop_before_update"].map((x) => x)),
        startAfterUpdate: json["start_after_update"],
        logContainerOutput: json["log_container_output"],
        checkContainerStatus: json["check_container_status"],
        waitBeforeCheckContainerStatus: json["wait_before_check_container_status"],
        waitBeforeLogContainerOutput: json["wait_before_log_container_output"],
        dockerSystemPruneAfterUpdate: json["docker_system_prune_after_update"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "version": version,
        "name": name,
        "rollback": rollback,
        "maintenance_window_from": maintenanceWindowFrom,
        "maintenance_window_to": maintenanceWindowTo,
        "remark": remark,
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "device_master": deviceMaster,
        "organization": organization,
        "facility": facility,
        "device": device,
        "docker_compose": dockerCompose,
        "device_serial": deviceSerial,
        "start_stopped_before_update": startStoppedBeforeUpdate,
        "deployment_type": deploymentType,
        "stop_before_update": List<dynamic>.from(stopBeforeUpdate.map((x) => x)),
        "start_after_update": startAfterUpdate,
        "log_container_output": logContainerOutput,
        "check_container_status": checkContainerStatus,
        "wait_before_check_container_status": waitBeforeCheckContainerStatus,
        "wait_before_log_container_output": waitBeforeLogContainerOutput,
        "docker_system_prune_after_update": dockerSystemPruneAfterUpdate,
    };
}
