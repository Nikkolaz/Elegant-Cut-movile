import 'package:flutter/material.dart';
import 'package:elegant_cut_mobile/src/pages/barber_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(context),
            const SizedBox(height: 25),
            _buildPromoCard(),
            const SizedBox(height: 25),
            _buildCalendar(context),
            const SizedBox(height: 25),
            _buildPlanSection(context),
            const SizedBox(height: 25),
            _buildBarbersSection(context),
            const SizedBox(height: 25),
            _buildServicesSection(context),
            const SizedBox(height: 25),
            _buildGallerySection(context),
            const SizedBox(height: 120), // Espacio extra para el scroll
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=sandra'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Sandra',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey.shade800,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Today 25 Nov.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
        ),
      ],
    );
  }

  Widget _buildPromoCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFC7B8F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily\nchallenge',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Do your plan before 09:00 AM',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                _buildAvatarStack(),
              ],
            ),
          ),
          Positioned(
            right: -10,
            top: 20,
            child: Icon(
              Icons.blur_on,
              size: 150,
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return Row(
      children: [
        for (int i = 0; i < 3; i++)
          Align(
            widthFactor: 0.7,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 13,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$i'),
              ),
            ),
          ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Center(
            child: Text(
              '+4',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const numbers = ['22', '23', '24', '25', '26', '27', '28'];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: days.length,
        itemBuilder: (context, index) {
          bool isSelected = index == 3; // Miércoles 25
          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? (isDark ? const Color(0xFFD48B41) : const Color(0xFF1C1C1E)) 
                  : (isDark ? Colors.grey.shade900 : Colors.white),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  numbers[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your plan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPlanCard(
                title: 'Corte &\nBarba',
                subtitle: '25 Nov.\n14:00-15:00\nSilla 1',
                tag: 'Premium',
                color: const Color(0xFFFFB74D),
                height: 250,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                children: [
                  _buildPlanCard(
                    title: 'Masaje',
                    subtitle: '28 Nov.\n18:00-19:30',
                    tag: 'Light',
                    color: const Color(0xFFBAE5F4),
                    height: 140,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 95,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9A8D4),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialIcon(Icons.camera_alt_outlined),
                        _buildSocialIcon(Icons.play_circle_outline),
                        _buildSocialIcon(Icons.message_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String subtitle,
    required String tag,
    required Color color,
    required double height,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              tag,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.1,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildBarbersSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barbers = [
      {
        'name': 'Marcus',
        'rating': '4.9',
        'img': 'https://i.pravatar.cc/150?u=1',
      },
      {'name': 'Alex', 'rating': '4.8', 'img': 'https://i.pravatar.cc/150?u=2'},
      {
        'name': 'Julian',
        'rating': '4.7',
        'img': 'https://i.pravatar.cc/150?u=3',
      },
      {
        'name': 'Daniel',
        'rating': '4.9',
        'img': 'https://i.pravatar.cc/150?u=4',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nuestros Expertos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: barbers.length,
            itemBuilder: (context, index) {
              final b = barbers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BarberDetailPage(barber: b),
                    ),
                  );
                },
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'barber_image_${b['name']}',
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                          backgroundImage: NetworkImage(b['img']!),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b['name']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        '⭐ ${b['rating']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final services = [
      {
        'name': 'Corte Clásico',
        'price': r'$25',
        'icon': Icons.content_cut,
        'color': isDark ? const Color(0xFF1A237E) : const Color(0xFFE3F2FD),
      },
      {
        'name': 'Barba Real',
        'price': r'$15',
        'icon': Icons.face,
        'color': isDark ? const Color(0xFF1B5E20) : const Color(0xFFF1F8E9),
      },
      {
        'name': 'Combo VIP',
        'price': r'$45',
        'icon': Icons.auto_awesome,
        'color': isDark ? const Color(0xFFE65100) : const Color(0xFFFFF3E0),
      },
      {
        'name': 'Tratamiento',
        'price': r'$20',
        'icon': Icons.spa,
        'color': isDark ? const Color(0xFF4A148C) : const Color(0xFFF3E5F5),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios Populares',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.4,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final s = services[index];
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: s['color'] as Color,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(s['icon'] as IconData, color: isDark ? Colors.white70 : Colors.black87),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        s['price'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGallerySection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Galería de Estilos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              'Ver todo',
              style: TextStyle(
                color: isDark ? const Color(0xFFD48B41) : Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&w=1000',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(20),
            alignment: Alignment.bottomLeft,
            child: const Text(
              'Tendencias 2024',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
