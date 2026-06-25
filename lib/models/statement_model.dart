// To parse this JSON data, do
//
//     final statementModal = statementModalFromJson(jsonString);

import 'dart:convert';

StatementModal statementModalFromJson(String str) => StatementModal.fromJson(json.decode(str));

String statementModalToJson(StatementModal data) => json.encode(data.toJson());

class StatementModal {
    bool? success;
    List<Datum>? data;

    StatementModal({
        this.success,
        this.data,
    });

    factory StatementModal.fromJson(Map<String, dynamic> json) => StatementModal(
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
    String? contentTypeEntity;
    String? objectCode;
    ContentObject? contentObject;
    String? createdAt;
    String? updatedAt;
    int? version;
    String? lastBalance;
    String? amount;
    String? balance;
    String? txType;
    String? source;
    String? objectId;
    String? description;
    String? status;
    int? createdBy;
    int? updatedBy;
    String? organization;
    int? contentType;

    Datum({
        this.id,
        this.contentTypeEntity,
        this.objectCode,
        this.contentObject,
        this.createdAt,
        this.updatedAt,
        this.version,
        this.lastBalance,
        this.amount,
        this.balance,
        this.txType,
        this.source,
        this.objectId,
        this.description,
        this.status,
        this.createdBy,
        this.updatedBy,
        this.organization,
        this.contentType,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        contentTypeEntity: json["content_type_entity"],
        objectCode: json["object_code"],
        contentObject: json["content_object"] == null ? null : ContentObject.fromJson(json["content_object"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        version: json["version"],
        lastBalance: json["last_balance"],
        amount: json["amount"],
        balance: json["balance"],
        txType: json["tx_type"],
        source: json["source"],
        objectId: json["object_id"],
        description: json["description"],
        status: json["status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        organization: json["organization"],
        contentType: json["content_type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "content_type_entity": contentTypeEntity,
        "object_code": objectCode,
        "content_object": contentObject?.toJson(),
        "created_at": createdAt,
        "updated_at": updatedAt,
        "version": version,
        "last_balance": lastBalance,
        "amount": amount,
        "balance": balance,
        "tx_type": txType,
        "source": source,
        "object_id": objectId,
        "description": description,
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "organization": organization,
        "content_type": contentType,
    };
}

class ContentObject {
    String? id;
    String? createdAt;
    String? updatedAt;
    String? code;
    dynamic externalSampleId;
    String? kitCode;
    dynamic captureResolution;
    String? remarks;
    String? error;
    dynamic invoiceId;
    dynamic sampleWeight;
    dynamic reagentWeight;
    int? sampleDilution;
    dynamic result;
    bool? reportReady;
    dynamic reportPdf;
    String? reportHtml;
    dynamic consolidatedHtml;
    String? amount;
    String? discount;
    String? discountPerc;
    int? quantity;
    String? charges;
    String? cgst;
    String? cgstPerc;
    String? sgst;
    String? sgstPerc;
    String? tax;
    String? taxPerc;
    String? total;
    dynamic discountRemarks;
    bool? synced;
    String? syncedAt;
    String? checkedAt;
    TrackingInfo? trackingInfo;
    String? status;
    int? createdBy;
    int? updatedBy;
    String? patient;
    String? testGroup;
    String? facility;
    String? batchType;
    dynamic organizationDiscount;

    ContentObject({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.code,
        this.externalSampleId,
        this.kitCode,
        this.captureResolution,
        this.remarks,
        this.error,
        this.invoiceId,
        this.sampleWeight,
        this.reagentWeight,
        this.sampleDilution,
        this.result,
        this.reportReady,
        this.reportPdf,
        this.reportHtml,
        this.consolidatedHtml,
        this.amount,
        this.discount,
        this.discountPerc,
        this.quantity,
        this.charges,
        this.cgst,
        this.cgstPerc,
        this.sgst,
        this.sgstPerc,
        this.tax,
        this.taxPerc,
        this.total,
        this.discountRemarks,
        this.synced,
        this.syncedAt,
        this.checkedAt,
        this.trackingInfo,
        this.status,
        this.createdBy,
        this.updatedBy,
        this.patient,
        this.testGroup,
        this.facility,
        this.batchType,
        this.organizationDiscount,
    });

    factory ContentObject.fromJson(Map<String, dynamic> json) => ContentObject(
        id: json["id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        code: json["code"],
        externalSampleId: json["external_sample_id"],
        kitCode: json["kit_code"],
        captureResolution: json["capture_resolution"],
        remarks: json["remarks"],
        error: json["error"],
        invoiceId: json["invoice_id"],
        sampleWeight: json["sample_weight"],
        reagentWeight: json["reagent_weight"],
        sampleDilution: json["sample_dilution"],
        result: json["result"],
        reportReady: json["report_ready"],
        reportPdf: json["report_pdf"],
        reportHtml: json["report_html"],
        consolidatedHtml: json["consolidated_html"],
        amount: json["amount"],
        discount: json["discount"],
        discountPerc: json["discount_perc"],
        quantity: json["quantity"],
        charges: json["charges"],
        cgst: json["cgst"],
        cgstPerc: json["cgst_perc"],
        sgst: json["sgst"],
        sgstPerc: json["sgst_perc"],
        tax: json["tax"],
        taxPerc: json["tax_perc"],
        total: json["total"],
        discountRemarks: json["discount_remarks"],
        synced: json["synced"],
        syncedAt: json["synced_at"],
        checkedAt: json["checked_at"],
        trackingInfo: json["tracking_info"] == null ? null : TrackingInfo.fromJson(json["tracking_info"]),
        status: json["status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        patient: json["patient"],
        testGroup: json["test_group"],
        facility: json["facility"],
        batchType: json["batch_type"],
        organizationDiscount: json["organization_discount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "code": code,
        "external_sample_id": externalSampleId,
        "kit_code": kitCode,
        "capture_resolution": captureResolution,
        "remarks": remarks,
        "error": error,
        "invoice_id": invoiceId,
        "sample_weight": sampleWeight,
        "reagent_weight": reagentWeight,
        "sample_dilution": sampleDilution,
        "result": result,
        "report_ready": reportReady,
        "report_pdf": reportPdf,
        "report_html": reportHtml,
        "consolidated_html": consolidatedHtml,
        "amount": amount,
        "discount": discount,
        "discount_perc": discountPerc,
        "quantity": quantity,
        "charges": charges,
        "cgst": cgst,
        "cgst_perc": cgstPerc,
        "sgst": sgst,
        "sgst_perc": sgstPerc,
        "tax": tax,
        "tax_perc": taxPerc,
        "total": total,
        "discount_remarks": discountRemarks,
        "synced": synced,
        "synced_at": syncedAt,
        "checked_at": checkedAt,
        "tracking_info": trackingInfo?.toJson(),
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "patient": patient,
        "test_group": testGroup,
        "facility": facility,
        "batch_type": batchType,
        "organization_discount": organizationDiscount,
    };
}

class TrackingInfo {
    String? origin;
    String? clientType;
    String? environment;

    TrackingInfo({
        this.origin,
        this.clientType,
        this.environment,
    });

    factory TrackingInfo.fromJson(Map<String, dynamic> json) => TrackingInfo(
        origin: json["origin"],
        clientType: json["client_type"],
        environment: json["environment"],
    );

    Map<String, dynamic> toJson() => {
        "origin": origin,
        "client_type": clientType,
        "environment": environment,
    };
}
