import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/contact_model.dart';

import 'package:url_launcher/url_launcher.dart';
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {

  final Box<ContactModel> contactBox = Hive.box<ContactModel>('contacts');
  final nameController = TextEditingController();
  final phoneController = TextEditingController();


  void addContact() {

    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      return;
    }

    contactBox.add(
      ContactModel(
        name: nameController.text,
        phone: phoneController.text,
      ),
    );

    setState(() {});

    nameController.clear();
    phoneController.clear();

    Navigator.pop(context);
  }
  Future<void> callContact(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    await launchUrl(
      phoneUri,
      mode: LaunchMode.externalApplication,
    );
  }
  void showAddContact() {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Add Emergency Contact",
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
              ),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                ),
              ),

            ],
          ),

          actions: [

            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: addContact,
              child: const Text("Save"),
            ),

          ],
        );

      },
    );

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Emergency Contacts",
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: showAddContact,
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.add,
        ),
      ),


      body: contactBox.isEmpty

          ? const Center(
        child: Text(
          "No emergency contacts added",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      )


          : ListView.builder(

        itemCount: contactBox.length,

        itemBuilder: (context,index){

          return Card(

            margin: const EdgeInsets.all(10),

            child: ListTile(

              leading: const CircleAvatar(
                child: Icon(
                  Icons.person,
                ),
              ),

              title: Text(
                  contactBox.getAt(index)!.name
              ),

              subtitle: Text(
                  contactBox.getAt(index)!.phone
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  IconButton(
                    icon: const Icon(
                      Icons.call,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      callContact(
                        contactBox.getAt(index)!.phone,
                      );
                    },
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        contactBox.deleteAt(index);
                      });
                    },
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