import 'package:flutter/material.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:intl/intl.dart';
import '../../auth/auth_config.dart';
import '../../services/apiService.dart';
import '../login.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

class TeachingAssessmentContent extends StatefulWidget {
  final int facultyId;

  const TeachingAssessmentContent({Key? key, required this.facultyId}) : super(key: key);

  @override
  _TeachingAssessmentContent createState() => _TeachingAssessmentContent(facultyId: facultyId);
}

class _TeachingAssessmentContent extends State<TeachingAssessmentContent> {
  final int facultyId;

  _TeachingAssessmentContent({required this.facultyId});

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
        // String aysem = flags.first['value'].toString().substring(0,4);
        // int aysemPlus = int.parse(aysem) + 1;
        return Scaffold(
          appBar: CustomAppBar(
            title: "",
            onMenuPressed: () {},
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child:  Column(
              children: [
                const SizedBox(height: 40),
                const Text("TEACHING ASSIGNMENTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
                      DataColumn(label: Text('Course Code & Section')),
                      DataColumn(label: Text('Subject Title')),
                      DataColumn(label: Text('Units')),
                      DataColumn(label: Text('Class Schedule')),
                      DataColumn(label: Text('No. of Students')),
                      DataColumn(label: Text('Credited Units')),
                      DataColumn(label: Text('College')),
                    ],
                    rows: (facultyInfo['classes'] as List<dynamic>?)
                        ?.map<DataRow>((data) {
                      return DataRow(
                        cells: [
                          DataCell(Text("${data['subjectCode']} - ${data['section']}" ?? '')),
                          DataCell(Text(data['subjectName'] ?? '')),
                          DataCell(Text(data['subjectUnits']?.toString() ?? '')),
                          DataCell(Text('Day: ${data['classDay']}, Time: ${formatTime(data['timeStart'])} - ${formatTime(data['timeEnd'])} at  ${data['room']}')),
                          DataCell(Text(data['enrolledSlots']?.toString() ?? '')),
                          DataCell(Text(data['subjectUnits']?.toString() ?? '')),
                          DataCell(Text(facultyInfo['college'] ?? '')),
                        ],
                      );
                    })?.toList() ?? [],

                  ),
                ),
                const SizedBox(height: 140),
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
                SizedBox(height: 40,),
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(

                      onPressed: fetchFacultyInfo.isNotEmpty
                          ? () async {
                        setState(() => isLoading = false);
                        await _generatePdf(facultyInfo['classes']);
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
                )
                // Additional container at the bottom
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
      } else {
        // Filter the visibleClassInfos based on the search text
        filteredFacultyClassInfo = facultyInfo['classes'].where((classInfo) {
          String subjectName = classInfo['subjectName'] ?? '';
          return subjectName.toLowerCase().contains(searchText.toLowerCase());
        }).toList();

        // Only update visibleClassInfos if searchText is in the filteredClassInfos
        if (filteredFacultyClassInfo.isNotEmpty) {
          fetchFacultyInfo = filteredFacultyClassInfo;
          print("VISIBLE CLASS INFOS: $filteredFacultyClassInfo");
        }
      }
    });
  }

  Future<void> _generatePdf(List<dynamic> classes) async {
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
                          pw.Text("Faculty no: ", style: pw.TextStyle(font: ttfRegular)),
                          pw.Text("${facultyInfo['id']}", style: pw.TextStyle(font: ttfBold)),
                        ]
                    ),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          // At the end
                          pw.Text("College: ", style: pw.TextStyle(font: ttfRegular)),
                          pw.Text(facultyInfo['college'], style: pw.TextStyle(font: ttfBold)),
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
                          pw.Text("Faculty Name: ", style: pw.TextStyle(font: ttfRegular)),
                          pw.Text("${facultyInfo['firstName']} ${facultyInfo['lastName']}", style: pw.TextStyle(font: ttfBold)),
                        ]
                    ),
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
                          'Course Code & Section',
                          'Subject Title',
                          'Units',
                          'Class Schedule',
                          'No. of Students',
                          'Credited Units',
                          'College',

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
                        // 'Course Code & Section',
                        // 'Subject Title',
                        // 'Units',
                        // 'Class Schedule',
                        // 'No. of Students',
                        // 'Credited Units',
                        // 'College',
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text("${selectedClass['subjectCode']} ${selectedClass['section']}" ?? '', style: pw.TextStyle(font: ttfRegular)),
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
                            child: pw.Text('Day: ${selectedClass['classDay']}, Time: ${formatTime(selectedClass['timeStart'])} - ${formatTime(selectedClass['timeEnd'])} at  ${selectedClass['room']}' ?? '', style: pw.TextStyle(font: ttfRegular)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('${selectedClass['enrolledSlots']}' ?? '', style: pw.TextStyle(font: ttfRegular)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('${selectedClass['subjectUnits']}' ?? '', style: pw.TextStyle(font: ttfRegular)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(selectedClass['college'] ?? 'N/A', style: pw.TextStyle(font: ttfRegular)),
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