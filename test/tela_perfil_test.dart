// Testes da tela de perfil.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeneighbor/models/perfil_comunitario.dart';
import 'package:safeneighbor/screens/tela_perfil.dart';
import 'package:safeneighbor/services/servico_perfil.dart';
import 'package:safeneighbor/theme/tema_aplicativo.dart';

void main() {
  final profiles = ProfileService();
  var account = 0;

  setUp(() {
    account++;
    profiles.resetForTests(
      displayName: 'Pessoa Vizinha',
      email: 'tela-perfil$account@teste.com',
    );
  });

  Widget app() => MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: ProfileScreen()),
      );

  testWidgets('mostra perfil padrao e permite editar nome e sobre',
      (tester) async {
    await tester.pumpWidget(app());

    expect(find.text('Pessoa Vizinha'), findsOneWidget);
    expect(find.text(defaultCommunityAbout), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('edit-profile-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('profile-name-field')),
      'Luan da Vila',
    );
    await tester.enterText(
      find.byKey(const ValueKey('profile-about-field')),
      'Gosto de compartilhar informacoes e apoiar meus vizinhos.',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('save-profile-button')),
    );
    await tester.tap(find.byKey(const ValueKey('save-profile-button')));
    await tester.pumpAndSettle();

    expect(find.text('Luan da Vila'), findsOneWidget);
    expect(
      find.text('Gosto de compartilhar informacoes e apoiar meus vizinhos.'),
      findsOneWidget,
    );
  });

  testWidgets('mostra selos desbloqueados conforme contribuicao',
      (tester) async {
    await profiles.addCurrentContribution(ContributionType.alertPublished);
    await tester.pumpWidget(app());

    await tester.scrollUntilVisible(
      find.text('Olhar atento'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Olhar atento'), findsOneWidget);
  });
}
