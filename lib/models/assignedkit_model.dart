// To parse this JSON data, do
//
//     final assignedKit = assignedKitFromJson(jsonString);

import 'dart:convert';

AssignedKit assignedKitFromJson(String str) => AssignedKit.fromJson(json.decode(str));

String assignedKitToJson(AssignedKit data) => json.encode(data.toJson());

class AssignedKit {
    bool? success;
    List<Datum>? data;

    AssignedKit({
        this.success,
        this.data,
    });

    factory AssignedKit.fromJson(Map<String, dynamic> json) => AssignedKit(
        success: json["success"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    String? id;
    String? statusCode;
    List<TestGroup>? testGroup;
    String? createdAt;
    String? updatedAt;
    String? code;
    dynamic qrCode;
    dynamic labelHtml;
    dynamic labelPdf;
    dynamic label;
    dynamic sampleStaging;
    String? batch;
    DateTime? expiryDate;
    String? unitPrice;
    int? sgst;
    int? cgst;
    int? tax;
    String? mrp;
    dynamic images;
    dynamic remarks;
    int? createdBy;
    int? updatedBy;
    String? kitMaster;
    String? warehouse;
    dynamic invoiceLineItem;
    String? facility;
    dynamic sample;
    dynamic kitRejectionReason;
    String? status;

    Datum({
        this.id,
        this.statusCode,
        this.testGroup,
        this.createdAt,
        this.updatedAt,
        this.code,
        this.qrCode,
        this.labelHtml,
        this.labelPdf,
        this.label,
        this.sampleStaging,
        this.batch,
        this.expiryDate,
        this.unitPrice,
        this.sgst,
        this.cgst,
        this.tax,
        this.mrp,
        this.images,
        this.remarks,
        this.createdBy,
        this.updatedBy,
        this.kitMaster,
        this.warehouse,
        this.invoiceLineItem,
        this.facility,
        this.sample,
        this.kitRejectionReason,
        this.status,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        statusCode: json["status_code"],
        testGroup: json["test_group"] == null ? [] : List<TestGroup>.from(json["test_group"]!.map((x) => TestGroup.fromJson(x))),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        code: json["code"],
        qrCode: json["qr_code"],
        labelHtml: json["label_html"],
        labelPdf: json["label_pdf"],
        label: json["label"],
        sampleStaging: json["sample_staging"],
        batch: json["batch"],
        expiryDate: json["expiry_date"] == null ? null : DateTime.parse(json["expiry_date"]),
        unitPrice: json["unit_price"],
        sgst: json["sgst"],
        cgst: json["cgst"],
        tax: json["tax"],
        mrp: json["mrp"],
        images: json["images"],
        remarks: json["remarks"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        kitMaster: json["kit_master"],
        warehouse: json["warehouse"],
        invoiceLineItem: json["invoice_line_item"],
        facility: json["facility"],
        sample: json["sample"],
        kitRejectionReason: json["kit_rejection_reason"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status_code": statusCode,
        "test_group": testGroup == null ? [] : List<dynamic>.from(testGroup!.map((x) => x.toJson())),
        "created_at": createdAt,
        "updated_at": updatedAt,
        "code": code,
        "qr_code": qrCode,
        "label_html": labelHtml,
        "label_pdf": labelPdf,
        "label": label,
        "sample_staging": sampleStaging,
        "batch": batch,
        "expiry_date": "${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}",
        "unit_price": unitPrice,
        "sgst": sgst,
        "cgst": cgst,
        "tax": tax,
        "mrp": mrp,
        "images": images,
        "remarks": remarks,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "kit_master": kitMaster,
        "warehouse": warehouse,
        "invoice_line_item": invoiceLineItem,
        "facility": facility,
        "sample": sample,
        "kit_rejection_reason": kitRejectionReason,
        "status": status,
    };
}

class TestGroup {
    String? id;
    String? code;
    String? status;

    TestGroup({
        this.id,
        this.code,
        this.status,
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
