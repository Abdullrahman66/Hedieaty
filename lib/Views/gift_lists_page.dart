import 'package:flutter/material.dart';
import 'package:project_2/Models/EventModel.dart';
import './gift_details_page.dart';
import '../Models/GiftModel.dart';
import '../Controllers/gift_controller.dart';
import '../Controllers/pledge_controller.dart';
import '../Models/UserModel.dart';
import '../Models/PledgeModel.dart';

class GiftListsPage extends StatefulWidget {
  final Event event;
  final UserModel user;

  const GiftListsPage({Key? key, required this.event, required this.user}) : super(key: key);
  @override
  _GiftListsPageState createState() => _GiftListsPageState();
}

class _GiftListsPageState extends State<GiftListsPage> {
  final GiftController _giftController = GiftController();
  final PledgeController _pledgeController = PledgeController();
  List<Gift> gifts = [];
  String _sortCriteria = 'Name';

  @override
  void initState() {
    super.initState();
    _fetchGifts();
  }

  Future<void> _fetchGifts() async {
    try {
      // Use the event's ID and Firestore ID to retrieve the gifts
      final fetchedGifts = await _giftController.getGiftsByEvents(
        eventId: widget.event.id,
        firestoreEventId: widget.event.firestoreID,
      );

      setState(() {
        gifts = fetchedGifts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching gifts: ${e.toString()}')),
      );
    }
  }

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

  void deleteGift(int id) async {
    await _giftController.deleteGift(id);
    await _fetchGifts();
  }

  void pledgeGift(Gift gift) async {
    if(gift.firestoreID != null){
      final updatedGift = Gift(
        id: gift.id,
        firestoreID: gift?.firestoreID,
        name: gift.name,
        description: gift.description,
        category: gift.category,
        price: gift.price,
        status: 'Pledged',
        imageURL: gift.imageURL,
        eventId: widget.event.id,
        firestoreEventId: widget.event.firestoreID,
        isPublished: gift != null && gift!.isPublished ? false : (gift?.isPublished ?? false),
      );
      await _giftController.updateGift(updatedGift);
      await _giftController.updateGiftInFirestore(updatedGift);
      final pledge = PledgeModel(
          pledgedBy: widget.user.uid,
          pledgedTo: widget.user.uid,
          giftFirestoreId: gift.firestoreID!
      );
      await _pledgeController.saveToFirestore(pledge);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gift is pledged for you.'),
          backgroundColor: Colors.blue,
        ),
      );
      await _fetchGifts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gift Must be Published first.'),
          backgroundColor: Colors.blue,

        ),
      );
    }

  }

  Future<void> _publishUnpublishedGifts() async {
    try {
      if (widget.event.firestoreID != null) {
        List<Gift> gifts = await _giftController.getGifts();
        List<Gift> unpublishedGifts = gifts.where((gift) => !gift.isPublished).toList();

        if (unpublishedGifts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('All gifts are already published.'),
              backgroundColor: Colors.blue,

            ),
          );
          return;
        }

        for (var gift in unpublishedGifts) {
          if (gift.firestoreID == null) {
            await _giftController.publishGift(gift);
            gift.isPublished = true;
          } else {
            await _giftController.updateGiftInFirestore(gift);
            gift.isPublished = true;
            await _giftController.updateGift(gift);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Unpublished gifts published successfully!'),
            backgroundColor: Colors.blue,

          ),
        );

        await _fetchGifts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Associated Event must be published first.'),
            backgroundColor: Colors.blue,

          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error publishing gifts: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
            'Gift Lists',
            style: TextStyle(color: Colors.amber, fontSize: 28.0),

        ),
        actions: [
          DropdownButton<String>(
            dropdownColor: Colors.black,
            iconEnabledColor: Colors.white,
            value: _sortCriteria,
            items: ['Name', 'Category', 'Status']
                .map((criteria) => DropdownMenuItem(
              value: criteria,
              child: Text('Sort by $criteria', style: TextStyle(color: Colors.white),),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) sortGifts(value);
            },
          ),
          IconButton(
            icon: Icon(Icons.cloud_upload, color: Colors.white,),
            onPressed: _publishUnpublishedGifts,
            tooltip: 'Publish Unpublished Gifts',
          ),
        ],
      ),
      body: gifts.isEmpty
          ? Center(
        child: Text(
          'No available Gifts',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(

            color: gift.status == 'Pledged' ? Colors.green[100] : Colors.grey[700],
            child: ListTile(
              leading: (gift.imageURL != null && gift.imageURL!.isNotEmpty)
                  ? CircleAvatar(
                backgroundImage: NetworkImage(gift.imageURL!),
                radius: 30,
              )
                  : null,
              title: Text(
                  gift.name,
                  style: TextStyle(fontSize: 20, color: Colors.amber),
              ),
              subtitle: Text(
                  '${gift.category} - ${gift.status}',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),

              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue,),
                    onPressed: gift.status == 'Pledged'
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiftDetailsPage(
                              gift: gift, event: widget.event),
                        ),
                      ).then((_) => _fetchGifts());
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: gift.status == 'Pledged'
                        ? null : () => deleteGift(gift.id!),
                  ),
                  ElevatedButton(
                    onPressed: gift.status == 'Pledged'
                        ? null
                        : () => pledgeGift(gift),
                    child: Text('Pledge'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftDetailsPage(event: widget.event),
            ),
          ).then((_) => _fetchGifts());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
