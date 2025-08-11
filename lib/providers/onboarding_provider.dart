import 'dart:io';
import 'package:flutter/material.dart';
import 'package:personal_branding_app/models/content_factory_item.dart';
import 'package:personal_branding_app/services/gemini_service.dart';
import 'package:uuid/uuid.dart';

class OnboardingProvider extends ChangeNotifier {
  // Data dari user
  String fullName = '';
  File? profileImage;
  String whatILove = '';
  String whatImGoodAt = '';
  String whatTheWorldNeeds = '';
  String whatICanBePaidFor = '';

  // State untuk AI
  bool isLoading = false;
  String? aiResponse;
  String? errorMessage;

  // Hasil parsing dari AI
  List<String> profileNameOptions = [];
  List<String> categoryOptions = [];
  List<String> microNicheOptions = [];

  // Pilihan user
  String? selectedProfileName;
  String? selectedCategory;
  String? selectedMicroNiche;

  String strengths = '';
  String weaknesses = '';
  String opportunities = '';
  String threats = '';
  String? premiseAiResponse;
  List<String> premiseOptions = [];
  String? selectedPremise;

  // Data untuk Content Pillar & Content Factory ---
  String? toneOfVoice;
  String targetAudience = '';
  String? pillarAiResponse;
  List<String> contentPillarOptions = [];
  List<ContentFactoryItem> contentFactories = [
    ContentFactoryItem(id: const Uuid().v4())
  ];

  final GeminiService _geminiService = GeminiService();

  void updateFullName(String name) {
    fullName = name;
    notifyListeners();
  }

  void setProfileImage(File image) {
    profileImage = image;
    notifyListeners();
  }

