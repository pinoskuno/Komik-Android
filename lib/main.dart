import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:komik_edmt/model/comic.dart';
import 'package:komik_edmt/screens/chapter_screen.dart';
import 'package:komik_edmt/state/state_manager.dart';
import 'package:komik_edmt/screens/read_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
      name: 'comic_edmt_flutter',
      options: Platform.isMacOS || Platform.isIOS
          ? FirebaseOptions(
              appId: 'IOS KEY',
              apiKey: 'AIzaSyBtU9PR2Ypz3r37C3rS1vgmQ7HMwnsSmx4',
              projectId: 'komikedmt',
              messagingSenderId: '63230820971',
              databaseURL: 'https://komikedmt-default-rtdb.firebaseio.com/')
          : FirebaseOptions(
              appId: '1:63230820971:android:4fa7f8d402c5944f62a72e',
              apiKey: 'AIzaSyBtU9PR2Ypz3r37C3rS1vgmQ7HMwnsSmx4',
              projectId: 'komikedmt',
              messagingSenderId: '63230820971',
              databaseURL: 'https://komikedmt-default-rtdb.firebaseio.com/'));
  runApp(ProviderScope(child: MyApp(app: app)));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  FirebaseApp app;
  MyApp({this.app});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      routes: {
        '/chapters': (context) => ChapterScreen(),
        '/read': (context) => ReadScreen()
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Komik', app: app),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);

  final FirebaseApp app;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference _bannerRef, _comicRef;
  List<Comic> listComicFromFirebase = <Comic>[];

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase _database = FirebaseDatabase(app: widget.app);
    _bannerRef = _database.reference().child('Banners');
    _comicRef = _database.reference().child('Comic');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      var searchEnable = watch(isSearch).state;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF4FC3F7),
          title: searchEnable
              ? TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(
                    hintText: 'Comics name or category',
                    hintStyle: TextStyle(color: Colors.white70)
                    ),
                    autofocus: false,
                    style: DefaultTextStyle.of(context).style.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                  suggestionsCallback: (searchString) async{
                    return  await searchComic(searchString);
                  },
                  itemBuilder: (context,comic){
                    return ListTile(leading: Image.network(comic.image),
                    title: Text('${comic.name}'),
                    subtitle: Text('${comic.category == null ? '' : comic.category}'),);
                  },
                  onSuggestionSelected: (comic){
                    context.read(comicSelected).state = comic;
                    Navigator.pushNamed(context, '/chapters');
                  })
              : Text(
                  widget.title,
                  style: TextStyle(color: Colors.white),
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.search_outlined),
              onPressed: () =>
                  context.read(isSearch).state = !context.read(isSearch).state,
            )
          ],
        ),
        body: FutureBuilder<List<String>>(
          future: getBanners(_bannerRef),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CarouselSlider(
                      items: snapshot.data
                          .map((e) => Builder(
                                builder: (context) {
                                  return Image.network(e, fit: BoxFit.cover);
                                },
                              ))
                          .toList(),
                      options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 1,
                          initialPage: 0,
                          height: MediaQuery.of(context).size.height / 3)),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                            color: Color(0xFF4FC3F7),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                'Komik Terbaru',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Color(0xFF4FC3F7),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(''),
                          ),
                        ),
                      )
                    ],
                  ),
                  FutureBuilder(
                      future: getComic(_comicRef),
                      builder: (context, snapshot) {
                        if (snapshot.hasError)
                          return Center(
                            child: Text('${snapshot.error}'),
                          );
                        else if (snapshot.hasData) {
                          listComicFromFirebase = [];
                          snapshot.data.forEach((item) {
                            var comic =
                                Comic.fromJson(json.decode(json.encode(item)));
                            listComicFromFirebase.add(comic);
                          });
                          return Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              padding: const EdgeInsets.all(4.0),
                              mainAxisSpacing: 1.0,
                              crossAxisSpacing: 1.0,
                              children: listComicFromFirebase.map((comic) {
                                return GestureDetector(
                                  onTap: () {
                                    context.read(comicSelected).state = comic;
                                    Navigator.pushNamed(context, '/chapters');
                                  },
                                  child: Card(
                                    elevation: 12,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(comic.image,
                                            fit: BoxFit.cover),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              color: Color(0xAA444343),
                                              padding: const EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${comic.name}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      })
                ],
              );
            } else if (snapshot.hasError)
              return Center(
                child: Text('${snapshot.error}'),
              );
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      );
    });
  }

  Future<List<dynamic>> getComic(DatabaseReference comicRef) {
    return comicRef.once().then((snapshot) => snapshot.value);
  }

  Future<List<String>> getBanners(DatabaseReference bannerRef) {
    return bannerRef
        .once()
        .then((snapshot) => snapshot.value.cast<String>().toList());
  }

  Future<List<Comic>> searchComic(searchString) async {
    return listComicFromFirebase.where((comic) =>
    comic.name.toLowerCase().contains(searchString.toLowerCase())

    ||
        ( comic.category !=null && comic.category.toLowerCase().contains(searchString.toLowerCase()))
    ).toList();
  }
}
