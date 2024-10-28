import 'package:flutter/material.dart';

class FriendGiftListPage extends StatelessWidget {
  final String friendName; // Receive friend's name via constructor
  final List<Map<String, dynamic>> gifts; // Gifts list of the friend

  const FriendGiftListPage({
    super.key,
    required this.friendName,
    required this.gifts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$friendName\'s Gift List'),
      ),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return ListTile(
            leading: Image.network(gift['imageUrl'], width: 50, height: 50),
            title: Text(gift['name']),
            subtitle: Text('Category: ${gift['category']}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Handle pledge logic
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Pledge Gift'),
                    content: Text('Do you want to pledge ${gift['name']}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Notify friend (placeholder logic)
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('You pledged ${gift['name']}!')),
                          );
                        },
                        child: const Text('Pledge'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Pledge'),
            ),
          );
        },
      ),
    );
  }
}
