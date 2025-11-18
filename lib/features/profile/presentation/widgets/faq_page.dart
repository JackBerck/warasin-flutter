import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        "q": "Apa itu WarasIn?",
        "a":
            "WarasIn adalah aplikasi pengingat minum obat dan pencatat kesehatan harian untuk membantu Anda dan keluarga.",
      },
      {
        "q": "Apakah data saya aman?",
        "a":
            "Data Anda disimpan dengan aman, tidak dibagikan ke pihak ketiga, dan Anda dapat menghapusnya kapan saja.",
      },
      {
        "q": "Bagaimana jika saya lupa password?",
        "a":
            "Gunakan fitur lupa password di halaman login dan ikuti instruksi yang dikirim via email.",
      },
      {
        "q": "Apa beda mode offline dan online?",
        "a":
            "Mode online menyimpan data cloud, sedangkan mode offline hanya di perangkat. Anda bebas memilih.",
      },
      {
        "q": "Siapa pengembang aplikasi ini?",
        "a":
            "WarasIn dikembangkan mahasiswa Universitas XYZ untuk membantu kesehatan masyarakat.",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...faqs.map(
            (faq) => ExpansionTile(
              title: Text(
                faq["q"]!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    faq["a"]!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
