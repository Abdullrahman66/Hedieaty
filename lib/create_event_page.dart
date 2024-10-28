import 'package:flutter/material.dart';

// Event Model
class Event {
  String name;
  String category;
  String status; // Upcoming/Current/Past

  Event({
    required this.name,
    required this.category,
    required this.status,
  });
}

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  // Sample list of events
  List<Event> events = [
    Event(name: 'Birthday Party', category: 'Personal', status: 'Upcoming'),
    Event(name: 'Conference', category: 'Work', status: 'Current'),
    Event(name: 'Family Reunion', category: 'Personal', status: 'Past'),
  ];

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String _selectedStatus = 'Upcoming'; // Default status

  // Sort Criteria
  String _sortCriteria = 'Name';

  // Function to open the Add/Edit Event dialog
  void _showEventDialog({Event? event, bool isEdit = false}) {
    if (isEdit) {
      _nameController.text = event!.name;
      _categoryController.text = event.category;
      _selectedStatus = event.status;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Event' : 'Add New Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: ['Upcoming', 'Current', 'Past']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (isEdit) {
                setState(() {
                  event!.name = _nameController.text;
                  event.category = _categoryController.text;
                  event.status = _selectedStatus;
                });
              } else {
                setState(() {
                  events.add(Event(
                    name: _nameController.text,
                    category: _categoryController.text,
                    status: _selectedStatus,
                  ));
                });
              }
              Navigator.pop(context); // Close dialog
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  // Function to delete an event
  void _deleteEvent(Event event) {
    setState(() {
      events.remove(event);
    });
  }

  // Function to sort events
  void _sortEvents(String criteria) {
    setState(() {
      _sortCriteria = criteria;
      if (criteria == 'Name') {
        events.sort((a, b) => a.name.compareTo(b.name));
      } else if (criteria == 'Category') {
        events.sort((a, b) => a.category.compareTo(b.category));
      } else if (criteria == 'Status') {
        events.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Events'),
        actions: [
          DropdownButton<String>(
            value: _sortCriteria,
            items: ['Name', 'Category', 'Status']
                .map((criteria) => DropdownMenuItem(
              value: criteria,
              child: Text('Sort by $criteria'),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) _sortEvents(value);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            child: ListTile(
              title: Text(event.name),
              subtitle: Text('${event.category} - ${event.status}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () =>
                        _showEventDialog(event: event, isEdit: true),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteEvent(event),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add Event',
      ),
    );
  }
}
