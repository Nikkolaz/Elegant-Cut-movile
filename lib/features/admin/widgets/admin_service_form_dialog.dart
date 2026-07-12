import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/admin_service.dart';

class AdminServiceFormDialog extends StatefulWidget {
  final Map<String, dynamic>? service;
  final Future<bool> Function(Map<String, dynamic> data) onSave;

  const AdminServiceFormDialog({
    super.key,
    this.service,
    required this.onSave,
  });

  @override
  State<AdminServiceFormDialog> createState() => _AdminServiceFormDialogState();
}

class _AdminServiceFormDialogState extends State<AdminServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();

  bool _isLoading = false;
  bool _isLoadingCategories = true;
  String _categoriesError = '';

  List<dynamic> _categories = [];
  int? _selectedCategoryId;

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameController = TextEditingController(text: s?['nombre_servicio'] ?? '');
    _priceController = TextEditingController(
      text: s?['precio'] != null ? s!['precio'].toString() : '',
    );
    _durationController = TextEditingController(
      text: s?['duracion_minutos'] != null ? s!['duracion_minutos'].toString() : '',
    );
    _descriptionController = TextEditingController(text: s?['descripcion'] ?? '');
    _selectedCategoryId = s?['id_categoria'];
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = '';
    });
    try {
      final response = await _adminService.getServiceCategories();
      if (!mounted) return;
      if (response['success'] == true) {
        setState(() {
          _categories = response['data'] ?? [];
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _categoriesError = response['message'] ?? 'Error al cargar categorías';
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = 'Error de conexión al cargar categorías';
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecciona una categoría', style: GoogleFonts.outfit()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'nombre': _nameController.text.trim(),
      'precio': double.parse(_priceController.text.trim()),
      'duracion': int.parse(_durationController.text.trim()),
      'descripcion': _descriptionController.text.trim(),
      'id_categoria': _selectedCategoryId,
    };

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
    final isEdit = widget.service != null;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              child: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_rounded : Icons.add_circle_outline_rounded,
                    color: primaryGold,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Editar Servicio' : 'Nuevo Servicio',
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
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Form ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Información del Servicio', isDark),

                      _buildTextField(
                        controller: _nameController,
                        label: 'Nombre del Servicio *',
                        hint: 'Ej. Corte de Cabello',
                        isDark: isDark,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _priceController,
                              label: 'Precio *',
                              hint: 'Ej. 15000',
                              isDark: isDark,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Requerido';
                                final n = double.tryParse(v.trim());
                                if (n == null || n <= 0) return 'Debe ser > 0';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _durationController,
                              label: 'Duración (min) *',
                              hint: 'Ej. 45',
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Requerido';
                                final n = int.tryParse(v.trim());
                                if (n == null || n <= 0) return 'Debe ser > 0';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Descripción *',
                        hint: 'Escribe una descripción del servicio...',
                        isDark: isDark,
                        maxLines: 3,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'La descripción es obligatoria' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildSectionTitle('Categoría', isDark),
                      _buildCategoryDropdown(isDark, primaryGold),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // ── Actions ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        ),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
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

  Widget _buildCategoryDropdown(bool isDark, Color primaryGold) {
    if (_isLoadingCategories) {
      return Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  color: Color(0xFFD48B41), strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Cargando categorías...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_categoriesError.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _categoriesError,
                style: GoogleFonts.outfit(
                    color: Colors.redAccent, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: _loadCategories,
              child: Text('Reintentar',
                  style: GoogleFonts.outfit(
                      color: primaryGold, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'No hay categorías disponibles.',
          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría *',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: _selectedCategoryId == null
                ? Border.all(color: Colors.transparent)
                : Border.all(
                    color: const Color(0xFFD48B41).withOpacity(0.6),
                    width: 1.5,
                  ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedCategoryId,
              isExpanded: true,
              hint: Text(
                'Selecciona una categoría',
                style: GoogleFonts.outfit(
                    color: Colors.grey.shade500, fontSize: 14),
              ),
              dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              items: _categories.map<DropdownMenuItem<int>>((cat) {
                final id = cat['id_categoria'] as int;
                final nombre = cat['nombre']?.toString() ?? 'Categoría';
                final genero =
                    cat['genero_servicio']?['nombre']?.toString() ?? '';
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(
                    genero.isNotEmpty ? '$nombre — $genero' : nombre,
                    style: GoogleFonts.outfit(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
            ),
          ),
        ),
      ],
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
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
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
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.outfit(
              color: isDark ? Colors.white : Colors.black87, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 13),
            filled: true,
            fillColor:
                isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: Color(0xFFD48B41), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
