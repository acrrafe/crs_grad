import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  // Main Route or Path, need nalang iconnect ung mga pang request
  String mobileURL = "https://mobile-crs-api.raphaelenciso.com/api/";

  // Get the email from microsoft login and fetch the data of the user
  Future<Map<String, dynamic>> fetchData(String email) async {
    var userLog = "users?emailAddress[eq]=$email"; // Users Path icoconnect sa main path
    var apiURL = "$mobileURL$userLog";
    var url = Uri.parse(apiURL);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final firstDataObject = jsonResponse['data'][0];
      final userType = firstDataObject['userType'];
      final emailAddress = firstDataObject['emailAddress'];
      final studentId = firstDataObject['studentId'];

      final data = {
        'userType': userType,
        'emailAddress': emailAddress,
        'studentId': studentId,
      };
      return data;

    } else {
      throw Exception('Failed to fetch data');

    }
  }

  // Get the studentId from Users and use that to fetch the users information
  Future<Map<String, dynamic>> fetchUserInfo(int studentId) async {
    var userLog = "students/$studentId"; // Path na icoconnect sa main path
    var apiURL = "$mobileURL$userLog";
    var url = Uri.parse(apiURL);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final firstDataObject = jsonResponse['data'];
      final userType = firstDataObject['userType'];
      final emailAddress = firstDataObject['emailAddress'];
      final program = firstDataObject['program'];
      final college = firstDataObject['college'];
      final status = firstDataObject['status'];
      final firstName = firstDataObject['firstName'];
      final middleName = firstDataObject['middleName'];
      final lastName = firstDataObject['lastName'];
      final contactNumber = firstDataObject['contactNumber'];
      final address = firstDataObject['address'];
      final birthDate = firstDataObject['birthDate'];
      final year = firstDataObject['year'];
      final enrollmentStatus = firstDataObject['enrollmentStatus'];


      final data = {
        'userType': userType,
        'emailAddress': emailAddress,
        'studentId': studentId,
        'program': program,
        'college': college,
        'status': status,
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'contactNumber': contactNumber,
        'address': address,
        'birthDate': birthDate,
        'year': year,
        'enrollmentStatus': enrollmentStatus,

      };
      return data;

    } else {
      throw Exception('Failed to fetch data');

    }
  }

  // Get the email from microsoft login and fetch the data of the user
  Future<List<Map<String, dynamic>>> fetchFlags() async {
    var userLog = "flags"; // Flag Path icoconnect sa main path
    var apiURL = "$mobileURL$userLog";

    final List<Map<String, dynamic>> resultList = [];

    var url = Uri.parse(apiURL);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final dataObjects = jsonResponse['data'];

      for (var dataObject in dataObjects) {
        final id = dataObject['id'];
        final name = dataObject['name'];
        final value = dataObject['value'];

        final data = {
          'id': id,
          'name': name,
          'value': value,
        };
        resultList.add(data);
      }

      return resultList;
    } else {
      throw Exception('Failed to fetch data');
    }
  }


  Future<List<Map<String, dynamic>>> fetchClassInfos(int aysem) async {
    var userLog = "class-infos?aysem[eq]=$aysem"; // Class Infos Path icoconnect sa main path
    var apiURL = "$mobileURL$userLog";
    var url = Uri.parse(apiURL);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('data')) {
        final List<dynamic> dataList = jsonResponse['data'];
        final List<Map<String, dynamic>> resultList = [];

        for (final data in dataList) {
          final id = data['id'];
          final subjectName = data['subjectName'];
          final subjectCode = data['subjectCode'];
          final subjectUnits = data['subjectUnits'];
          final collegeId = data['collegeId'];
          final faculty = data['faculty'];
          final room = data['room'];
          final classType = data['classType'];
          final classDay = data['classDay'];
          final timeStart = data['timeStart'];
          final timeEnd = data['timeEnd'];
          final meetingType = data['meetingType'];
          final program = data['program'];
          final section = data['section'];
          final maxSlots = data['maxSlots'];
          final enrolledSlots = data['enrolledSlots'];
          final withDateRange = data['withDateRange'];
          final dateStart = data['dateStart'];
          final dateEnd = data['dateEnd'];
          final aysem = data['aysem'];
          final studentsList = List<Map<String, dynamic>>.from(data['students'] ?? []);

          final data2 = {
            'id': id,
            'subjectName': subjectName,
            'subjectCode': subjectCode,
            'subjectUnits': subjectUnits,
            'collegeId': collegeId,
            'faculty': faculty,
            'room': room,
            'classType': classType,
            'classDay': classDay,
            'timeStart': timeStart,
            'timeEnd': timeEnd,
            'meetingType': meetingType,
            'program': program,
            'section': section,
            'maxSlots': maxSlots,
            'enrolledSlots': enrolledSlots,
            'withDateRange': withDateRange,
            'dateStart': dateStart,
            'dateEnd': dateEnd,
            'aysem': aysem,
            'students': studentsList,
          };

          resultList.add(data2);
        }

        print("JSON RESPONSE: $jsonResponse");
        print("DATA: $resultList");
        return resultList;
      }
    }

    throw Exception('Failed to fetch data');
  }


  Future<Map<String, dynamic>> addBalance(int studentId, double totalAmount, double balance, int paymentpPartials, String program, String aysem) async {
    var userLog = "balances"; // Users Path icoconnect sa main path
    var apiURL = "$mobileURL$userLog";
    print("URL: $apiURL");
    var url = Uri.parse(apiURL);
    final requestData = {
      'studentId': studentId,
      'totalAmount': totalAmount,
      'balance': balance,
      'paymentPartials': paymentpPartials,
      'program': program,
      'aysem': aysem,
    };
    print("REQUEST DATA: $requestData");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestData),
    );

    final jsonResponseEncode = json.encode(requestData);
    print("JSONENCODE $jsonResponseEncode");
    if (response.statusCode == 201) {
      // Process successful response
      final jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      // Handle the error case
      print("Failed to add data. Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      throw Exception('Failed to add data');
    }

  }

  // Get the studentId from Users and use that to fetch the users information
  Future<Map<String, dynamic>> fetchUserBalance(int studentId) async {
    var userLog = "balances?studentId[eq]=$studentId"; // Path na icoconnect sa main path
    var apiURL = "$mobileURL$userLog";
    var url = Uri.parse(apiURL);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final firstDataObject = jsonResponse['data'];
      final totalAmount = firstDataObject['totalAmount'];
      final paidAmount = firstDataObject['paidAmount'];
      final excess = firstDataObject['excess'];
      final balance = firstDataObject['balance'];
      final aysem = firstDataObject['aysem'];
      final List<Map<String, dynamic>> payments = firstDataObject['payments'];

      final data = {
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'excess': excess,
        'balance': balance,
        'aysem': aysem,
        'payments': payments,
      };
      return data;

    } else {
      throw Exception('Failed to fetch data');

    }
  }


}