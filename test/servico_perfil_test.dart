// Testes do servico que guarda o perfil.
import 'package:flutter_test/flutter_test.dart';
import 'package:safeneighbor/models/perfil_comunitario.dart';
import 'package:safeneighbor/services/servico_perfil.dart';

void main() {
  final profiles = ProfileService();
  var accountSequence = 0;

  setUp(() {
    accountSequence++;
    profiles.resetForTests(
      displayName: 'Pessoa Vizinha',
      email: 'perfil$accountSequence@teste.com',
    );
  });

  test('cria perfil local padrão', () {
    final profile = profiles.currentProfile;

    expect(profile.displayName, 'Pessoa Vizinha');
    expect(profile.about, defaultCommunityAbout);
    expect(profile.points, 0);
    expect(profile.selectedTitle.label, 'Novo Vizinho');
    expect(
        profile.unlockedTitles.map((title) => title.label), ['Novo Vizinho']);
    expect(profile.earnedBadges.map((badge) => badge.label), ['Boas-vindas']);
    expect(profile.nextTitle?.label, 'Vizinho Atento');
  });

  test('edita nome e descrição preservando os demais dados', () async {
    await profiles.updateCurrentProfile(
      name: '  Luan da Vila  ',
      about: '  Sempre pronto para colaborar.  ',
    );

    expect(profiles.currentProfile.displayName, 'Luan da Vila');
    expect(
      profiles.currentProfile.about,
      'Sempre pronto para colaborar.',
    );
    expect(profiles.currentProfile.points, 0);
  });

  test('soma pontos e atualiza o contador de cada contribuição', () async {
    for (final type in ContributionType.values) {
      await profiles.addCurrentContribution(type);
    }

    final profile = profiles.currentProfile;
    expect(profile.points, 57);
    expect(profile.alertsPublished, 1);
    expect(profile.groupsJoined, 1);
    expect(profile.groupsCreated, 1);
    expect(profile.messagesSent, 1);
    expect(
      ContributionType.values.map(profile.contributionCount),
      everyElement(1),
    );
  });

  test('desbloqueia títulos e selos de acordo com os pontos', () async {
    await profiles.addCurrentContribution(ContributionType.groupCreated);
    await profiles.addCurrentContribution(ContributionType.groupCreated);

    final profile = profiles.currentProfile;
    expect(profile.points, 50);
    expect(
      profile.unlockedTitles.map((title) => title.label),
      ['Novo Vizinho', 'Vizinho Atento', 'Protetor Local'],
    );
    expect(
      profile.earnedBadges.map((badge) => badge.label),
      [
        'Boas-vindas',
        'Primeira contribuição',
        'Olhar atento',
        'Voz da comunidade'
      ],
    );
    expect(profile.nextTitle?.label, 'Guardião da Comunidade');

    await profiles.selectCurrentTitle('protetor-local');
    expect(profiles.currentProfile.selectedTitle.label, 'Protetor Local');
  });

  test('impede selecionar título ainda bloqueado', () async {
    await expectLater(
      profiles.selectCurrentTitle('guardiao-da-comunidade'),
      throwsStateError,
    );
    expect(profiles.currentProfile.selectedTitle.label, 'Novo Vizinho');
  });
}
