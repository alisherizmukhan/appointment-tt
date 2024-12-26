import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'confirmation_screen.dart';
import '../services/appointment_service.dart';

class DateTimeScreen extends StatefulWidget {
  final String type;

  const DateTimeScreen({super.key, required this.type});

  @override
  _DateTimeScreenState createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<Map<String, dynamic>> schedules = [];
  List<Map<String, dynamic>> visibleSchedules = [];
  Map<String, dynamic>? selectedSlot;
  bool isLoading = true;
  String? errorMessage;
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null).then((_) {
      _fetchSchedules();
    }).catchError((error) {
      setState(() {
        errorMessage = 'Ошибка инициализации локализации: $error';
        isLoading = false;
      });
    });
  }

  Future<void> _fetchSchedules() async {
    try {
      final fetchedSchedules =
          await _appointmentService.fetchSchedules(widget.type);
      setState(() {
        schedules = fetchedSchedules;
        visibleSchedules = _getFirstTwoDates(fetchedSchedules);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка загрузки расписания: $e';
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFirstTwoDates(
      List<Map<String, dynamic>> allSchedules) {
    Map<String, List<Map<String, dynamic>>> groupedSlots = {};
    for (var slot in allSchedules) {
      final date = DateFormat('d MMMM, EEEE', 'ru').format(
        DateTime.parse(slot['datetime']),
      );
      if (!groupedSlots.containsKey(date)) {
        groupedSlots[date] = [];
      }
      groupedSlots[date]!.add(slot);
    }
    final firstTwoDates = groupedSlots.keys.take(2).toList();
    return allSchedules
        .where((slot) => firstTwoDates.contains(
              DateFormat('d MMMM, EEEE', 'ru')
                  .format(DateTime.parse(slot['datetime'])),
            ))
        .toList();
  }

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
              'Выберите дату и время',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildWarningBox(),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : visibleSchedules.isEmpty
                          ? Center(
                              child: Text(
                                'Нет доступных временных слотов',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            )
                          : ListView(
                              children: _buildSlotWidgets(
                                  showAll ? schedules : visibleSchedules),
                            ),
            ),
            if (!isLoading && schedules.length > visibleSchedules.length)
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showAll = true;
                      visibleSchedules = schedules;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4435FF)),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    'Показать еще',
                    style: TextStyle(
                      color: Color(0xFF4435FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            label: const Text(
              'Назад',
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              shape: const StadiumBorder(),
              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: selectedSlot != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmationScreen(
                          selectedSlot: {
                            'id': selectedSlot!['id'],
                            'time': DateFormat('HH:mm').format(
                                DateTime.parse(
                                    selectedSlot!['datetime'])),
                            'date': DateFormat('d MMMM', 'ru').format(
                                DateTime.parse(
                                    selectedSlot!['datetime'])),
                            'price': selectedSlot!['price'],
                          },
                          appointmentType: widget.type,
                          patientName: 'Иванов Иван',
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedSlot != null
                  ? const Color(0xFF4435FF)
                  : Colors.grey.shade300,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 48, vertical: 16),
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

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepLine(isActive: true),
        _buildStepLine(isActive: true),
        _buildStepLine(isActive: true),
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

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning,
                  color: Color(0xFFDC6803),
                  size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Отмена и изменение времени приема может стоить денег.',
                      style: TextStyle(
                        color: Color(0xFFA66C47),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: const BorderSide(
                              color: Color(
                                  0xFFD8BFB2)),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                      ),
                      child: const Text(
                        'Подробнее',
                        style: TextStyle(
                          color: Color(0xFFA66C47),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSlotWidgets(List<Map<String, dynamic>> schedulesToShow) {
    Map<String, List<Map<String, dynamic>>> groupedSlots = {};
    for (var slot in schedulesToShow) {
      final date = DateFormat('d MMMM, EEEE', 'ru').format(
        DateTime.parse(slot['datetime']),
      );
      if (!groupedSlots.containsKey(date)) {
        groupedSlots[date] = [];
      }
      groupedSlots[date]!.add(slot);
    }

    return groupedSlots.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.key,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entry.value.map((slot) {
              final time = DateFormat('HH:mm').format(
                DateTime.parse(slot['datetime']),
              );
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSlot = slot;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: selectedSlot == slot
                        ? const Color(0xFF4435FF)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: selectedSlot == slot
                          ? const Color(0xFF4435FF)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: selectedSlot == slot
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${slot['price']}₸',
                        style: TextStyle(
                          color: selectedSlot == slot
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}
