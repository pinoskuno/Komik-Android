import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komik_edmt/model/Chapters.dart';
import 'package:komik_edmt/model/comic.dart';

final comicSelected = StateProvider((ref) => Comic());
final chapterSelected = StateProvider((ref) => Chapters());
final isSearch = StateProvider((ref) => false);

