
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:plm_crs_grad/screens/student/student_dashboard.dart';
import 'package:intl/intl.dart';

import '../../models/pdf_student_model.dart';
import '../../services/apiService.dart';

class StudentEnrollmentApp extends StatelessWidget {
  final int studentId;
  const StudentEnrollmentApp({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(
          title: "",
          onMenuPressed: (){},
        ),
        body: StudentEnrollmentPage(studentId: studentId),
      ),
    );
  }
}

class StudentEnrollmentPage extends StatefulWidget {
  final int studentId;
  const StudentEnrollmentPage({Key? key, required this.studentId}) : super(key: key);

  @override
  _StudentEnrollmentPageState createState() => _StudentEnrollmentPageState(studentId: studentId);
}
class _StudentEnrollmentPageState extends State<StudentEnrollmentPage> {
  final int studentId;
  _StudentEnrollmentPageState({required this.studentId});

  int _currentStep = 1;
  int _currentPage = 1;
  int _rowsPerPage = 7;
  List<int> selectedClass = [];
  List<Map<String, dynamic>> userSelectedClasses = [];

  late List<Map<String, dynamic>> userBalance = [];

  int _selectedPaymentType = 0;
  bool isLastPage = false;


  APIService apiService = APIService();
  Future<void>? fetchData;
  late Map<String, dynamic> data = {};
  late List<Map<String, dynamic>> flags = [];
  late List<Map<String, dynamic>> classInfos = [];
  int? value;

  @override
  void initState() {
    super.initState();
    apiService.fetchUserInfo(widget.studentId).then((data) {
      setState(() {
        this.data = data;
      });
      // Check enrollmentStatus and conditionally call fetchDataAsync
      if (data['enrollmentStatus'] != 1) {
        fetchData = fetchDataAsync();
      } else {
        fetchData = Future.error('Enrollment status is 1'); // Set a completed future with an error
      }
    });
  }

