
// MODEL THAT IS USED FOR RECEIVING THE OF FACULTY COMING FROM getFacultyRemarks
class CRSGPdfModel {
  int studentNo;
  String studentName;
  String studentCourse;
  String college;
  String aysem;
  String paymentTerm;
  List<Map<String, dynamic>> selectedClass;
  double tuitionFee;
  double miscellaneousFee;
  double otherFees;
  double totalAmount;
  int paymentType;
  String dateAssessed;
  List<Map<String, dynamic>> payment;

  CRSGPdfModel({
    required this.studentNo,
    required this.studentName,
    required this.studentCourse,
    required this.college,
    required this.aysem,
    required this.paymentTerm,
    required this.selectedClass,
    required this.tuitionFee,
    required this.miscellaneousFee,
    required this.otherFees,
    required this.totalAmount,
    required this.paymentType,
    required this.dateAssessed,
    required this.payment });


  // factory SFEFacultyModel.fromJson(Map<String, dynamic> json) {
  //   return SFEFacultyModel(
  //     facultyName: json['name'] ?? '',
  //     subCode: json['subjectname'] ?? '', // Provide a default value (0 in this case) if 'choiceid' is null
  //     section: int.tryParse(json['section'].toString()) ?? 0, // Provide a default value (0 in this case) if 'choiceid' is null
  //     subTitle: json['subjecttitle'] ?? '',
  //     facAverage: json['facultyassess'] ?? 0.0,
  //     facAdjRating: json['facultyassess_scale'] ?? '',// Provide a default value (0 in this case) if 'choicenum' is null
  //     corAverage: json['courseassess'] ?? 0.0,
  //     corAdjRating: json['courseassess_scale'] ?? '', // Provide a default value (0 in this case) if 'choicenum' is null
  //     selfAverage: json['selfassess'] ?? 0.0,
  //     selfAdjRating: json['selfassess_scale'] ?? '', // Provide a default value (0 in this case) if 'choicenum' is nul
  //     aysem : json['aysem'] ?? 0,
  //   );
  // }
}