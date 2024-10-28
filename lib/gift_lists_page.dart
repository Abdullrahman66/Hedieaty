import 'package:flutter/material.dart';

// Gift model to hold gift information
class Gift {
  String name;
  String category;
  String status; // "Available", "Pledged"
  bool isPledged;

  Gift({
    required this.name,
    required this.category,
    required this.status,
    this.isPledged = false,
  });
}

class GiftListsPage extends StatefulWidget {
  @override
  _GiftListsPageState createState() => _GiftListsPageState();
}

class _GiftListsPageState extends State<GiftListsPage> {
  // List of sample gifts
  List<Gift> gifts = [
    Gift(name: 'Teddy Bear', category: 'Toys', status: 'Available'),
    Gift(name: 'Perfume', category: 'Accessories', status: 'Pledged', isPledged: true),
    Gift(name: 'Book', category: 'Books', status: 'Available'),
  ];

  String _sortCriteria = 'Name'; // Default sorting criteria

  // Method to sort the list of gifts
  void sortGifts(String criteria) {
    setState(() {
      _sortCriteria = criteria;
      if (criteria == 'Name') {
        gifts.sort((a, b) => a.name.compareTo(b.name));
      } else if (criteria == 'Category') {
        gifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (criteria == 'Status') {
        gifts.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  // Add or Edit Gift Dialog
  void showGiftDialog({Gift? gift, bool isEdit = false}) {
    final nameController = TextEditingController(text: gift?.name);
    final categoryController = TextEditingController(text: gift?.category);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Gift' : 'Add New Gift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Gift Name'),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: gift?.status ?? 'Available',
              items: ['Available', 'Pledged']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (isEdit && gift != null) {
                  gift.name = nameController.text;
                  gift.category = categoryController.text;
                } else {
                  gifts.add(
                    Gift(
                      name: nameController.text,
                      category: categoryController.text,
                      status: 'Available',
                    ),
                  );
                }
              });
              Navigator.pop(context); // Close the dialog
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  // Delete Gift
  void deleteGift(Gift gift) {
    setState(() {
      gifts.remove(gift);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Gift Lists'),
        titleTextStyle: TextStyle(
          color: Colors.amber,
          fontSize: 28.0,
        ),
        actions: [
          DropdownButton<String>(

            value: _sortCriteria,
            dropdownColor: Colors.grey[850],
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.white, // Dropdown icon color
            ),
            items: ['Name', 'Category', 'Status']
                .map((criteria) => DropdownMenuItem(
              value: criteria,
              child: Text(
                'Sort by $criteria',
                style: TextStyle(color: Colors.white,fontSize: 16.0),
              ),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) sortGifts(value);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(
            color: gift.isPledged ? Colors.greenAccent[400] : Colors.white,
            child: ListTile(
              title: Text(
                gift.name,
                style: TextStyle(fontSize: 20.0,),
              ),
              subtitle: Text(
                '${gift.category} - ${gift.status}',
                style: TextStyle(fontSize: 16.0),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showGiftDialog(gift: gift, isEdit: true),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteGift(gift),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showGiftDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add Gift',
      ),
    );
  }
}
