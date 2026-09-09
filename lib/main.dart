import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/tela_inicial.dart';
import 'theme/tema_aplicativo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SafeNeighborApp());
}

class SafeNeighborApp extends StatelessWidget {
  const SafeNeighborApp({
    super.key,
    this.loadMapTiles = true,
  });

  final bool loadMapTiles;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeNeighbor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: TelaInicial(carregarMapa: loadMapTiles),
    );
  }
}
