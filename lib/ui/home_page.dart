import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {
  orderAZ,
  orderZA
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper.internal();
  List<Contact> _contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderAZ,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderZA,
              )
            ],
            onSelected: _orderList,
          )
        ]
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _showContactPage();
        },
        backgroundColor: Colors.red
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: _contacts.length,
        itemBuilder: _contactCard
      )
    );
  }


  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _showOptions(context, index);
      },
      child: Padding(
        padding: EdgeInsets.all(2),
        child: Card(
          elevation: 4,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(3),
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _contacts[index].img != null ?
                      FileImage(File(_contacts[index].img)) :
                      AssetImage("images/contact.png")
                    )
                  )
                )
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _contacts[index].name ?? "",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Text(
                      _contacts[index].email ?? "",
                      style: TextStyle(
                          fontSize: 18
                      )
                    ),
                    Text(
                      _contacts[index].phone ?? "",
                      style: TextStyle(
                          fontSize: 18
                      )
                    )
                  ],
                ),
              )
            ]
          )
        )
      )
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {

          },
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: FlatButton(
                      onPressed: () {
                        launch("tel:${_contacts[index].phone}");
                        Navigator.pop(context);
                      },
                      child: Text("Ligar",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 20
                        )
                      )
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: _contacts[index]);
                      },
                      child: Text("Editar",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 20
                        ),
                      )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: FlatButton(
                      onPressed: () {
                        helper.deleteContact(_contacts[index].id);
                        setState(() {
                          _contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                      child: Text("Excluir",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 20
                        ),
                      )
                    ),
                  )
                ]
              )
            );
          },
        );
      }
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(contact: contact)
      )
    );

    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAll().then((list) {
      setState(() {
        _contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch(result) {
      case OrderOptions.orderAZ:
        _contacts.sort((a,b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderZA:
        _contacts.sort((a,b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }

    setState(() { });
  }
}
