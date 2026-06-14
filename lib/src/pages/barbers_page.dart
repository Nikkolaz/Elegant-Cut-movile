import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/carita_widget.dart';
import 'barber_detail_page.dart';
import '../api/barber_api_service.dart';

class BarbersPage extends StatefulWidget {
  const BarbersPage({super.key});

  @override
  State<BarbersPage> createState() => _BarbersPageState();
}

class _BarbersPageState extends State<BarbersPage> {
  int _selectedTab = 0;
  String _selectedCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: BarberApiService().getBarbers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)));
            }

            final apiBarbers = snapshot.data ?? [];
            final Set<String> categoriesSet = {'Todos'};
            for (var b in apiBarbers) {
              if (b['specialty'] != null) {
                categoriesSet.add(b['specialty'].toString().split(',').first.trim());
              }
            }
            final dynamicCategories = categoriesSet.toList();

            final filteredBarbers = _selectedCategory == 'Todos' 
                ? apiBarbers 
                : apiBarbers.where((b) => b['specialty']?.contains(_selectedCategory) == true).toList();
            
            final topBarbers = apiBarbers.take(3).toList();

            return SingleChildScrollView(
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
                      itemCount: topBarbers.length,
                      itemBuilder: (context, index) {
                        return _buildFeaturedCard(context, topBarbers[index], isDark);
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: dynamicCategories.map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _buildFilterChip(cat, isDark),
                          );
                        }).toList(),
                      ),
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
                          children: filteredBarbers.map((barber) => _buildListItem(context, barber, isDark)).toList(),
                        ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
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

  Widget _buildFilterChip(String cat, bool isDark) {
    final isSelected = _selectedCategory == cat;
    return ChoiceChip(
      label: Text(cat),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedCategory = cat),
      labelStyle: GoogleFonts.outfit(
        color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: const Color(0xFFFFD56B),
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Map<String, dynamic> barber, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarberDetailPage(barber: barber),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
        children: [
          const SizedBox(height: 15),
          SizedBox(
            width: 80,
            height: 80,
            child: CaritaWidget(
              size: 80,
              color: const Color(0xFF88C9F9),
              expressionType: barber['expression'] ?? 0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            barber['name'] ?? 'Barbero',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          Text(
            barber['specialty'] ?? 'Profesional',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.black54,
            ),
          ),
          const Spacer(),
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
                    const Icon(Icons.star_rounded, color: Color(0xFFD48B41), size: 18),
                    const SizedBox(width: 5),
                    Text(
                      '${barber['rating'] ?? 5.0}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  barber['price'] ?? '\$0',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildListItem(BuildContext context, Map<String, dynamic> barber, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarberDetailPage(barber: barber),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF88C9F9).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: CaritaWidget(
                size: 60,
                color: const Color(0xFF88C9F9),
                expressionType: barber['expression'] ?? 0,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barber['name'] ?? '',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  barber['specialty'] ?? '',
                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '${barber['rating'] ?? 5.0}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Color(0xFFD48B41), size: 14),
            ],
          ),
          const SizedBox(width: 15),
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                const SizedBox(height: 4),
                Text(
                  barber['price'] ?? '',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