  Future<void> fetchDataAsync() async {
    try {
      // Use 'await' to wait for the completion of fetchFlags
      List<Map<String, dynamic>> flags = await apiService.fetchFlags();
      if (flags != null) {
        setState(() {
          this.flags = flags;
        });
        // Assuming 'value' is the key you're interested in
        int value = int.parse(flags.first['value']);
        // Check if 'value' is an integer
        userBalance = await apiService.fetchUserBalance(widget.studentId, value);
        List<Map<String, dynamic>> classInfos = await apiService.fetchClassInfos(value);
        if (classInfos != null) {
          setState(() {
            this.classInfos = classInfos;
            userBalance = userBalance;
          });
        }


      }


    } catch (error) {
      // Handle errors here
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = _currentStep == 1 ? (classInfos.length / _rowsPerPage).ceil() : (selectedClass.length / _rowsPerPage).ceil();
    return Theme(
      // Modify the ThemeData according to your needs
      data: ThemeData(
        // Define your custom theme properties here
        primarySwatch: Colors.green,
      ),
        child: FutureBuilder(
            future: fetchData,
            builder: (context, snapshot) {
              if (fetchData == null) {
                // Handle the case when fetchData is null
                return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!)));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Future is still loading, return a loading indicator or placeholder
                return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!)));

              } else if (snapshot.hasError) {
                return Center(
                  child:   Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Congratulations on your \n successful enrollment!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await fetchDataAsync();

                          List<Map<String, dynamic>> selectedClass = (data['class_infos'] as List).cast<Map<String, dynamic>>();
                          Map<String, double> result = calculateTotalAmount(selectedClass, flags);

                          double? totalAmount = result['totalAmount'];
                          double? totalTuitionFee = result['totalTuitionFee'];
                          double? countMiscellaneousFee = result['countMiscellaneousFee'];
                          double? otherFee = result['otherFee'];

                          // Handle "Print EAF" button click
                          List<Map<String, double>> paymentBreakdown = [];
                          var studentNum = studentId;
                          var studentName = "${data['firstName']} ${data['middleName']} ${data['lastName']}";
                          var studentCourse = "${data['program']}";
                          var studentCollege = "${data['college']}";
                          var aysem = int.parse(flags[0]['value']);
                          print("AYSEM: $userBalance");
                          var paymentTerm = 'N/A';
                          // SelectedClass
                          var dateAssessed = 'N/A';

                          // Access the payments list
                          var paymentsList = userBalance[0]['payments'];


                          int paymentsListLength = paymentsList.length;

                          var payment = totalAmount! / paymentsListLength;

                          for (int count = 1; count <= paymentsListLength; count++) {
                            // Create a Map with the key based on the count and the payment value
                            Map<String, double> paymentMap = {};
                            if (count == 1) {
                              paymentMap = {'${count}st Payment': payment};
                            } else if (count == 3) {
                              paymentMap = {'${count}rd Payment': payment};
                            } else if (count == 4 || count == 5) {
                              paymentMap = {'${count}th Payment': payment};
                            } else {
                              paymentMap = {'${count}nd Payment': payment};
                            }
                            paymentBreakdown.add(paymentMap);
                          }


                          CRSGPdfModel pdfData = CRSGPdfModel(studentNo: studentNum,
                              studentName: studentName, studentCourse: studentCourse, college: studentCollege,
                              aysem: aysem, paymentTerm: paymentTerm, selectedClass: selectedClass,
                              tuitionFee: totalTuitionFee!, miscellaneousFee: countMiscellaneousFee!, otherFees:
                              otherFee!, totalAmount: totalAmount, paymentType: paymentsListLength, dateAssessed:
                              dateAssessed, payment: paymentBreakdown);

                           await _generatePdf(pdfData);

                        },

                        style: ElevatedButton.styleFrom(
                          primary: Colors.green[900], // Change button color to green
                        ),
                        child: Text('Print EAF'),
                      ),
                    ],
                  ),
                );
              } else {
                // int totalPages = _currentStep == 1 ? (classInfos.length / _rowsPerPage).ceil() : (selectedClass.length / _rowsPerPage).ceil();
                return SingleChildScrollView(
                  child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Progress Tracker with Line
                          SizedBox(height: 20),
                          if(_currentStep <= 3)
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStepIndicator(1),
                                    SizedBox(height: 5),
                                    _buildStepColumn(1, 'ENLIST AVAILABLE\n      CLASSES'),
                                  ],
                                ),
                                _buildLineBetweenSteps(1),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStepIndicator(2),
                                    SizedBox(height: 5),
                                    _buildStepColumn(2, 'VIEW CLASSES\n    ENLISTED'),
                                  ],
                                ),
                                _buildLineBetweenSteps(2),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStepIndicator(3),
                                    SizedBox(height: 5),
                                    _buildStepColumn(3, 'SELECT PAYMENT\n  AND PRINT EAF'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _currentStep == 1 || _currentStep == 2,
                            child: Column(
                              children: [
                                // Red box with pagination and search bar
                                Container(
                                  color: Colors.red[900],
                                  padding: EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Page $_currentPage of $totalPages',
                                                  style: TextStyle(color: Colors.white)),
                                              IconButton(
                                                icon: Icon(Icons.arrow_back_ios_new_rounded),
                                                color: Colors.white,
                                                onPressed: _currentPage == 1
                                                    ? null  // Disable the button if the current page is equal to total pages
                                                    : () {
                                                  _handlePreviousPage();
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.arrow_forward_ios_rounded),
                                                color: Colors.white,
                                                onPressed: totalPages == _currentPage
                                                    ? null  // Disable the button if the current page is equal to total pages
                                                    : () {
                                                  _handleNextPage();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Content based on step
                          _buildStepContent(),
                          // Next and Back buttons
                          Visibility(
                              visible: _currentStep == 1 || _currentStep == 2 || _currentStep == 3,
                              child:Padding(
                            padding: EdgeInsets.all(10.0), // Adjust the padding as needed
                            child: Row(
                              mainAxisAlignment: _currentStep == 1 ? MainAxisAlignment.end: MainAxisAlignment.spaceBetween,
                              children: [
                                if (_currentStep > 1)
                                  OutlinedButton(
                                    onPressed: () {
                                      _handleBackButtonClick();
                                    },
                                    child: Text(
                                      _currentStep == 2 ? 'Back to Step 1' : 'Back to Step 2',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ElevatedButton(
                                  onPressed: (selectedClass.length > 0 && _selectedPaymentType == 0)
                                      ? _handleNextButtonClick
                                      : (selectedClass.length > 0 && _selectedPaymentType > 0)
                                      ? () => _submitButton(_selectedPaymentType, userSelectedClasses)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    primary: (selectedClass.length > 0 && (_selectedPaymentType != 0 || _selectedPaymentType == 0))
                                        ? Colors.green[900]
                                        : Colors.grey, // Change color to grey when the button is disabled
                                  ),
                                  child: Text(isLastPage && _selectedPaymentType > 0  ? 'Submit' : 'Next'),
                                ),


                              ],
                            ),
                          )),
                        ],
                      )
                  ),
                );
              }
            }
        ),


    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 1) {
      isLastPage = false;
      return _buildStep1Content();
    } else if (_currentStep == 2) {
      isLastPage = false;
      return _buildStep2Content();
    } else if (_currentStep == 3){
      isLastPage = true;
      return _buildStep3Content(_selectedPaymentType, userSelectedClasses);
    } else{
      return _buildStep4Content(context, _selectedPaymentType, userSelectedClasses);
    }
  }

  Widget _buildStep1Content() {
    int startIndex = (_currentPage - 1) * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    endIndex = endIndex > classInfos.length ? classInfos.length : endIndex;
    List<Map<String, dynamic>> visibleClassInfos = classInfos.sublist(startIndex, endIndex);

    return Flexible(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Class/Section')),
              DataColumn(label: Text('Class Title')),
              DataColumn(label: Text('Units')),
              DataColumn(label: Text('Prerequisites')),
              DataColumn(label: Text('Schedule')),
              DataColumn(label: Text('Slots')),
              DataColumn(label: Text('Enlisted')),
              DataColumn(label: Text('Enrolled')),
            ],
            rows: visibleClassInfos.map<DataRow>((classInfo) {
              String program = classInfo['program'] ?? '';
              int classSection = classInfo['section'] ?? 0;
              String classTitle = classInfo['subjectName'] ?? '';
              int units = classInfo['subjectUnits'] ?? 0;
              int slots = classInfo['maxSlots'] ?? 0;
              int enrolledSlots = classInfo['enrolledSlots'] ?? 0;
              String classDay = classInfo['classDay'] ?? '';
              String fullDay;

              switch (classDay) {
                case 'M':
                  fullDay = 'Monday';
                  break;
                case 'T':
                  fullDay = 'Tuesday';
                  break;
                case 'W':
                  fullDay = 'Wednesday';
                  break;
                case 'TH' || 'Th' || 'th':
                  fullDay = 'Thursday';
                  break;
                case 'F':
                  fullDay = 'Friday';
                  break;
                case 'S':
                  fullDay = 'Saturday';
                  break;
                default:
                  fullDay = 'Unknown';
                  break;
              }
              String timeStart = classInfo['timeStart'] ?? '';
              String timeEnd = classInfo['timeEnd'] ?? '';

              DateTime startDateTime = DateTime.parse("2023-01-01 $timeStart");
              DateTime endDateTime = DateTime.parse("2023-01-01 $timeEnd");
              String formattedStartTime = DateFormat('hh:mm a').format(startDateTime);
              String formattedEndTime = DateFormat('hh:mm a').format(endDateTime);

              return DataRow(
                selected: selectedClass.contains(classInfo['id']),
                onSelectChanged: (b) {
                  onSelectedRow(b!, classInfo['id']);
                },
                cells: [
                  DataCell(Text("${program} - ${classSection.toString()}")),
                  DataCell(Text(classTitle)),
                  DataCell(Text(units.toString())),
                  DataCell(
                    Align(
                      alignment: Alignment.center,
                      child: Text('Prerequisites'), // Replace with actual value
                    ),
                  ),
                  DataCell(Text("$fullDay ${formattedStartTime} - ${formattedEndTime}")), // Replace with actual value
                  DataCell(Text(slots.toString())),
                  DataCell(Text('Enlisted')), // Replace with actual value
                  DataCell(Text(enrolledSlots.toString())), // Replace with actual value
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep2Content() {
    // Filter classInfos based on selectedClass
    List<Map<String, dynamic>> selectedClasses = classInfos
        .where((classInfo) => selectedClass.contains(classInfo['id']))
        .toList();
    userSelectedClasses = selectedClasses;
    print(userSelectedClasses);

    return Flexible(
      fit: FlexFit.loose,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Class/Section')),
              DataColumn(label: Text('Schedule')),
              DataColumn(label: Text('Class Title')),
            ],
            rows: selectedClasses.map<DataRow>((classInfo) {
              // Extract relevant information from classInfo
              String classSection = "${classInfo['program']} - ${classInfo['section']}";
              String schedule = "${classInfo['classDay']} ${classInfo['timeStart']} - ${classInfo['timeEnd']}";
              String classTitle = classInfo['subjectName'];
              return DataRow(
                cells: [
                  DataCell(Text(classSection)),
                  DataCell(Text(schedule)),
                  DataCell(Text(classTitle)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep3Content(int selectedPayment, List<Map<String, dynamic>> selectedClasses) {
    // Call the calculateTotalAmount function
    Map<String, double> result = calculateTotalAmount(selectedClasses, flags);

    double? totalAmount = result['totalAmount'];
    double? totalTuitionFee = result['totalTuitionFee'];
    double? countMiscellaneousFee = result['countMiscellaneousFee'];
    double? otherFee = result['otherFee'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DataTable(
          columns: const [
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Amount')),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text('Total Tuition Fee')),
              DataCell(Text(totalTuitionFee.toString())),
            ]),
            DataRow(cells: [
              DataCell(Text('Total Miscellaneous Fee')),
              DataCell(Text(countMiscellaneousFee.toString())),
            ]),
            DataRow(cells: [
              DataCell(Text('Other Fee')),
              DataCell(Text(otherFee.toString())),
            ]),
            DataRow(cells: [
              DataCell(Text('Total Amount')),
              DataCell(Text(totalAmount.toString())),
            ]),
          ],
        ),
        SizedBox(height: 16.0),
        Text(
          'Select Payment Type',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.0),
        CustomRadioButton('Full Payment', 1),
        CustomRadioButton('2 Partial Payment', 2),
        CustomRadioButton('3 Partial Payment', 3),
        CustomRadioButton('4 Partial Payment', 4),
        CustomRadioButton('5 Partial Payment', 5),
      ],
    );
  }


  Widget _buildStep4Content(BuildContext context, int selectedPayment, List<Map<String, dynamic>> selectedClasses) {

    // Call the calculateTotalAmount function
    Map<String, double> result = calculateTotalAmount(selectedClasses, flags);

    double? totalAmount = result['totalAmount'];
    double? totalTuitionFee = result['totalTuitionFee'];
    double? countMiscellaneousFee = result['countMiscellaneousFee'];
    double? otherFee = result['otherFee'];

    //, int studentNum, String studentName, String yearTerm,
    //       String course, String college, String paymentTerms
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Text(
          'Congratulations on your \n successful enrollment!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            // Handle "Print EAF" button click
            List<Map<String, double>> paymentBreakdown = [];
            var studentNum = studentId;
            var studentName = "${data['firstName']} ${data['middleName']} ${data['lastName']}";
            var studentCourse = "${data['program']}";
            var studentCollege = "${data['college']}";
            var aysem = int.parse(flags.first['value']);
            var paymentTerm = 'N/A';
            // SelectedClass
            var dateAssessed = 'N/A';
            var payment = totalAmount! / _selectedPaymentType;

            for (int count = 1; count <= _selectedPaymentType; count++) {
              Map<String, double> paymentMap = {};
              if (count == 1) {
                paymentMap = {'${count}st Payment': payment};
              } else if (count == 3) {
                paymentMap = {'${count}rd Payment': payment};
              } else if (count == 4 || count == 5) {
                paymentMap = {'${count}th Payment': payment};
              } else {
                paymentMap = {'${count}nd Payment': payment};
              }
              paymentBreakdown.add(paymentMap);
            }
            CRSGPdfModel pdfData = CRSGPdfModel(studentNo: studentNum,
                studentName: studentName, studentCourse: studentCourse, college: studentCollege,
                aysem: aysem, paymentTerm: paymentTerm, selectedClass: userSelectedClasses,
                tuitionFee: totalTuitionFee!, miscellaneousFee: countMiscellaneousFee!, otherFees:
                otherFee!, totalAmount: totalAmount, paymentType: _selectedPaymentType, dateAssessed:
                dateAssessed, payment: paymentBreakdown);

            await _generatePdf(pdfData);
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.green[900], // Change button color to green
          ),
          child: Text('Print EAF'),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Future<void> _generatePdf(CRSGPdfModel pdfData) async {
    final pdf = pw.Document();

    final fontBold = await rootBundle.load("assets/Tinos-Bold.ttf");
    final fontRegular = await rootBundle.load("assets/Tinos-Regular.ttf");

    List<Map<String, dynamic>> listOfFees = [
      {"Tuition Fees (Masteral)":pdfData.tuitionFee}, {"Miscellaneous Fees": pdfData.miscellaneousFee},
      {"Other Fees": pdfData.otherFees}, {"Total Amount": pdfData.totalAmount},
      {"Payment": pdfData.payment}
    ];

    List<Map<String, dynamic>> amountPaid = [];

    for(int count=1; count<=3; count++){
      Map<String, dynamic> paymentMap = {};

      if (count == 1 && pdfData.paymentType == 1) {
        paymentMap = {'Payment Type': "Full"};
      } else if(count == 1 && pdfData.paymentType > 1){
        paymentMap = {'Payment Type': "Partial"};
      }
      else if (count == 2) {
        paymentMap = {'Date Assessed': 'N/A'};
      } else if (count == 3) {
        paymentMap = {'1st Payment': pdfData.payment[0]["1st Payment"]};
      } else {
        paymentMap = {"N/A": "N/A"};
      }
      amountPaid.add(paymentMap);
    }
    // print("PAYMENT TYPE ${ pdfData.paymentType}");
    // print("PAYMENT ${pdfData.payment[0]["1st Payment"]}");
    // print("AMOUNT PAID: $amountPaid");

    // Define font objects
    // final pw.Font ttfFontBold = pw.Font.ttf(fontBold);
    // final pw.Font ttfFontRegular = pw.Font.ttf(fontRegular);
    // final pw.Font ttfFontLight = pw.Font.ttf(fontLight);
    final ttfBold = pw.Font.ttf(fontBold);
    final ttfRegular = pw.Font.ttf(fontRegular);
    // Add content to the PDF document
    late String formattedStartTime;
    late String formattedEndTime;
    for (var selectedClass in pdfData.selectedClass){
      String timeStart = selectedClass['timeStart'] ?? '';
      String timeEnd = selectedClass['timeEnd'] ?? '';
      DateTime startDateTime = DateTime.parse("2023-01-01 $timeStart");
      DateTime endDateTime = DateTime.parse("2023-01-01 $timeEnd");
      formattedStartTime = DateFormat('hh:mm a').format(startDateTime);
      formattedEndTime = DateFormat('hh:mm a').format(endDateTime);
    }
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
                          pw.Text("${pdfData.studentNo}", style: pw.TextStyle(font: ttfBold)),
                        ]
                    ),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          // At the end
                          pw.Text("Course: ", style: pw.TextStyle(font: ttfRegular)),
                          pw.Text(pdfData.studentCourse, style: pw.TextStyle(font: ttfBold)),
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
                          pw.Text(pdfData.studentName, style: pw.TextStyle(font: ttfBold)),
                        ]
                    ),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          // At the end
                          pw.Text("College: ", style: pw.TextStyle(font: ttfRegular)),
                          pw.Text(pdfData.college, style: pw.TextStyle(font: ttfBold)),
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
                          pw.Text("${pdfData.aysem}", style: pw.TextStyle(font: ttfBold)),
                        ]
                    ),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          // At the end
                          pw.Text("Payment Term: ", style: pw.TextStyle(font: ttfRegular)),
                          pw.Text(pdfData.paymentTerm, style: pw.TextStyle(font: ttfBold)),
                        ]
                    )
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
                          'Subject Code',
                          'Sec.',
                          'Subject Title',
                          'Units',
                          'Days',
                          'Date Start',
                          'Time',
                          'Room'
                        ])
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(headerText, style: pw.TextStyle(font: ttfRegular)),
                          ),
                      ],
                    ),
                    // Data rows (without border)
                    for (var selectedClass in pdfData.selectedClass)
                      pw.TableRow(
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(selectedClass['subjectCode'] ?? '', style: pw.TextStyle(font: ttfRegular)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text("${selectedClass['section']}", style: pw.TextStyle(font: ttfRegular)), // Add logic for 'Sec.' based on your data
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
                            child: pw.Text(selectedClass['classDay'] ?? '', style: pw.TextStyle(font: ttfRegular)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text("N/A", style: pw.TextStyle(font: ttfRegular)),
                          ),

                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text("$formattedStartTime - $formattedEndTime", style: pw.TextStyle(font: ttfRegular)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(selectedClass['room'] ?? '', style: pw.TextStyle(font: ttfRegular)),
                          ),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 16), // Add some spacing between the tables
                // Second table with 2 columns
                pw.Table(
                  border: pw.TableBorder.symmetric(outside: pw.BorderSide(width: 2, color: PdfColors.black)),
                  defaultVerticalAlignment: pw.TableCellVerticalAlignment.bottom,
                  children: [
                    // Header row with custom content
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Fees', style: pw.TextStyle(font: ttfRegular)),
                          width: 200, // Set a specific width for the "Fees" column
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Amount Paid', style: pw.TextStyle(font: ttfRegular)),
                        ),
                      ],
                    ),
                    // Data rows (without border)
                    for (var fees in listOfFees)
                      pw.TableRow(
                        children: [
                          for (var entry in fees.entries)
                            pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              width: 100,
                              child: pw.RichText(
                                text: pw.TextSpan(
                                  text: '${entry.key}: ',
                                  children: [
                                    pw.TextSpan(
                                      text: entry.value.toString()
                                          .replaceAll('{', '').replaceAll('}', '')
                                          .replaceAll('[', '').replaceAll(']', ''),
                                      style: pw.TextStyle(
                                        font: isNumeric(entry.value) ? ttfBold : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (fees == listOfFees.first)
                            pw.Container(
                              padding: pw.EdgeInsets.all(2),
                              child: pw.RichText(
                                text: pw.TextSpan(
                                  children: [
                                    for (var entry in amountPaid)
                                      ...[
                                        pw.TextSpan(
                                          text: entry.keys.first,
                                          style: pw.TextStyle(font:ttfRegular),
                                        ),
                                        pw.TextSpan(
                                          text: ': ',
                                          style: pw.TextStyle(font:ttfRegular),
                                        ),
                                        pw.TextSpan(
                                          text: entry.values.first.toString(),
                                          style: pw.TextStyle(
                                            font: ttfBold,
                                            fontSize: 14
                                          ),
                                        ),
                                        pw.TextSpan(
                                          text: '\n',
                                        ),
                                      ],
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 50),
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text('As earlier conformed with thru the Online CRS-GP,', style: pw.TextStyle(font: ttfRegular)),
                      pw.SizedBox(height: 1.5),
                      pw.Text('I hereby agree to abide by and conform with the pertinent', style: pw.TextStyle(font: ttfRegular)),
                      pw.SizedBox(height: 1.5),
                      pw.Text('academic policies, rules, and regulations, of the University', style: pw.TextStyle(font: ttfRegular)),
                      pw.SizedBox(height: 1.5),
                      pw.Text('including those stipulated in the operative PLM Student Manual.', style: pw.TextStyle(font: ttfRegular)),
                      pw.SizedBox(height: 1.5),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Get the app's document directory
    final directory = (await getExternalStorageDirectory())!.path;
    final file = File('$directory/eaf_document.pdf');

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


  Widget CustomRadioButton(String text, int index) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedPaymentType = index;
          print("PAYMENT TYPE $_selectedPaymentType");
          print("CURRENT STEP $_currentStep");
          isLastPage = true;
        });
      },
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(
          color: (_selectedPaymentType == index) ? Colors.green : Colors.black,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: (_selectedPaymentType == index) ? Colors.green : Colors.black,
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: step < _currentStep
            ? Colors.green
            : (step == _currentStep
            ? Colors.red[900]
            : Colors.grey),
      ),
      child: Center(
        child: Text(
          step < _currentStep ? '✔' : '$step',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStepColumn(int step, String title) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 10.0),
        ),
      ],
    );
  }

  Widget _buildLineBetweenSteps(int step) {
    return Container(
      height: 2.0,
      width: 30.0,
      color: step < _currentStep
          ? Colors.green
          : (_currentStep == step
          ? Colors.red[900]
          : Colors.grey),
    );
  }

  void _submitButton(int selectedPayment, List<Map<String, dynamic>> selectedClasses) async {
    Map<String, double> result = calculateTotalAmount(selectedClasses, flags);
    double? totalAmount = result['totalAmount'];

    if (flags.isNotEmpty) {
      var flag = flags[0]['value']; // Assuming 'value' is the key you want
      var program = "CET";
      var id = studentId;

      await apiService.addBalance(id, totalAmount!, totalAmount, selectedPayment, program, flag);
      await apiService.addStudentClassInfo(id, selectedClasses);
      await apiService.updateStudentEnrollment(id);
      _handleNextButtonClick();

    } else {
      // Handle the case when flags is empty
      print('No flags available');
    }
  }


  Map<String, double> calculateTotalAmount(List<dynamic> selectedClasses, List<dynamic> flags) {
    double totalAmount = 0;
    double totalTuitionFee = 0;
    double countMiscellaneousFee = 0;
    double otherFee = 0;

    // Calculate total subject units
    int totalUnits = 0;
    for (var classInfo in selectedClasses) {
      totalUnits += (int.parse(classInfo['subjectUnits'].toString()) ?? 0);
    }
    print("TOTAL UNITS: $totalUnits");

    for (var flag in flags) {
      var id = flag['id'];
      var name = flag['name'];
      var value = flag['value'];

      // Check if the current flag is 'tuitionFee'
      if (name == 'tuitionFee') {
        // Get the value of 'tuitionFee'
        double tuitionFee = double.parse(value ?? '0');
        // Add the current tuition fee to the running total
        totalTuitionFee += totalUnits * tuitionFee;
      }

      // Convert 'id' to int for comparison
      var flagId = int.parse(id.toString() ?? '0');

      if (flagId > 2 && flagId < 8) {
        countMiscellaneousFee += double.parse(value ?? '0');
      } else if (flagId == 8) {
        otherFee += double.parse(value ?? '0');
      }
    }

    totalAmount = totalTuitionFee + countMiscellaneousFee + otherFee;
    print("TOTAL totalTuitionFee: $totalTuitionFee");
    print("TOTAL countMiscellaneousFee: $countMiscellaneousFee");
    print("TOTAL otherFee: $otherFee");
    print("TOTAL AMOUNT: $totalAmount");

    // Return the values as a map
    return {
      'totalAmount': totalAmount,
      'totalTuitionFee': totalTuitionFee,
      'countMiscellaneousFee': countMiscellaneousFee,
      'otherFee': otherFee,
    };
  }


  // Bottom Buttons
  void _handleNextButtonClick() {
    setState(() {
      if (_currentStep < 4) {
        _currentStep++;
      }
    });
  }

  void _handleBackButtonClick() {
    setState(() {
      if (_currentStep > 1) {
         isLastPage = false;
        _selectedPaymentType = 0;
        _currentStep--;
      }
    });
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
  // For Enlisting Subjects for step 1
  void onSelectedRow(bool selected, classInfo) {
    setState(() {
      if(selected){
        selectedClass.add(classInfo);
      }else{
        selectedClass.remove(classInfo);
      }
    });

  }

  bool isNumeric(dynamic value) {
    if (value is num) {
      return true;
    } else {
      final stringValue = '$value';
      return double.tryParse(stringValue) != null;
    }
  }
  // Function to build text from the list of dictionaries
  String buildTextFromAmountPaid(List<Map<String, dynamic>> amountPaid) {
    String result = '';
    for (var entry in amountPaid) {
      var key = entry.keys.first;
      var value = entry[key];
      result += '$key: $value\n';
    }
    return result;
  }
}



// Custom Search Bar
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      child: const TextField(
        style: TextStyle(fontSize: 14.0), // Adjust the font size
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Adjust padding
          labelText: 'Search',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}






