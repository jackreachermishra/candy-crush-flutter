import 'dart:async';

import 'package:prismleaf_vale/pages/home_page.dart';
import 'package:flutter/material.dart';

import 'ads/ads_service.dart';
import 'bloc/bloc_provider.dart';
import 'bloc/game_bloc.dart';
import 'brand/brand_theme.dart';
import 'brand/progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameProgress.instance.load();
  runApp(const MyApp());
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => unawaited(AdsService.instance.initialize()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GameBloc _gameBloc = GameBloc();

  @override
  void dispose() {
    _gameBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameBloc>(
      bloc: _gameBloc,
      child: MaterialApp(
        title: Brand.name,
        debugShowCheckedModeBanner: false,
        theme: Brand.theme,
        home: const HomePage(),
      ),
    );
  }
}
