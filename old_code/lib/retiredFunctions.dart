/*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - returns the display of images and a text input

  Description:    Shows a carousel with all the images and separate descriptions for each image
  ---------------------------------------------------------------------------------------------------*/
// Widget _pictureDisplay() {
//   Widget retVal;

//   retVal = CarouselSlider(
//     height: 420.0, //fucking littttttttt
//     initialPage: 0,
//     enableInfiniteScroll: false, // this makes it so we can only scroll one way
//     onPageChanged: (index) {
//       _currentIndex = index;
//     },
//     items: widget.imageList
//         .asMap()
//         .map((i, imageFile) {
//           return MapEntry(
//             i,
//             Builder(
//               builder: (BuildContext context) {
//                 return Container(
//                   width: MediaQuery.of(context).size.width,
//                   margin: EdgeInsets.all(10.0),
//                   decoration: BoxDecoration(color: Colors.black),
//                   child: Column(
//                     children: <Widget>[
//                       Image.file(imageFile),
//                       TextField(
//                         controller: descriptionController[i],
//                         keyboardType: TextInputType.multiline,
//                         maxLines: 4,
//                         decoration: InputDecoration(labelText: "Add Description here"),
//                       )
//                     ],
//                   ),
//                 );
//               },
//             ),
//           );
//         })
//         .values
//         .toList(),
//   );

//   return retVal;
// }
