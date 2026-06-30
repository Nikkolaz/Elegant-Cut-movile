import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/custom_toast.dart';

class AdminBarberFormDialog extends StatefulWidget {
  final Map<String, dynamic>? barber;
  final Future<bool> Function(Map<String, dynamic> data) onSave;

  const AdminBarberFormDialog({
    super.key,
    this.barber,
    required this.onSave,
  });

  @override
  State<AdminBarberFormDialog> createState() => _AdminBarberFormDialogState();
}

class _AdminBarberFormDialogState extends State<AdminBarberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _firstNameController;
  late final TextEditingController _secondNameController;
  late final TextEditingController _lastName1Controller;
  late final TextEditingController _lastName2Controller;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _bioController;
  late final TextEditingController _experienceController;
  late final TextEditingController _specialtiesController;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final b = widget.barber;
    
    // Parse first name and second name if they exist in nested properties or combined
    String firstName = '';
    String secondName = '';
    String lastName1 = '';
    String lastName2 = '';

    if (b != null) {
      firstName = b['prim_nombre'] ?? '';
      secondName = b['seg_nombre'] ?? '';
      lastName1 = b['apellido1'] ?? '';
      lastName2 = b['apellido2'] ?? '';
      
      // Fallback if name is single string in response
      if (firstName.isEmpty && b['name'] != null) {
        final parts = (b['name'] as String).split(' ');
        if (parts.isNotEmpty) firstName = parts[0];
        if (parts.length > 1) lastName1 = parts[1];
        if (parts.length > 2) lastName2 = parts.sublist(2).join(' ');
      }
    }

    _firstNameController = TextEditingController(text: firstName);
    _secondNameController = TextEditingController(text: secondName);
    _lastName1Controller = TextEditingController(text: lastName1);
    _lastName2Controller = TextEditingController(text: lastName2);
    _emailController = TextEditingController(text: b?['email'] ?? '');
    _usernameController = TextEditingController(text: b?['username'] ?? '');
    _phoneController = TextEditingController(text: b?['telefono'] ?? b?['phone'] ?? '');
    _passwordController = TextEditingController();
    
    // Portfolio fields
    final portfolio = b != null ? (b['portafolios'] ?? b) : null;
    _bioController = TextEditingController(text: portfolio?['biografia'] ?? portfolio?['biography'] ?? '');
    _experienceController = TextEditingController(text: portfolio?['experiencia'] ?? portfolio?['experience'] ?? '');
    
    String specs = '';
    if (portfolio?['especialidades'] != null) {
      if (portfolio['especialidades'] is List) {
        specs = (portfolio['especialidades'] as List).join(', ');
      } else {
        specs = portfolio['especialidades'].toString();
      }
    } else if (b?['specialties'] != null) {
      if (b!['specialties'] is List) {
        specs = (b['specialties'] as List).join(', ');
      } else {
        specs = b['specialties'].toString();
      }
    }
    _specialtiesController = TextEditingController(text: specs);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _lastName1Controller.dispose();
    _lastName2Controller.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _specialtiesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'prim_nombre': _firstNameController.text.trim(),
      'seg_nombre': _secondNameController.text.trim(),
      'apellido1': _lastName1Controller.text.trim(),
      'apellido2': _lastName2Controller.text.trim(),
      'email': _emailController.text.trim(),
      'username': _usernameController.text.trim().isEmpty 
          ? _emailController.text.trim().split('@')[0] 
          : _usernameController.text.trim(),
      'telefono': _phoneController.text.trim(),
      'biografia': _bioController.text.trim(),
      'experiencia': _experienceController.text.trim(),
      'especialidades': _specialtiesController.text.trim(),
    };

    if (widget.barber == null) {
      data['password_hash'] = _passwordController.text.trim();
    } else {
      if (_passwordController.text.trim().isNotEmpty) {
        data['password_hash'] = _passwordController.text.trim();
      }
    }

    final success = await widget.onSave(data);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);
    final isEdit = widget.barber != null;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              child: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_rounded : Icons.person_add_alt_1_rounded,
                    color: primaryGold,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Editar Barbero' : 'Nuevo Barbero',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Form content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Información Personal', isDark),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              label: 'Primer Nombre *',
                              hint: 'Ej. Juan',
                              isDark: isDark,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _secondNameController,
                              label: 'Segundo Nombre',
                              hint: 'Ej. Carlos',
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _lastName1Controller,
                              label: 'Primer Apellido *',
                              hint: 'Ej. Pérez',
                              isDark: isDark,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastName2Controller,
                              label: 'Segundo Apellido',
                              hint: 'Ej. Gómez',
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Correo Electrónico *',
                        hint: 'barbero@elegantcut.com',
                        isDark: isDark,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v!.isEmpty) return 'El correo es obligatorio';
                          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegExp.hasMatch(v)) return 'Ingrese un correo válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _usernameController,
                              label: 'Usuario',
                              hint: 'Ej. juanbarber',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              label: 'Teléfono',
                              hint: 'Ej. 3001234567',
                              isDark: isDark,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Seguridad', isDark),
                      _buildTextField(
                        controller: _passwordController,
                        label: isEdit ? 'Cambiar Contraseña' : 'Contraseña *',
                        hint: isEdit ? 'Dejar en blanco para no cambiar' : 'Mínimo 6 caracteres',
                        isDark: isDark,
                        obscure: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (!isEdit && (v == null || v.isEmpty)) {
                            return 'La contraseña es obligatoria';
                          }
                          if (v != null && v.isNotEmpty && v.length < 6) {
                            return 'Debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Perfil Profesional', isDark),
                      _buildTextField(
                        controller: _experienceController,
                        label: 'Experiencia',
                        hint: 'Ej. 5 años / Especialista en degradados',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _specialtiesController,
                        label: 'Especialidades',
                        hint: 'Ej. Degradados, Barba (Separado por comas)',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _bioController,
                        label: 'Biografía',
                        hint: 'Escribe una breve descripción del barbero...',
                        isDark: isDark,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            // Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGold,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              isEdit ? 'Guardar' : 'Crear',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFD48B41),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    bool obscure = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 13),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD48B41), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
