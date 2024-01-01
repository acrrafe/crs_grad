import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

  // Get the studentId from Users and use that to fetch the users information
  Future<Map<String, dynamic>> updateStudentEnrollment(int studentId) async {
    var userLog = "students/$studentId"; // Path na icoconnect sa main path
    var apiURL = "$mobileURL$userLog";
    var url = Uri.parse(apiURL);

    final requestData = {
      'enrollmentStatus': 1,
    };

    print("REQUEST DATA: $requestData");
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse;

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

  // Get the information of the classes based on the current semester
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

  // Get the information of the enlisted classes of a specific enrolled student
  Future<List<Map<String, dynamic>>> fetchClassEnlisted(int studentId, int aysem) async {
    var userLog = "students/$studentId?class-infos?aysem[eq]=$aysem"; // Class Infos Path icoconnect sa main path
    var apiURL = "$mobileURL$userLog";
    var url = Uri.parse(apiURL);
    print("URL: $apiURL");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('data')) {
        print("JSON RESPONSE: $jsonResponse");
        final List<dynamic> dataList = jsonResponse['data']['class_infos'];
        final List<Map<String, dynamic>> resultList = [];

        final collegeLong = jsonResponse['data']['collegeLong'];

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
          final load = data['load'] ?? '';

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
            'collegeLong': collegeLong,
            'section': section,
            'maxSlots': maxSlots,
            'enrolledSlots': enrolledSlots,
            'withDateRange': withDateRange,
            'dateStart': dateStart,
            'dateEnd': dateEnd,
            'aysem': aysem,
            'load': load,
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

  // Get the information of the enrolled students and save it in the class infos database
  Future<Map<String, dynamic>> addStudentClassInfo(int studentId, List<Map<String, dynamic>> selectedClasses) async {
    List<int> studentsId = [studentId];
    List<Map<String, dynamic>> responses = [];

    print("Processing selected class: $selectedClasses");

    for (Map<String, dynamic> selectedClass in selectedClasses) {
      var selectedClassesId = selectedClass['id'];
      print("SELECTED CLASSES ID: $selectedClassesId");
      var userLog = "class-infos/$selectedClassesId";
      var apiURL = "$mobileURL$userLog";
      print("URL: $apiURL");

      var url = Uri.parse(apiURL);

      final requestData = {
        'enrolledSlots': selectedClass['enrolledSlots'] + 1,
        'studentsId': studentsId,
      };

      print("REQUEST DATA: $requestData");
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      final jsonResponseEncode = json.encode(requestData);
      print("JSONENCODE $jsonResponseEncode");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        responses.add(jsonResponse);
      } else {
        print("Failed to add data. Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        throw Exception('Failed to add data');
      }
    }

    return {'responses': responses};
  }

  // Get the information of the enrolled students and save it in the balance database
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
  Future<List<Map<String, dynamic>>> fetchUserBalance(int studentId) async {
    var userLog = "balances?studentId[eq]=$studentId"; // Path na icoconnect sa main path
    var apiURL = "$mobileURL$userLog";
    var url = Uri.parse(apiURL);
    final response = await http.get(url);

    final List<Map<String, dynamic>> resultList = [];

    print(response.body);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // Check if 'data' is a List and not empty
      if (jsonResponse['data'] is List && jsonResponse['data'].isNotEmpty) {
        final List<dynamic> dataList = jsonResponse['data'];

        for (final data in dataList) {
          final totalAmount = data['totalAmount'];
          final paidAmount = data['paidAmount'];
          final excess = data['excess'];
          final balance = data['balance'];
          final aysem = data['aysem'];
          final List<dynamic> payments = data['payments'];


            final data2 = {
              'totalAmount': totalAmount,
              'paidAmount': paidAmount,
              'excess': excess,
              'balance': balance,
              'aysem': aysem,
              'payments': payments,
            };
          resultList.add(data2);
        }
        return resultList;

      } else {
        throw Exception('Data not found or is in an unexpected format');
      }
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  // Get the information of the graded classes of a specific student
  Future<List<Map<String, dynamic>>> fetchStudentGrades(int studentId, int aysem) async {
    var userLog = "grades?studentId[eq]=$studentId&aysem[eq]=$aysem"; // Class Infos Path icoconnect sa main path
    var apiURL = "$mobileURL$userLog";
    var url = Uri.parse(apiURL);
    print("URL: $apiURL");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('data')) {
        print("JSON RESPONSE: $jsonResponse");
        final List<dynamic> dataList = jsonResponse['data'];
        final List<Map<String, dynamic>> resultList = [];

        for (final data in dataList) {
          final id = data['id'];
          final studentId = data['studentId'];
          final classInfoId = data['classInfoId'];
          final grade = data['grade'];
          final name = data['name'];
          final program = data['program'];
          final college = data['college'];
          final subjectName = data['subjectName'];
          final subjectCode = data['subjectCode'];
          final subjectUnits = data['subjectUnits'];
          final aysem = data['aysem'];

          final data2 = {
            'id': id,
            'studentId': studentId,
            'classInfoId': classInfoId,
            'subjectName': subjectName,
            'grade': grade,
            'name': name,
            'program': program,
            'college': college,
            'subjectCode': subjectCode,
            'subjectUnits': subjectUnits,
            'aysem': aysem,
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

  // Get the studentId from Users and use that to fetch the users information
  Future <List<Map<String, dynamic>>> fetchUserMessages(int studentId) async {
    var userLog = "notifications?studentId[eq]=$studentId"; // Path na icoconnect sa main path
    var apiURL = "$mobileURL$userLog";
    var url = Uri.parse(apiURL);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      final List<dynamic> dataList = jsonResponse['data'];
      final List<Map<String, dynamic>> resultList = [];
      for (final data in dataList) {

        final id = data['id'];
        final title = data['title'];
        final description = data['description'];
        final dateString = data['date'];

        // final dateTime = DateTime.parse(dateString);
        // final formattedDate = DateFormat('h:mm a MMM dd, yyyy').format(dateTime);

        final data2 = {
          'id': id,
          'title': title,
          'description': description,
          'date': dateString,
        };
        print("JSON RESPONSE: $jsonResponse");
        print("DATA: $resultList");
        resultList.add(data2);
      }
      return resultList;


    } else {
      throw Exception('Failed to fetch data');

    }
  }



}