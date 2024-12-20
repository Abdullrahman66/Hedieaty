import 'package:flutter/material.dart';
import '../Controllers/user_controller.dart';
import '../Models/GiftModel.dart';
import '../Controllers/gift_controller.dart';
import '../Models/EventModel.dart';
import '../Models/UserModel.dart';
import '../Models/PledgeModel.dart';
import '../Controllers/pledge_controller.dart';
class EventGiftsPage extends StatefulWidget {
  final Event event;
  final UserModel friend;
  final UserModel user;

  const EventGiftsPage({Key? key, required this.event, required this.friend, required this.user}) : super(key: key);

  @override
  _EventGiftsPageState createState() => _EventGiftsPageState();
}

class _EventGiftsPageState extends State<EventGiftsPage> {
  final GiftController _giftController = GiftController();
  final PledgeController _pledgeController = PledgeController();
  final UserController _userController = UserController();
  List<Gift> gifts=[];

  @override
  void initState() {
    super.initState();
    _fetchEventGifts();
  }

  Future<void> _fetchEventGifts() async {
    try {
      final fetchedGifts = await _giftController.getGiftsByFirestoreEventId(widget.event.firestoreID!);
      setState(() {
        gifts  = fetchedGifts;
      });
    } catch (e) {
      print("Error fetching gifts for event: $e");
    }
  }

  void pledgeGift(gift) async {
    final updatedGift = Gift(
      id: gift.id,
      firestoreID: gift?.firestoreID,
      name: gift.name,
      description: gift.description,
      category: gift.category,
      price: gift.price,
      status: 'Pledged',
      eventId: widget.event.id,
      imageURL: gift.imageURL,
      firestoreEventId: widget.event.firestoreID,
      isPublished: gift != null && gift!.isPublished ? false : (gift?.isPublished ?? false),
    );
    await _giftController.updateGiftInFirestore(updatedGift);
    final pledge = PledgeModel(
        pledgedBy: widget.user.uid,
        pledgedTo: widget.friend.uid,
        giftFirestoreId: gift.firestoreID!
    );
    await _pledgeController.saveToFirestore(pledge);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Gift is pledged for ${widget.friend.name}'),
        backgroundColor: Colors.blue,

      ),
    );
    await _userController.addNotification(widget.friend.uid, "${widget.user.name} Pledged the ${gift.name} for you!");
    await _fetchEventGifts();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Gifts for ${widget.event.name}"),
        titleTextStyle: const TextStyle(color: Colors.amber, fontSize: 24.0),
      ),
      backgroundColor: Colors.grey[850],
      // body: FutureBuilder<List<Gift>>(
      //   future: _gifts,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(child: CircularProgressIndicator());
      //     } else if (snapshot.hasError) {
      //       return Center(
      //         child: Text(
      //           'Error: ${snapshot.error}',
      //           style: const TextStyle(color: Colors.white),
      //         ),
      //       );
      //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      //       return const Center(
      //         child: Text(
      //           'No gifts found for this event.',
      //           style: TextStyle(color: Colors.white),
      //         ),
      //       );
      //     }
      //
      //     final gifts = snapshot.data!;
        body:  gifts.isEmpty
            ? Center(
          child: Text(
            'No available Gifts',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
          : ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return Card(
                color: Colors.grey[700],
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: (gift.imageURL != null && gift.imageURL!.isNotEmpty)
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(gift.imageURL!),
                    radius: 30,
                  )
                      : null,
                  title: Text(
                    gift.name,
                    style: const TextStyle(color: Colors.amber, fontSize: 20.0),
                  ),
                  subtitle: Text(
                    "Status: ${gift.status}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  isThreeLine: true,
                  trailing: gift.status == 'Pledged'
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                        onPressed: () {
                          pledgeGift(gift);
                        },
                        child: Text("Pledge"),
                  ),
                ),
              );
            },
          ),
      // ),
    );
  }
}
