import 'package:audio_player/my_app.dart';
import 'package:audio_player/services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => PlayerService(),
    child: const MyApp(),
  ));
}
