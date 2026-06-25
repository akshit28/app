class ApiConstants {
  // static String baseUrl = 'https://gateway.tangentup.com';
  // static String mqttUrl = 'mqtt.tangentup.com';
  // static String baseUrl1 = 'https://gateway.tangentup.com';
  static String baseUrl = 'https://gateway.cytocloud.com';
  static String mqttUrl = 'mqtt.cytocloud.com';
  static String baseUrl1 = 'https://gateway.cytocloud.com';
  static String loginEndpoint = '/auth/login/';
  static String addPatient = '/patient/upsert/';
  static String patientList = '/patient/list/';
  static String userFacilities = '/user/facilities/';
  static String deviceList = '/device/list/';
  static String testGroups = '/test/groups/';
  static String testList = '/test/list/';
  static String newScanQueue = '/scan/queue/';
  static String testScanList = '/scan/list/';
  static String cancelScan = '/scan/cancel/';
  static String continueScan = '/scan/continue/';
  static String kitValdation = '/validate/kit/';
  static String forwarder = '/forwarder/';
  static String verifyToken = '/auth/verify-token/';
  static String getMenu = '/menu-item/get/';
  static String commands = '/device/command/all/';
  static String commandQueue = '/device/command/queue/';
  static String commandHistory = '/device/command/history/';
  static String commandCancel = '/device/command/cancel/';
}
