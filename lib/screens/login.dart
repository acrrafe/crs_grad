import 'package:aad_oauth/aad_oauth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:microsoft_graph_api/microsoft_graph_api.dart';
import 'package:microsoft_graph_api/models/models.dart';
import 'student/student_dashboard.dart';
import '../auth/auth_config.dart';
import '../services/apiService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UserApp());
}
class UserApp extends StatelessWidget {
  const UserApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PLM CRS GRAD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red[900]!),
        useMaterial3: true,
        textTheme: TextTheme(
          titleLarge: TextStyle(color: Colors.red[900]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[900]!), // Button color
          ),
        ),

      ),
      home: const UserHomePage(title: 'GRADUATE SCHOOL PROGRAMS'),
      navigatorKey: navigatorKey,
    );
  }
}

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<UserHomePage> createState() => UserHomePageState();
}

class UserHomePageState extends State<UserHomePage> {
  // Initialize AadOauth from Azure
  final AadOAuth oauth = AadOAuth(config);
  APIService apiService = APIService();

  @override
  void initState() {
    super.initState();
    checkCachedAccountInformation();
  }

  Future<void> checkCachedAccountInformation() async {
    var checkHashVal = await hasCachedAccountInformation();
    var accessToken = await oauth.getAccessToken();
    final graphAPI = MSGraphAPI(accessToken!);
    final User userInfo = await graphAPI.me.fetchUserInfo();
    Map<String, dynamic> data = await apiService.fetchData(userInfo.mail!);
    if (checkHashVal) {
      if (data['userType'] != null &&
          data['emailAddress'] != null &&
          data['studentId'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StudentDashboardApp(studentId: data['studentId']),
          ),
        );
      } else if (data['userType'] == 'faculty') {
        // Gayahin mo lang din ung sa if pero lagay mo ung sarili mong path
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: checkCachedAccountInformation(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a circular progress indicator while waiting for the future to complete
              return CircularProgressIndicator();
            }  else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 120),
                  Image.asset(
                    'images/plm_logo.png',
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'WELCOME TO CRS \n   GSP HARIBON!',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.52, // Will take 50% of screen space
                    child: ElevatedButton(
                      onPressed: () {
                        login(false);
                      },
                      child: Text(
                        'Login${kIsWeb ? ' (web popup)' : ''}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  if (kIsWeb)
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.52, // Will take 50% of screen space
                      child: ElevatedButton(
                        onPressed: () {
                          login(true);
                        },
                        child: Text(
                          'Login(web popup)',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
}
  // Login Function
  void login(bool redirect) async {
    config.webUseRedirect = redirect;
    final result = await oauth.login();
    result.fold(
          (errorMessage) => showError(errorMessage.toString()),
          (token) async {
            showAlertDialog(context);
        var accessToken = await oauth.getAccessToken();
        await fetchUserProfile(accessToken!);
      },
    );
  }
  // Fetch User Profile by passing the token generated by microsoft
  Future<void> fetchUserProfile(String accessToken) async {
    try {
      final graphAPI = MSGraphAPI(accessToken);
      final User userInfo = await graphAPI.me.fetchUserInfo();
      Map<String, dynamic> data = await apiService.fetchData(userInfo.mail!);

      if (data['userType'] != null && data['emailAddress'] != null && data['studentId'] != null) {
        if(data['userType'] == 'student'){
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)
          => StudentDashboardApp(studentId: data['studentId'])));
        }else if(data['userType'] == 'faculty'){
          // Gayahin mo lang ung loob ng if, ibahin mo lang kung saang activity mo idadirect
          /*
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)
                    => FacultyDashBoard App(studentId: data['studentId'])));  // Name ng Class mo sa ibang activity
           */
        }else{
          showMessage('Your Account is not registered!');
        }
      } else {
        showMessage('One or more required values (userType, emailAddress, studentId) are null, unable to navigate to the student dashboard');
      }
    } catch (e) {
      showError('Error fetching user details: $e');
    }
  }
  // Check Session
  Future<bool> hasCachedAccountInformation() async {
    var hasCachedAccountInformation = await oauth.hasCachedAccountInformation;
    return hasCachedAccountInformation;
  }

  // Show Messages
  void showError(dynamic ex) {
    showMessage(ex.toString());
  }
  void showMessage(String text) {
    var alert = AlertDialog(
      content: Text(text),
      actions: <Widget>[
        TextButton(
          child: Text('Ok', style: TextStyle(color: Colors.red[900]!),),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            backgroundColor: Colors.white,
          ),
          child: Material(type: MaterialType.transparency, child: alert,),
        );
      },
    );
  }
  // Loading for checking the email if it is exisiting in the database
  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          Container(
            margin: EdgeInsets.only(left: 12),
            child: Text("Loading", style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            primaryColor: Colors.red[900],
            textTheme: TextTheme(
              bodyText1: TextStyle(color: Colors.black),
            ),
          ),
          child: alert,
        );
      },
    );
  }


}
