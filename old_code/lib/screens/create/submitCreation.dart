import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craetor/models/post.dart';
import 'package:craetor/screens/root/root.dart';
import 'package:craetor/services/firebase/authProvider.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'package:flutter/material.dart';

class OurSubmitCreation extends StatefulWidget {
  final List<File> imageList;
  final File coverImage;
  OurSubmitCreation({
    this.imageList,
    this.coverImage,
  });
  @override
  State<StatefulWidget> createState() => _OurSubmitCreation();
}

class _OurSubmitCreation extends State<OurSubmitCreation> {
  OurPost userPost = OurPost();
  static List<TextEditingController> descriptionController = List();
  static TextEditingController coverDescriptionController = TextEditingController();
  String dropdownValue = 'none';

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    When the screen is first launched, set up controllers for every picture that is on there. 
  ---------------------------------------------------------------------------------------------------*/
  @override
  initState() {
    widget.imageList.forEach((data) {
      //dont do anything with the data just create the same number of text controllers
      descriptionController.add(TextEditingController());
    });
    super.initState();
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         context - what context we are in
  
  Return:         None

  Description:    Gets the current user id and then collect all the information from the posts and collect
                  it into a userPost and create the post. Afterwards, send to feed page and clear the 
                  descriptions controllers, so next post you dont have the old info
  ---------------------------------------------------------------------------------------------------*/
  Future<void> _submitPost(BuildContext context) async {
    var auth = OurAuthProvider.of(context).auth;
    await auth.getCurrentUser().then((userInfo) {
      userPost.uid = userInfo.uid;
      userPost.descriptions = descriptionController;
      userPost.coverDescription = coverDescriptionController;
      userPost.imageCount = widget.imageList.length;
      userPost.images = widget.imageList;
      userPost.coverImage = widget.coverImage;
      userPost.time = Timestamp.now();
      userPost.likeCount = 0;
      userPost.category = dropdownValue;
      OurBaseStore().createPost(userPost);
      descriptionController = List();
      coverDescriptionController.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OurRoot(),
        ),
        (Route<dynamic> route) => false,
      );
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         image - a file path of the image
                  index - which element it is in the list 

  Return:         Widget - each individual index of the post

  Description:    Displays an image and its correlating description in a row next to each other
  ---------------------------------------------------------------------------------------------------*/
  Widget _eachEntry(File image, int index) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Row(
        children: <Widget>[
          Image(
            image: FileImage(image),
            height: 100.0,
            width: 100.0,
          ),
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 10.0, top: 5.0),
              child: TextField(
                controller:
                    (index == -1) ? coverDescriptionController : descriptionController[index],
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration.collapsed(hintText: "add description here..."),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 2000,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None

  Return:         Widget - a list of all the remaining images other then the cover image

  Description:    In a ListView, display the remaining images that do not include the cover photo, and 
                  also a button at the bottom so the user can submit the post.
  ---------------------------------------------------------------------------------------------------*/
  Widget _displayImages() {
    return ListView.builder(
      itemCount: widget.imageList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index < widget.imageList.length) {
          return _eachEntry(widget.imageList[index], index);
        } else {
          return Column(
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "select a category:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0,
                    ),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue,
                    underline: Container(
                      height: 0,
                      color: Theme.of(context).accentColor.withOpacity(.5),
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>[
                      'none',
                      'art',
                      'cooking',
                      'crafts',
                      'design',
                      'electronics',
                      'fashion',
                      'gardening',
                      'home',
                      'makeup',
                      'mods',
                      'photography',
                      'refurbishing',
                      'textile',
                      'vehicles',
                      'woodworking',
                      '3D'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                          width: 200.0, // for example
                          child: Text(value, textAlign: TextAlign.center),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 60.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white38,
                        blurRadius: 5.0, // has the effect of softening the shadow
                        offset: Offset(
                          0.0, // horizontal, move right 10
                          2.0, // vertical, move down 10
                        ),
                      )
                    ],
                  ),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
                      child: Text(
                        "submit",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    onPressed: () => _submitPost(context),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Contains a carousel of images that are have been take from the create screen. User can
                  scroll through the list of images, and they will repeat once user gets to the end. 
                  Add a description for each image and be able to submit the post.
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(
          icon: const BackButtonIcon(),
          iconSize: 18.0,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_height * .20),
          child: Expanded(
            flex: 3,
            child: _eachEntry(widget.coverImage,
                -1), //sending invalid index so function knows its the cover photo
          ),
        ),
      ),
      body: _displayImages(),
    );
  }
}
