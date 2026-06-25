// To parse this JSON data, do
//
//     final invoiceItemModel = invoiceItemModelFromJson(jsonString);

import 'dart:convert';
import 'package:aap/models/accountstatement_model.dart';

InvoiceItemModel invoiceItemModelFromJson(String str) => InvoiceItemModel.fromJson(json.decode(str));

String invoiceItemModelToJson(InvoiceItemModel data) => json.encode(data.toJson());

class InvoiceItemModel {
    List<InvoiceItem> itemList;
    String itemCode;

    InvoiceItemModel({
        required this.itemList,
        required this.itemCode,
    });

    factory InvoiceItemModel.fromJson(Map<String, dynamic> json) => InvoiceItemModel(
        itemList: List<InvoiceItem>.from(json["itemList"].map((x) => x)),
        itemCode: json["itemCode"],
    );

    Map<String, dynamic> toJson() => {
        "itemList": List<dynamic>.from(itemList.map((x) => x)),
        "itemCode": itemCode,
    };
}