import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onAlert;
  final VoidCallback onFreeze;
  final VoidCallback onBan;

  const ReportCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.onTap,
    required this.onAlert,
    required this.onFreeze,
    required this.onBan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap, // <-- added onTap here
        leading: imageUrl != null && imageUrl!.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(imageUrl!),
              )
            : const CircleAvatar(
                child: Icon(Icons.person),
              ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Alert') onAlert();
            if (value == 'Freeze') onFreeze();
            if (value == 'Ban') onBan();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Alert', child: Text('Alert')),
            const PopupMenuItem(value: 'Freeze', child: Text('Freeze')),
            const PopupMenuItem(value: 'Ban', child: Text('Ban')),
          ],
        ),
      ),
    );
  }
}
