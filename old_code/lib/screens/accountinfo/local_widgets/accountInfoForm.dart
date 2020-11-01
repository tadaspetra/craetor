import 'package:craetor/models/userData.dart';
import 'package:craetor/services/firebase/authProvider.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'package:craetor/widgets/texts/textFormField.dart';
import 'package:flutter/material.dart';

import 'package:craetor/utils/validation/formFieldValidator.dart';

class OurAccountInfoForm extends StatefulWidget {
  @override
  _OurAccountInfoFormState createState() => _OurAccountInfoFormState();
}

class _OurAccountInfoFormState extends State<OurAccountInfoForm> {
  OurUserData _userData = OurUserData();
  OurFormFieldValidator validate = OurFormFieldValidator();
  final _accountFormKeySign = GlobalKey<FormState>();
  static TextEditingController firstNameController = TextEditingController();
  static TextEditingController lastNameController = TextEditingController();

  static TextEditingController bioController = TextEditingController();
  static TextEditingController experienceController = TextEditingController();
  static TextEditingController topCategoryController = TextEditingController();
  static TextEditingController websiteController = TextEditingController();
  static TextEditingController phoneController = TextEditingController();
  static TextEditingController educationController = TextEditingController();
  static TextEditingController ageController = TextEditingController();
  static TextEditingController workplaceController = TextEditingController();
  static TextEditingController locationController = TextEditingController();

  String dropdownValue = 'none';
  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Initializes the user's data values and sets the controller's text to each specific
                  field it applies to
  ---------------------------------------------------------------------------------------------------*/
  void didChangeDependencies() {
    super.didChangeDependencies();
    var auth = OurAuthProvider.of(context).auth;
    auth.getCurrentUser().then((user) {
      OurBaseStore().getUserInformation(user.uid).then((user) {
        setState(() {
          _userData.firstName = user.data["firstName"];
          firstNameController.text = _userData.firstName;
          _userData.lastName = user.data["lastName"];
          lastNameController.text = _userData.lastName;

          _userData.bio = user.data["bio"];
          bioController.text = _userData.bio;
          _userData.experience = user.data["experience"];
          experienceController.text = _userData.experience;
          _userData.topCategory = user.data["topCategory"];
          topCategoryController.text = _userData.topCategory;
          if (topCategoryController.text != null && topCategoryController.text != "") {
            dropdownValue = topCategoryController.text;
          }
          _userData.website = user.data["website"];
          websiteController.text = _userData.website;
          _userData.phoneNumber = user.data["phoneNumber"];
          phoneController.text = _userData.phoneNumber;
          _userData.education = user.data["education"];
          educationController.text = _userData.education;
          _userData.age = user.data["age"];
          ageController.text = _userData.age;
          _userData.workplace = user.data["workplace"];
          workplaceController.text = _userData.workplace;
          _userData.location = user.data["location"];
          locationController.text = _userData.location;
        });
      });
      _userData.uid = user.uid;
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         context- represents this Scaffold in the app
  
  Return:         None

  Description:    Verifies that all the text form fields are valid, sets user's data values to
                  each fields text, updates all those fields values in firebase, navigate to profile
  ---------------------------------------------------------------------------------------------------*/
  void submitEditedInfo(BuildContext context) async {
    if (_accountFormKeySign.currentState.validate()) {
      _userData.firstName = firstNameController.text.trim();
      _userData.lastName = lastNameController.text.trim();
      _userData.bio = bioController.text;
      _userData.experience = experienceController.text;
      _userData.topCategory = dropdownValue;
      _userData.website = websiteController.text.trim();
      _userData.phoneNumber = phoneController.text.trim();
      _userData.education = educationController.text;
      _userData.age = ageController.text.trim();
      _userData.workplace = workplaceController.text;
      _userData.location = locationController.text;
      OurBaseStore().updateUserInfo(_userData);
      Navigator.pop(context);
    } else {
      //do nothing
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Builds a form that includes all the different data that a user can change. When button
                  is pressed to submit, they will be validated, and updated in the users info.
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _accountFormKeySign,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OurTextFormField(
              icon: Icon(Icons.person_outline),
              controller: firstNameController,
              label: "edit first name",
              formValidator: (value) => validate.nameValidator(value.trim()),
            ),
            SizedBox(
              height: 10.0,
            ),
            OurTextFormField(
              icon: Icon(Icons.person_outline),
              controller: lastNameController,
              label: "enter last name",
              formValidator: (value) => validate.nameValidator(value.trim()),
            ),
            SizedBox(
              height: 10.0,
            ),
            OurTextFormField(
              icon: Icon(Icons.info_outline),
              controller: bioController,
              label: "edit bio",
              multipleLines: true,
              formValidator: (value) => validate.genericValidator(value),
            ),
            SizedBox(
              height: 10.0,
            ),
            OurTextFormField(
              icon: Icon(Icons.info_outline),
              controller: experienceController,
              label: "edit experience",
              multipleLines: true,
              formValidator: (value) => validate.genericValidator(value),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Text(
                    "top category:",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
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
            SizedBox(
              height: 10.0,
            ),
            OurTextFormField(
              icon: Icon(Icons.web),
              controller: websiteController,
              label: "edit website",
              formValidator: (value) => validate.genericValidator(value.trim()),
            ),
            SizedBox(
              height: 10.0,
            ),
            OurTextFormField(
              icon: Icon(Icons.phone),
              controller: phoneController,
              label: "edit phone number",
              formValidator: (value) => validate.genericValidator(value.trim()),
            ),
            SizedBox(
              height: 10.0,
            ),
            OurTextFormField(
              icon: Icon(Icons.school),
              controller: educationController,
              label: "edit education",
              formValidator: (value) => validate.genericValidator(value),
            ),
            SizedBox(
              height: 10.0,
            ),
            OurTextFormField(
              icon: Icon(Icons.info_outline),
              controller: ageController,
              label: "edit age",
              formValidator: (value) => validate.genericValidator(value.trim()),
            ),
            SizedBox(
              height: 10.0,
            ),
            OurTextFormField(
              icon: Icon(Icons.work),
              controller: workplaceController,
              label: "edit workplace",
              formValidator: (value) => validate.genericValidator(value),
            ),
            SizedBox(
              height: 10.0,
            ),
            OurTextFormField(
              icon: Icon(Icons.location_on),
              controller: locationController,
              label: "edit location",
              formValidator: (value) => validate.genericValidator(value),
            ),
            SizedBox(
              height: 40.0,
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
                child: Text(
                  "update",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              onPressed: () => submitEditedInfo(context),
            ),
            SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }
}
