import 'package:aad_oauth/aad_oauth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plm_crs_grad/services/apiService.dart';
import '../../auth/auth_config.dart';
import '../login.dart';
import 'enrollment.dart';
import 'grades.dart';
import 'message.dart';

class StudentDashboardApp extends StatelessWidget {
  final int studentId; // New field to hold the student ID
  const StudentDashboardApp({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Dashboard',
      home: StudentDashboardHome(studentId: studentId),
    );
  }
}

class StudentDashboardHome extends StatefulWidget {
  final int studentId; // New field to hold the student ID
  const StudentDashboardHome({Key? key, required this.studentId}) : super(key: key);
  @override
  _StudentDashboardHomeState createState() => _StudentDashboardHomeState();
}

class _StudentDashboardHomeState extends State<StudentDashboardHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        StudDashBoardContent(studentId: widget.studentId),
        StudentEnrollmentApp(studentId: widget.studentId),
        StudentGradesApp(studentId: widget.studentId),
        StudentMessageApp(studentId: widget.studentId),
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.check_box),
            icon: Icon(Icons.check_box_outlined),
            label: 'Enrollment',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.grade),
            icon: Icon(Icons.grade_outlined),
            label: 'Grades',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.message),
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

class StudDashBoardContent extends StatefulWidget {
  final int studentId;

  const StudDashBoardContent({super.key, required this.studentId});
  @override
  _StudDashBoardContent createState() => _StudDashBoardContent(studentId: studentId);
}


class _StudDashBoardContent extends State<StudDashBoardContent> {
  final int studentId;
  _StudDashBoardContent({required this.studentId});

  Future<void>? fetchData;

  APIService apiService = APIService();
  late Map<String, dynamic> studentInfo = {};
  late List<Map<String, dynamic>> classInfos = [];
  late List<Map<String, dynamic>> classInfo = [];
  late List<Map<String, dynamic>> flags = [];
  late List<Map<String, dynamic>> userBalance = [];


  @override
  void initState() {
    super.initState();
    apiService.fetchUserInfo(widget.studentId).then((data) {
      setState(() {
        studentInfo = data;
      });
    });

    apiService.fetchFlags().then((flag){
      if (flag != null) {
          print(flag.first);
          setState(() {
            flags = flag;
          });
          int value = int.parse(flags.first['value']);
          if(value != null){
            fetchData = fetchDataAsync(value);

          }else {
            fetchData = Future.error('Enrollment status is 1'); // Set a completed future with an error
          }
      }
    });
    }

