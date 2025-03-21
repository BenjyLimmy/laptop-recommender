import 'package:flutter/material.dart';
import 'package:laptop_reco/pages/aspect_selection_page.dart';
import 'package:laptop_reco/models/preferences_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PreferencesModel>(
      create: (_) => PreferencesModel(),
      child: MaterialApp(
        title: 'Laptop Recommender',
        theme: ThemeData.dark(),
        home: AspectSelectionPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
