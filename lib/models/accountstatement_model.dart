// To parse this JSON data, do
//
//     final accountsStatement = accountsStatementFromJson(jsonString);

import 'dart:convert';

AccountsStatement accountsStatementFromJson(String str) => AccountsStatement.fromJson(json.decode(str));

String accountsStatementToJson(AccountsStatement data) => json.encode(data.toJson());

class AccountsStatement {
    bool success;
    List<Datum> data;

    AccountsStatement({
        required this.success,
        required this.data,
    });

    factory AccountsStatement.fromJson(Map<String, dynamic> json) => AccountsStatement(
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
    List<InvoiceItemGrouped> invoiceItemGrouped;
    String amount;
    String tax;
    String grandTotal;
    String createdAt;
    String updatedAt;
    int code;
    DateTime fromDate;
    DateTime toDate;
    int year;
    int month;
    int days;
    dynamic pdf;
    dynamic remarks;
    String status;
    dynamic createdBy;
    dynamic updatedBy;
    String facility;
    List<InvoiceItem> invoiceItems;
    String cgst;
    String sgst;

    Datum({
        required this.id,
        required this.invoiceItemGrouped,
        required this.amount,
        required this.tax,
        required this.grandTotal,
        required this.createdAt,
        required this.updatedAt,
        required this.code,
        required this.fromDate,
        required this.toDate,
        required this.year,
        required this.month,
        required this.days,
        required this.pdf,
        required this.remarks,
        required this.status,
        required this.createdBy,
        required this.updatedBy,
        required this.facility,
        required this.invoiceItems,
        required this.cgst,
        required this.sgst
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        invoiceItemGrouped: List<InvoiceItemGrouped>.from(json["invoice_item_grouped"].map((x) => InvoiceItemGrouped.fromJson(x))),
        amount: json["amount"],
        tax: json["tax"],
        grandTotal: json["grand_total"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        code: json["code"],
        fromDate: DateTime.parse(json["from_date"]),
        toDate: DateTime.parse(json["to_date"]),
        year: json["year"],
        month: json["month"],
        days: json["days"],
        pdf: json["pdf"],
        remarks: json["remarks"],
        status: json["status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        facility: json["facility"],
        invoiceItems: List<InvoiceItem>.from(json["invoice_items"].map((x) => InvoiceItem.fromJson(x))),
        cgst: json["cgst"],
        sgst: json["sgst"]
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "invoice_item_grouped": List<dynamic>.from(invoiceItemGrouped.map((x) => x.toJson())),
        "amount": amount,
        "tax": tax,
        "grand_total": grandTotal,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "code": code,
        "from_date": "${fromDate.year.toString().padLeft(4, '0')}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}",
        "to_date": "${toDate.year.toString().padLeft(4, '0')}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}",
        "year": year,
        "month": month,
        "days": days,
        "pdf": pdf,
        "remarks": remarks,
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "facility": facility,
        "invoice_items": List<dynamic>.from(invoiceItems.map((x) => x.toJson())),
        "cgst": cgst,
        "sgst": sgst,
    };
}

class InvoiceItemGrouped {
    int contentType;
    String objectId;
    String type;
    String itemName;
    String itemCode;
    String hsn;
    String amount;
    String quantity;
    String charges;
    String cgstPerc;
    String cgst;
    String sgstPerc;
    String sgst;
    String taxPerc;
    String tax;
    String total;

    InvoiceItemGrouped({
        required this.contentType,
        required this.objectId,
        required this.type,
        required this.itemName,
        required this.itemCode,
        required this.hsn,
        required this.amount,
        required this.quantity,
        required this.charges,
        required this.cgstPerc,
        required this.cgst,
        required this.sgstPerc,
        required this.sgst,
        required this.taxPerc,
        required this.tax,
        required this.total,
    });

    factory InvoiceItemGrouped.fromJson(Map<String, dynamic> json) => InvoiceItemGrouped(
        contentType: json["content_type"],
        objectId: json["object_id"],
        type: json["type"],
        itemName: json["item_name"],
        itemCode: json["item_code"],
        hsn: json["hsn"],
        amount: json["amount"],
        quantity: json["quantity"],
        charges: json["charges"],
        cgstPerc: json["cgst_perc"],
        cgst: json["cgst"],
        sgstPerc: json["sgst_perc"],
        sgst: json["sgst"],
        taxPerc: json["tax_perc"],
        tax: json["tax"],
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "content_type": contentType,
        "object_id": objectId,
        "type": type,
        "item_name": itemName,
        "item_code": itemCode,
        "hsn": hsn,
        "amount": amount,
        "quantity": quantity,
        "charges": charges,
        "cgst_perc": cgstPerc,
        "cgst": cgst,
        "sgst_perc": sgstPerc,
        "sgst": sgst,
        "tax_perc": taxPerc,
        "tax": tax,
        "total": total,
    };
}

class InvoiceItem {
    String id;
    String contentTypeEntity;
    String objectCode;
    ContentObject contentObject;
    String createdAt;
    String updatedAt;
    String itemCode;
    String objectId;
    String amount;
    int quantity;
    String charges;
    String cgst;
    String cgstPerc;
    String sgst;
    String sgstPerc;
    String tax;
    String taxPerc;
    String total;
    String status;
    dynamic createdBy;
    dynamic updatedBy;
    int contentType;

    InvoiceItem({
        required this.id,
        required this.contentTypeEntity,
        required this.objectCode,
        required this.contentObject,
        required this.createdAt,
        required this.updatedAt,
        required this.itemCode,
        required this.objectId,
        required this.amount,
        required this.quantity,
        required this.charges,
        required this.cgst,
        required this.cgstPerc,
        required this.sgst,
        required this.sgstPerc,
        required this.tax,
        required this.taxPerc,
        required this.total,
        required this.status,
        required this.createdBy,
        required this.updatedBy,
        required this.contentType,
    });

    factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        id: json["id"],
        contentTypeEntity: json["content_type_entity"],
        objectCode: json["object_code"],
        contentObject: ContentObject.fromJson(json["content_object"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        itemCode: json["item_code"],
        objectId: json["object_id"],
        amount: json["amount"],
        quantity: json["quantity"],
        charges: json["charges"],
        cgst: json["cgst"],
        cgstPerc: json["cgst_perc"],
        sgst: json["sgst"],
        sgstPerc: json["sgst_perc"],
        tax: json["tax"],
        taxPerc: json["tax_perc"],
        total: json["total"],
        status: json["status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        contentType: json["content_type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "content_type_entity": contentTypeEntity,
        "object_code": objectCode,
        "content_object": contentObject.toJson(),
        "created_at": createdAt,
        "updated_at": updatedAt,
        "item_code": itemCode,
        "object_id": objectId,
        "amount": amount,
        "quantity": quantity,
        "charges": charges,
        "cgst": cgst,
        "cgst_perc": cgstPerc,
        "sgst": sgst,
        "sgst_perc": sgstPerc,
        "tax": tax,
        "tax_perc": taxPerc,
        "total": total,
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "content_type": contentType,
    };
}

class ContentObject {
    String id;
    String createdAt;
    String updatedAt;
    String name;
    String? model;
    String? registryTag;
    String? firmwareTag;
    dynamic pixelToMicron;
    GpioPinsDefinition? gpioPinsDefinition;
    dynamic ledMappings;
    int? subscriptionFee;
    int sgst;
    int cgst;
    int tax;
    String hsn;
    String status;
    int createdBy;
    int updatedBy;
    String? manufacturer;
    List<String> testGroup;
    List<String>? deviceCommand;
    String? code;
    String? mrp;
    String? batch;
    DateTime? expiryDate;
    int? addQuantity;
    String? description;
    String? category;
    String? warehouse;

    ContentObject({
        required this.id,
        required this.createdAt,
        required this.updatedAt,
        required this.name,
        this.model,
        this.registryTag,
        this.firmwareTag,
        this.pixelToMicron,
        this.gpioPinsDefinition,
        this.ledMappings,
        this.subscriptionFee,
        required this.sgst,
        required this.cgst,
        required this.tax,
        required this.hsn,
        required this.status,
        required this.createdBy,
        required this.updatedBy,
        this.manufacturer,
        required this.testGroup,
        this.deviceCommand,
        this.code,
        this.mrp,
        this.batch,
        this.expiryDate,
        this.addQuantity,
        this.description,
        this.category,
        this.warehouse,
    });

    factory ContentObject.fromJson(Map<String, dynamic> json) => ContentObject(
        id: json["id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        name: json["name"],
        model: json["model"],
        registryTag: json["registry_tag"],
        firmwareTag: json["firmware_tag"],
        pixelToMicron: json["pixel_to_micron"],
        gpioPinsDefinition: json["gpio_pins_definition"] == null ? null : GpioPinsDefinition.fromJson(json["gpio_pins_definition"]),
        ledMappings: json["led_mappings"],
        subscriptionFee: json["subscription_fee"],
        sgst: json["sgst"],
        cgst: json["cgst"],
        tax: json["tax"],
        hsn: json["hsn"],
        status: json["status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        manufacturer: json["manufacturer"],
        testGroup: List<String>.from(json["test_group"].map((x) => x)),
        deviceCommand: json["device_command"] == null ? [] : List<String>.from(json["device_command"]!.map((x) => x)),
        code: json["code"],
        mrp: json["mrp"],
        batch: json["batch"],
        expiryDate: json["expiry_date"] == null ? null : DateTime.parse(json["expiry_date"]),
        addQuantity: json["add_quantity"],
        description: json["description"],
        category: json["category"],
        warehouse: json["warehouse"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "name": name,
        "model": model,
        "registry_tag": registryTag,
        "firmware_tag": firmwareTag,
        "pixel_to_micron": pixelToMicron,
        "gpio_pins_definition": gpioPinsDefinition?.toJson(),
        "led_mappings": ledMappings,
        "subscription_fee": subscriptionFee,
        "sgst": sgst,
        "cgst": cgst,
        "tax": tax,
        "hsn": hsn,
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "manufacturer": manufacturer,
        "test_group": List<dynamic>.from(testGroup.map((x) => x)),
        "device_command": deviceCommand == null ? [] : List<dynamic>.from(deviceCommand!.map((x) => x)),
        "code": code,
        "mrp": mrp,
        "batch": batch,
        "expiry_date": "${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}",
        "add_quantity": addQuantity,
        "description": description,
        "category": category,
        "warehouse": warehouse,
    };
}

class GpioPinsDefinition {
    String l;
    String o;
    String p;
    String x;
    String y;
    String z;
    String sl;
    String home;
    String heater;
    String colLed;
    String colGain;
    Settings settings;
    String heaterOn;
    String ledReset;
    String heaterOff;
    String portCheck;
    String colTimeExp;
    String resetArduino;
    String pipetteHoming;
    String getTemperature;
    String disambiguationCmd;
    String singleAxisHoming;
    String colStepIntegration;

    GpioPinsDefinition({
        required this.l,
        required this.o,
        required this.p,
        required this.x,
        required this.y,
        required this.z,
        required this.sl,
        required this.home,
        required this.heater,
        required this.colLed,
        required this.colGain,
        required this.settings,
        required this.heaterOn,
        required this.ledReset,
        required this.heaterOff,
        required this.portCheck,
        required this.colTimeExp,
        required this.resetArduino,
        required this.pipetteHoming,
        required this.getTemperature,
        required this.disambiguationCmd,
        required this.singleAxisHoming,
        required this.colStepIntegration,
    });

    factory GpioPinsDefinition.fromJson(Map<String, dynamic> json) => GpioPinsDefinition(
        l: json["L"],
        o: json["O"],
        p: json["P"],
        x: json["X"],
        y: json["Y"],
        z: json["Z"],
        sl: json["SL"],
        home: json["HOME"],
        heater: json["HEATER"],
        colLed: json["COL_LED"],
        colGain: json["COL_GAIN"],
        settings: Settings.fromJson(json["SETTINGS"]),
        heaterOn: json["HEATER_ON"],
        ledReset: json["LED_RESET"],
        heaterOff: json["HEATER_OFF"],
        portCheck: json["PORT_CHECK"],
        colTimeExp: json["COL_TIME_EXP"],
        resetArduino: json["RESET_ARDUINO"],
        pipetteHoming: json["PIPETTE_HOMING"],
        getTemperature: json["GET_TEMPERATURE"],
        disambiguationCmd: json["DISAMBIGUATION_CMD"],
        singleAxisHoming: json["SINGLE_AXIS_HOMING"],
        colStepIntegration: json["COL_STEP_INTEGRATION"],
    );

    Map<String, dynamic> toJson() => {
        "L": l,
        "O": o,
        "P": p,
        "X": x,
        "Y": y,
        "Z": z,
        "SL": sl,
        "HOME": home,
        "HEATER": heater,
        "COL_LED": colLed,
        "COL_GAIN": colGain,
        "SETTINGS": settings.toJson(),
        "HEATER_ON": heaterOn,
        "LED_RESET": ledReset,
        "HEATER_OFF": heaterOff,
        "PORT_CHECK": portCheck,
        "COL_TIME_EXP": colTimeExp,
        "RESET_ARDUINO": resetArduino,
        "PIPETTE_HOMING": pipetteHoming,
        "GET_TEMPERATURE": getTemperature,
        "DISAMBIGUATION_CMD": disambiguationCmd,
        "SINGLE_AXIS_HOMING": singleAxisHoming,
        "COL_STEP_INTEGRATION": colStepIntegration,
    };
}

class Settings {
    int byteSize;
    int braudRate;
    int readTimeout;
    int writeTimeout;

    Settings({
        required this.byteSize,
        required this.braudRate,
        required this.readTimeout,
        required this.writeTimeout,
    });

    factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        byteSize: json["BYTE_SIZE"],
        braudRate: json["BRAUD_RATE"],
        readTimeout: json["READ_TIMEOUT"],
        writeTimeout: json["WRITE_TIMEOUT"],
    );

    Map<String, dynamic> toJson() => {
        "BYTE_SIZE": byteSize,
        "BRAUD_RATE": braudRate,
        "READ_TIMEOUT": readTimeout,
        "WRITE_TIMEOUT": writeTimeout,
    };
}