  Future<void> fetchDataAsync(int flagValue) async {
    try {
      print("STUDENT ID: ${widget.studentId}");
      print("FLAGS VALUE: $flagValue");
      classInfo = await apiService.fetchClassEnlisted(widget.studentId, flagValue);
      userBalance = await apiService.fetchUserBalance(widget.studentId, flagValue);
      print("USER BALANCE: $userBalance");
      setState(() {
        classInfos = classInfo;
        userBalance = userBalance;
      });

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
        body: FutureBuilder(
          future: fetchData,
          builder: (context, snapshot)
          {
            if (fetchData == null) {
              // Handle the case when fetchData is null
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Future is still loading, return a loading indicator or placeholder
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!)));
            } else {
              int rowCount=0;
              int rowCount2=0;
              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity, // Maximize the width of the container
                        padding: EdgeInsets.all(9.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 3.0,
                          margin: EdgeInsets.all(10.0),
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  // Maximize the width of the title background
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red[900],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    'STATUS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: studentInfo['enrollmentStatus'] == 0
                                      ? Text(
                                    'You\'re not yet officially Enrolled for this term.',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                    ),
                                  )
                                      : Text(
                                    'You\'ve already enrolled for this term. Enjoy your classes!',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity, // Maximize the width of the container
                        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 3.0,
                          margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  // Maximize the width of the title background
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red[900],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: const Text(
                                    'STUDENT INFORMATION',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10.0, 8.0, 10.0, 8.0),
                                        child: Text(
                                          'Student ID: ${widget.studentId}',
                                          style: const TextStyle(color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        )
                                    ),
                                    Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10.0, 8.0, 10.0, 8.0),
                                        child: Text(
                                          'Student Name: ${studentInfo['firstName']} ${studentInfo['middleName']} ${studentInfo['lastName']}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        )
                                    ),
                                    Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10.0, 8.0, 10.0, 8.0),
                                        child: Text(
                                          'Student Email : ${studentInfo['emailAddress']}',
                                          style: const TextStyle(color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        )
                                    ),
                                    Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10.0, 8.0, 10.0, 8.0),
                                        child: Text(
                                          'Contact No. : ${studentInfo['contactNumber']}',
                                          style: const TextStyle(color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        )
                                    ),
                                  ],
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity, // Maximize the width of the container
                        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 3.0,
                          margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  // Maximize the width of the title background
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red[900],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: const Text(
                                    'ENLISTED CLASS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Loop through classInfos and create Text widgets for each class
                                    for (var classInfo in classInfos)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                10.0, 8.0, 10.0, 8.0),
                                            child: Text(
                                              '${classInfo['subjectName']}',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                10.0, 8.0, 10.0, 8.0),
                                            child: Text(
                                              'Day: ${classInfo['classDay']}, Time: ${formatTime(
                                                  classInfo['timeStart'])} - ${formatTime(
                                                  classInfo['timeEnd'])} at  ${classInfo['room']}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity, // Maximize the width of the container
                        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 3.0,
                          margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  // Maximize the width of the title background
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red[900],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: const Text(
                                    'PAYMENT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('Payment Term ')),
                                          DataColumn(label: Text('Total Amount')),
                                          DataColumn(label: Text('Overall Balance')),
                                          DataColumn(label: Text('Amount to be paid for this sem')),
                                        ],
                                        rows: userBalance.map<DataRow>((
                                            userBalances) {
                                          // Extract relevant information from classInfo
                                          // String classSection = "${userBalances['payments']['paymentPartial']}";
                                          int itemCount = userBalances['payments']
                                              .length;
                                          String paymentType = " ";
                                          switch (itemCount) {
                                            case 1:
                                              paymentType = "One Time Payment";
                                              break;
                                            case 2:
                                              paymentType = "Two Partial Payment";
                                              break;
                                            case 3:
                                              paymentType = "Three Partial Payment";
                                              break;
                                            case 4:
                                              paymentType = "Four Partial Payment";
                                              break;
                                            case 5:
                                              paymentType = "Five Partial Payment";
                                              break;
                                            default:
                                              break;
                                          }

                                          double totalAmount = double.parse(userBalances['totalAmount'].toString());
                                          double balance = double.parse(userBalances['balance'].toString());
                                          double payments = double.parse(userBalances['payments'][0]['amount'].toString());
                                              // .isNotEmpty
                                              // ? userBalances['payments'][0]['amount']
                                              // .toString()
                                              // : 'N/A';

                                          return DataRow(
                                            cells: [
                                              DataCell(Text(paymentType ?? "")),
                                              DataCell(Text(totalAmount.toString()?? "")),
                                              DataCell(Text(balance.toString()?? "")),
                                              DataCell(Text(payments.toString()?? "")),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    )

                                  ],
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        width: double.infinity, // Maximize the width of the container
                        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 3.0,
                          margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  // Maximize the width of the title background
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red[900],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: const Text(
                                    'PAYMENT HISTORY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('No.')),
                                          DataColumn(label: Text('Paid Installment ')),
                                          DataColumn(label: Text('Year Term')),
                                          DataColumn(label: Text('Date Paid')),
                                          DataColumn(label: Text('Paid Amount')),
                                          DataColumn(label: Text('Excess')),
                                          DataColumn(label: Text('Status')),
                                        ],

                                        rows: userBalance.isNotEmpty
                                            ? userBalance[0]['payments'].map<DataRow>((userBalances) {
                                          rowCount++;
                                          // Your DataRow creation logic here
                                          int itemCount = userBalances['paymentPartial'];
                                          String classSection = " ";
                                          switch (itemCount) {
                                            case 1:
                                              classSection = "1st Payment";
                                              break;
                                            case 2:
                                              classSection = "2nd Payment";
                                              break;
                                            case 3:
                                              classSection = "3rd Payment";
                                              break;
                                            case 4:
                                              classSection = "4th Payment";
                                              break;
                                            case 5:
                                              classSection = "5th Payment";
                                              break;
                                            default:
                                              break;
                                          }

                                          String status = userBalances['status'];
                                          String statusLong = " ";
                                          switch (status) {
                                            case "B":
                                              statusLong = "Billed";
                                              break;
                                            case "P":
                                              statusLong = "Paid";
                                              break;
                                            case "V":
                                              statusLong = "Void";
                                              break;
                                            default:
                                              break;
                                          }

                                          return DataRow(
                                            cells: [
                                              DataCell(Text(rowCount.toString())),
                                              DataCell(Text(classSection)),
                                              DataCell(Text(userBalance.first['aysem'].toString())),
                                              DataCell(Text(userBalances['paidDate'] != null ? userBalances['paidDate'] : "N/A")),
                                              DataCell(Text(double.parse(userBalances['amount'].toString()).toString())),
                                              DataCell(Text(userBalances['excess'] != null ? double.parse(userBalances['excess'].toString()).toString() : "0.00")),
                                              DataCell(Text(statusLong)),
                                            ],
                                          );
                                        }).toList()
                                            : <DataRow>[], // Return an empty list if userBalance is empty

                                      ),
                                    )
                                  ],
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        width: double.infinity, // Maximize the width of the container
                        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 3.0,
                          margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  // Maximize the width of the title background
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red[900],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: const Text(
                                    'ASSESSMENT HISTORY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('No.')),
                                          DataColumn(label: Text('Year/Term')),
                                          DataColumn(label: Text('Total Tuition')),
                                          DataColumn(label: Text('Paid Amount')),
                                          DataColumn(label: Text('Balance')),
                                        ],
                                        rows: userBalance.map<DataRow>((
                                            userBalances) {
                                          rowCount2++;
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(rowCount2.toString())),
                                              DataCell(Text(userBalances['aysem'].toString())),
                                              DataCell(Text(double.parse(userBalances['totalAmount'].toString()).toString())),
                                              DataCell(Text(userBalances['paidAmount'] != null ? double.parse(userBalances['paidAmount'].toString()).toString() : "0.0")),
                                              DataCell(Text(double.parse(userBalances['totalAmount'].toString()).toString())),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    )

                                  ],
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10,)
                    ],
                  ),
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




