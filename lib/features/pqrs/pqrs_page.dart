import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/pqrs_api_service.dart';

class PqrsPage extends StatefulWidget {
  const PqrsPage({super.key});

  @override
  State<PqrsPage> createState() => _PqrsPageState();
}

class _PqrsPageState extends State<PqrsPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Petición';
  final List<String> _pqrsTypes = ['Petición', 'Queja', 'Reclamo', 'Sugerencia'];
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isSubmitting = true; });

      try {
        final prefs = await SharedPreferences.getInstance();
        final idUsuario = prefs.getInt('id_usuario') ?? 1;
        final email = prefs.getString('email') ?? 'anonimo@example.com';
        final nombreCompleto = prefs.getString('firstName') ?? 'Usuario Anónimo';
        final String tipoAEnviar = _selectedType == 'Petición' ? 'Peticion' : _selectedType;

        final apiService = PqrsApiService();
        final result = await apiService.createPqrs(
          idUsuario: idUsuario,
          tipoSolicitud: tipoAEnviar,
          nombreCompleto: nombreCompleto,
          email: email,
          asunto: '$_selectedType desde App',
          descripcion: _detailController.text.trim(),
          telefono: _contactController.text.trim(),
        );

        if (!mounted) return;

        setState(() { _isSubmitting = false; });

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡$_selectedType enviada con éxito! La administración atenderá su caso pronto.', style: GoogleFonts.outfit()), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Error al enviar la $_selectedType', style: GoogleFonts.outfit()), behavior: SnackBarBehavior.floating, backgroundColor: Colors.red.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() { _isSubmitting = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión. Inténtalo de nuevo más tarde.', style: GoogleFonts.outfit()), behavior: SnackBarBehavior.floating, backgroundColor: Colors.red.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      }
    }
  }

  @override
  void dispose() {
    _detailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Buzón PQRS', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Cómo podemos ayudarte?', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 10),
              Text('Selecciona el tipo de solicitud y detalla los motivos para que nuestra administración pueda atender y resolver tu caso.', style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.5)),
              const SizedBox(height: 30),

              Text('Tipo de Solicitud', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                    style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87, fontSize: 16),
                    items: _pqrsTypes.map((String type) { return DropdownMenuItem<String>(value: type, child: Text(type)); }).toList(),
                    onChanged: (String? newValue) { if (newValue != null) { setState(() { _selectedType = newValue; }); } },
                  ),
                ),
              ),
              const SizedBox(height: 25),

              Text('Detalle y Motivos', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _detailController,
                maxLines: 5,
                style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Describe detalladamente tu $_selectedType...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD48B41), width: 2)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Por favor, ingresa los detalles.';
                  if (value.trim().length < 10) return 'El detalle debe ser más descriptivo (mín. 10 caracteres).';
                  return null;
                },
              ),
              const SizedBox(height: 25),

              Text('Contacto (Email o Teléfono)', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactController,
                style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Para poder darte una respuesta...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD48B41), width: 2)),
                  prefixIcon: Icon(Icons.contact_mail_outlined, color: Colors.grey.shade500),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Por favor, proporciona un medio de contacto.';
                  return null;
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD48B41),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Text('Enviar Solicitud', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
