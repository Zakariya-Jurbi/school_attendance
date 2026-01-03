import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../objects/user.dart';
import '../objects/classroom.dart';

class AttendancePage extends StatefulWidget {
  final Classroom classroom;
  final User user;

  const AttendancePage({
    super.key,
    required this.classroom,
    required this.user
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<String> attendanceDates = [];
  bool isLoading = true;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;


  final Color primaryGreen = const Color(0xFF16A34A);
  final Color backgroundColor = const Color(0xFFF8FCF8);

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    setState(() => isLoading = true);
    final url = Uri.parse(
        "http://abohmed.atwebpages.com/get_attendance.php?student_id=${widget.user.id}&classroom_id=${widget.classroom.id}"
    );

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);
        setState(() {
          attendanceDates = data
              .where((item) => item['status'] == 'Present')
              .map((item) => item['date'].toString())
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  bool isPresent(int day) {
    String formattedDate = "$selectedYear-${selectedMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
    return attendanceDates.contains(formattedDate);
  }

  double calculatePercentage(int totalDays) {
    if (totalDays == 0) return 0.0;
    int count = attendanceDates.where((d) => d.contains("-${selectedMonth.toString().padLeft(2, '0')}-")).length;
    return (count / totalDays) * 100;
  }

  int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    int totalDays = getDaysInMonth(selectedYear, selectedMonth);
    double percent = calculatePercentage(totalDays);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text("Attendance History",
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildStatsRow(percent),
                  const Divider(color: Colors.black12, height: 32),
                  _buildSelectors(),
                  const SizedBox(height: 20),
                  _buildCalendarGrid(totalDays),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.user.name.toUpperCase(),
            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 18)),
        Text("Class: ${widget.classroom.name}",
            style: const TextStyle(color: Colors.black54, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatsRow(double percent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Monthly View",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        Text("${percent.toStringAsFixed(0)}% Present",
            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSelectors() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<int>(
          value: selectedMonth,
          dropdownColor: Colors.white,
          underline: const SizedBox(),
          style: const TextStyle(color: Colors.black),
          items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text("Month ${i + 1}"))),
          onChanged: (val) => setState(() => selectedMonth = val!),
        ),
        DropdownButton<int>(
          value: selectedYear,
          dropdownColor: Colors.white,
          underline: const SizedBox(),
          style: const TextStyle(color: Colors.black),
          items: List.generate(5, (i) => DropdownMenuItem(value: 2026 - i, child: Text("${2026 - i}"))),
          onChanged: (val) => setState(() => selectedYear = val!),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(int totalDays) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: totalDays,
      itemBuilder: (context, index) {
        final day = index + 1;
        bool present = isPresent(day);
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: present ? primaryGreen.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: present ? primaryGreen : Colors.transparent),
          ),
          child: Text("$day",
              style: TextStyle(
                  color: present ? primaryGreen : Colors.black38,
                  fontWeight: present ? FontWeight.bold : FontWeight.normal
              )),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _dot(primaryGreen), const Text(" Present", style: TextStyle(color: Colors.black54)),
        const SizedBox(width: 20),
        _dot(Colors.black12), const Text(" Absent/No Data", style: TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _dot(Color color) => Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}