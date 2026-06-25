import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:aap/util/snackbar.dart';
import 'package:aap/services/commands_service.dart';
import 'package:aap/util/confirmDialog.dart';

class CommandHistory extends StatefulWidget {
  const CommandHistory({super.key});

  @override
  State<CommandHistory> createState() => _CommandHistoryState();
}

class _CommandHistoryState extends State<CommandHistory> {
  List item = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchCommandList('init');
  }

  fetchCommandList(String call) async {
    loading = true;
    setState(() {});
    var command = CommandService();
    var payload = {};
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    if (call == "init") {
      item.clear();
      payload['deviceId'] = "";
      payload["endDate"] = now.toIso8601String().toString();
      payload["pageNum"] = 1;
      payload["rowCount"] = 20;
      payload["startDate"] = yesterday.toIso8601String().toString();
    }

    var response = await command.commandsList(payload);

    if (response.success) {
      item.addAll(response.data.rows);
    } else {

    }
    loading = false;
    setState(() {});
  }

  showCancelDialog(BuildContext context, String deviceCommandId) {
    String title = "Cancel";
    String content = "Are you sure you want to cancel command.";
    continueCallBack() =>
        {Navigator.of(context).pop(), cancelCommand(context, deviceCommandId)};

    cancelCallBack() => {
          Navigator.of(context).pop(),
        };
    ConfirmBox alert = ConfirmBox(
        title: title,
        content: content,
        continueCallBack: continueCallBack,
        cancelCallBack: cancelCallBack);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  cancelCommand(BuildContext context, String deviceCommandId) async {
    var resp = await CommandService().cancelCommand(deviceCommandId);

    if (resp == true) {
      if (mounted) {
        const CustomSnackBar(
                seconds: 2, text: 'Command cancelled.', type: 'success')
            .show(context);
        fetchCommandList('init');
      }
    } else {
      if (mounted) {
        const CustomSnackBar(
                seconds: 2,
                text: 'Error occured while cancelling command.',
                type: 'error')
            .show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.blue,
        title: const Text("Commands List"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          loading && item.isEmpty ? const Padding(
                      padding: EdgeInsets.fromLTRB(15, 40, 15, 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                    ) : const SizedBox.shrink(),
          Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: item.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 7),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                RichText(
                                  text: TextSpan(
                                      text: 'Device: ',
                                      style:
                                          const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: item[index].deviceName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        )
                                      ]),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: 'Command: ',
                                      style:
                                          const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          // text: "${item[index].externalSampleId} ----- ${index+1}",
                                          text: item[index].deviceCommandName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        )
                                      ]),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: 'Requested By: ',
                                      style:
                                          const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: item[index].requestedBy,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        )
                                      ]),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: 'Requested On: ',
                                      style:
                                          const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: DateFormat("dd-MM-yy HH:mm:ss")
                                              .format(DateTime.parse(
                                                      item[index].requestedOn)
                                                  .toLocal()),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        )
                                      ]),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: 'Updated On: ',
                                      style:
                                          const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: DateFormat("dd-MM-yy HH:mm:ss")
                                              .format(DateTime.parse(
                                                      item[index].updatedOn)
                                                  .toLocal()),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        )
                                      ]),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: 'Response: ',
                                      style:
                                          const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: item[index].response,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        )
                                      ]),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: 'Status: ',
                                      style:
                                          const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: item[index].status,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        )
                                      ]),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Spacer(),
                                    Wrap(
                                      spacing: 2.0,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        Visibility(
                                            visible:
                                                item[index].isCancelledAllowed,
                                            child: TextButton(
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              onPressed: () {
                                                showCancelDialog(
                                                    context,
                                                    item[index]
                                                        .deviceCommandId);
                                              },
                                            ))
                                      ],
                                    )
                                  ],
                                )
                              ],
                            )),
                      ),
                    );
                  }))
        ],
      ),
    );
  }
}
