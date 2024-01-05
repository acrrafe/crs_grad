// import 'dart:js_interop';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plm_crs_grad/screens/student/student_dashboard.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

import '../../services/apiService.dart';

class StudentGradesApp extends StatelessWidget {
  final int studentId;

  const StudentGradesApp({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(
          title: "",
          onMenuPressed: (){},
        ),
        body: StudentGradesAppPage(studentId: studentId),
      ),
    );
  }
}
class StudentGradesAppPage extends StatefulWidget {
  final int studentId;
  const StudentGradesAppPage({Key? key, required this.studentId}) : super(key: key);
  @override
  _StudentGradesAppPageState createState() => _StudentGradesAppPageState(studentId);
}

class _StudentGradesAppPageState extends State<StudentGradesAppPage> {
  final int studentId;

  _StudentGradesAppPageState(this.studentId);

  Future<void>? fetchData;
  Future<void>? fetchUserData;

  APIService apiService = APIService();
  late Map<String, dynamic> studentInfo = {};
  late Map<String, dynamic> studentInfos = {};
  late List<Map<String, dynamic>> classInfos = [];
  late List<Map<String, dynamic>> classInfo = [];
  late List<Map<String, dynamic>> flags = [];
  late List<Map<String, dynamic>> visibleClassInfos = [];
  late List<Map<String, dynamic>> filteredClassInfos = [];

  bool isLoading = true;

  int _currentPage = 1;
  int _rowsPerPage = 10;
  int totalPages = 0;
  late int aysem;


  @override
  void initState() {
    super.initState();
    fetchUserData = fetchUserDataAsync();
  }

  Future<void> fetchUserDataAsync() async {
    try {
      print("STUDENT ID: ${widget.studentId}");
      studentInfos = await apiService.fetchUserInfo(widget.studentId);
      print("STUDENT INFO: $studentInfos");
      setState(() {
        studentInfo = studentInfos;
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> fetchDataAsync(int flagValue) async {
    try {
      print("STUDENT ID: ${widget.studentId}");
      print("FLAGS VALUE: $flagValue");
      classInfo = await apiService.fetchStudentGrades(widget.studentId, flagValue);

      setState(() {
        classInfos = classInfo;
        int startIndex = (_currentPage - 1) * _rowsPerPage;
        int endIndex = startIndex + _rowsPerPage;
        endIndex = endIndex > classInfos.length ? classInfos.length : endIndex;
        visibleClassInfos = classInfos.sublist(startIndex, endIndex);
        print("VISIBLE CLASS INFOS: $visibleClassInfos");
        totalPages = (classInfos.length / _rowsPerPage).ceil();
        print("CLASS INFO: $classInfos");
      });
    } catch (error) {
      // Handle errors here
      print('Error fetching data: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUserData,
      builder: (context, snapshot) {
        if (fetchUserData == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!),
            ),
          );
        } else {
          return SingleChildScrollView(
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 10.0),
                  // Student Information Card
                  buildStudentInfoCard(),
                  SizedBox(height: 20),
                  // Pagination and Search Bar Row
                  buildPaginationAndSearchBarRow(),
                  // DataTable
                  buildDataTable(),
                  // Button at the center below the table
                  Center(
                    child: ElevatedButton(

                      onPressed: visibleClassInfos.isNotEmpty
                          ? () async {
                        setState(() => isLoading = false);
                        await _generatePdf(visibleClassInfos);
                        setState(() => isLoading = true);
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green[900], // Change button color to green
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: isLoading ? Text("Print Grades") : CircularProgressIndicator(color: Colors.white),
                      )
                    ),
                  ),
                  // Add your enrollment-related widgets here
                ],
              ),
            ),
          );
        }
      },
    );
  }

// Student Information Card
  Widget buildStudentInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.red[800]!,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3.0,
        margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Information Details
              buildStudentInfoDetails(),
            ],
          ),
        ),
      ),
    );
  }

