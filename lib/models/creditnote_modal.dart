// To parse this JSON data, do
//
//     final creditNoteModal = creditNoteModalFromJson(jsonString);

import 'dart:convert';

CreditNoteModal creditNoteModalFromJson(String str) => CreditNoteModal.fromJson(json.decode(str));

String creditNoteModalToJson(CreditNoteModal data) => json.encode(data.toJson());

class CreditNoteModal {
    bool success;
    List<Datum> data;

    CreditNoteModal({
        required this.success,
        required this.data,
    });

    factory CreditNoteModal.fromJson(Map<String, dynamic> json) => CreditNoteModal(
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
    String createdAt;
    String updatedAt;
    String amount;
    DateTime date;
    dynamic referenceNumber;
    String remarks;
    String status;
    int createdBy;
    int updatedBy;
    String facility;

    Datum({
        required this.id,
        required this.createdAt,
        required this.updatedAt,
        required this.amount,
        required this.date,
        required this.referenceNumber,
        required this.remarks,
        required this.status,
        required this.createdBy,
        required this.updatedBy,
        required this.facility,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        amount: json["amount"],
        date: DateTime.parse(json["date"]),
        referenceNumber: json["reference_number"],
        remarks: json["remarks"],
        status: json["status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        facility: json["facility"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "amount": amount,
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "reference_number": referenceNumber,
        "remarks": remarks,
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "facility": facility,
    };
}
