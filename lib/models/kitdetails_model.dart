// To parse this JSON data, do
//
//     final kitDeatilsModel = kitDeatilsModelFromJson(jsonString);

import 'dart:convert';

KitDeatilsModel kitDeatilsModelFromJson(String str) => KitDeatilsModel.fromJson(json.decode(str));

String kitDeatilsModelToJson(KitDeatilsModel data) => json.encode(data.toJson());

class KitDeatilsModel {
    bool success;
    List<Datum> data;

    KitDeatilsModel({
        required this.success,
        required this.data,
    });

    factory KitDeatilsModel.fromJson(Map<String, dynamic> json) => KitDeatilsModel(
        success: json["success"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String id;
    String statusCode;
    List<TestGroup> testGroup;
    String createdAt;
    String updatedAt;
    String code;
    String qrCode;
    String labelHtml;
    String labelPdf;
    String label;
    dynamic sampleStaging;
    String batch;
    DateTime expiryDate;
    dynamic images;
    dynamic remarks;
    dynamic createdBy;
    dynamic updatedBy;
    String kitMaster;
    String warehouse;
    dynamic orderLineItem;
    dynamic facility;
    dynamic sample;
    dynamic kitRejectionReason;
    String status;

    Datum({
        required this.id,
        required this.statusCode,
        required this.testGroup,
        required this.createdAt,
        required this.updatedAt,
        required this.code,
        required this.qrCode,
        required this.labelHtml,
        required this.labelPdf,
        required this.label,
        required this.sampleStaging,
        required this.batch,
        required this.expiryDate,
        required this.images,
        required this.remarks,
        required this.createdBy,
        required this.updatedBy,
        required this.kitMaster,
        required this.warehouse,
        required this.orderLineItem,
        required this.facility,
        required this.sample,
        required this.kitRejectionReason,
        required this.status,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        statusCode: json["status_code"],
        testGroup: List<TestGroup>.from(json["test_group"].map((x) => TestGroup.fromJson(x))),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        code: json["code"],
        qrCode: json["qr_code"],
        labelHtml: json["label_html"],
        labelPdf: json["label_pdf"],
        label: json["label"],
        sampleStaging: json["sample_staging"],
        batch: json["batch"],
        expiryDate: DateTime.parse(json["expiry_date"]),
        images: json["images"],
        remarks: json["remarks"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        kitMaster: json["kit_master"],
        warehouse: json["warehouse"],
        orderLineItem: json["order_line_item"],
        facility: json["facility"],
        sample: json["sample"],
        kitRejectionReason: json["kit_rejection_reason"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status_code": statusCode,
        "test_group": List<dynamic>.from(testGroup.map((x) => x.toJson())),
        "created_at": createdAt,
        "updated_at": updatedAt,
        "code": code,
        "qr_code": qrCode,
        "label_html": labelHtml,
        "label_pdf": labelPdf,
        "label": label,
        "sample_staging": sampleStaging,
        "batch": batch,
        "expiry_date": "${expiryDate.year.toString().padLeft(4, '0')}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}",
        "images": images,
        "remarks": remarks,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "kit_master": kitMaster,
        "warehouse": warehouse,
        "order_line_item": orderLineItem,
        "facility": facility,
        "sample": sample,
        "kit_rejection_reason": kitRejectionReason,
        "status": status,
    };
}

class TestGroup {
    String id;
    String code;
    String status;

    TestGroup({
        required this.id,
        required this.code,
        required this.status,
    });

    factory TestGroup.fromJson(Map<String, dynamic> json) => TestGroup(
        id: json["id"],
        code: json["code"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "status": status,
    };
}
