import 'package:craetor/screens/create/submitCreation.dart';
import 'package:craetor/screens/root/root.dart';
import 'package:craetor/utils/image.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:multi_image_picker/multi_image_picker.dart';

final bool finalCAMERA = false;
final bool finalGALLERY = true;
final int finalMAXIMAGES = 25;

class OurCreate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OurCreateState();
}

class _OurCreateState extends State<OurCreate> {
  File coverImage;
  List<File> imageList = List();
  int currentListElement = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<File> images = List<File>();

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Show a dialog with options to add cover photo from camera or gallery. After the action is taken,
                  pop the dialog window and load in the images.
  ---------------------------------------------------------------------------------------------------*/
  void getCoverImage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.camera_alt),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text("from camera"),
                        ),
                      ],
                    ),
                    onPressed: () {
                      OurImage().getImage(source: finalCAMERA, circle: false).then((data) {
                        if (data == null) {
                          //do nothing
                        } else {
                          Navigator.pop(context);
                          setState(() {
                            coverImage = data;
                          });
                        }
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.image),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text("from gallery"),
                        ),
                      ],
                    ),
                    onPressed: () {
                      OurImage().getImage(source: finalGALLERY, circle: false).then((data) {
                        if (data == null) {
                          //do nothing
                        } else {
                          Navigator.pop(context);
                          setState(() {
                            coverImage = data;
                          });
                        }
                      });
                    },
                  ),
                )
              ],
            ),
          );
        });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Show a dialog with 2 options: to add a photo from the camera, and to add multiple images
  ---------------------------------------------------------------------------------------------------*/
  void getImage() {
    List<Asset> _tempList = List();
    if (imageList.length >= finalMAXIMAGES) {
      final nineSnackBar = SnackBar(
        content: Text(
            "Can post up to " + finalMAXIMAGES.toString() + " images. Clear images to restart"),
        duration: Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(nineSnackBar);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.camera_alt),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                            child: Text("add from camera"),
                          ),
                        ],
                      ),
                      onPressed: () {
                        OurImage().getImage(source: finalCAMERA, circle: false).then((data) {
                          if (data == null) {
                            //do nothing
                          } else {
                            Navigator.pop(context);
                            setState(() {
                              imageList.add(data);
                              images.add(data);
                              currentListElement++;
                            });
                          }
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.add_to_photos),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                            child: Text("select multiple images"),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        List<String> _fileNames = List();
                        _tempList =
                            await OurImage().getMultipleImages(finalMAXIMAGES - imageList.length);
                        if (_tempList != null) {
                          Navigator.pop(context);
                          for (int i = 0; i < _tempList.length; i++) {
                            _fileNames.add(await _tempList[i].filePath);
                          }
                          setState(() {
                            _fileNames.forEach((data) {
                              imageList.add(File(data));
                              images.add(File(data));
                            });
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
            );
          });
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - the top widget of the screen

  Description:    Displays two buttons. One for accessing the camera, and another for accessing the gallery.
  ---------------------------------------------------------------------------------------------------*/
  Widget _displayTop(double iconHeight) {
    Widget retVal;

    retVal = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 120.0,
                height: 120.0,
                alignment: Alignment.center,
                padding: EdgeInsets.all(0.0),
                child: (coverImage != null) ? Image.file(coverImage) : Text(""),
              ),
              SizedBox(
                height: 40.0,
              )
            ],
          ),
          Column(
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                icon: Icon(Icons.add),
                iconSize: iconHeight,
                onPressed: () {
                  getCoverImage();
                },
              ),
              (coverImage == null) ? Text("add cover photo") : Text("change cover photo"),
              SizedBox(
                height: 40.0,
              )
            ],
          ),
        ],
      ),
    );

    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - the middle widget for the page

  Description:    Displays a text in the middle of the screen that lets you clear images or add more
  ---------------------------------------------------------------------------------------------------*/
  Widget _displayMiddle() {
    Widget retVal;

    retVal = Container(
      padding: EdgeInsets.all(10.0),
      alignment: Alignment.center,
      child: FlatButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: (imageList.length == 0)
                  ? Text("")
                  : FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.clear),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                            child: Text("clear images"),
                          ),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          imageList = List();
                          images = List();
                        });
                      },
                    ),
            ),
            Spacer(),
            Icon(Icons.add_to_photos),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("add supporting images"),
            ),
          ],
        ),
        onPressed: getImage,
      ),
    );

    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - the last widget for the page, which is a grid of images

  Description:    Displays a grid of images that have already been taken by the user. It should be 3 pictures 
                  wide on most cellular devices. 
  ---------------------------------------------------------------------------------------------------*/
  Widget _displayBottom() {
    Widget retVal;

    retVal = SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150.0,
        mainAxisSpacing: 3.0,
        crossAxisSpacing: 3.0,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return GestureDetector(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(0.0),
              child: Image.file(imageList[index]),
            ),
            onTap: () async {
              File newFile;
              newFile = await OurImage().cropImage(image: images[index]);
              setState(() {
                if (newFile != null) {
                  imageList[index] = newFile;
                }
              });
            },
          );
        },
        childCount: imageList.length,
      ),
    );
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         context - the context of which app is in, used for snackbar
  
  Return:         None

  Description:    Checks for at least one image and then takes you to the submitCreation page.
  ---------------------------------------------------------------------------------------------------*/

  void _goToSubmit(BuildContext context) {
    if (coverImage == null) {
      final zeroSnackBar = SnackBar(
        content: Text("need at least a cover photo"),
      );
      Scaffold.of(context).showSnackBar(zeroSnackBar);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OurSubmitCreation(
            imageList: imageList,
            coverImage: coverImage,
          ),
        ),
      );
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Builds a page two buttons at the top for camera and gallery, then below shows your list
                  of images in a 3 picture wide grid. Will pop scope is so that, the app doesnt exit when
                  you click to go back on this page. This will hopefully be updated to have a stack and will
                  no longer be needed.
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OurRoot(),
        ),
        (Route<dynamic> route) => false,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          leading: IconButton(
            icon: const BackButtonIcon(),
            iconSize: 18.0,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => OurRoot(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "next",
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
              onPressed: () => _goToSubmit(context),
            )
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(_height * .20),
            child: _displayTop(_height * .10),
          ),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                _displayMiddle(),
              ]),
            ),
            _displayBottom(),
          ],
        ),
      ),
    );
  }
}
