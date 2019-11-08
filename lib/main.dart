import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';

void main() => runApp(MyApp());

Future<void> writeToFile(ByteData data, String path) {
  print(path);
  final buffer = data.buffer;
  return new File(path).writeAsBytes(
      buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

Future<String> _getPath() async {
  var appDoc = await getExternalStorageDirectories();
  print(appDoc);
  String path = appDoc[0].path;
  return path;
}

String _createFileName() {
  final now = DateTime.now();
  return "lgtm-${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}";
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LGTM Maker',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(title: 'LGTM Maker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  GlobalKey _globalKey = GlobalKey();
  double _fontSize = 64.0;
  String lgtm = "LGTM";
  final _textController = TextEditingController(text: "LGTM");
  Color _fontColor = Colors.white;

  Future openImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future saveImage() async {
    print("saveImage");

    RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject();

    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    await Share.file("lgtm", "lgtm", byteData.buffer.asUint8List(), 'image/png');

    /*
    String path = await _getPath();
    String fileName = _createFileName();

    writeToFile(byteData, "$path/$fileName.png");
    */
  }

  void clearImage() {
    setState(() {
      _image = null;
    });
  }

  void fontSizeUp() {
    setState(() {
      _fontSize += 1.0;
    });
  }

  void fontSizeDown() {
    setState(() {
      _fontSize -= 1.0;
    });
  }

  void changeColor(Color color) {
    setState(() => _fontColor = color);
  }

  void showColorPicker() {
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _fontColor,
            onColorChanged: changeColor,
            enableLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          //   enableLabel: true, // only on portrait mode
          // ),
          //
          // Use Block color picker:
          //
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Set'),
            onPressed: () {
              //setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var _fabMiniMenuItemList = [
       new FabMiniMenuItem.withText(
         Icon(Icons.add_photo_alternate),
         Colors.amber.shade300,
         4.0,
         "Button menu",
         openImage,
         "Open",
         Colors.blue,
         Colors.white,
         true
       ),
      new FabMiniMenuItem.withText(
          Icon(Icons.share),
          Colors.amber.shade300,
          4.0,
          "Button menu",
          saveImage,
          "Share",
          Colors.blue,
          Colors.white,
          true
      ),
      new FabMiniMenuItem.withText(
          Icon(Icons.clear),
          Colors.amber,
          4.0,
          "Button menu",
          clearImage,
          "Clear",
          Colors.blue,
          Colors.white,
          true
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton:
        FabDialer(_fabMiniMenuItemList, Colors.amber, Icon(Icons.add)),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
                child: _image == null
              ? Text('No image selected.')
              : RepaintBoundary(
                    key: _globalKey,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Image.file(_image),
                        Text(
                          lgtm,
                          style: TextStyle(
                              color: _fontColor,
                              fontSize: _fontSize,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    )
                )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _textController,
                onChanged: (value) {
                  setState(() {
                    lgtm = value;
                  });
                },
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 4, left: 4),
                  child: RaisedButton(
                    child: Text("Font Size Up"),
                    onPressed: fontSizeUp,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4, left: 4),
                  child: RaisedButton(
                    child: Text("Font Size Down"),
                    onPressed: fontSizeDown,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 4, left: 4),
                  child: RaisedButton(
                    child: Text("Color"),
                    onPressed: showColorPicker,
                  ),
                )
              ],
            )
          ]
        ),
      )
    );
  }
}