  // Fungsi utama untuk memanggil AI
  Future<void> generateIdentity() async {
    isLoading = true;
    errorMessage = null;
    aiResponse = null;
    notifyListeners();

    final paidForText = whatICanBePaidFor.isNotEmpty
        ? whatICanBePaidFor
        : "Aku masih belum tau, tolong dibantu menemukan jawaban untuk peluang monetisasinya";

    // --- PROMPT YANG DIPERBARUI DENGAN CONTOH FORMAT ---
    final prompt = """
Analisis data Ikigai berikut:
- Nama: $fullName
- What I Love: $whatILove
- What I’m Good At: $whatImGoodAt
- What The World Needs: $whatTheWorldNeeds
- What I Can Be Paid For: $paidForText

Tugas Anda adalah memberikan analisis, 5 rekomendasi niche, peluang monetisasi, dan 5 rekomendasi nama profil.
Berikan jawaban HANYA dalam format yang sama persis seperti contoh di bawah ini. Jangan mengubah struktur atau judulnya.

Dari analisis Ikigai-mu, benang merah yang muncul adalah "[Analisis benang merah Anda di sini]." Ini bisa menjadi fondasi kuat untuk personal
branding yang otentik dan berkelanjutan.

Rekomendasi Niche Spesifik & Penjelasan
Berikut adalah lima pilihan niche yang bisa kamu ambil, lengkap dengan kategorinya dan micro-niche:
1. Kategori: [Nama Kategori 1]
Niche: [Nama Niche 1]
Micro-niche: [Nama Micro-niche 1]
Kenapa cocok? [Penjelasan singkat kenapa cocok 1]

2. Kategori: [Nama Kategori 2]
Niche: [Nama Niche 2]
Micro-niche: [Nama Micro-niche 2]
Kenapa cocok? [Penjelasan singkat kenapa cocok 2]

3. Kategori: [Nama Kategori 3]
Niche: [Nama Niche 3]
Micro-niche: [Nama Micro-niche 3]
Kenapa cocok? [Penjelasan singkat kenapa cocok 3]

4. Kategori: [Nama Kategori 4]
Niche: [Nama Niche 4]
Micro-niche: [Nama Micro-niche 4]
Kenapa cocok? [Penjelasan singkat kenapa cocok 4]

5. Kategori: [Nama Kategori 5]
Niche: [Nama Niche 5]
Micro-niche: [Nama Micro-niche 5]
Kenapa cocok? [Penjelasan singkat kenapa cocok 5]

Peluang Monetisasi
Dari niche di atas, kamu bisa menghasilkan uang melalui:
[Opsi Monetisasi 1]
[Opsi Monetisasi 2]
[Opsi Monetisasi 3]

Rekomendasi Nama Profil Sosial Media
1. $fullName | [Nama Niche 1 (2 kata)]
2. $fullName | [Nama Niche 2 (2 kata)]
3. $fullName | [Nama Niche (2 kata)]
4. $fullName | [Nama Niche (2 kata)]
5. $fullName | [Nama Niche (2 kata)]

Apakah sudah puas dengan hasil ini, atau ada aspek lain yang ingin lebih diperdalam?
""";

    try {
      final result = await _geminiService.generateContent(prompt);
      if (result != null && result.isNotEmpty) {
        aiResponse = result;
        _parseAiResponse(result);
      } else {
        errorMessage = "Gagal mendapatkan respons dari AI. Coba lagi.";
      }
    } catch (e) {
      errorMessage = "Terjadi kesalahan: ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }

  void _parseAiResponse(String text) {
    // Reset lists dan gunakan Set untuk menghindari duplikat
    final uniqueNames = <String>{};
    final uniqueCategories = <String>{};
    final uniqueNiches = <String>{};
    String monetizationText = '';

    // --- Parsing Nama Profil ---
    // Cari blok "Rekomendasi Nama Profil Sosial Media", lalu ambil semua baris bernomor di bawahnya.
    final nameBlockRegex = RegExp(
        r"Rekomendasi Nama Profil Sosial Media\s*([\s\S]*)",
        caseSensitive: false);
    final nameBlockMatch = nameBlockRegex.firstMatch(text);
    if (nameBlockMatch != null) {
      final nameContent = nameBlockMatch.group(1)!;
      final nameLineRegex = RegExp(r"^\d+\.\s*(.*)", multiLine: true);
      final nameMatches = nameLineRegex.allMatches(nameContent);
      for (final match in nameMatches) {
        uniqueNames.add(match.group(1)!.trim());
      }
    }

    // --- Parsing Kategori & Micro-Niche ---
    final categoryRegex = RegExp(r"^\s*(?:\d+\.\s*)?Kategori:\s*(.*)",
        multiLine: true, caseSensitive: false);
    final nicheRegex = RegExp(r"^\s*Micro-niche:\s*(.*)",
        multiLine: true, caseSensitive: false);

    final categoryMatches = categoryRegex.allMatches(text);
    for (final match in categoryMatches) {
      uniqueCategories.add(match.group(1)!.trim());
    }

    final nicheMatches = nicheRegex.allMatches(text);
    for (final match in nicheMatches) {
      uniqueNiches.add(match.group(1)!.trim());
    }

    // --- Parsing Peluang Monetisasi ---
    final monetizationBlockRegex = RegExp(
        r"Peluang Monetisasi\s*([\s\S]*?)(?=\n\n|Rekomendasi Nama Profil)",
        caseSensitive: false);
    final monetizationBlockMatch = monetizationBlockRegex.firstMatch(text);
    if (monetizationBlockMatch != null) {
      // Ambil semua baris di bawah judul dan gabungkan dengan koma
      monetizationText = monetizationBlockMatch
          .group(1)!
          .split('\n')
          .where((line) =>
              line.trim().isNotEmpty &&
              !line.toLowerCase().contains("dari niche di atas"))
          .map((line) => line.trim())
          .join(', ');
    }
    opportunities = monetizationText;

    // Konversi dari Set ke List
    profileNameOptions = uniqueNames.toList();
    categoryOptions = uniqueCategories.toList();
    microNicheOptions = uniqueNiches.toList();
  }

  // --- Fungsi untuk Generate Premis ---
  Future<void> generatePremise() async {
    isLoading = true;
    errorMessage = null;
    premiseAiResponse = null;
    notifyListeners();

    // Menggabungkan kekuatan awal dengan tambahan dari user
    final finalStrengths = "$whatImGoodAt, $strengths";

    final prompt = """
Nama akun dan niche aku "$selectedProfileName"
Aku ingin membuat premis personal branding yang kuat untuk kategori niche "$selectedCategory", dan spesifik membahas tentang "$selectedMicroNiche".

Aku akan memberikan analisis sederhana menggunakan metode SWOT dengan istilah yang mudah dipahami:
KEKUATAN SAYA: $finalStrengths
KELEMAHAN SAYA: $weaknesses
PELUANG YANG ADA: $opportunities
ANCAMAN YANG ADA: $threats

Dari analisis ini, buatkan premis personal branding dalam format seperti berikut:
'Dari "$weaknesses", akhirnya "$finalStrengths", dan kini "$opportunities".'

ATAU

'Dari "$threats" menjadi "$finalStrengths", saya percaya bahwa "$opportunities", dan saya ingin "$opportunities".'

Pastikan premis ini menarik, mudah dipahami, dan menggugah emosi audiens agar mereka bisa merasa terhubung dengan perjalanan saya.
Berikan 10 pilihan premis agar saya memiliki lebih banyak ide dan lebih mengenal diri saya.
JAWAB HANYA DALAM FORMAT SEPERTI CONTOH DI BAWAH. JANGAN UBAH STRUKTURNYA.

--- CONTOH FORMAT JAWABAN ---
Berikut adalah 10 pilihan premis personal branding yang bisa kamu gunakan:

1. Perjalanan dari Pemalu ke Panggung
"Dulu aku adalah seorang introvert yang takut berbicara di depan umum. Namun, aku memutuskan untuk belajar public speaking, hingga akhirnya bisa tampil percaya diri. Kini, aku membimbing orang lain melalui Pelatihan dan Workshop."

2. Mengubah Ketakutan Jadi Keahlian
"Dulu, berbicara di depan orang banyak membuatku gugup. Tapi aku sadar, komunikasi adalah kunci. Sekarang, aku membantu orang lain menguasai public speaking melalui Workshop dan Coaching."

...dan seterusnya hingga 10.
--- AKHIR CONTOH FORMAT ---
""";

    try {
      final result = await _geminiService.generateContent(prompt);
      if (result != null && result.isNotEmpty) {
        premiseAiResponse = result;
        _parsePremiseResponse(result);
      } else {
        errorMessage = "Gagal mendapatkan respons dari AI. Coba lagi.";
      }
    } catch (e) {
      errorMessage = "Terjadi kesalahan: ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }

  void _parsePremiseResponse(String text) {
    // Reset list
    premiseOptions = [];

    // Regex untuk menemukan awal dari daftar premis.
    final listStartRegex = RegExp(r'(\d+\.\s+.*)', dotAll: true);
    final listMatch = listStartRegex.firstMatch(text);

    if (listMatch != null) {
      final listContent = listMatch.group(0)!;

      // Regex untuk memisahkan setiap blok premis.
      final premiseBlocks = listContent.split(RegExp(r'\n\s*(?=\d+\.\s+)'));

      // Regex untuk mengekstrak konten di dalam tanda kutip ganda ""
      final quoteRegex = RegExp(r'"(.*?)"', dotAll: true);

      // Membersihkan, mengekstrak, dan menambahkan setiap premis ke dalam daftar pilihan
      premiseOptions = premiseBlocks
          .map((block) {
            final quoteMatch = quoteRegex.firstMatch(block);
            // Jika ditemukan teks di dalam kutip, kembalikan teks tersebut.
            // Jika tidak, cari teks setelah baris judul.
            if (quoteMatch != null) {
              return quoteMatch.group(1)?.trim();
            } else {
              // Fallback: ambil teks setelah baris pertama (judul)
              final lines = block.split('\n');
              if (lines.length > 1) {
                return lines.sublist(1).join('\n').trim();
              }
            }
            return null; // Jika tidak ada yang cocok
          })
          .where((premise) =>
              premise != null &&
              premise.isNotEmpty) // Filter hasil yang null atau kosong
          .cast<String>() // Cast kembali ke List<String>
          .toList();
    }
  }

  // --- FUNGSI YANG DIPERBARUI ---
  Future<void> generateContentPillars() async {
    isLoading = true;
    errorMessage = null;
    pillarAiResponse = null;
    notifyListeners();

    final prompt = """
Buatkan daftar Content Pillar yang lengkap, relevan, dan strategis di sosial media untuk nama akun "$selectedProfileName", yang mana niche tersebut masuk ke dalam kategori "$selectedCategory", dan berfokus utama pada "$selectedMicroNiche" menggunakan tone of voice berikut: "$toneOfVoice", yang memiliki target audiens "$targetAudience" dengan menggunakan premisku ini sebagai referensi: "$selectedPremise"

Aku ingin daftar content pillar ini mencakup:
> Topik utama yang relevan dengan niche dan bisa dikembangkan dalam jangka panjang
> Sub-topik turunan yang masih berhubungan dengan topik utama
> Mencakup 5 pillar konten utama yang meliputi: Educational (Edukasi), Entertain (Hiburan), Social Proof (Bukti Sosial), Personal Story (Cerita Pribadi), dan Promotional (Promosi) yang telah disesuaikan dengan personal branding yang telah telah dibangun dengan memberikan sentuhan terkait niche pada penyebutan pillar utama
> Tambahkan beberapa Pillar lagi sebagai tambahan referensi untuk lebih banyak pilihan

Tambahkan juga insight tentang:
- Kenapa content pillar ini penting untuk membangun otoritas di niche tersebut
- Bagaimana content pillar ini bisa membantu audiens dan menyelesaikan masalah mereka
- Format yang cocok untuk menyampaikan konten dari masing-masing pilar (misalnya: video pendek / panjang, carousel, thread, dll.)

Pastikan outputnya:
✔ Tidak terbatas pada jumlah tertentu, buat sebanyak mungkin agar bisa dipilih sesuai kebutuhan
✔ Mudah dikembangkan menjadi strategi konten jangka panjang
✔ Relevan dengan tren industri "$selectedCategory" dan sesuai dengan target audiens "$targetAudience"
✔ Membantu saya membangun personal branding yang kuat di bidang ini

Jika ada insight tambahan atau rekomendasi pengembangan, tambahkan untuk memperkaya strategi saya.

Berikan jawaban HANYA dalam format seperti contoh di bawah ini. Jangan ubah strukturnya. Jangan gunakan bold text.

DAFTAR CONTENT PILLAR: $selectedProfileName

1. Educational (Edukasi: Public Speaking & Communication Mastery)
Kenapa penting?
- Membangun otoritas sebagai mentor public speaking
- Memberikan value nyata bagi audiens yang ingin belajar
Sub-topik:
- Teknik Dasar Public Speaking untuk Pemula
- Cara Mengatasi Grogi dan Rasa Takut Berbicara di Depan Umum
Format Konten:
- Video pendek (Reels, TikTok, Shorts)
- Carousel Instagram

2. Entertain (Hiburan: Relatable Content & Engaging Challenges)
Kenapa penting?
- Meningkatkan engagement dan membangun hubungan dengan audiens
Sub-topik:
- Meme Seputar Public Speaking & Communication
- Parodi Kesalahan Public Speaking yang Sering Dilakukan
Format Konten:
- Meme & GIF
- Duet Video (TikTok)
""";

    try {
      final result = await _geminiService.generateContent(prompt);
      if (result != null && result.isNotEmpty) {
        pillarAiResponse = result;
        _parsePillarResponse(result);
      } else {
        errorMessage = "Gagal mendapatkan respons dari AI. Coba lagi.";
      }
    } catch (e) {
      errorMessage = "Terjadi kesalahan: ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }

  void _parsePillarResponse(String text) {
    // Regex untuk menemukan judul pillar seperti "1. Educational (Edukasi: ...)"
    // Ini akan menangkap semua teks di baris yang diawali dengan nomor.
    final pillarTitleRegex = RegExp(r"^\s*\d+\.\s*(.*?)(?=\n|$)", multiLine: true);
    final matches = pillarTitleRegex.allMatches(text);
    contentPillarOptions = matches.map((m) => m.group(1)!.trim()).toList();
  }
  
  // --- BARU: Fungsi untuk Content Factory ---
  void addContentFactory() {
    contentFactories.add(ContentFactoryItem(id: const Uuid().v4()));
    notifyListeners();
  }

  void updateFactoryPillar(String id, String pillar) {
    final index = contentFactories.indexWhere((f) => f.id == id);
    if (index != -1) {
      contentFactories[index].selectedPillar = pillar;
      notifyListeners();
    }
  }

  void updateFactoryIdeaCount(String id, int count) {
    final index = contentFactories.indexWhere((f) => f.id == id);
    if (index != -1) {
      contentFactories[index].ideaCount = count;
      notifyListeners();
    }
  }

  Future<void> generateContentIdeas(String id) async {
    final index = contentFactories.indexWhere((f) => f.id == id);
    if (index == -1) return;

    final factory = contentFactories[index];
    factory.isLoading = true;
    notifyListeners();

    final prompt = """
Buatkan daftar ide konten yang lengkap, kreatif, dan strategis untuk akun sosial media "$selectedProfileName", yang memiliki kategori niche "$selectedCategory", dengan sub-topik yang membahas tentang "$selectedMicroNiche". Fokus utama dari konten ini adalah pilar "${factory.selectedPillar}", menggunakan tone of voice berikut: "$toneOfVoice", yang memiliki target audiens "$targetAudience". 

Aku ingin daftar ide konten ini mencakup:
- Ide-ide spesifik yang bisa langsung dieksekusi
- Sudut pandang yang fresh dan relate dengan tren saat ini
- Gambaran kontennya seperti apa, potensi viral, dan insight kontennya

Pastikan outputnya:
✔ Buat sebanyak ${factory.ideaCount} pilihan, agar bisa dipilih sesuai kebutuhan
✔ Kreatif, menarik, dan punya potensi viral sesuai tren terkini
✔ Bisa dikembangkan menjadi strategi konten jangka panjang
✔ Relevan dengan target audiens dan membantu mereka menyelesaikan masalah atau mencapai tujuan mereka
✔ Membantuku membangun personal branding yang kuat dan sustainable
✔ Kemas dalam bentuk tabel, mudah di baca dan dipahami

Jika ada insight tambahan atau rekomendasi pengembangan ide konten, tambahkan untuk memperkaya strategi pembuatan konten ku.
""";

    try {
      final result = await _geminiService.generateContent(prompt);
      factory.generatedIdeas = result;
    } catch (e) {
      factory.generatedIdeas = "Error: ${e.toString()}";
    }

    factory.isLoading = false;
    notifyListeners();
  }
}
