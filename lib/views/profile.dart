import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cadence/event_data.dart';
import 'package:cadence/views/saved.dart';
import 'package:cadence/views/purchased.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final eventData = Provider.of<EventData>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(
              Icons.arrow_back_ios
          ),
        ),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_add_rounded),
            title: const Text('Saved Events'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedEventsScreen()),
              );
              print('Saved Events tapped');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_shopping_cart_rounded),
            title: const Text('Purchased Events'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PurchasedEventsScreen()),
              );
              print('Purchased Events tapped');
            },
          ),
// Add more profile-related tiles here
        ],
      ),
    );
  }
}
