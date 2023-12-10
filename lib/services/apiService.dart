import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  // Main Route or Path, need nalang iconnect ung mga pang request
  String loginURL = "https://mobile-crs-api.raphaelenciso.com/api/";

  // Get the email from microsoft login and fetch the data of the user
  Future<Map<String, dynamic>> fetchData(String email) async {
    var userLog = "users?emailAddress[eq]=$email"; // Users Path icoconnect sa main path
    var apiURL = "$loginURL$userLog";
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
    var apiURL = "$loginURL$userLog";
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
}