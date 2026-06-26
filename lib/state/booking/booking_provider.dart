import 'package:flutter/material.dart';
import '../../core/network/barber_api_service.dart';
import '../../core/network/services_api_service.dart';
import '../../core/network/booking_api_service.dart';

class BookingProvider extends ChangeNotifier {
  final BarberApiService _barberApi = BarberApiService();
  final ServicesApiService _servicesApi = ServicesApiService();
  final BookingApiService _bookingApi = BookingApiService();

  bool _isLoading = false;
  List<Map<String, dynamic>> _barbers = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _selectedServices = [];
  List<Map<String, dynamic>> _timeSlots = [];
  bool _isLoadingSlots = false;
  DateTime? _selectedDate;
  int? _selectedTimeSlot;
  int _selectedBarber = 0;
  int _currentStep = 0;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get barbers => _barbers;
  List<Map<String, dynamic>> get services => _services;
  List<Map<String, dynamic>> get selectedServices => _selectedServices;
  List<Map<String, dynamic>> get timeSlots => _timeSlots;
  bool get isLoadingSlots => _isLoadingSlots;
  DateTime? get selectedDate => _selectedDate;
  int? get selectedTimeSlot => _selectedTimeSlot;
  int get selectedBarber => _selectedBarber;
  int get currentStep => _currentStep;

  double get total {
    double sum = 0;
    for (final s in _selectedServices) {
      final precio = s['precio'];
      if (precio is num) {
        sum += precio.toDouble();
      } else {
        final priceStr = s['price']?.toString().replaceAll('\$', '') ?? '0';
        sum += double.tryParse(priceStr) ?? 0;
      }
    }
    return sum;
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _barbers = await _barberApi.getBarbers();
      _services = await _servicesApi.getServices();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  void toggleService(Map<String, dynamic> service) {
    final idx = _selectedServices.indexWhere(
      (s) => s['id'] == service['id'],
    );
    if (idx >= 0) {
      _selectedServices.removeAt(idx);
    } else {
      _selectedServices.add(service);
    }
    notifyListeners();
  }

  bool isServiceSelected(Map<String, dynamic> service) {
    return _selectedServices.any((s) => s['id'] == service['id']);
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void selectBarber(int index) {
    _selectedBarber = index;
    notifyListeners();
  }

  Future<void> loadTimeSlots(DateTime date, int barberId) async {
    _isLoadingSlots = true;
    _selectedTimeSlot = null;
    notifyListeners();

    try {
      _timeSlots = await _bookingApi.getAvailableSlots(date, barberId);
    } catch (_) {
      _timeSlots = [];
    }

    _isLoadingSlots = false;
    notifyListeners();
  }

  void selectTimeSlot(int index) {
    _selectedTimeSlot = index;
    notifyListeners();
  }

  Future<bool> createAppointment({
    required int barberId,
    required List<int> serviceIds,
    required DateTime date,
    required int idHorario,
    String? observaciones,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _bookingApi.createAppointment(
        barberId: barberId,
        serviceIds: serviceIds,
        date: date,
        idHorario: idHorario,
        observaciones: observaciones ?? '',
      );

      _isLoading = false;
      notifyListeners();

      if (success) {
        _resetBooking();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _resetBooking() {
    _selectedServices = [];
    _selectedDate = null;
    _selectedTimeSlot = null;
    _selectedBarber = 0;
    _currentStep = 0;
    _timeSlots = [];
    notifyListeners();
  }

  void reset() {
    _resetBooking();
  }
}
