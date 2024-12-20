import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/EventModel.dart';
import '../Controllers/event_controller.dart';
import '../Models/NotificationService.dart';
import '../Models/UserModel.dart';
import './gift_lists_page.dart';

class CreateEventPage extends StatefulWidget {
  final UserModel user;

  const CreateEventPage({Key? key, required this.user}) : super(key: key);
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final EventController _eventController = EventController();
  List<Event> _events = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedDate = "";
  String _selectedSorting = "Name";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    NotificationService().initialize(widget.user.uid, context);

  }

  @override
  void dispose() {
    NotificationService().dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    try {
      List<Event> events = await _eventController.getEvents(widget.user.uid);
      setState(() {
        _events = events;
        _isLoading = false;
        _sortEvents();
      });
    } catch (e) {
      print("Error fetching events: ${e.toString()}");
    }
  }

  String _getEventStatus(String date) {
    DateTime eventDate = DateFormat('yyyy-MM-dd').parse(date);
    DateTime today = DateTime.now();
    if (eventDate.isBefore(today)) {
      return "Past";
    } else if (eventDate.isAfter(today)) {
      return "Upcoming";
    } else {
      return "Current";
    }
  }

  void _sortEvents() {
    setState(() {
      switch (_selectedSorting) {
        case "Name":
          _events.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case "Category":
          _events.sort((a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()));
          break;
        case "Status":
          _events.sort((a, b) {
            String statusA = _getEventStatus(a.date);
            String statusB = _getEventStatus(b.date);
            return statusA.compareTo(statusB);
          });
          break;
      }
    });
  }

  Future<void> _addOrEditEvent({Event? event}) async {
    if (event != null) {
      _nameController.text = event.name;
      _categoryController.text = event.category;
      _locationController.text = event.location;
      _descriptionController.text = event.description;
      _selectedDate = event.date;
    } else {
      _nameController.clear();
      _categoryController.clear();
      _locationController.clear();
      _descriptionController.clear();
      _selectedDate = "";
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event != null ? "Edit Event" : "Add New Event"),
          content: SingleChildScrollView(
            child: Column(
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
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      setState(() {
                        _selectedDate = formattedDate;
                      });
                    }
                  },
                  child: Text(_selectedDate.isEmpty ? "Pick a Date" : _selectedDate),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                Event newEvent = Event(
                  id: event?.id,
                  name: _nameController.text,
                  category: _categoryController.text,
                  location: _locationController.text,
                  description: _descriptionController.text,
                  date: _selectedDate,
                  userId: widget.user.uid, // Replace with actual user ID
                  isPublished: event != null && event.isPublished ? false : (event?.isPublished ?? false), // Manage isPublished,
                  firestoreID: event?.firestoreID,
                );

                if (event == null) {
                  await _eventController.addEvent(newEvent);
                } else {
                  await _eventController.editEvent(newEvent);
                }

                await _fetchEvents();
              },
              child: Text(event != null ? "Save" : "Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _publishUnpublishedEvents() async {
    setState(() => _isLoading = true); // Show loading indicator
    try {
      List<Event> events = await _eventController.getEvents(widget.user.uid);
      List<Event> unpublishedEvents = events.where((event) => !event.isPublished).toList();

      if(events.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No Events created to publish.'),
            backgroundColor: Colors.blue,

          ),
        );
        return;
      }
      if (unpublishedEvents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('All events are already published.'),
            backgroundColor: Colors.blue,
          ),
        );
        return;
      }

      for (var event in unpublishedEvents) {
        if (event.firestoreID == null) {
          await _eventController.publishEvent(event);
          event.isPublished = true;
        } else {
          await _eventController.updateEventInFirestore(event);
          event.isPublished = true; // Update local state
          await _eventController.editEvent(event);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Unpublished events published successfully!'),
          backgroundColor: Colors.blue,

        ),
      );

      await _fetchEvents(); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error publishing events: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }



  Future<void> _deleteEvent(Event event) async {
    await _eventController.deleteEvent(event.id, event.firestoreID);
    if(event.firestoreID != null){
      await _eventController.deleteEventFromFirestore(event.firestoreID!);
    }
    await _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "My Events",
          style: TextStyle(color: Colors.amber, fontSize: 28.0),
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedSorting,
            dropdownColor: Colors.black,
            iconEnabledColor: Colors.white,
            style: TextStyle(color: Colors.white, fontSize: 16),
            underline: SizedBox(), // Remove underline
            items: ["Name", "Category", "Status"]
                .map((criteria) => DropdownMenuItem<String>(
              value: criteria,
              child: Text("Sort by $criteria"),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSorting = value;
                  _sortEvents(); // Re-sort when criteria changes
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.cloud_upload, color: Colors.white,),
            onPressed: _publishUnpublishedEvents,
            tooltip: 'Publish Unpublished Events',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? Center(
        child: Text(
          "No available events",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          String status = _getEventStatus(event.date);
          return Card(
            color: Colors.grey[700],
            child: ListTile(
              title: Text(
                event.name,
                style: TextStyle(fontSize: 20, color: Colors.amber),
              ),
              subtitle: Text(
                "${event.category} - ${event.date}\nStatus: $status",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _addOrEditEvent(event: event),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteEvent(event),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GiftListsPage(event: event, user: widget.user),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditEvent(),
        child: Icon(Icons.add),
      ),
    );
  }
}
