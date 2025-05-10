import 'package:flutter/material.dart';
import 'package:labtrack_mobile/screens/reagent_form_screen.dart';
import 'qr_scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.science, color: Color(0xFF00B4B3)),
            const SizedBox(width: 10),
            Text(
              'LabTrack',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          // No AppBar ou em um FloatingActionButton secundário
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReagentFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchCard(),
            const SizedBox(height: 24),
            _buildSectionTitle("Reagentes em Destaque"),
            _buildReagentCard(
              "Ácido Clorídrico",
              "HCl • Solução 1M",
              "Validade: 15/03/2025",
              0.7,
            ),
            const SizedBox(height: 16),
            _buildReagentCard(
              "Hidróxido de Sódio",
              "NaOH • P.A.",
              "Validade: 22/04/2025",
              0.4,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Estoque Rápido"),
            _buildReagentGrid(),
            const SizedBox(height: 24),
            _buildSectionTitle("Próximas Validades"),
            _buildExpiryList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrScanScreen()),
          );
        },
        backgroundColor: const Color(0xFF0061A8),
        child: const Icon(Icons.qr_code_scanner, size: 28),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2E3A47),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Buscar reagente...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReagentCard(
    String name,
    String type,
    String expiry,
    double stock,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B4B3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.science,
                      color: Color(0xFF00B4B3),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    type,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                expiry,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: stock,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF0061A8),
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${(stock * 100).toInt()}% do estoque",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      "Detalhes",
                      style: TextStyle(color: Color(0xFF0061A8), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReagentGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final reagents = [
          {"name": "Etanol", "type": "P.A. 99.8%", "icon": Icons.liquor},
          {"name": "Água", "type": "Destilada", "icon": Icons.water_drop},
          {"name": "Acetona", "type": "Grau HPLC", "icon": Icons.clean_hands},
          {"name": "Cloreto", "type": "NaCl P.A.", "icon": Icons.cookie},
        ];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0061A8).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      reagents[index]["icon"] as IconData,
                      color: const Color(0xFF0061A8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    reagents[index]["name"] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reagents[index]["type"] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpiryList() {
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          Card(
            elevation: 0,
            margin: EdgeInsets.only(bottom: i == 2 ? 0 : 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6D00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFFF6D00),
                  size: 20,
                ),
              ),
              title: const Text(
                "Ácido Sulfúrico",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text("Vence em 30 dias"),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
      ],
    );
  }
}
