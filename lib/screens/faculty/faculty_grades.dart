import 'package:flutter/material.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:intl/intl.dart';
import 'package:plm_crs_grad/screens/faculty/grades_table,.dart';
import '../../auth/auth_config.dart';
import '../../services/apiService.dart';
import '../login.dart';

class FacultyGradeContent extends StatefulWidget {
  final int facultyId;

  const FacultyGradeContent({Key? key, required this.facultyId}) : super(key: key);

  @override
  _FacultyGradeContent createState() => _FacultyGradeContent(facultyId: facultyId);
}

class _FacultyGradeContent extends State<FacultyGradeContent> {
  final int facultyId;

  _FacultyGradeContent({required this.facultyId});

  Future<void>? fetchData;

  APIService apiService = APIService();
  late List<Map<String, dynamic>> flags = [];
  late Map<String, dynamic> facultyInfo = {};
  late List<dynamic> fetchFacultyInfo = [];
  late List<dynamic> filteredFacultyClassInfo = [];
  late int totalUnits = 0;

  late int aysem;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    apiService.fetchFlags().then((flag){
      if (flag != null) {
        print(flag.first);
        setState(() {
          flags = flag;
        });

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
        if(facultyInfo['classes'] != null){
          fetchFacultyInfo = facultyInfo['classes'];
        }

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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text("GRADE SHEET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 30),
            Padding(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("A.Y. (Sem): ", style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold), ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(4),
                    height: MediaQuery.of(context).size.height * 0.06,
                    margin: EdgeInsets.fromLTRB(0, 0, 5.0, 0),
                    color: Colors.white,
                    child: SearchBar(onChanged: updateDataTable),
                  ),
                ),
              ],
            ),
              padding: EdgeInsets.fromLTRB(10.0, 0, 5.0, 0),),
            // Align(
            //   alignment: Alignment.center,
            //   child: Text(
            //     "1st Semester of SY ${aysem.toString()} - ${aysemPlus.toString()}",
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //   ),
            // ),
            const SizedBox(height: 20),
            // Visibility(visible: facultyInfo['classes'] != null,
            //   child:  Padding(child: Text(
            //     "${facultyInfo['firstName']} ${facultyInfo['lastName']}",
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            //   padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),),),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                MaterialStateColor.resolveWith((states) => Colors.red[900]!),
                headingTextStyle: TextStyle(color: Colors.white),
                border: TableBorder.all(width: 1.0),
                columns: const [
                  DataColumn(label: Text('Class')),
                  DataColumn(label: Text('Section')),
                  DataColumn(label: Text('Subject Title')),
                  DataColumn(label: Text('Schedule/Room')),
                  DataColumn(label: Text('Instructor')),
                  DataColumn(label: Text('Class List')),
                ],
                rows: (facultyInfo['classes'] as List<dynamic>?)
                    ?.map<DataRow>((data) {
                  return DataRow(
                    cells: [
                      DataCell(Text(data['subjectCode']?.toString() ?? '')),
                      DataCell(Text(" ${data['section']}" ?? '')),
                      DataCell(Text(data['subjectName'] ?? '')),
                      DataCell(Text('Day: ${data['classDay']}, Time: ${formatTime(data['timeStart'])} - ${formatTime(data['timeEnd'])} at  ${data['room']}')),
                      DataCell(Text(data['faculty']?.toString() ?? '')),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.note_alt_outlined), // Change the icon as needed
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>
                                    GradesContent(classId: data['id'])));
                          },
                        ),
                      ),
                    ],
                  );
                })?.toList() ?? [],

              ),
            ),
            // Additional container at the bottom
            const SizedBox(height: 180),
            Visibility(
              visible: fetchFacultyInfo.isEmpty,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "No data is available",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      )

    );


  }

  void updateDataTable(String searchText) {
    aysem = int.tryParse(searchText) ?? 0;
    fetchDataAsync(aysem);

    setState(() {
      if (searchText.isEmpty) {
        // If the search text is empty, show all items
        fetchFacultyInfo = facultyInfo['classes'];
      }
      // else {
      //   // Filter the visibleClassInfos based on the search text
      //   filteredFacultyClassInfo = facultyInfo['classes'].where((classInfo) {
      //     String subjectName = classInfo['subjectName'] ?? '';
      //     return subjectName.toLowerCase().contains(searchText.toLowerCase());
      //   }).toList();
      //
      //   // Only update visibleClassInfos if searchText is in the filteredClassInfos
      //   if (filteredFacultyClassInfo.isNotEmpty) {
      //     fetchFacultyInfo = filteredFacultyClassInfo;
      //     print("VISIBLE CLASS INFOS: $filteredFacultyClassInfo");
      //   }
      // }
    });
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
class SearchBar extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final Function(String) onChanged;

  SearchBar({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      child: TextField(
        controller: searchController,
        style: TextStyle(fontSize: 14.0),
        onChanged: (value){
          value;
        },
        onSubmitted: (value) {
          onChanged(value);
          print(value);// Pass the search query to the onChanged callback
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          hintText: 'e.g. 20231',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Set the default border color
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[900]!), // Change the color as needed
          ),
          prefixIcon: Icon(Icons.search, color: Colors.green[900]!,),
        ),
      ),
    );
  }

}