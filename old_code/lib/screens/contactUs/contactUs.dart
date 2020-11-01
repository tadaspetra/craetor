import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OurContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "contact us",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "If you see any issues or would like to report any improvements or new categories we could include, please feel free to contact us at:",
                style: TextStyle(fontSize: 18, color: Theme.of(context).secondaryHeaderColor),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: SelectableText(
                "craetornetwork@gmail.com",
                style: TextStyle(fontSize: 18, decoration: TextDecoration.underline),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: "craetornetwork@gmail.com"));
                  SnackBar _snackbar = SnackBar(
                    content: Text("Copied to clipboard"),
                    duration: Duration(seconds: 1),
                  );
                  Scaffold.of(context).showSnackBar(_snackbar);
                },
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Instagram: ",
                style: TextStyle(fontSize: 18, color: Theme.of(context).secondaryHeaderColor),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: SelectableText(
                "@craetornetwork",
                style: TextStyle(fontSize: 18, decoration: TextDecoration.underline),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: "@craetornetwork"));
                  SnackBar _snackbar = SnackBar(
                    content: Text("Copied to clipboard"),
                    duration: Duration(seconds: 1),
                  );
                  Scaffold.of(context).showSnackBar(_snackbar);
                },
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Twitter: ",
                style: TextStyle(fontSize: 18, color: Theme.of(context).secondaryHeaderColor),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: SelectableText(
                "@craetornetwork",
                style: TextStyle(fontSize: 18, decoration: TextDecoration.underline),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: "@craetornetwork"));
                  SnackBar _snackbar = SnackBar(
                    content: Text("Copied to clipboard"),
                    duration: Duration(seconds: 1),
                  );
                  Scaffold.of(context).showSnackBar(_snackbar);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
