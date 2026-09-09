// Testes principais das telas e do menu do aplicativo.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:safeneighbor/main.dart';
import 'package:safeneighbor/services/servico_perfil.dart';

void main() {
  setUp(() => ProfileService().resetForTests());

  testWidgets('mostra a tela inicial com os alertas', (tester) async {
    await tester.pumpWidget(const SafeNeighborApp(loadMapTiles: false));

    expect(find.text('Sua regiao esta em nivel critico'), findsOneWidget);
    expect(find.text('5 alertas nas ultimas 24 horas'), findsOneWidget);
    expect(find.text('Novo Alerta'), findsNothing);
    expect(find.byIcon(Icons.add_location_alt_outlined), findsOneWidget);
    expect(find.byKey(const ValueKey('side-menu')), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Grupos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.byKey(const ValueKey('app-logo')), findsNWidgets(2));
  });

  testWidgets('abre o chat lateral sem exigir login', (tester) async {
    await tester.pumpWidget(const SafeNeighborApp(loadMapTiles: false));

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('chat-screen')), findsOneWidget);
    expect(find.text('Chat da vizinhanca'), findsOneWidget);
  });

  testWidgets('alterna entre mapa chat e grupos pelo menu', (tester) async {
    await tester.pumpWidget(const SafeNeighborApp(loadMapTiles: false));

    expect(find.byKey(const ValueKey('map-screen')), findsOneWidget);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chat-screen')), findsOneWidget);
    expect(find.text('Chat da vizinhanca'), findsOneWidget);

    await tester.tap(find.text('Grupos'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('groups-screen')), findsOneWidget);
    expect(find.text('Grupos por perto'), findsOneWidget);

    await tester.tap(find.text('Mapa'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('map-screen')), findsOneWidget);
  });

  testWidgets('mantem o menu compacto em tela estreita', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const SafeNeighborApp(loadMapTiles: false));

    expect(
      tester.getSize(find.byKey(const ValueKey('side-menu'))).width,
      76,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('abre a pagina de perfil sem exigir login', (tester) async {
    ProfileService().resetForTests(
      displayName: 'Pessoa do Perfil',
      email: 'perfil-menu@teste.com',
    );
    await tester.pumpWidget(const SafeNeighborApp(loadMapTiles: false));

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-screen')), findsOneWidget);
    expect(find.text('Pessoa do Perfil'), findsOneWidget);
    expect(find.text('Novo Vizinho'), findsWidgets);
  });
}
