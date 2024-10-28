import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class MyPledgedGiftsPage extends StatelessWidget {
  final List<Gift> pledgedGifts;

  MyPledgedGiftsPage({Key? key, required this.pledgedGifts}) : super(key: key);

  // Format the due date for display
  String formatDate(DateTime? date) {
    if (date == null) return 'No Due Date';
    return DateFormat.yMMMd().format(date);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'My Pledged Gifts',
          style: TextStyle(color: Colors.amber,fontSize: 28.0,),
        ),
      ),
      body: pledgedGifts.isEmpty
          ? const Center(child: Text('No pledged gifts yet!'))
          : ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return ListTile(
            leading: Icon(
              Icons.card_giftcard,
              color: gift.dueDate != null &&
                  gift.dueDate!.isBefore(DateTime.now())
                  ? Colors.red // Highlight overdue gifts
                  : Colors.grey,
            ),
            title: Text(
              gift.name,
              style: TextStyle(color: Colors.white,fontSize: 20.0,),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Friend: ${gift.friendName ?? 'Unknown'}',style: TextStyle(color: Colors.white,fontSize: 16.0,),),
                Text('Due: ${formatDate(gift.dueDate)}',style: TextStyle(color: Colors.white,fontSize: 16.0,),),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // Add logic to modify or cancel pledge
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Modify ${gift.name} pledge!'),
                  ),
                );
              },
              child: const Text('Modify'),
            ),
          );
        },
      ),
    );
  }
}
class Gift {
  final String name;
  final String category;
  final bool isPledged;
  final String? friendName; // Friend associated with the pledge
  final DateTime? dueDate;  // Due date for the pledge

  Gift({
    required this.name,
    required this.category,
    this.isPledged = false,
    this.friendName,
    this.dueDate,
  });
}