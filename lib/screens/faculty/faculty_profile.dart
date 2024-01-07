import 'package:aad_oauth/aad_oauth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plm_crs_grad/services/apiService.dart';
import '../../auth/auth_config.dart';
import '../login.dart';

class FacultyProfileContent extends StatefulWidget {
  final int facultyId;

  const FacultyProfileContent({super.key, required this.facultyId});
  @override
  _FacultyProfileContent createState() => _FacultyProfileContent(facultyId: facultyId);
}

class _FacultyProfileContent extends State<FacultyProfileContent> {
  final int facultyId;
  _FacultyProfileContent({required this.facultyId});

  Future<void>? fetchData;

  APIService apiService = APIService();
  late Map<String, dynamic> facultyInfo = {};


  @override
  void initState() {
    super.initState();
    fetchData = fetchDataAsync();
  }

  Future<void> fetchDataAsync() async {
    try {
      print("STUDENT ID: ${widget.facultyId}");

      facultyInfo =await apiService.fetchFacultyInfo(widget.facultyId);
      print("USER BALANCE: $facultyInfo");
      setState(() {
        facultyInfo = facultyInfo;
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
            return Scaffold(
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity, // Maximize the width of the container
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 3.0,
                        margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        child: Flexible(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(2.0, 14.0, 2.0, 10),
                            child:     Column(
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
                                    'PERSONAL DETAILS',
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10.0, 8.0, 10.0, 8.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Employee No: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${widget.facultyId}',
                                                ),
                                              ],
                                            ),
                                          ),

                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10.0, 8.0, 10.0, 8.0),

                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Birth Date: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${facultyInfo['birthDate']}',
                                                ),
                                              ],
                                            ),
                                          ),

                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10.0, 8.0, 10.0, 8.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'First Name: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${facultyInfo['firstName']}',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10.0, 8.0, 10.0, 8.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Last Name: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${facultyInfo['lastName']}',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],

                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10.0, 8.0, 10.0, 8.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Email Address: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${facultyInfo['emailAddress']}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10.0, 8.0, 10.0, 8.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Sex: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${facultyInfo['gender'] == 'M' ? 'Male' : 'Female'}',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10.0, 8.0, 10.0, 8.0),

                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Contact No: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${facultyInfo['contactNumber']}',
                                                ),
                                              ],
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
                        child: Flexible(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(2.0, 14.0, 2.0, 10),
                            child:     Column(
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
                                    'EMPLOYMENT DETAILS',
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
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'TIN No: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${facultyInfo['tinNo']}',
                                            ),
                                          ],
                                        ),
                                      ),

                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10.0, 8.0, 10.0, 8.0),

                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'GSIS No: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${facultyInfo['gsisNo']}',
                                            ),
                                          ],
                                        ),
                                      ),

                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10.0, 8.0, 10.0, 8.0),

                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Instructor Code: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${facultyInfo['instructorCode']}',
                                            ),
                                          ],
                                        ),
                                      ),

                                    ),
                                  ],
                                )

                              ],
                            ),
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
                        child: Flexible(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(2.0, 14.0, 2.0, 10),
                            child:     Column(
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
                                    'CURRENT ADDRESS',
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
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Street Address: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${facultyInfo['address']}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10.0, 8.0, 10.0, 8.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Zip Code: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${facultyInfo['zipCode']}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  ],
                                )

                              ],
                            ),
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

