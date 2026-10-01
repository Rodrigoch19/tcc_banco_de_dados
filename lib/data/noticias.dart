// Dados simples usados no painel de noticias.
class SecurityNews {
  const SecurityNews({
    required this.tag,
    required this.title,
    required this.summary,
    required this.time,
  });

  final String tag;
  final String title;
  final String summary;
  final String time;
}

const securityNews = <SecurityNews>[
  SecurityNews(
    tag: 'Prevencao',
    title: 'Nova ronda comunitaria comeca na Vila Mariana',
    summary:
        'Moradores e guarda civil organizaram rondas noturnas as tercas e sextas, com ponto de encontro na praca central.',
    time: 'Ha 2 h',
  ),
  SecurityNews(
    tag: 'Infraestrutura',
    title: 'Prefeitura troca 320 lampadas por LED no bairro',
    summary:
        'Ruas com relatos frequentes de iluminacao precaria entram na primeira fase do mutirao de manutencao.',
    time: 'Ha 6 h',
  ),
  SecurityNews(
    tag: 'Alerta regional',
    title: 'Aumento de furtos de celular em pontos de onibus',
    summary:
        'Boletins da regiao apontam concentracao de casos entre 18h e 21h. Evite usar o aparelho na calcada.',
    time: 'Ontem',
  ),
  SecurityNews(
    tag: 'Comunidade',
    title: 'Grupo de vizinhos mapeia rotas seguras para escolas',
    summary:
        'Iniciativa cruza alertas do SafeNeighbor com horarios de entrada e saida para sugerir trajetos.',
    time: '2 dias',
  ),
];
