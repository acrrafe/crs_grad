import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/apiService.dart';


class GradesContent extends StatefulWidget {
  final int classId;

  const GradesContent({Key? key, required this.classId}) : super(key: key);

  @override
  _GradesContent createState() => _GradesContent(classId: classId);
}

class _GradesContent extends State<GradesContent> {
  final int classId;

  _GradesContent({required this.classId});

  Future<void>? fetchData;

  APIService apiService = APIService();
  late List<Map<String, dynamic>> classInfo = [];
  late int totalUnits = 0;

  @override
  void initState() {
    super.initState();
    fetchData = fetchDataAsync(widget.classId);
  }

  Future<void> fetchDataAsync(int classId) async {
    try {
      print("STUDENT ID: ${widget.classId}");
      print("FLAGS VALUE: $classId");
      classInfo = await apiService.fetchFacultyGrades(widget.classId);
      print("USER BALANCE: $classInfo");

      setState(() {
        classInfo = classInfo;
      });

    } catch (error) {
      // Handle errors here
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white, // Set your desired background color
        appBar: const CustomAppBar(),
        body:FutureBuilder(
      future: fetchData,
      builder: (context, snapshot)
      {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Future is still loading, return a loading indicator or placeholder
        return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!)));
      } else {
        String aysem = classInfo[0]['aysem'].toString();
        int currSem = int.parse(aysem.toString()[4]);
        int rowCount = 0;
        return Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 60),
              // Horizontally scrollable DataTable
              Center(
                child:  Text(
                  "REPORT OF GRADES",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[900]),
                ),
              ),
              Visibility(
                visible: classInfo.isEmpty,
                child: const SizedBox(height: 150),
              ),
              Visibility(
                visible: classInfo.isNotEmpty,
                child: const SizedBox(height: 20),
              ),
              Visibility(
                visible: classInfo.isEmpty,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "No data is available",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Visibility(
                  visible: classInfo.isNotEmpty,
                  child:   SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        DataTable(
                          headingRowColor:
                          MaterialStateColor.resolveWith((states) => Colors.transparent!),
                          headingTextStyle: TextStyle(color: Colors.black),
                          border: TableBorder(
                            horizontalInside: BorderSide(width: 1.0),
                            verticalInside: BorderSide.none,
                            top: BorderSide(width: 1.0),
                            left: BorderSide(width: 1.0),
                            right: BorderSide(width: 1.0),
                            bottom: BorderSide.none,
                          ),
                          columns: [
                            DataColumn(
                                label: Text('COURSE CODE',
                                    style: TextStyle(color: Colors.blue[900]!))),
                            DataColumn(
                                label: Text('SUBJECT TITLE',
                                    style: TextStyle(color: Colors.blue[900]!))),
                            DataColumn(
                                label: Text('UNITS', style: TextStyle(color: Colors.blue[900]!))),
                            DataColumn(
                                label: Text('TERM/AY',
                                    style: TextStyle(color: Colors.blue[900]!))),
                          ],
                          rows: [
                            DataRow(
                              color: MaterialStateColor.resolveWith((states) => Colors.red[900]!),
                              cells: [
                                DataCell(Text(
                                  classInfo.isNotEmpty ? classInfo[0]['subjectCode'].toString() : '',
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold),
                                )),
                                DataCell(Text(
                                  classInfo.isNotEmpty ? classInfo[0]['subjectName'].toString() : '',
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold),
                                )),
                                DataCell(Text(
                                  classInfo.isNotEmpty ? classInfo[0]['subjectUnits'].toString() : '',
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold),
                                )),
                                DataCell(Text(
                                  classInfo.isNotEmpty
                                      ? "$currSem/${classInfo[0]['aysem'].toString()}"
                                      : '',
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold),
                                )),
                              ],
                            ),
                          ],
                        ),

                        DataTable(
                          headingRowColor:
                          MaterialStateColor.resolveWith((states) => Colors.grey[300]!),
                          headingTextStyle: TextStyle(color: Colors.white),
                          border: TableBorder(
                            horizontalInside: BorderSide(width: 1.0),
                            verticalInside: BorderSide(width: 1.0),
                            left: BorderSide(width: 1.0),
                            right: BorderSide(width: 1.0),
                            top: BorderSide(width: 1.0),
                            bottom: BorderSide(width: 1.0),
                          ),
                          columns: [
                            DataColumn(label: Text('COUNT', style: TextStyle(color: Colors.blue[900]!))),
                            DataColumn(label: Text('STUDENT NO.', style: TextStyle(color: Colors.blue[900]!))),
                            DataColumn(label: Text('STUDENT NAME', style: TextStyle(color: Colors.blue[900]!))),
                            DataColumn(label: Text('COLLEGE', style: TextStyle(color: Colors.blue[900]!))),
                            DataColumn(label: Text('PROGRAM TYPE', style: TextStyle(color: Colors.blue[900]!))),
                            DataColumn(label: Text('FINAL GRADE', style: TextStyle(color: Colors.blue[900]!))),
                            DataColumn(label: Text('REMARKS', style: TextStyle(color: Colors.blue[900]!))),
                          ],
                          rows: classInfo.map<DataRow>((data) {
                            rowCount++;
                            return DataRow(
                              cells: [
                                DataCell(Text("${rowCount.toString()}" ?? '')),
                                DataCell(Text("${data['studentId'].toString()}" ?? '')),
                                DataCell(Text(data['name'].toString() ?? '')),
                                DataCell(Text(data['college'].toString() ?? '')),
                                DataCell(Text(data['program'].toString() ?? '')),
                                DataCell(Text(data['grade'].toString() ?? '')),
                                DataCell(Text(data['remarks'].toString() ?? '')),
                              ],
                            );
                          })?.toList() ?? [],
                        ),
                      ],
                    ),

                  ),
              ),
              // Additional container at the bottom
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
  const CustomAppBar({super.key});
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
        icon: Icon(Icons.arrow_back), // Burger menu icon
        onPressed: (){
          Navigator.pop(context);
        },
        color: Colors.black, // Set icon color
      ),
    );
  }
}