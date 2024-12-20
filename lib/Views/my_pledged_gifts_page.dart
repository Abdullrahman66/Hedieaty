import 'package:flutter/material.dart';
import '../Models/GiftModel.dart';
import '../Models/UserModel.dart';
import '../Controllers/gift_controller.dart';
import '../Controllers/user_controller.dart';
import '../Controllers/pledge_controller.dart';

class PledgedGiftsPage extends StatefulWidget {
  final UserModel user;

  const PledgedGiftsPage({Key? key, required this.user}) : super(key: key);

  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final GiftController _giftController = GiftController();
  final UserController _userController = UserController();
  final PledgeController _pledgeController = PledgeController();

  List<Map<String, dynamic>> pledgedGifts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    try {
      // Fetch all pledges for the logged-in user
      final pledges = await _pledgeController.getFromFirestoreByUserId(widget.user.uid);

      // For each pledge, fetch the gift and user details
      List<Map<String, dynamic>> pledgeDetails = [];
      for (var pledge in pledges) {
        final gift = await Gift.getGiftByFirestoreId(pledge.giftFirestoreId);
        final pledgedByUser = await UserModel.getUserByFirestoreId(pledge.pledgedBy);

        pledgeDetails.add({
          'gift': gift,
          'pledgedBy': pledgedByUser,
        });
      }

      setState(() {
        pledgedGifts = pledgeDetails;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching pledged gifts: ${e.toString()}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
            'My Pledged Gifts',
            style: TextStyle(color: Colors.amber, fontSize: 28.0),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pledgedGifts.isEmpty
          ? Center(
        child: Text(
          'No pledged gifts available.',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index]['gift'] as Gift;
          final pledgedByUser = pledgedGifts[index]['pledgedBy'] as UserModel;

          return Card(
            color: Colors.grey[700],
            child: ListTile(
              leading: gift.imageURL != null ? CircleAvatar(
                backgroundImage: NetworkImage(gift.imageURL!),
              ) : null,
              title: Text(
                  gift.name,
                style: TextStyle(fontSize: 20, color: Colors.amber),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pledged By: ${pledgedByUser.name}',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),

                  ),
                  Text(
                    'Gift Description: ${gift.description}',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),

                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
