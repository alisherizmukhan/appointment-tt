import 'package:go_router/go_router.dart';
import '../screens/appointment_format_screen.dart';
import '../screens/patient_info_screen.dart';
import '../screens/date_time_screen.dart';
import '../screens/confirmation_screen.dart';
import '../screens/success_screen.dart';

class AppRoutes {
  static const String appointmentFormat = '/';
  static const String patientInfo = '/patient-info';
  static const String dateTime = '/date-time';
  static const String confirmation = '/confirmation';
  static const String success = '/success';

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: appointmentFormat,
        builder: (context, state) => const AppointmentFormatScreen(),
      ),
      GoRoute(
        path: patientInfo,
        builder: (context, state) => PatientInfoScreen(
          selectedOption: state.extra as Map<String, String>,
        ),
      ),
      GoRoute(
        path: dateTime,
        builder: (context, state) {
          final type = state.extra as String;
          return DateTimeScreen(type: type);
        },
      ),
      GoRoute(
        path: confirmation,
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          return ConfirmationScreen(
            selectedSlot:
                params['selectedSlot'],
            appointmentType:
                params['appointmentType'],
            patientName: params['patientName'],
          );
        },
      ),
      GoRoute(
        path: success,
        builder: (context, state) => const SuccessScreen(),
      ),
    ],
  );
}
