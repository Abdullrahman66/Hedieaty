import 'package:flutter/material.dart';
import '../Models/GiftModel.dart';
import '../Controllers/gift_controller.dart';
import 'package:project_2/Models/EventModel.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift? gift;
  final Event event;

  GiftDetailsPage({this.gift, required this.event});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final GiftController _giftController = GiftController();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _imageURLController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.gift?.description ?? '');
    _categoryController =
        TextEditingController(text: widget.gift?.category ?? '');
    _priceController = TextEditingController(
        text: widget.gift?.price?.toString() ?? '');
    _imageURLController =
        TextEditingController(text: widget.gift?.imageURL ?? '');
  }

  Future<void> _saveGift() async {
      final updatedGift = Gift(
        id: widget.gift?.id,
        firestoreID: widget.gift?.firestoreID,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        status: widget.gift?.status ?? 'Available',
        imageURL: _imageURLController.text ?? widget.gift?.imageURL ?? '',
        eventId: widget.event.id,
        firestoreEventId: widget.event.firestoreID,
        isPublished: widget.gift != null && widget.gift!.isPublished ? false : (widget.gift?.isPublished ?? false),
      );

      if (widget.gift == null) {
        await _giftController.addGift(updatedGift);
      } else {
        await _giftController.updateGift(updatedGift);
      }

      Navigator.pop(context);

  }

  String? validateImageUrl(String? value) {

    // Regular expression to validate URLs ending with common image extensions
    final RegExp imageUrlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-])\/?.\.(jpg|jpeg|png|gif|bmp|webp)$',
      caseSensitive: false,
    );

    // Check if the value matches the pattern
    if (!imageUrlPattern.hasMatch(value!)) {
      return 'Please enter a valid image URL (e.g., .jpg, .png)';
    }

    // If all validations pass, return null (no error)
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.gift?.status == 'Pledged';

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
            widget.gift == null ? 'Add Gift' : 'Edit Gift',
          style: TextStyle(color: Colors.amber, fontSize: 28.0),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Gift Name',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.card_giftcard)
                  ),
                  enabled: !isLocked,
                ),
              ),
              SizedBox(height: 12,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: 'Description',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.description_outlined)
                  ),
                  enabled: !isLocked,
                ),
              ),
              SizedBox(height: 12,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                      labelText: 'Category',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.category)
                  ),
                  enabled: !isLocked,
                ),
              ),
              SizedBox(height: 12,),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                      labelText: 'Price',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.monetization_on)
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !isLocked,
                ),
              ),
              SizedBox(height: 12,),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _imageURLController,
                  decoration: InputDecoration(
                      labelText: 'Image URL (Optional)',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.link)
                  ),
                  // validator: (value) {
                  //   if(value != null){
                  //     validateImageUrl(value);
                  //   }
                  //   return null;
                  // },
                  enabled: !isLocked,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber),
                  // Button background color
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  // Button text color
                  elevation: MaterialStateProperty.all(5),
                  minimumSize: MaterialStateProperty.all(Size(40, 40.0)),
                  // Button elevation
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20.0), // Round button corners
                    ),
                  ),
                ),
                onPressed:  (){
                    _saveGift();
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
