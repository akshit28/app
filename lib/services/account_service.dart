import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:aap/constants/constants.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/models/accountstatement_model.dart';
import 'package:aap/models/error_model.dart';
import 'package:aap/models/creditnote_modal.dart';
import 'package:aap/models/payments_modal.dart';
import 'package:aap/models/statement_model.dart';

class AccountService {
  var sharedIns = SharedPref();

  Future fetchStatement(
      String selectedMonth, String selectedYear, String facility) async {
    final AccountsStatement data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    // var startMonth = int.parse(selectedMonth) - 1;
    // var endMonth = int.parse(selectedMonth);
    try {
      var url = Uri.parse(ApiConstants.baseUrl1 + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, dynamic>{
            "forwarder_endpoint": "/invoice/get",
            "forwarder_type": "MASTER",
            "facility": facility,
            "year": selectedYear,
            "month": selectedMonth
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = AccountsStatement.fromJson(json.decode(response.body));
          return data;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {
        final apiError = ErrorModel.fromJson(json.decode(response.body));
        return apiError;
      }
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }

  Future fetchCreditNote(String facility, String year, String month) async {
    final CreditNoteModal data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;

    try {
      var url = Uri.parse(ApiConstants.baseUrl1 + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, dynamic>{
            "forwarder_endpoint": "/credit-note/get",
            "forwarder_type": "MASTER",
            "facility": facility,
            "date__year": year,
            "date__month": month
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = CreditNoteModal.fromJson(json.decode(response.body));
          return data;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {
        final apiError = ErrorModel.fromJson(json.decode(response.body));
        return apiError;
      }
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }

  Future fetchPayments(String facility, String year, String month) async {
    final PaymentsModal data;
    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;

    try {
      var url = Uri.parse(ApiConstants.baseUrl1 + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: jsonEncode(<String, dynamic>{
            "forwarder_endpoint": "/payment/get",
            "forwarder_type": "MASTER",
            "facility": facility,
            "date__year": year,
            "date__month": month
          }));

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = PaymentsModal.fromJson(json.decode(response.body));
          return data;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {
        final apiError = ErrorModel.fromJson(json.decode(response.body));
        return apiError;
      }
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }

  Future fetchStatements(
      String facility, String startMonth, String txnType) async {
    final StatementModal data;

    final String userToken =
        await sharedIns.getValueFromSharedPreferences("userToken") as String;
    late String payload;

    if (startMonth.isNotEmpty && txnType.isNotEmpty) {
      payload = jsonEncode(<String, String>{
        "forwarder_endpoint": "/ledger/get",
        "forwarder_type": "MASTER",
        "facility_id": facility,
        "created_at__gte": startMonth,
        "tx_type": txnType
      });
    } else if (startMonth.isNotEmpty) {
      payload = jsonEncode(<String, String>{
        "forwarder_endpoint": "/ledger/get",
        "forwarder_type": "MASTER",
        "facility_id": facility,
        "created_at__gte": startMonth,
      });
    } else if (txnType.isNotEmpty) {
      payload = jsonEncode(<String, String>{
        "forwarder_endpoint": "/ledger/get",
        "forwarder_type": "MASTER",
        "facility_id": facility,
        "tx_type": txnType
      });
    } else {
      payload = jsonEncode(<String, String>{
        "forwarder_endpoint": "/ledger/get",
        "forwarder_type": "MASTER",
        "facility_id": facility,
      });
    }

    try {
      var url = Uri.parse(ApiConstants.baseUrl1 + ApiConstants.forwarder);
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authentication': userToken,
          },
          body: payload);

      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        if (resp["success"]) {
          data = StatementModal.fromJson(json.decode(response.body));
          return data;
        } else {
          final apiError = ErrorModel.fromJson(json.decode(response.body));
          return apiError;
        }
      } else {
        final apiError = ErrorModel.fromJson(json.decode(response.body));
        return apiError;
      }
    } catch (e) {
      print("Error Code : ${e.toString()}");
    }
  }
}
