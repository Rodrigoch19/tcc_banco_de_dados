# SafeNeighbor (Flutter / Dart)

Aplicativo de segurança comunitária feito com Flutter. O projeto mostra um
mapa, alertas, grupos, conversas e um perfil comunitário.

## Como executar

```bash
flutter pub get
flutter run
```

## Por onde começar a estudar

Se você ainda está começando no Flutter, leia os arquivos nesta ordem:

1. `lib/main.dart`: inicia o aplicativo com `runApp`.
2. `lib/screens/tela_inicial.dart`: mostra como usar `StatefulWidget`, variáveis
   e `setState`.
3. `lib/screens/tela_conversas.dart`: exemplo menor de `StatelessWidget`.
4. `lib/models/alerta.dart`: classes simples que guardam dados.
5. `lib/data/alertas_exemplo.dart`: lista com dados usados na demonstração.
6. `lib/widgets/cartao_alerta.dart`: exemplo de um componente reutilizável.

Os arquivos de localização e geocodificação são mais técnicos porque precisam
conversar com o celular, o navegador e a internet. Eles podem ficar para depois.

## Organização dos arquivos

Todos os arquivos criados para o projeto possuem nomes em português, sem
acentos e no formato `snake_case`. A única exceção é `main.dart`, pois esse é o
nome padrão do arquivo que inicia um projeto Flutter.

```text
lib/
  main.dart
  data/
    alertas_exemplo.dart
    grupos_exemplo.dart
    noticias.dart
  models/
    alerta.dart
    grupo_comunitario.dart
    perfil_comunitario.dart
  screens/
    tela_inicial.dart
    tela_mapa.dart
    tela_conversas.dart
    tela_grupos.dart
    tela_conversa_grupo.dart
    tela_perfil.dart
  services/
    servico_banco_dados.dart
    servico_grupos.dart
    servico_localizacao.dart
    servico_perfil.dart
    transporte_geocodificacao_reversa.dart
    transporte_geocodificacao_reversa_io.dart
    transporte_geocodificacao_reversa_web.dart
  theme/
    tema_aplicativo.dart
  widgets/
    barra_superior.dart
    caixa_transparente.dart
    cartao_alerta.dart
    logo_aplicativo.dart
    mapa_alertas.dart
    menu_lateral.dart
    pagina_menu.dart
    painel_alertas.dart
    painel_criar_grupo.dart
    painel_editar_perfil.dart
    painel_informacoes.dart
    painel_legenda.dart
    painel_noticias.dart
    painel_novo_alerta.dart
```

Os testes também têm nomes em português. O final `_test.dart` foi mantido
porque o Flutter usa esse padrão para encontrar os testes automaticamente.

## Conceitos usados

O código das telas prioriza os conceitos iniciais do Flutter:

- `StatelessWidget` e `StatefulWidget`;
- `build` para montar a tela;
- `setState` para atualizar informações;
- `if`, `for` e listas simples;
- `Row`, `Column`, `Container`, `Text`, `TextField` e `ListView`;
- funções pequenas para separar cada tarefa.

O aplicativo abre todas as telas diretamente, sem cadastro, senha ou tela de
login. O perfil local é sincronizado com o Cloud Firestore usando uma sessão
anônima interna do Firebase.

## Configuração do Firebase

O projeto está associado ao Firebase `teste-tcc-446d5`. Para preparar um novo
ambiente ou atualizar as credenciais, execute:

```bash
flutterfire configure
firebase deploy --only firestore:rules
```

No Console do Firebase, crie o banco `(default)` no modo Cloud Firestore. Em
**Authentication > Sign-in method**, ative somente o provedor **Anônimo**. Ele
identifica a instalação para as regras do banco, mas não mostra login para a
pessoa usuária.

Depois publique as regras seguras deste repositório:

```bash
firebase deploy --only firestore:rules
```

As regras permitem que cada sessão leia e altere somente o próprio documento
em `profiles/{uid}` e também validam os campos recebidos.
