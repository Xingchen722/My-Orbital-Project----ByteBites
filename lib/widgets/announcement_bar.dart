import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AnnouncementBar extends StatefulWidget {
  const AnnouncementBar({super.key});

  @override
  State<AnnouncementBar> createState() => _AnnouncementBarState();
}

class _AnnouncementBarState extends State<AnnouncementBar> {
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('announcements') ?? [];
    setState(() {
      messages = list.map((e) => jsonDecode(e)['message'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.yellow[100],
      height: 36,
      child: Row(
        children: [
          const Icon(Icons.campaign, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: messages.isEmpty
                ? Text(l10n.noAnnouncementsYet, style: TextStyle(fontSize: 16, color: Colors.grey[600]))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: messages.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(child: Text(messages[i], style: TextStyle(fontSize: 16, color: Colors.black))),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
} 