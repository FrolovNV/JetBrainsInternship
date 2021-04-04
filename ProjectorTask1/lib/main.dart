import 'dart:ui' as ui;
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:async';
import 'dart:typed_data';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DrawingPoints> points = [];
  DrawingLine line = null;
  DrawingRectangle rectangle = null;

  Color currentColor = Colors.cyan;
  double brushWidth = 3.0;
  bool drawingFlag = true;
  final picker = ImagePicker();
  File image;
  ui.Image uiImage;
  bool isImageloaded = false;
  bool drawingLine = false;
  bool drawingRectangle = false;


  openGallery() async {
    var picture = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (picture != null) {
        image = File(picture.path);
      }
    });
    final ByteData data = await rootBundle.load(picture.path);
    uiImage = await loadImage(new Uint8List.view(data.buffer));
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<void> selectImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Get image from: ",
            ),
            content: SingleChildScrollView(
                child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("From Gallery"),
                  onTap: () {
                    openGallery();
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  child: Text("White Canvas"),
                  onTap: (){
                    setState(() {
                    uiImage = null;
                    Navigator.of(context).pop();
                  }); },
                )
              ],
            )),
            actions: [
              MaterialButton(
                elevation: 5.0,
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Colors.cyan,
              ),
            ],
          );
        });
  }

  Future<void> changeColorDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Change Color and Stroke Width: ",
            ),
            content: Column(children: <Widget>[
              ColorPicker(
                color: currentColor,
                onColorChanged: (Color color) =>
                    setState(() => currentColor = color),
              ),
            ]),
            actions: [
              MaterialButton(
                elevation: 5.0,
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Colors.cyan,
              ),
            ],
          );
        });
  }

  bool checkDistance(Offset point1, Offset point2) {
    if (point1 == null) {
      return false;
    }
    double distance = sqrt(pow((point1.dx - point2.dx), 2) + pow((point1.dy - point2.dy), 2));
    return (distance < brushWidth * 1.5);
  }

  void findPointForOffsets(Offset point1, Offset point2, Paint paint) {
    setState(() {
      for (double i = 0; i<1; i+=0.1) {
        Offset newPoint = Offset.lerp(point1, point2, i);
        if (newPoint != null) {
          points.add(DrawingPoints(point: newPoint, paint: paint));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.cyan,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: width,
                  height: height * 0.6,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                        ),
                      ]),
                  child: GestureDetector(
                    onPanDown: (details) {
                      setState(() {
                        if (drawingRectangle) {
                          rectangle = DrawingRectangle(
                            startPoint: details.localPosition,
                            endPoint: details.localPosition,
                            paint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = currentColor
                              ..strokeWidth = brushWidth
                          );
                          return;
                        }
                        if (drawingLine) {
                          line = DrawingLine(
                            startPoint: details.localPosition,
                            endPoint: details.localPosition,
                            paint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = currentColor
                              ..strokeWidth = brushWidth);
                          return;
                        }
                        if (!drawingFlag && points.isNotEmpty) {
                          int index = points.indexWhere((element) => checkDistance(element?.point, details.localPosition));
                          if (index == -1) {
                            return;
                          }
                          points[index] = null;
                          return;
                        }
                        points.add(DrawingPoints(
                            point: details.localPosition,
                            paint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = currentColor
                              ..strokeWidth = brushWidth));
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        if (drawingRectangle) {
                          rectangle.endPoint = details.localPosition;
                          return;
                        }
                        if (drawingLine) {
                          line.endPoint = details.localPosition;
                          return;
                        }
                        if (!drawingFlag && points.isNotEmpty) {
                          int index = points.indexWhere((element) => checkDistance(element?.point, details.localPosition));
                          if (index == -1) {
                            return;
                          }
                          points[index] = null;
                          return;
                        }
                        points.add(DrawingPoints(
                            point: details.localPosition,
                            paint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = currentColor
                              ..strokeWidth = brushWidth));
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        if (drawingRectangle) {
                          Offset point1 = Offset(rectangle.startPoint.dx, rectangle.endPoint.dy);
                          Offset point2 = Offset(rectangle.endPoint.dx, rectangle.startPoint.dy);
                          findPointForOffsets(rectangle.startPoint, point1, rectangle.paint);
                          findPointForOffsets(rectangle.startPoint, point2, rectangle.paint);
                          findPointForOffsets(rectangle.endPoint, point1, rectangle.paint);
                          findPointForOffsets(rectangle.endPoint, point2, rectangle.paint);
                          points.add(null);
                          rectangle = null;
                          return;
                        }
                        if (drawingLine) {
                          findPointForOffsets(line.startPoint, line.endPoint, line.paint);
                          line = null;
                        }
                        points.add(null);
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      child:
                          CustomPaint(painter: MyCustomPainter(points: points, line: line, rectangle: rectangle, image: uiImage)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: width * 0.8,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                          icon: Icon(
                            Icons.brush,
                            color: (drawingFlag) ? Colors.blue : Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              drawingFlag = !drawingFlag;
                              drawingLine = false;
                              drawingRectangle = false;
                            });
                          }),
                      IconButton(
                          icon: Icon(Icons.color_lens, color: currentColor),
                          onPressed: () {
                            changeColorDialog(context);
                          }),
                      IconButton(
                          icon: Icon(Icons.layers_clear),
                          onPressed: () {
                            setState(() {
                              points.clear();
                            });
                          }),
                      Slider(
                          min: 1.0,
                          max: 7.0,
                          label: "Stroke width = $brushWidth",
                          value: brushWidth,
                          onChanged: (double value) {
                            this.setState(() {
                              brushWidth = value;
                            });
                          }),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: width * 0.8,
                  height: height * 0.05,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: Row(
                    children: <Widget>[
                      Spacer(),
                      GestureDetector(
                        child: Text(
                            "Drawing Line",
                            style: TextStyle(color: (drawingLine)? Colors.blue : Colors.black)
                        ),
                        onTap: (){
                          setState(() {
                            drawingLine = !drawingLine;
                            drawingFlag = true;
                            drawingRectangle = false;
                          });
                        },
                      ),
                      Spacer(),
                      GestureDetector(
                        child: Text(
                            "Drawing Rectangle",
                        style: TextStyle(color: (drawingRectangle)? Colors.blue : Colors.black)
                        ),
                        onTap: (){
                          setState(() {
                            drawingRectangle = !drawingRectangle;
                            drawingFlag = true;
                            drawingLine = false;
                          });
                        },
                      ),
                      Spacer(),
                     ]
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          selectImage(context);
        },
        child: Text(
          "Pic",
          style: TextStyle(fontSize: 20, color: Colors.cyan),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingPoints> points;
  DrawingLine line;
  DrawingRectangle rectangle;

  ui.Image image;

  MyCustomPainter({this.points, this.line, this.rectangle, this.image});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);

    if (image != null) {
      canvas.drawImage(image, new Offset(0.0, 0.0), new Paint());
    }

    if (line != null) {
      canvas.drawLine(line.startPoint, line.endPoint, line.paint);
    }

    if (rectangle != null) {
      Offset point1 = Offset(rectangle.startPoint.dx, rectangle.endPoint.dy);
      Offset point2 = Offset(rectangle.endPoint.dx, rectangle.startPoint.dy);
      canvas.drawLine(rectangle.startPoint, point1, rectangle.paint);
      canvas.drawLine(rectangle.startPoint, point2, rectangle.paint);
      canvas.drawLine(rectangle.endPoint, point1, rectangle.paint);
      canvas.drawLine(rectangle.endPoint, point2, rectangle.paint);
    }

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i].point, points[i + 1].point, points[i].paint);
      } else if (points[i + 1] != null && points[i + 1] == null) {
        canvas.drawPoints(
            ui.PointMode.points, [points[i].point], points[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class DrawingPoints {
  Offset point;
  Paint paint;

  DrawingPoints({this.point, this.paint});
}

class DrawingLine {
  Offset startPoint;
  Offset endPoint;

  Paint paint;
  DrawingLine({this.startPoint, this.endPoint, this.paint});
}

class DrawingRectangle {
  Offset startPoint;
  Offset endPoint;
  Paint paint;

  DrawingRectangle({this.startPoint, this.endPoint, this.paint});
}