import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentService {
  final String baseUrl = 'https://phydoc-test-2d45590c9688.herokuapp.com';

  Future<List<Map<String, dynamic>>> fetchSchedules(String type) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/get_schedule?type=$type'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['slots']);
      } else {
        throw Exception('Failed to fetch schedules: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching schedules: $e');
    }
  }

  Future<void> createAppointment(int slotId, String type) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/appoint'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'slot_id': slotId, 'type': type}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('Appointment created successfully');
      } else {
        final error = json.decode(response.body);
        throw Exception('Failed to create appointment: ${error['detail']}');
      }
    } catch (e) {
      throw Exception('Error creating appointment: $e');
    }
  }
}
