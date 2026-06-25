import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:aap/constants/constants.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

class MqttManager {
  MqttClient? client;
  // MqttBrowserClient? client;
  // String clientId;
  String brokerAddress;
  int brokerPort;

  StreamController<String> messageStreamController = StreamController<String>.broadcast();
  Stream<String> get messageStream => messageStreamController.stream;


  getClientId() {
    var rng = Random();
    return 'argus_client_${rng.nextInt(99999999)}';
  }

  bool isConnected = false;
  MqttManager(this.brokerAddress, this.brokerPort);

  bool get connected => isConnected;
  // final MqttClient client = MqttClient('mqtt://mqtt.tangentup.com:9001', 'your_client_id');

  Future<void> connect() async {

    //mqtt for web
    // client = MqttBrowserClient(Uri.parse('wss://mqtt.tangentup.com:9001').toString(), getClientId());
    // client?.port = 8083;
    // client?.setProtocolV311();


    //mqtt for app
    client = MqttServerClient(ApiConstants.mqttUrl, getClientId());
    
    client?.logging(on: false); // Enable logging for debugging (optional)

    client?.onConnected = _onConnected;
    client?.onDisconnected = _onDisconnected;
    client?.onSubscribed = _onSubscribed;
    client?.onSubscribeFail = _onSubscribeFail;
    // client?.keepAlivePeriod = 60;
    client?.connectTimeoutPeriod = 30000;
    client?.websocketProtocolString = ['wss'];
     
    // client.onUnsubscribed = _onUnsubscribed;
    // client.onUnsubscribeFail = _onUnsubscribeFail;
    client?.onAutoReconnect = _onAutoReconnect;

    // final MqttConnectMessage connMess =
    //     MqttConnectMessage().withClientIdentifier(getClientId());
    // .authenticateAs('', '');

    try {
      await client?.connect();
    } catch (e) {
      print('Error while connecting to MQTT broker: $e');
    }

    client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) { 
      // print("client?.updates?.listen ******");
      handleIncomingMessages(messages);
    });
    
    final Stream<List<MqttReceivedMessage<MqttMessage>>> incomingMessagesStream =
        client?.updates ?? Stream.empty();

    incomingMessagesStream.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      handleIncomingMessages(messages);
    });

    // client?.published?.listen((MqttPublishMessage messages) { 
    //   print("client?.published?.liste ********");
    //   final String topic = messages.variableHeader?.topicName ?? '';
    //   final String payload = MqttPublishPayload.bytesToStringAsString(messages.payload.message);

    //   print("handleIncomingMessages $topic $payload");
    //   handleIncomingMessages(messages as List<MqttReceivedMessage<MqttMessage>>);
    // });
  }

  void _onConnected() {
    print('Connected to MQTT broker');
    isConnected = true;
    // Perform any actions upon successful connection
  }

  void _onDisconnected() {
    print('Disconnected from MQTT broker');
    isConnected = false;
    // Perform any actions upon disconnection
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void _onSubscribeFail(String topic) {
    print('Failed to subscribe to topic: $topic');
  }

  void _onUnsubscribed(String topic) {
    print('Unsubscribed from topic: $topic');
  }

  void _onUnsubscribeFail(String topic) {
    print('Failed to unsubscribe from topic: $topic');
  }

  void _onAutoReconnect() {
    print('Reconnecting to MQTT broker');
    // Perform any actions on auto-reconnection
  }

  void subscribe(String topic) {
    if (isConnected) {
      client?.subscribe(topic, MqttQos.exactlyOnce);
    } else {
      print('Cannot subscribe. Not connected to MQTT broker.');
    }
  }

  void unsubscribe(String topic) {
    if (isConnected) {
      client?.unsubscribe(topic);
    } else {
      print('Cannot unsubscribe. Not connected to MQTT broker.');
    }
  }

  void publish(String topic, String message) {
    if (isConnected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      // client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
    } else {
      print('Cannot publish. Not connected to MQTT broker.');
    }
  }

  void handleIncomingMessages(List<MqttReceivedMessage<MqttMessage>> messages) {
    String payloadString = "";
    messages.forEach((MqttReceivedMessage<MqttMessage> message) {
      final MqttPublishMessage? payload = message.payload as MqttPublishMessage?;
      final String topic = message.topic;
      final String payloadString = payload != null ? MqttPublishPayload.bytesToStringAsString(payload.payload.message) : '';

      // Add the received message to the stream
      print("handleIncomingMessages $topic: $payloadString");
      // messageStreamController.add(json.decode(payloadString)['sample_id']);
      messageStreamController.add(payloadString);
    });
  }

  // void _onMessageReceived(String topic, String payload) {
  //   print('Received message from topic: $topic');
  //   print('Message: $payload');
  // }

  void disconnect() {
    if (isConnected) {
      client?.disconnect();
    }
  }
}
