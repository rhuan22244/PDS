import 'package:flutter/material.dart';

class VacinasPage extends StatefulWidget {
  const VacinasPage({super.key});

  @override
  State<VacinasPage> createState() => _VacinasPageState();
}

class _VacinasPageState extends State<VacinasPage> {
  final TextEditingController _searchController = TextEditingController();
  String idadeSelecionada = 'Todas';

  final List<String> idades = [
    'Todas',
    'Bebê (0-2)',
    'Criança (3-9)',
    'Adolescente (10-17)',
    'Adulto (18-59)',
    'Idoso (60+)',
  ];

  final List<Map<String, dynamic>> todasVacinas = [
    {
      'nome': 'BCG',
      'local': 'Posto Central Porto Alegre',
      'faixaEtaria': 'Bebê (0-2)',
      'data': 'Até 5 anos',
      'cidade': 'Porto Alegre',
      'detalhes': 'A vacina BCG protege contra formas graves de tuberculose.'
    },
    {
      'nome': 'Hepatite B',
      'local': 'Posto Central Canoas',
      'faixaEtaria': 'Bebê (0-2)',
      'data': 'Ao nascer',
      'cidade': 'Canoas',
      'detalhes':
      'A vacina contra Hepatite B protege contra infecções do vírus da hepatite B.'
    },
    {
      'nome': 'Pentavalente',
      'local': 'UBS Centro Caxias',
      'faixaEtaria': 'Bebê (0-2)',
      'data': '2, 4 e 6 meses',
      'cidade': 'Caxias do Sul',
      'detalhes':
      'A vacina pentavalente protege contra difteria, tétano, coqueluche, hepatite B e Haemophilus influenzae tipo b.'
    },
    {
      'nome': 'Tríplice Viral',
      'local': 'Posto Central',
      'faixaEtaria': 'Criança (3-9)',
      'data': '12 meses e 15 meses',
      'cidade': 'Porto Alegre',
      'detalhes':
      'Protege contra sarampo, caxumba e rubéola.'
    },
    {
      'nome': 'HPV',
      'local': 'UBS Santana',
      'faixaEtaria': 'Adolescente (10-17)',
      'data': '9 a 14 anos',
      'cidade': 'Canoas',
      'detalhes':
      'Vacina para prevenção do papilomavírus humano, que pode causar câncer cervical.'
    },
    {
      'nome': 'COVID-19',
      'local': 'UBS Zona Sul',
      'faixaEtaria': 'Idoso (60+)',
      'data': 'Reforço anual (60+)',
      'cidade': 'Porto Alegre',
      'detalhes':
      'Vacina para prevenção da COVID-19, especialmente recomendada para idosos.'
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool filtraPorIdade(Map<String, dynamic> vacina) {
    if (idadeSelecionada == 'Todas') return true;
    return vacina['faixaEtaria'] == idadeSelecionada;
  }

  bool filtraPorNome(Map<String, dynamic> vacina) {
    return _searchController.text.isEmpty ||
        vacina['nome']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
  }

  List<Map<String, dynamic>> getVacinasFiltradas() {
    return todasVacinas
        .where((vacina) => filtraPorNome(vacina) && filtraPorIdade(vacina))
        .toList();
  }

  void mostrarDetalhesVacina(Map<String, dynamic> vacina) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return VacinaDetalhesSheet(vacina: vacina);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vacinasFiltradas = getVacinasFiltradas();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Vacinas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF2EAEA),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome da vacina',
                prefixIcon: const Icon(Icons.vaccines),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchController.clear()),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: idadeSelecionada,
              onChanged: (value) => setState(() => idadeSelecionada = value!),
              decoration: InputDecoration(
                labelText: 'Filtrar por faixa etária',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: idades
                  .map((faixa) => DropdownMenuItem(
                value: faixa,
                child: Text(faixa),
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Vacinas disponíveis:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: vacinasFiltradas.isEmpty
                  ? const Center(
                child: Text(
                  'Nenhuma vacina encontrada.',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: vacinasFiltradas.length,
                itemBuilder: (context, index) {
                  final vacina = vacinasFiltradas[index];
                  return InkWell(
                    onTap: () => mostrarDetalhesVacina(vacina),
                    child: VacinaCard(
                      nome: vacina['nome'],
                      local: vacina['local'],
                      data: vacina['data'],
                      disponivel: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VacinaCard extends StatelessWidget {
  final String nome;
  final String local;
  final String data;
  final bool disponivel;

  const VacinaCard({
    super.key,
    required this.nome,
    required this.local,
    required this.data,
    required this.disponivel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: disponivel ? Colors.green : Colors.redAccent,
          child: const Icon(Icons.vaccines, color: Colors.white),
        ),
        title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Local: $local"),
            Text("Indicação: $data"),
            Row(
              children: [
                Icon(
                  disponivel ? Icons.check_circle : Icons.cancel,
                  color: disponivel ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(disponivel ? 'Disponível' : 'Indisponível'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VacinaDetalhesSheet extends StatelessWidget {
  final Map<String, dynamic> vacina;

  const VacinaDetalhesSheet({super.key, required this.vacina});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vacina['nome'],
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
          ),
          const SizedBox(height: 12),
          Text(
            'Local: ${vacina['local']}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Indicação: ${vacina['data']}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 6),
          if (vacina['detalhes'] != null)
            Text(
              vacina['detalhes'],
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text('Fechar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}