// Student Information Details
  Widget buildStudentInfoDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildInfoContainer('STUDENT ID : ${widget.studentId}'),
        buildInfoContainer(
            'STUDENT NAME: ${studentInfo['firstName']} ${studentInfo['middleName']} ${studentInfo['lastName']}'),
        buildInfoContainer('COURSE : ${studentInfo['program']}'),
        buildInfoContainer('GRADUATE SCHOOL : ${studentInfo['college']}'),
      ],
    );
  }

// Helper method to build information container
  Widget buildInfoContainer(String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
        ),
      ),
    );
  }

// Pagination and Search Bar Row
  Widget buildPaginationAndSearchBarRow() {
    return Container(
      color: Colors.red[900],
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Pagination
          buildPagination(),
          // Search Bar
          buildSearchBar(),
        ],
      ),
    );
  }

// Pagination
  Widget buildPagination() {
    return Flexible(
      child: Container(
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter Year Semester',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

// Search Bar
  Widget buildSearchBar() {
    return Flexible(
      child: Container(
        padding: EdgeInsets.all(4),
        height: MediaQuery.of(context).size.height * 0.06,
        margin: EdgeInsets.fromLTRB(0, 0, 5.0, 0),
        color: Colors.white,
        child: SearchBar(
          onChanged: updateDataTable,
        ),
      ),
    );
  }

// DataTable
  Widget buildDataTable() {
    return Flexible(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          height: 300,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Subject Code/Section')),
              DataColumn(label: Text('Subject Title')),
              DataColumn(label: Text('Units')),
              DataColumn(label: Text('Grade')),
              DataColumn(label: Text('Remarks')),
            ],
            rows: visibleClassInfos.map<DataRow>((classInfo) {
              return DataRow(
                cells: [
                  DataCell(
                      Text("${classInfo['subjectCode']} ${classInfo['program']}")),
                  DataCell(Text(classInfo['subjectName'])),
                  DataCell(Text(classInfo['subjectUnits'].toString())),
                  DataCell(Text(classInfo['grade'].toString())),
                  DataCell(Text(classInfo['remarks'] ?? "N\\A"),),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Pagination Button
  void _handleNextPage() {
    setState(() {
      _currentPage++;
    });
  }
  void _handlePreviousPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
      }
    });
  }

  void updateDataTable(String searchText) {
    aysem = int.tryParse(searchText) ?? 0;
    fetchDataAsync(aysem);

    setState(() {
      if (searchText.isEmpty) {
        // If the search text is empty, show all items
        visibleClassInfos = classInfos;
      } else {
        // Filter the visibleClassInfos based on the search text
        filteredClassInfos = classInfos.where((classInfo) {
          String subjectName = classInfo['subjectName'] ?? '';
          return subjectName.toLowerCase().contains(searchText.toLowerCase());
        }).toList();

        // Only update visibleClassInfos if searchText is in the filteredClassInfos
        if (filteredClassInfos.isNotEmpty) {
          visibleClassInfos = filteredClassInfos;
          print("VISIBLE CLASS INFOS: $visibleClassInfos");
        }
      }
    });
  }


  Future<void> _generatePdf(List<Map<String, dynamic>> classes) async {
    final pdf = pw.Document();

    final fontBold = await rootBundle.load("assets/Tinos-Bold.ttf");
    final fontRegular = await rootBundle.load("assets/Tinos-Regular.ttf");

    final ttfBold = pw.Font.ttf(fontBold);
    final ttfRegular = pw.Font.ttf(fontRegular);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'PAMANTASAN NG LUNGSOD NG MAYNILA',
                    style: pw.TextStyle(fontSize: 12, font: ttfBold),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text('University of the City Manila', style: pw.TextStyle(font: ttfRegular)),
                  pw.SizedBox(height: 2),
                  pw.Text('Intramuros, Manila', style: pw.TextStyle(font: ttfRegular)),
                  pw.SizedBox(height: 2),
                  pw.Text('ENROLLMENT ASSESSMENT FORM', style: pw.TextStyle(fontSize: 12, font: ttfBold)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          // At the start
                          pw.Text("Student no: ", style: pw.TextStyle(font: ttfRegular)),
                          pw.Text("${studentInfo['studentId']}", style: pw.TextStyle(font: ttfBold)),
                        ]
                    ),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          // At the end
                          pw.Text("Course: ", style: pw.TextStyle(font: ttfRegular)),
                          pw.Text(studentInfo['program'], style: pw.TextStyle(font: ttfBold)),
                        ]
                    )
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          // At the start
                          pw.Text("Student Name: ", style: pw.TextStyle(font: ttfRegular)),
                          pw.Text("${studentInfo['firstName']} ${studentInfo['middleName']} ${studentInfo['lastName']}", style: pw.TextStyle(font: ttfBold)),
                        ]
                    ),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          // At the end
                          pw.Text("College: ", style: pw.TextStyle(font: ttfRegular)),
                          pw.Text(studentInfo['college'], style: pw.TextStyle(font: ttfBold)),
                        ]
                    )
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          // At the start
                          pw.Text("Year/Term: ", style: pw.TextStyle(font: ttfRegular)),
                          pw.Text("$aysem", style: pw.TextStyle(font: ttfBold)),
                        ]
                    ),
                  ],
                ),
                pw.SizedBox(height: 16), // Add some spacing between the rows and tables
                // First table with 8 columns
                pw.Table(
                  border: pw.TableBorder.symmetric(outside: pw.BorderSide(width: 2, color: PdfColors.black)),
                  defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    // Header row with custom content
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        for (var headerText in [
                          'Subject Code / Section',
                          'Subject Title',
                          'Units',
                          'Grade',
                          'Remarks',
                        ])
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(headerText, style: pw.TextStyle(font: ttfRegular)),
                          ),
                      ],
                    ),
                    // Data rows (without border)
                    for (var selectedClass in classes)
                      pw.TableRow(
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text("${selectedClass['subjectCode']} ${selectedClass['program']}" ?? '', style: pw.TextStyle(font: ttfRegular)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(selectedClass['subjectName'] ?? '', style: pw.TextStyle(font: ttfRegular)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('${selectedClass['subjectUnits']}' ?? '', style: pw.TextStyle(font: ttfRegular)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(selectedClass['grade'].toString() ?? '', style: pw.TextStyle(font: ttfRegular)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(selectedClass['remarks'] ?? 'N/A', style: pw.TextStyle(font: ttfRegular)),
                          ),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 16), // Add some spacing between the tables
                // Second table with 2 columns
                // pw.SizedBox(height: 50),
                // pw.Container(
                //   alignment: pw.Alignment.center,
                //   child: pw.Column(
                //     crossAxisAlignment: pw.CrossAxisAlignment.center,
                //     mainAxisAlignment: pw.MainAxisAlignment.center,
                //     children: [
                //       pw.Text('As earlier conformed with thru the Online CRS-GP,', style: pw.TextStyle(font: ttfRegular)),
                //       pw.SizedBox(height: 1.5),
                //       pw.Text('I hereby agree to abide by and conform with the pertinent', style: pw.TextStyle(font: ttfRegular)),
                //       pw.SizedBox(height: 1.5),
                //       pw.Text('academic policies, rules, and regulations, of the University', style: pw.TextStyle(font: ttfRegular)),
                //       pw.SizedBox(height: 1.5),
                //       pw.Text('including those stipulated in the operative PLM Student Manual.', style: pw.TextStyle(font: ttfRegular)),
                //       pw.SizedBox(height: 1.5),
                //     ],
                //   ),
                // ),
              ],
            ),
          ];
        },
      ),
    );

    // Get the app's document directory
    final directory = (await getExternalStorageDirectory())!.path;
    final file = File('$directory/grades_document.pdf');

    // Save the PDF document to a file
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);

    // Open the PDF file using the default viewer
    // You can customize this part based on how you want to handle the PDF file
    // For example, you can use the 'open_file' package to open the PDF in a viewer app
    // or share it through other means.
    // Example using 'open_file':
    // await OpenFile.open(file.path);
  }


}


// Custom Search Bar
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
          labelText: 'e.g. 20231',
          hintText: 'e.g. 20231',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

}






