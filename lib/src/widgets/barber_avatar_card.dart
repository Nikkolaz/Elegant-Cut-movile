import 'package:flutter/material.dart';
import 'package:elegant_cut_mobile/src/pages/barber_detail_page.dart';

class BarberAvatarCard extends StatelessWidget {
  final Map<String, String> barber;

  const BarberAvatarCard({
    super.key,
    required this.barber,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
        width: 90,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Hero(
              tag: 'barber_image_${barber['name']}',
              child: CircleAvatar(
                radius: 35,
                backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                backgroundImage: NetworkImage(barber['img']!),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              barber['name']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              '⭐ ${barber['rating']}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
