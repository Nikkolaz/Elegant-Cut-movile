import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/carita_widget.dart';

class BarbersPage extends StatefulWidget {
  const BarbersPage({super.key});

  @override
  State<BarbersPage> createState() => _BarbersPageState();
}

class _BarbersPageState extends State<BarbersPage> {
  int _selectedTab = 0;
  String _selectedCategory = 'Todos';

  final List<String> _categories = ['Todos', 'Clásicos', 'Degradados', 'Barba', 'Moderno'];

  final List<Map<String, dynamic>> _topBarbers = [
    {
      'name': 'Marcus "The Pro"',
      'desc': 'Experto en cortes urbanos',
      'rating': '5.0',
      'price': r'$25',
      'color': const Color(0xFF98E68E),
      'expression': 3,
    },
    {
      'name': 'Alex Master',
      'desc': 'Especialista en barbas',
      'rating': '4.9',
      'price': 'Libre',
      'color': const Color(0xFFFFB2D1),
      'expression': 1,
    },
  ];

  final List<Map<String, dynamic>> _allBarbers = [
    {
      'name': 'Corte con Tim',
      'desc': 'Clásico y elegante',
      'category': 'Clásicos',
      'rating': 50,
      'price': r'$15/c',
      'color': const Color(0xFF88C9F9),
      'expression': 0,
    },
    {
      'name': 'Pride Barber',
      'desc': 'Estilo vanguardista',
      'category': 'Moderno',
      'rating': 49,
      'price': r'$25/c',
      'color': const Color(0xFFFFD56B),
      'expression': 2,
    },
    {
      'name': 'News with Ani',
      'desc': 'Tendencias 2024',
      'category': 'Degradados',
      'rating': 32,
      'price': 'Cerrado',
      'color': const Color(0xFFC7B8F5),
      'expression': 4,
    },
    {
      'name': 'Virtual Stylist',
      'desc': 'Asesoría de imagen',
      'category': 'Moderno',
      'rating': 45,
      'price': r'$10/c',
      'color': const Color(0xFFA8E6CF),
      'expression': 1,
    },
    {
      'name': 'Beard Master',
      'desc': 'Cuidado de barba pro',
      'category': 'Barba',
      'rating': 48,
      'price': r'$20/c',
      'color': const Color(0xFFFF9E80),
      'expression': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Lógica de filtrado
    final filteredBarbers = _selectedCategory == 'Todos' 
        ? _allBarbers 
        : _allBarbers.where((b) => b['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 1. TABS SUPERIORES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      _buildTopTab('Top Barberos', 0),
                      _buildTopTab('Nuevos', 1),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 2. HORIZONTAL TOP BARBERS
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _topBarbers.length,
                  itemBuilder: (context, index) {
                    return _buildFeaturedCard(_topBarbers[index], isDark);
                  },
                ),
              ),

              const SizedBox(height: 30),

              // 3. SECCIÓN "TODOS LOS BARBEROS"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Todos los Barberos',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.tune, color: isDark ? Colors.grey : Colors.black54),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 4. CATEGORÍAS (CHIPS)
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _selectedCategory = cat),
                        labelStyle: GoogleFonts.outfit(
                          color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        selectedColor: const Color(0xFFFFD56B),
                        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        elevation: 0,
                        pressElevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide.none,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 5. LISTA VERTICAL FILTRADA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: filteredBarbers.isEmpty 
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          'No hay barberos en esta categoría',
                          style: GoogleFonts.outfit(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      children: filteredBarbers.map((barber) => _buildListItem(barber, isDark)).toList(),
                    ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFD56B) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> barber, bool isDark) {
    return Container(
      width: 170,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          // Avatar
          SizedBox(
            width: 80,
            height: 80,
            child: CaritaWidget(
              size: 80,
              color: barber['color'] as Color,
              expressionType: barber['expression'] as int,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            barber['name'] as String,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          Text(
            barber['desc'] as String,
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // Bottom Bar
          Container(
            height: 45,
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFD48B41), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      barber['rating'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  barber['price'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> barber, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          // Circular Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (barber['color'] as Color).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: CaritaWidget(
                size: 60,
                color: barber['color'] as Color,
                expressionType: barber['expression'] as int,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barber['name'] as String,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  barber['desc'] as String,
                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Rating
          Row(
            children: [
              Text(
                barber['rating'].toString(),
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Color(0xFFD48B41), size: 14),
            ],
          ),
          const SizedBox(width: 15),
          // Action Area
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Icon(
                  barber['price'] == 'Cerrado' ? Icons.volume_off : Icons.chat_bubble_outline,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  barber['price'] as String,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: barber['price'] == 'Cerrado' ? Colors.red.shade300 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
