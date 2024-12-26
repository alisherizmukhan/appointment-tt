import 'package:flutter/material.dart';
import 'date_time_screen.dart';

class PatientInfoScreen extends StatefulWidget {
  final Map<String, String> selectedOption;

  const PatientInfoScreen({super.key, required this.selectedOption});

  @override
  _PatientInfoScreenState createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  bool isSelfSelected = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController iinController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 40,
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
              'Выберите кого хотите записать',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      alignment: isSelfSelected
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 32,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4435FF),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior
                                .translucent,
                            onTap: () {
                              setState(() {
                                isSelfSelected = true;
                              });
                            },
                            child: Center(
                              child: Text(
                                'Себя',
                                style: TextStyle(
                                  color: isSelfSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior
                                .translucent,
                            onTap: () {
                              setState(() {
                                isSelfSelected = false;
                              });
                            },
                            child: Center(
                              child: Text(
                                'Другого',
                                style: TextStyle(
                                  color: isSelfSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isSelfSelected
                    ? _buildSelfInfo()
                    : _buildOtherInfo(),
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationButtons(
              context,
              isSelfSelected || _isOtherInfoValid(),
              onBack: () {
                Navigator.pop(context);
              },
              onNext: isSelfSelected || _isOtherInfoValid()
                  ? () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => DateTimeScreen(
                            type: widget.selectedOption['title'] ==
                                    'Онлайн-консультация'
                                ? 'online'
                                : 'offline',
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
        _buildStepLine(isActive: true),
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

  Widget _buildSelfInfo() {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        key: const ValueKey(1),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Имя и фамилия:', 'Иванов Иван'),
          _buildInfoRow('ИИН:', '041115486195'),
          _buildInfoRow('Номер телефона:', '+7 707 748 4815'),
          _buildInfoRow('Адрес прописки:', 'ул. Гани Иляева 15'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOtherInfo() {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        key: const ValueKey(2),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledTextField(
            label: 'Имя и фамилия',
            hint: 'Введите имя человека',
            controller: nameController,
          ),
          _buildLabeledTextField(
            label: 'ИИН',
            hint: 'Введите ИИН человека',
            controller: iinController,
          ),
          _buildLabeledTextField(
            label: 'Номер телефона',
            hint: 'Введите номер телефона',
            controller: phoneController,
          ),
          _buildLabeledTextField(
            label: 'Адрес',
            hint: 'Адрес прописки',
            controller: addressController,
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(color: Color(0xFF4435FF), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  bool _isOtherInfoValid() {
    return nameController.text.isNotEmpty &&
        iinController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        addressController.text.isNotEmpty;
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
