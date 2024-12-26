import 'package:flutter/material.dart';
import 'patient_info_screen.dart';

class AppointmentFormatScreen extends StatefulWidget {
  const AppointmentFormatScreen({super.key});

  @override
  _AppointmentFormatScreenState createState() =>
      _AppointmentFormatScreenState();
}

class _AppointmentFormatScreenState extends State<AppointmentFormatScreen> {
  int? selectedIndex;

  final List<Map<String, String>> options = [
    {
      'title': 'Онлайн-консультация',
      'description':
          'Врач созвонится с вами и проведет консультацию в приложении.'
    },
    {
      'title': 'Записаться в клинику',
      'description': 'Врач будет ждать вас в своем кабинете в клинике.'
    },
    {
      'title': 'Вызвать на дом',
      'description': 'Врач сам приедет к вам домой в указанное время и дату.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 30,
        flexibleSpace: Stack(
          children: [
            Center(
              child: _buildStepIndicator(),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: _buildCloseButton(),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Выберите формат приема',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return _buildOptionCard(index);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationButtons(
              context,
              selectedIndex != null,
              onBack: () {
                Navigator.pop(context);
              },
              onNext: selectedIndex != null
                  ? () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => PatientInfoScreen(
                            selectedOption: options[selectedIndex!],
                          ),
                          transitionsBuilder:
                              (_, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            final offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepLine(isActive: true),
        _buildStepLine(isActive: false),
        _buildStepLine(isActive: false),
      ],
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      width: 30,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4435FF) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.close, color: Colors.grey.shade600),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    final option = options[index];
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECEBFF) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? const Color(0xFF4435FF) : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option['title']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              option['description']!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    bool isNextEnabled, {
    required VoidCallback onBack,
    required VoidCallback? onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            label: const Text(
              'Назад',
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: const StadiumBorder(),
              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isNextEnabled ? const Color(0xFF4435FF) : Colors.grey.shade300,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Дальше',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
