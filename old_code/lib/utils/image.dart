import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class OurImage {
  /*---------------------------------------------------------------------------------------------------
  Inputs:         source - false is for camera and true is for gallery
                  circle - whether the cropper should be circular
  
  Return:         File - the file for the image that was created using image picker

  Description:    Use image picker for the camera, but use multiple image picker for gallery just to stay
                  consistent with the posts.
  ---------------------------------------------------------------------------------------------------*/
  Future<File> getImage({bool source, bool circle}) async {
    File _image;
    File _croppedFile;
    Asset _temp;

    if (source == false) {
      _image = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      _temp = (await MultiImagePicker.pickImages(maxImages: 1))[0];
      _image = File(await _temp.filePath);
    }

    _croppedFile = await ImageCropper.cropImage(
      sourcePath: _image.path,
      circleShape: circle,
      toolbarColor: Colors.black,
      toolbarWidgetColor: Colors.purpleAccent[100],
    );

    return _croppedFile;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         List<Asset> - List of Assets, which are defined by the MultiPicker library

  Description:    Can select multiple pictures and return back the whole list.
  ---------------------------------------------------------------------------------------------------*/
  Future<List<Asset>> getMultipleImages(int maxImages) async {
    List<Asset> resultList;
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: maxImages,
      );
    } catch (e) {
      //error occurred
    }

    return resultList;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         image - the image that needs to be cropped
  
  Return:         File - the file for the image that was cropped

  Description:    Simply take the image, and crop it.
  ---------------------------------------------------------------------------------------------------*/
  Future<File> cropImage({File image}) async {
    File _croppedFile;

    _croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      toolbarColor: Colors.black,
      toolbarWidgetColor:
          Colors.purpleAccent[100], //should be the same as the secondary color for appp
    );

    return _croppedFile;
  }
}
