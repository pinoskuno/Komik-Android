import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komik_edmt/state/state_manager.dart';

class ChapterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (contex, watch, _) {
      var comic = watch(comicSelected).state;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFB3E5FC),
          title: Center(
            child: Text(
              '${comic.name.toUpperCase()}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: comic.chapters != null && comic.chapters.length > 0
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                    itemCount: comic.chapters.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          context.read(chapterSelected).state =
                              comic.chapters[index];
                          Navigator.pushNamed(context, '/read');
                        },
                        child: Column(
                          children: [
                            ListTile(
                              title: Text('${comic.chapters[index].name}'),
                            ),
                            Divider(
                              thickness: 1,
                            )
                          ],
                        ),
                      );
                    }),
              )
            : Center(
                child: Text('Loading'),
              ),
      );
    });
  }
}
