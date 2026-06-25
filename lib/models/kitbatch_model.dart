// To parse this JSON data, do
//
//     final kitBatch = kitBatchFromJson(jsonString);

import 'dart:convert';

List<KitBatch> kitBatchFromJson(String str) => List<KitBatch>.from(json.decode(str).map((x) => KitBatch.fromJson(x)));

String kitBatchToJson(List<KitBatch> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class KitBatch {
    String id;
    String facility;
    String kitRejectionReason;
    String status;

    KitBatch({
        required this.id,
        required this.facility,
        required this.kitRejectionReason,
        required this.status,
    });

    factory KitBatch.fromJson(Map<String, dynamic> json) => KitBatch(
        id: json["id"],
        facility: json["facility"],
        kitRejectionReason: json["kit_rejection_reason"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "facility": facility,
        "kit_rejection_reason": kitRejectionReason,
        "status": status,
    };
}
