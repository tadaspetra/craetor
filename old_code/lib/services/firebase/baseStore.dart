import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craetor/models/globals.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:craetor/models/post.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:craetor/models/userData.dart';

class OurBaseStore {
  final Firestore firestore = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  /*---------------------------------------------------------------------------------------------------
  Inputs:         uid - which user you want to retrieve token for
  
  Return:         The snapshot of all the token info

  Description:    Returns the token for this particular device
  ---------------------------------------------------------------------------------------------------*/

  Future<DocumentSnapshot> getToken(String uid) async {
    String fcmToken = await _fcm.getToken();
    Future<DocumentSnapshot> retVal;
    try {
      retVal =
          firestore.collection("users").document(uid).collection("token").document(fcmToken).get();
    } catch (e) {
      //print(e);
    }
    return retVal;
  }
  /*---------------------------------------------------------------------------------------------------
  Inputs:         uid - which user you want to add token for
  
  Return:         None

  Description:    Adds the user token for the specific device
  ---------------------------------------------------------------------------------------------------*/

  Future<void> addToken(String uid) async {
    String fcmToken = await _fcm.getToken();

    try {
      await firestore
          .collection('users')
          .document(uid)
          .collection("token")
          .document(fcmToken)
          .setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      });
      await firestore.collection('users').document(uid).updateData({
        'receivesNotifications': true,
      });
    } catch (e) {
      //print(e);
    }
  }
  /*---------------------------------------------------------------------------------------------------
  Inputs:         uid - which user you want to remove token for 
                  becauseSignOut - if token removed because of signOut then this would be true
  
  Return:         None

  Description:    Removes token for the specific device. If removed because of signout, you do not want to 
                  remove the flag, so it can be checked again on the next login and token added back.
  ---------------------------------------------------------------------------------------------------*/

  Future<void> removeToken(String uid, bool becauseSignOut) async {
    String fcmToken = await _fcm.getToken();

    try {
      await firestore
          .collection('users')
          .document(uid)
          .collection("token")
          .document(fcmToken)
          .delete();

      if (!becauseSignOut) {
        await firestore.collection('users').document(uid).updateData({
          'receivesNotifications': false,
        });
      }
    } catch (e) {
      // print(e);
    }
  }
  /*---------------------------------------------------------------------------------------------------
  Inputs:         currentUser - all the data associated with the current user defined in the "models"
  
  Return:         None

  Description:    Takes all the user information and stores it in cloud firestore in the users collection
                  under a document that is named with the users id.
  ---------------------------------------------------------------------------------------------------*/

  Future<void> addUserInformation(OurUserData currentUser) async {
    String _searchName = currentUser.firstName.toLowerCase() + currentUser.lastName.toLowerCase();
    _searchName = _searchName.replaceAll(RegExp(r"\s+\b|\b\s"), "");

    //firstName.replaceAll(RegExp(r"\s+\b|\b\s"), "");
    try {
      await firestore.collection('users').document(currentUser.uid).setData({
        'firstName': currentUser.firstName.toLowerCase(),
        'lastName': currentUser.lastName.toLowerCase(),
        'email': currentUser.email.toLowerCase(),
        'fullName': _searchName,
        'profilePicture': currentUser.profilePicture,
      });
      addToken(currentUser.uid);
    } catch (e) {
      // print(e);
    }
  }
  /*---------------------------------------------------------------------------------------------------
  Inputs:         uid - the user id of the which users information you want
  
  Return:         DocumentSnapshot - all the information for that user.

  Description:    Find the document corresponding to the user inputted, and return all the users data.
  ---------------------------------------------------------------------------------------------------*/

  Future<DocumentSnapshot> getUserInformation(String uid) async {
    Future<DocumentSnapshot> retVal;
    try {
      retVal = firestore.collection("users").document(uid).get();
    } catch (e) {
      // print(e);
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         userPost - all the post information that is necessary 
  
  Return:         None

  Description:    Takes the list of images stores it in cloud storage. Then after it is stored,
                  the file urls are retrieved and then stored into firestore along with all the other 
                  information from the post
  ---------------------------------------------------------------------------------------------------*/

  Future<void> createPost(OurPost userPost) async {
    try {
      List<String> imageURLs = List();
      List<String> stringDescriptions = List();
      String _coverDescription = userPost.coverDescription.text;

      String fileName = basename(userPost.coverImage.path);
      StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('${userPost.uid}/posts/$fileName');
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(userPost.coverImage);
      //Not necessary, but if we want to show a loading bar for percentage uploaded we would need
      //to use the taskSnapshot. I think we wouldn't await onComplete. We can decide if we want this
      //StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      await uploadTask.onComplete;

      String coverImageUrl = await firebaseStorageRef.getDownloadURL();
      for (int i = 0; i < userPost.imageCount; i++) {
        String fileName = basename(userPost.images[i].path);
        StorageReference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('${userPost.uid}/posts/$fileName');
        StorageUploadTask uploadTask = firebaseStorageRef.putFile(userPost.images[i]);
        //Not necessary, but if we want to show a loading bar for percentage uploaded we would need
        //to use the taskSnapshot. I think we wouldn't await onComplete. We can decide if we want this
        //StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
        await uploadTask.onComplete;

        String tempUrl = await firebaseStorageRef.getDownloadURL();
        imageURLs.add(tempUrl);
        stringDescriptions.add(userPost.descriptions[i].text);
      }
      await firestore.collection("posts").document().setData({
        'uid': userPost.uid,
        'images': imageURLs,
        'coverImage': coverImageUrl,
        'descriptions': stringDescriptions,
        'coverDescription': _coverDescription,
        'time': userPost.time,
        'likeCount': userPost.likeCount,
        'category': userPost.category,
      });
    } catch (e) {
      //print(e);
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         List<DocumentSnapshot> - a list of the all documents that are in firebase.

  Description:    Gets all the first defined number of posts from the collection
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getPosts() async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("posts")
          .orderBy("time", descending: true)
          .limit(fPOSTQUERYLENTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         lastDocument - the last document that is displayed on the screen
  
  Return:         List<DocumentSnapshot> - a list of the all documents that are in firebase.

  Description:    Gets all the next defined number of posts after the lastDocument
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getNextPosts(DocumentSnapshot lastDocument) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("posts")
          .orderBy("time", descending: true)
          .startAfterDocument(lastDocument)
          .limit(fPOSTQUERYLENTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         uid - the user id of the which users information you want
  
  Return:         List<DocumentSnapshot> - a list of the specific user's documents from firebase

  Description:    Gets a defined number of posts from the user.
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getUserPosts(String uid) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("posts")
          .where("uid", isEqualTo: uid)
          .orderBy("time", descending: true)
          .limit(fPOSTQUERYLENTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         uid - the user id of the which users information you want
                  lastDocument - the last document that has already been loaded in
  
  Return:         List<DocumentSnapshot> - a list of the specific user's documents from firebase

  Description:    Get the next number of defined posts from the users starting after the last document
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getNextUserPosts(String uid, DocumentSnapshot lastDocument) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("posts")
          .where("uid", isEqualTo: uid)
          .orderBy("time", descending: true)
          .startAfterDocument(lastDocument)
          .limit(fPOSTQUERYLENTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }
  /*---------------------------------------------------------------------------------------------------
  Inputs:         postId - the post id of the which post information you want
  
  Return:         DocumentSnapshot - a snapshot of the single post that was requested

  Description:    Gets all the single post by postId
  ---------------------------------------------------------------------------------------------------*/

  Future<DocumentSnapshot> getPostByPostId(String postId) async {
    DocumentSnapshot retVal;
    try {
      DocumentSnapshot documentSnapshot =
          await firestore.collection("posts").document(postId).get();
      retVal = documentSnapshot;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         category - which catergory of posts do you want
  
  Return:         List<DocumentSnapshot> - a list of the posts with the specified category

  Description:    Gets a defined number of posts with the category field equal to the one passed in
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getPostsByCategory(String category) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("posts")
          .where("category", isEqualTo: category)
          .orderBy("time", descending: true)
          .limit(fPOSTQUERYLENTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         category - which catergory of posts do you want
                  lastDocument - the last document that has already been loaded in

  Return:         List<DocumentSnapshot> - a list of the posts with the specified category

  Description:    Gets the next defined number of posts with the category field equal to the one passed in
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getNextPostsByCategory(
      String category, DocumentSnapshot lastDocument) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("posts")
          .where("category", isEqualTo: category)
          .orderBy("time", descending: true)
          .startAfterDocument(lastDocument)
          .limit(fPOSTQUERYLENTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         postId - identifies which post in the collection to apply changes to
                  upOrDown - distinguishes is the post has been liked or disliked
                  uid - the user id of the which users information you want
  
  Return:         None

  Description:    If the post has been liked, the value will update the data to increase
                  the count by 1 and will create a document that identifies that the user 
                  has liked the post. If the post has been unliked, update data will decrease
                  the count by 1 and the document in the likes collection will be deleted
  ---------------------------------------------------------------------------------------------------*/
  Future<void> updateLike(String postId, bool upOrDown, String uid) async {
    try {
      final DocumentReference postRef = firestore.collection("posts").document(postId);
      if (upOrDown) {
        await firestore
            .collection("posts")
            .document(postId)
            .collection("likes")
            .document(uid)
            .setData({
          "user": true,
        });
        Firestore.instance.runTransaction((Transaction tx) async {
          DocumentSnapshot postSnapshot = await tx.get(postRef);
          if (postSnapshot.exists) {
            await tx.update(
                postRef, <String, dynamic>{'likeCount': postSnapshot.data['likeCount'] + 1});
          }
        });
      } else {
        await firestore
            .collection("posts")
            .document(postId)
            .collection("likes")
            .document(uid)
            .delete();
        Firestore.instance.runTransaction((Transaction tx) async {
          DocumentSnapshot postSnapshot = await tx.get(postRef);
          if (postSnapshot.exists) {
            await tx.update(
                postRef, <String, dynamic>{'likeCount': postSnapshot.data['likeCount'] - 1});
          }
        });
      }
    } catch (e) {
      //print(e);
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         userData - data associated with user as defined in the "models"
  
  Return:         None

  Description:    Updates the data fields for the specific user
  ---------------------------------------------------------------------------------------------------*/
  Future<void> updateUserInfo(OurUserData userData) async {
    String _searchName = userData.firstName.toLowerCase() + userData.lastName.toLowerCase();
    _searchName = _searchName.replaceAll(RegExp(r"\s+\b|\b\s"), "");
    try {
      await firestore.collection("users").document(userData.uid).updateData({
        'firstName': userData.firstName.toLowerCase(),
        'lastName': userData.lastName.toLowerCase(),
        'fullName': _searchName,
        'bio': userData.bio,
        'experience': userData.experience,
        'topCategory': userData.topCategory,
        'website': userData.website,
        'phoneNumber': userData.phoneNumber,
        'education': userData.education,
        'age': userData.age,
        'workplace': userData.workplace,
        'location': userData.location,
      });
    } catch (e) {
      //print(e);
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         uid- the user id of the which users information you want
                  picture- image to submit to firebase
  
  Return:         String- returns the profile picture's image url

  Description:    Stores an image selected in the cloud storage. Then after it is stored, the file url
                  is retrieved and updated in firebase
  ---------------------------------------------------------------------------------------------------*/
  Future<String> updateUserProfilePic(File data, String uid) async {
    String retVal;
    try {
      String fileName = basename(data.path);
      StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('$uid/profilePicture/$fileName');
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(data);
      //Not necessary, but if we want to show a loading bar for percentage uploaded we would need
      //to use the taskSnapshot. I think we wouldn't await onComplete. We can decide if we want this
      //StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      await uploadTask.onComplete;

      String profileImageUrl = await firebaseStorageRef.getDownloadURL();
      await firestore.collection("users").document(uid).updateData({
        'profilePicture': profileImageUrl,
      });
      retVal = profileImageUrl;
    } catch (e) {
      //print(e);
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         postId - identifies which post is being checked
                  uid - the user id of which user is being checked
  
  Return:         None

  Description:    Look for the document coinciding with the user id in the likes collection for the 
                  specific post. If there is something returned from this function then the caller will
                  know that it is there. If null is returned, then it is not there.
  ---------------------------------------------------------------------------------------------------*/
  Future<DocumentSnapshot> doesLikeExist(String postId, String uid) async {
    Future<DocumentSnapshot> retVal;
    try {
      retVal =
          firestore.collection("posts").document(postId).collection("likes").document(uid).get();
    } catch (e) {
      //print(e);
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         postId - identifies which post is being commented
                  uid - the user id of which user is commenting
                  comment - the comment that the user is leaving
                  firstName - first name of the commentator
                  lastName - last name of the commentator
  
  Return:         None

  Description:    Add a comment in a comment collection inside the posts, and store the necessary data
  ---------------------------------------------------------------------------------------------------*/
  Future<void> addComment(String postId, String uid, String comment, String firstName,
      String lastName, String profilePicture) async {
    try {
      await firestore
          .collection("posts")
          .document(postId)
          .collection("comments")
          .document()
          .setData({
        'uid': uid,
        'comment': comment,
        'firstName': firstName.toLowerCase(),
        'lastName': lastName.toLowerCase(),
        'profilePicture': profilePicture,
        'time': Timestamp.now(),
      });
    } catch (e) {
      //print(e);
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         postId - the id of which post you want to get all the comments from
  
  Return:         List<DocumentSnapshot> - a list of the all documents that are in firebase 

  Description:    Gets a defined number of comments associated to the postId that is passed in
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getComments(String postId) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("posts")
          .document(postId)
          .collection("comments")
          .orderBy("time", descending: false)
          .limit(fCOMMENTQUERYLENGTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         postId - the id of which post you want to get all the comments from
                  lastDocument - the last document that has already been loaded in
  
  Return:         List<DocumentSnapshot> - a list of the all documents that are in firebase 

  Description:    Gets the next defined number of comments associated to the postId that is passed in
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getNextComments(
      String postId, DocumentSnapshot lastDocument) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("posts")
          .document(postId)
          .collection("comments")
          .orderBy("time", descending: false)
          .startAfterDocument(lastDocument)
          .limit(fCOMMENTQUERYLENGTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         currentUid - Uid of the user currently using the app
                  otherUid - the user id of who the current user is updating follow status
                  follow - whether the user is following or unfollowing. 
                          True - following
                          False - unfollowing
  
  Return:         None

  Description:    If the post has been liked, the value will update the data to increase
                  the count by 1 and will create a document that identifies that the user 
                  has liked the post. If the post has been unliked, update data will decrease
                  the count by 1 and the document in the likes collection will be deleted
  ---------------------------------------------------------------------------------------------------*/
  Future<void> updateFollow(String currentUid, String otherUid, bool follow) async {
    try {
      if (follow) {
        await firestore
            .collection("users")
            .document(currentUid)
            .collection("following")
            .document(otherUid)
            .setData({
          "user": true,
        });
        await firestore
            .collection("users")
            .document(otherUid)
            .collection("followers")
            .document(currentUid)
            .setData({
          "user": true,
        });
      } else {
        await firestore
            .collection("users")
            .document(currentUid)
            .collection("following")
            .document(otherUid)
            .delete();
        await firestore
            .collection("users")
            .document(otherUid)
            .collection("followers")
            .document(currentUid)
            .delete();
      }
    } catch (e) {
      //print(e);
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         currentUid - Uid of the user currently using the app
                  otherUid - the user id of which user is being checked
  
  Return:         DocumentSnapshot - the document that corresponds ot the query

  Description:    Look for the document coinciding with the user id in the following collection in the 
                  current users colletion. If there is something returned from this function then the caller will
                  know current user is following the other. If null is returned, then current user is not.
  ---------------------------------------------------------------------------------------------------*/
  Future<DocumentSnapshot> doesFollowExist(String currentUid, String otherUid) async {
    Future<DocumentSnapshot> retVal;
    try {
      retVal = firestore
          .collection("users")
          .document(currentUid)
          .collection("following")
          .document(otherUid)
          .get();
    } catch (e) {
      //print(e);
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         uid - the user id of whos following posts you want to show
  
  Return:         List<DocumentSnapshot> - a list of the documents from all the inputs followers

  Description:    Goes through the users followers. Gets their uid and one by one queries their posts and 
                  displays all following users posts in a row by time until the next follower. This is not
                  how we want it. Firebase doesn't support OR where queries. Hopefull it will and it will
                  be updated in task #127. Added sorting after all the follower post queries are 
                  executed.
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getFeed(List<String> tenFollowing) async {
    List<DocumentSnapshot> retVal = List();
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("posts")
          .where("uid", whereIn: tenFollowing)
          .orderBy("time", descending: true)
          .limit(fPOSTQUERYLENTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  Future<List<DocumentSnapshot>> getNextFeed(
      List<String> tenFollowing, DocumentSnapshot lastDocument) async {
    List<DocumentSnapshot> retVal = List();
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("posts")
          .where("uid", whereIn: tenFollowing)
          .orderBy("time", descending: true)
          .startAfterDocument(lastDocument)
          .limit(fPOSTQUERYLENTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
    Inputs:         likerUid - Uid of the person liking post
                    postId - which post the liker is liking
                    postPicture - the first picture of the post
                    postOwnerUid - Uid of the person who owns the post
    
    Return:         None

    Description:   Adds a type 0 notifcation to the postOwners notifications collection
    ---------------------------------------------------------------------------------------------------*/
  Future<void> addLikeNotification(
      String likerUid, String postId, dynamic postPicture, String postOwnerUid) async {
    try {
      DocumentSnapshot likerInfo = await getUserInformation(likerUid);
      //store notification type and current user stats
      await firestore
          .collection("users")
          .document(postOwnerUid)
          .collection("notifications")
          .document()
          .setData({
        'type': 0, //type 0 for likes type 1 for comments type 2 for follow
        'uid': likerUid,
        'likerFirstName': likerInfo.data["firstName"].toLowerCase(),
        'likerLastName': likerInfo.data["lastName"].toLowerCase(),
        'profilePicture': likerInfo.data['profilePicture'],
        'time': Timestamp.now(),
        'postId': postId,
        'postPicture': postPicture,
      });
    } catch (e) {
      //print(e);
    }
  }

  /*---------------------------------------------------------------------------------------------------
    Inputs:         likerUid - Uid of the person liking post
                    postId - which post the liker is liking
                    postOwnerUid - Uid of the person who owns the post
    
    Return:         None

    Description:    Remove the notification from postOwners notification collection when picture is  
                    unliked
    ---------------------------------------------------------------------------------------------------*/
  Future<void> removeLikeNotification(String likerUid, String postId, String postOwnerUid) async {
    try {
      //query for likerUid and postId and type 0
      firestore
          .collection("users")
          .document(postOwnerUid)
          .collection("notifications")
          .where("uid", isEqualTo: likerUid)
          .where("postId", isEqualTo: postId)
          .where("type", isEqualTo: 0)
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          ds.reference.delete();
        }
      });
    } catch (e) {
      // print(e);
    }
  }

  /*---------------------------------------------------------------------------------------------------
    Inputs:         commenterUid - Uid of the person commenting on the post
                    postId - which post the commenter is commenting on
                    postPicture - the first picture of the post
                    postOwnerUid - Uid of the person who owns the post
                    commentContent - what the comment that was left contains
    
    Return:         None 

    Description:    Adds a type 1 notifcation to the postOwners notifications collection
    ---------------------------------------------------------------------------------------------------*/
  Future<void> addCommentNotification(String commenterUid, String postId, dynamic postPicture,
      String postOwnerUid, String commentContent) async {
    try {
      DocumentSnapshot commenterInfo = await getUserInformation(commenterUid);
      //store notification type and current user stats
      await firestore
          .collection("users")
          .document(postOwnerUid)
          .collection("notifications")
          .document()
          .setData({
        'type': 1, //type 0 for likes type 1 for comments type 2 for follow
        'uid': commenterUid,
        'commenterFirstName': commenterInfo.data["firstName"].toLowerCase(),
        'commenterLastName': commenterInfo.data["lastName"].toLowerCase(),
        'profilePicture': commenterInfo.data['profilePicture'],
        'time': Timestamp.now(),
        'postId': postId,
        'postPicture': postPicture,
        'commentContent': commentContent,
      });
    } catch (e) {
      //print(e);
    }
  }

  /*---------------------------------------------------------------------------------------------------
    Inputs:         followerUid - the Uid of the person doing the following
                    beingFollowedUid - the Uid of the person being followed
    
    Return:         None

    Description:    Adds a type 2 notifcation to the postOwners notifications collection
    ---------------------------------------------------------------------------------------------------*/
  Future<void> addFollowNotification(String followerUid, String beingFollowedUid) async {
    try {
      DocumentSnapshot likerInfo = await getUserInformation(followerUid);
      //store notification type and current user stats
      await firestore
          .collection("users")
          .document(beingFollowedUid)
          .collection("notifications")
          .document()
          .setData({
        'type': 2, //type 0 for likes type 1 for comments type 2 for follow
        'uid': followerUid,
        'followerFirstName': likerInfo.data["firstName"].toLowerCase(),
        'followerLastName': likerInfo.data["lastName"].toLowerCase(),
        'profilePicture': likerInfo.data['profilePicture'],
        'time': Timestamp.now(),
      });
    } catch (e) {
      //print(e);
    }
  }

  /*---------------------------------------------------------------------------------------------------
    Inputs:         followerUid - the Uid of the person doing the following
                    beingFollowedUid - the Uid of the person being followed
    
    Return:         None

    Description:    Remove the notification from postOwners notification collection when person is 
                    unfollowed
    ---------------------------------------------------------------------------------------------------*/
  Future<void> removeFollowNotification(String followerUid, String beingFollowedUid) async {
    try {
      //query for likerUid and postId and type 0
      firestore
          .collection("users")
          .document(beingFollowedUid)
          .collection("notifications")
          .where("uid", isEqualTo: followerUid)
          .where("type", isEqualTo: 2)
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          ds.reference.delete();
        }
      });
    } catch (e) {
      //print(e);
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         uesrId - the id of which post you want to get the notifications for
  
  Return:         List<DocumentSnapshot> - a list of the all documents that are in firebase 

  Description:    Gets 50 of the notifications from the specified user
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getNotifications(String userId) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("users")
          .document(userId)
          .collection("notifications")
          .orderBy("time", descending: true)
          .limit(fNOTIFICATIONQUERYLENGTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         fullName - the first and last name of the user together with no spaces
  
  Return:         List<DocumentSnapshot> - a list of the users that match conditions from firevase

  Description:    Gets the defined number of users who's fullName field starts with the same as passed in
  ---------------------------------------------------------------------------------------------------*/
  Future<List<DocumentSnapshot>> getSearchResults(String fullName) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("users")
          .where("fullName", isGreaterThanOrEqualTo: fullName.toLowerCase())
          .where('fullName', isLessThan: fullName.toLowerCase() + 'z')
          .orderBy("fullName", descending: true)
          .limit(fSEARCHQUERYLENTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         fullName - the first and last name of the user together with no spaces
                  lastDocument - the last document that has already been loaded in
  
  Return:         List<DocumentSnapshot> - a list of the users that match conditions from firevase

  Description:    Gets the enxt defined number of users who's fullName field starts with the same as passed in
  ---------------------------------------------------------------------------------------------------*/
  Future<List<DocumentSnapshot>> getNextSearchResults(
      String fullName, DocumentSnapshot lastDocument) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("users")
          .where("fullName", isGreaterThanOrEqualTo: fullName.toLowerCase())
          .where('fullName', isLessThan: fullName.toLowerCase() + 'z')
          .orderBy("fullName", descending: true)
          .startAfterDocument(lastDocument)
          .limit(fSEARCHQUERYLENTH)
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         uesrId - the id of which post you want to get the followers for
  
  Return:         List<DocumentSnapshot> - a list of the all documents that are in firebase 

  Description:    Gets all the followers for the specified user
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getFollowers(String userId) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("users")
          .document(userId)
          .collection("followers")
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         uesrId - the id of which post you want to get the followers for
  
  Return:         List<DocumentSnapshot> - a list of the all documents that are in firebase 

  Description:    Gets all the followers for the specified user
  ---------------------------------------------------------------------------------------------------*/

  Future<List<DocumentSnapshot>> getFollowing(String userId) async {
    List<DocumentSnapshot> retVal;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("users")
          .document(userId)
          .collection("following")
          .getDocuments();
      retVal = querySnapshot.documents;
    } catch (e) {
      //print(e);
      retVal = e;
    }
    return retVal;
  }
}
