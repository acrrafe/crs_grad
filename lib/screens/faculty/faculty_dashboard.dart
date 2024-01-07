import 'package:aad_oauth/aad_oauth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plm_crs_grad/screens/faculty/faculty_teaching.dart';
import '../../auth/auth_config.dart';
import '../../services/apiService.dart';
import '../login.dart';
import 'faculty_grades.dart';
import 'faculty_profile.dart';


class FacultyDashBoardApp extends StatelessWidget {
  final int facultyId; // New field to hold the student ID
  const FacultyDashBoardApp({Key? key, required this.facultyId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Dashboard',
      home: FacultyDashBoardHome(facultyId: facultyId),
    );
  }
}

class FacultyDashBoardHome extends StatefulWidget {
  final int facultyId; // New field to hold the student ID
  const FacultyDashBoardHome({Key? key, required this.facultyId}) : super(key: key);
  @override
  _FacultyDashBoardHomeState createState() => _FacultyDashBoardHomeState();
}

class _FacultyDashBoardHomeState extends State<FacultyDashBoardHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        FacDashBoardContent(facultyId: widget.facultyId),
        FacultyGradeContent(facultyId: widget.facultyId),
        TeachingAssessmentContent(facultyId: widget.facultyId),
        FacultyProfileContent(facultyId: widget.facultyId),
      ][_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Set to fixed
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue[900], // Color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        selectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye_outlined),
            activeIcon: Icon(Icons.remove_red_eye),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.note_alt_rounded),
            icon: Icon(Icons.note_alt_outlined),
            label: 'Grades',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.work_history),
            icon: Icon(Icons.work_history_outlined),
            label: 'Teaching',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.person),
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class FacDashBoardContent extends StatefulWidget {
  final int facultyId;

  const FacDashBoardContent({Key? key, required this.facultyId}) : super(key: key);

  @override
  _FacDashBoardContent createState() => _FacDashBoardContent(facultyId: facultyId);
}

class _FacDashBoardContent extends State<FacDashBoardContent> {
  final int facultyId;

  _FacDashBoardContent({required this.facultyId});

  Future<void>? fetchData;

  APIService apiService = APIService();
  late List<Map<String, dynamic>> flags = [];
  late Map<String, dynamic> facultyInfo = {};
  late int totalUnits = 0;

  @override
  void initState() {
    super.initState();

    apiService.fetchFlags().then((flag){
      if (flag != null) {
        print(flag.first);
        setState(() {
          flags = flag;
        });
        int value = int.parse(flags.first['value']);
        if(value != null){
          fetchData = fetchDataAsync(value);
        }
      }
    });
  }

  Future<void> fetchDataAsync(int flagValue) async {
    try {
      print("STUDENT ID: ${widget.facultyId}");
      print("FLAGS VALUE: $flagValue");
      facultyInfo = await apiService.fetchFacultyClass(widget.facultyId, flagValue);
      print("USER BALANCE: $facultyInfo");

      setState(() {
        facultyInfo = facultyInfo;
      });

      for (Map<String, dynamic> data in facultyInfo['classes'] as List<
          dynamic>) {
        totalUnits += (data['subjectUnits'] as int?) ?? 0;
      }

    } catch (error) {
      // Handle errors here
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "",
        onMenuPressed: () {},
      ),
      body:  FutureBuilder(
        future: fetchData,
        builder: (context, snapshot)
        {if (fetchData == null) {
          // Handle the case when fetchData is null
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Future is still loading, return a loading indicator or placeholder
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!)));
        } else {
          String aysem = flags.first['value'].toString().substring(0,4);
          int aysemPlus = int.parse(aysem) + 1;
          int currSem = int.parse(flags.first['value'].toString()[4]);
          String currSemWhole = "";
          if (currSem == 1) {
            currSemWhole = '${currSem}st Semester';
          } else if (currSem == 2) {
            currSemWhole = '${currSem}nd Semester';
          } else if (currSem == 3) {
            currSemWhole = '${currSem}rd Semester';
          } else if (currSem == 4) {
            currSemWhole = '${currSem}th Semester';
          } else {
            currSemWhole = '${currSem}th Semester';
          }

          print("FACULTY INFO $facultyInfo}");
          return Scaffold(
            body: Column(
              children: [
                const SizedBox(height: 60),
                Text(
                  "$currSemWhole of SY ${aysem.toString()} - ${aysemPlus.toString()}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20,),
                // Horizontally scrollable DataTable
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                    MaterialStateColor.resolveWith((states) => Colors.red[900]!),
                    headingTextStyle: TextStyle(color: Colors.white),
                    border: TableBorder.all(width: 1.0),
                    columns: const [
                      DataColumn(label: Text('Class Code')),
                      DataColumn(label: Text('Course Code & Section')),
                      DataColumn(label: Text('Course Title')),
                      DataColumn(label: Text('Class Schedule')),
                      DataColumn(label: Text('Credits')),
                    ],
                    rows: facultyInfo['classes'].map<DataRow>((data) {
                      return DataRow(
                        cells: [
                          DataCell(Text(data['id'].toString() ?? '')),
                          DataCell(Text("${data['subjectCode'].toString()} - ${data['section'].toString()} " ?? '')),
                          DataCell(Text(data['subjectName'].toString() ?? '')),
                          DataCell(Text('Day: ${data['classDay']}, Time: ${formatTime(data['timeStart'])} - ${formatTime(data['timeEnd'])} at  ${data['room']}')),
                          DataCell(Text(data['subjectUnits'].toString() ?? '')),
                        ],
                      );
                    })?.toList() ?? [],
                  ),
                ),
                // Additional container at the bottom
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.black),
                      right: BorderSide(width: 1.0, color: Colors.black),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(width: 1.0, color: Colors.black),
                          ),
                        ),
                        child: Text('Total No. of Credits: '),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Text(totalUnits.toString()),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          );
        }
        },
      ),
    );



  }
}

String formatTime(String time) {
  if (time != null && time.isNotEmpty) {
    DateTime dateTime = DateTime.parse("2023-01-01 $time");
    return DateFormat('hh:mm a').format(dateTime);
  } else {
    return '';
  }
}


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuPressed;

  final AadOAuth oauth = AadOAuth(config);

  CustomAppBar({super.key,
    required this.title,
    required this.onMenuPressed,
  });
  @override
  Size get preferredSize => const Size.fromHeight(56.0);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      // title: Text(
      //   title,
      //   style: TextStyle(color: Colors.black), // Set text color
      // ),
      backgroundColor: Colors.white,
      elevation: 0.0, // Remove the shadow
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(2.0),
        child: Container(
          color: Colors.yellow, // Yellow line color
          height: 5.0, // Set the thickness of the yellow line
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'images/plm_logo.png', // Replace with your image asset path
            height: 50.0, // Set the height of the image
            width: 50.0,
          ),
        ),
      ],
      leading: IconButton(
        icon: Icon(Icons.logout), // Burger menu icon
        onPressed: (){
          showLogoutConfirmationDialog(context);
        },
        color: Colors.black, // Set icon color
      ),
    );
  }

  void logout() async {
    await oauth.logout();
    // You can perform additional actions after logout if needed
  }

  Future<void> showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                logout();
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const UserHomePage(title: "GRADUATE SCHOOL PROGRAMS")),
                );
              },
            ),
          ],
        );
      },
    );
  }
}







