import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/canteen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentCanteenCard extends StatelessWidget {
  final Canteen canteen;

  const StudentCanteenCard({
    super.key,
    required this.canteen,
  });

  String _getLocalizedDescription(BuildContext context, Canteen canteen) {
    final l10n = AppLocalizations.of(context)!;
    switch (canteen.id) {
      case '1':
        return l10n.canteenDescriptionSummit;
      case '2':
        return l10n.canteenDescriptionFrontier;
      case '3':
        return l10n.canteenDescriptionTechno;
      case '4':
        return l10n.canteenDescriptionPGP;
      case '5':
        return l10n.canteenDescriptionDeck;
      case '6':
        return l10n.canteenDescriptionTerrace;
      case '7':
        return l10n.canteenDescriptionYIH;
      case '8':
        return l10n.canteenDescriptionFineFood;
      default:
        return canteen.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              color: Colors.grey[300],
            ),
            child: Center(
              child: Icon(
                Icons.restaurant,
                size: 64,
                color: Colors.grey[600],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canteen.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      canteen.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_getLocalizedDescription(context, canteen)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      canteen.operatingHours,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 实现查看菜单功能
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.menuNotification(canteen.name)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16a951),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: Text(
                    l10n.viewMenu,
                    style: const TextStyle(color: Colors.white),
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