import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_theme.dart';

/// Esmaül Hüsna kaydı.
@immutable
class AsmaName {
  const AsmaName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.recommendedCount,
  });

  final int number;
  final String arabic;
  final String transliteration;
  final String meaning;
  final int recommendedCount;
}

/// Esmaül Hüsna (Allah'ın 99 Güzel İsmi) ekranı.
class EsmaulHusnaScreen extends StatefulWidget {
  const EsmaulHusnaScreen({super.key});

  static const List<AsmaName> names = <AsmaName>[
    AsmaName(number: 1, arabic: 'اللّٰهُ', transliteration: 'Allah', meaning: 'Her ismin vasfını ihtiva eden öz adı, eşsiz yaratıcı.', recommendedCount: 66),
    AsmaName(number: 2, arabic: 'الرَّحْمٰنُ', transliteration: 'Er-Rahmân', meaning: 'Dünyada bütün mahlûkata merhamet eden, şefkat gösteren.', recommendedCount: 298),
    AsmaName(number: 3, arabic: 'الرَّحِيمُ', transliteration: 'Er-Rahîm', meaning: 'Ahirette müminlere sonsuz ikram ve merhamet eden.', recommendedCount: 258),
    AsmaName(number: 4, arabic: 'الْمَلِكُ', transliteration: 'El-Melik', meaning: 'Mülkün, kâinatın gerçek ve mutlak sahibi.', recommendedCount: 90),
    AsmaName(number: 5, arabic: 'الْقُدُّوسُ', transliteration: 'El-Kuddûs', meaning: 'Her noksanlıktan uzak ve her türlü takdise lâyık olan.', recommendedCount: 170),
    AsmaName(number: 6, arabic: 'السَّلَامُ', transliteration: 'Es-Selâm', meaning: 'Kullarını selâmete çıkaran, esenlik veren.', recommendedCount: 131),
    AsmaName(number: 7, arabic: 'الْمُؤْمِنُ', transliteration: 'El-Mü\'min', meaning: 'Gönüllere iman ışığı ve güven veren.', recommendedCount: 137),
    AsmaName(number: 8, arabic: 'الْمُهَيْمِنُ', transliteration: 'El-Müheymin', meaning: 'Bütün varlıkları görüp gözeten ve koruyan.', recommendedCount: 145),
    AsmaName(number: 9, arabic: 'الْعَزِيزُ', transliteration: 'El-Azîz', meaning: 'İzzet sahibi, mağlup edilmesi imkânsız mutlak galip.', recommendedCount: 94),
    AsmaName(number: 10, arabic: 'الْجَبَّارُ', transliteration: 'El-Cebbâr', meaning: 'Kırılanları onaran, dilediğini kudretiyle gerçekleştiren.', recommendedCount: 206),
    AsmaName(number: 11, arabic: 'الْمُتَكَبِّرُ', transliteration: 'El-Mütekebbir', meaning: 'Büyüklükte eşi, benzeri olmayan.', recommendedCount: 662),
    AsmaName(number: 12, arabic: 'الْخَالِقُ', transliteration: 'El-Hâlık', meaning: 'Yoktan var eden, takdirine uygun yaratan.', recommendedCount: 731),
    AsmaName(number: 13, arabic: 'الْبَارِئُ', transliteration: 'El-Bâri', meaning: 'Her şeyi birbirine uygun ve kusursuz yaratan.', recommendedCount: 214),
    AsmaName(number: 14, arabic: 'الْمُصَوِّرُ', transliteration: 'El-Musavvir', meaning: 'Varlıklara şekil ve suret veren.', recommendedCount: 336),
    AsmaName(number: 15, arabic: 'الْغَفَّارُ', transliteration: 'El-Gaffâr', meaning: 'Günahları örten ve çok mağfiret eden.', recommendedCount: 1281),
    AsmaName(number: 16, arabic: 'الْقَهَّارُ', transliteration: 'El-Kahhâr', meaning: 'Kudreti karşısında her şeyin boyun eğdiği.', recommendedCount: 306),
    AsmaName(number: 17, arabic: 'الْوَهَّابُ', transliteration: 'El-Vehhâb', meaning: 'Karşılıksız bolca nimet ve ihsan bağışlayan.', recommendedCount: 14),
    AsmaName(number: 18, arabic: 'الرَّزَّاقُ', transliteration: 'Er-Rezzâk', meaning: 'Bütün canlıların maddi ve manevi rızkını veren.', recommendedCount: 308),
    AsmaName(number: 19, arabic: 'الْفَتَّاحُ', transliteration: 'El-Fettâh', meaning: 'Hayır kapılarını açan, müşkülleri çözen.', recommendedCount: 489),
    AsmaName(number: 20, arabic: 'الْعَلِيمُ', transliteration: 'El-Alîm', meaning: 'Gizli ve açık her şeyi hakkıyla bilen.', recommendedCount: 150),
    AsmaName(number: 21, arabic: 'الْقَابِضُ', transliteration: 'El-Kâbıd', meaning: 'Hikmetiyle daraltan, ruhları kabzeden.', recommendedCount: 903),
    AsmaName(number: 22, arabic: 'الْبَاسِطُ', transliteration: 'El-Bâsıt', meaning: 'Rızkı genişleten, gönüllere ferahlık veren.', recommendedCount: 72),
    AsmaName(number: 23, arabic: 'الْخَافِضُ', transliteration: 'El-Hâfıd', meaning: 'Zalim ve kibirlileri alçaltan.', recommendedCount: 1481),
    AsmaName(number: 24, arabic: 'الرَّافِعُ', transliteration: 'Er-Râfi', meaning: 'İman ve tevazu sahiplerini yükselten.', recommendedCount: 351),
    AsmaName(number: 25, arabic: 'الْمُعِزُّ', transliteration: 'El-Muiz', meaning: 'Dilediğine izzet ve şeref bahşeden.', recommendedCount: 117),
    AsmaName(number: 26, arabic: 'الْمُذِلُّ', transliteration: 'El-Müzil', meaning: 'Haddi aşanları zillete düşüren.', recommendedCount: 770),
    AsmaName(number: 27, arabic: 'السَّمِيعُ', transliteration: 'Es-Semî', meaning: 'Gizli ve açık her sesi, her duayı işiten.', recommendedCount: 180),
    AsmaName(number: 28, arabic: 'الْبَصِيرُ', transliteration: 'El-Basîr', meaning: 'Her şeyi en ince ayrıntısına kadar gören.', recommendedCount: 302),
    AsmaName(number: 29, arabic: 'الْحَكَمُ', transliteration: 'El-Hakem', meaning: 'Mutlak hüküm sahibi, hak ile batılı ayıran.', recommendedCount: 68),
    AsmaName(number: 30, arabic: 'الْعَدْلُ', transliteration: 'El-Adl', meaning: 'Mutlak adalet sahibi, asla zulmetmeyen.', recommendedCount: 104),
    AsmaName(number: 31, arabic: 'اللَّطِيفُ', transliteration: 'El-Latîf', meaning: 'En ince işlerin sırrını bilen, kullarına lütfeden.', recommendedCount: 129),
    AsmaName(number: 32, arabic: 'الْخَبِيرُ', transliteration: 'El-Habîr', meaning: 'Her şeyin iç yüzünden ve gizli taraflarından haberdar olan.', recommendedCount: 812),
    AsmaName(number: 33, arabic: 'الْحَلِيمُ', transliteration: 'El-Halîm', meaning: 'Cezalandırmada acele etmeyen, yumuşak muamele eden.', recommendedCount: 88),
    AsmaName(number: 34, arabic: 'الْعَظِيمُ', transliteration: 'El-Azîm', meaning: 'Zâtı ve sıfatları bakımından pek yüce olan.', recommendedCount: 1020),
    AsmaName(number: 35, arabic: 'الْغَفُورُ', transliteration: 'El-Gafûr', meaning: 'Affı ve bağışlaması sonsuz olan.', recommendedCount: 1286),
    AsmaName(number: 36, arabic: 'الشَّكُورُ', transliteration: 'Eş-Şekûr', meaning: 'Az amele karşılık çok sevap ve mükâfat veren.', recommendedCount: 526),
    AsmaName(number: 37, arabic: 'الْعَلِيُّ', transliteration: 'El-Aliyy', meaning: 'Yücelikte sınır olmayan, her şeyden üstün.', recommendedCount: 110),
    AsmaName(number: 38, arabic: 'الْكَبِيرُ', transliteration: 'El-Kebîr', meaning: 'Büyüklüğü akıllarla kavranamayacak kadar ulu olan.', recommendedCount: 232),
    AsmaName(number: 39, arabic: 'الْحَفِيظُ', transliteration: 'El-Hafîz', meaning: 'Her şeyi koruyan ve muhafaza eden.', recommendedCount: 998),
    AsmaName(number: 40, arabic: 'الْمُقِيتُ', transliteration: 'El-Mukît', meaning: 'Bedenlerin ve ruhların gıdasını yaratıp ulaştıran.', recommendedCount: 550),
    AsmaName(number: 41, arabic: 'الْحَسِيبُ', transliteration: 'El-Hasîb', meaning: 'Kullarına yeten ve herkesin hesabını en iyi gören.', recommendedCount: 80),
    AsmaName(number: 42, arabic: 'الْجَلِيلُ', transliteration: 'El-Celîl', meaning: 'Celâl, azamet ve ululuk sahibi.', recommendedCount: 73),
    AsmaName(number: 43, arabic: 'الْكَرِيمُ', transliteration: 'El-Kerîm', meaning: 'Keremi, cömertliği ve ikramı bol olan.', recommendedCount: 270),
    AsmaName(number: 44, arabic: 'الرَّقِيبُ', transliteration: 'Er-Rakîb', meaning: 'Bütün varlıkları her an gözetleyen.', recommendedCount: 312),
    AsmaName(number: 45, arabic: 'الْمُجِيبُ', transliteration: 'El-Mücîb', meaning: 'Dualara ve yakarışlara icabet eden.', recommendedCount: 55),
    AsmaName(number: 46, arabic: 'الْوَاسِعُ', transliteration: 'El-Vâsi', meaning: 'İlmi, rahmeti ve kudreti her şeyi kuşatan.', recommendedCount: 137),
    AsmaName(number: 47, arabic: 'الْحَكِيمُ', transliteration: 'El-Hakîm', meaning: 'Her işi ve emri hikmetli olan.', recommendedCount: 78),
    AsmaName(number: 48, arabic: 'الْوَدُودُ', transliteration: 'El-Vedûd', meaning: 'Salih kullarını çok seven ve sevilmeye en lâyık olan.', recommendedCount: 20),
    AsmaName(number: 49, arabic: 'الْمَجِيدُ', transliteration: 'El-Mecîd', meaning: 'Şanı yüce ve ikramı sonsuz olan.', recommendedCount: 57),
    AsmaName(number: 50, arabic: 'الْبَاعِثُ', transliteration: 'El-Bâis', meaning: 'Ölüleri dirilten ve peygamberler gönderen.', recommendedCount: 573),
    AsmaName(number: 51, arabic: 'الشَّهِيدُ', transliteration: 'Eş-Şehîd', meaning: 'Her zaman ve her yerde hazır olup her şeye şahit olan.', recommendedCount: 319),
    AsmaName(number: 52, arabic: 'الْحَقُّ', transliteration: 'El-Hakk', meaning: 'Varlığı hiç değişmeden duran, gerçek olan.', recommendedCount: 108),
    AsmaName(number: 53, arabic: 'الْوَكِيلُ', transliteration: 'El-Vekîl', meaning: 'Kendisine tevekkül edenlerin işlerini en güzel yoluna koyan.', recommendedCount: 66),
    AsmaName(number: 54, arabic: 'الْقَوِيُّ', transliteration: 'El-Kaviyy', meaning: 'Kudreti en üstün ve hiç eksilmeyen.', recommendedCount: 116),
    AsmaName(number: 55, arabic: 'الْمَتِينُ', transliteration: 'El-Metîn', meaning: 'Çok sağlam, kudreti sarsılmaz olan.', recommendedCount: 500),
    AsmaName(number: 56, arabic: 'الْوَلِيُّ', transliteration: 'El-Veliyy', meaning: 'Müminlerin dostu ve yardımcısı.', recommendedCount: 46),
    AsmaName(number: 57, arabic: 'الْحَمِيدُ', transliteration: 'El-Hamîd', meaning: 'Her türlü övgüye ve شükre lâyık olan.', recommendedCount: 62),
    AsmaName(number: 58, arabic: 'الْمُحْصِي', transliteration: 'El-Muhsî', meaning: 'Her şeyin sayısını ve ölçüsünü tek tek bilen.', recommendedCount: 148),
    AsmaName(number: 59, arabic: 'الْمُبْدِئُ', transliteration: 'El-Mübdi', meaning: 'Mahlûkatı örneksiz olarak ilk baştan yaratan.', recommendedCount: 56),
    AsmaName(number: 60, arabic: 'الْمُعِيدُ', transliteration: 'El-Muîd', meaning: 'Yarattıklarını öldükten sonra tekrar dirilten.', recommendedCount: 124),
    AsmaName(number: 61, arabic: 'الْمُحْيِي', transliteration: 'El-Muhyî', meaning: 'Can bağışlayan, hayat veren.', recommendedCount: 68),
    AsmaName(number: 62, arabic: 'الْمُمِيتُ', transliteration: 'El-Mümît', meaning: 'Canlıların ölümünü takdir eden.', recommendedCount: 490),
    AsmaName(number: 63, arabic: 'الْحَيُّ', transliteration: 'El-Hayy', meaning: 'Ezeli ve ebedi hayat sahibi, diri olan.', recommendedCount: 18),
    AsmaName(number: 64, arabic: 'الْقَيُّومُ', transliteration: 'El-Kayyûm', meaning: 'Gökleri ve yeri ayakta tutan.', recommendedCount: 156),
    AsmaName(number: 65, arabic: 'الْوَاجِدُ', transliteration: 'El-Vâcid', meaning: 'İstediğini istediği anda bulan, hiçbir şeye muhtaç olmayan.', recommendedCount: 14),
    AsmaName(number: 66, arabic: 'الْمَاجِدُ', transliteration: 'El-Mâcid', meaning: 'Kadri ve şanı büyük, keremi bol olan.', recommendedCount: 48),
    AsmaName(number: 67, arabic: 'الْوَاحِدُ', transliteration: 'El-Vâhid', meaning: 'Zâtında, sıfatlarında ve işlerinde tek olan.', recommendedCount: 19),
    AsmaName(number: 68, arabic: 'الصَّمَدُ', transliteration: 'Es-Samed', meaning: 'Her şeyin kendisine muhtaç olduğu, kendisi hiçbir şeye muhtaç olmayan.', recommendedCount: 134),
    AsmaName(number: 69, arabic: 'الْقَادِرُ', transliteration: 'El-Kâdir', meaning: 'Dilediğini dilediği gibi yapmaya gücü yeten.', recommendedCount: 305),
    AsmaName(number: 70, arabic: 'الْمُقْتَدِرُ', transliteration: 'El-Muktedir', meaning: 'Kudret sahipleri üzerinde mutlak tasarruf sahibi.', recommendedCount: 744),
    AsmaName(number: 71, arabic: 'الْمُقَدِّمُ', transliteration: 'El-Mukaddim', meaning: 'Dilediğini öne geçiren, yükselten.', recommendedCount: 184),
    AsmaName(number: 72, arabic: 'الْمُؤَخِّرُ', transliteration: 'El-Muahhir', meaning: 'Hikmeti gereği dilediğini erteleyen veya geride bırakan.', recommendedCount: 846),
    AsmaName(number: 73, arabic: 'الْأَوَّلُ', transliteration: 'El-Evvel', meaning: 'Varlığının başlangıcı olmayan.', recommendedCount: 37),
    AsmaName(number: 74, arabic: 'الْآخِرُ', transliteration: 'El-Âhir', meaning: 'Varlığının sonu olmayan, baki kalan.', recommendedCount: 801),
    AsmaName(number: 75, arabic: 'الظَّاهِرُ', transliteration: 'Ez-Zâhir', meaning: 'Varlığı sayısız delillerle apaçık ortada olan.', recommendedCount: 1106),
    AsmaName(number: 76, arabic: 'الْبَاطِنُ', transliteration: 'El-Bâtın', meaning: 'Zâtının mahiyeti akıl ve duyularla idrak edilemeyen.', recommendedCount: 62),
    AsmaName(number: 77, arabic: 'الْوَالِي', transliteration: 'El-Vâlî', meaning: 'Kâinatı ve her an olan biteni tek başına idare eden.', recommendedCount: 47),
    AsmaName(number: 78, arabic: 'الْمُتَعَالِي', transliteration: 'El-Müteâlî', meaning: 'Yaratılmışların sıfatlarından münezzeh ve pek yüce.', recommendedCount: 551),
    AsmaName(number: 79, arabic: 'الْبَرُّ', transliteration: 'El-Berr', meaning: 'Kullarına iyiliği ve bağışı bol olan.', recommendedCount: 202),
    AsmaName(number: 80, arabic: 'التَّوَّابُ', transliteration: 'Et-Tevvâb', meaning: 'Tevbeleri kabul edip günahları bağışlayan.', recommendedCount: 409),
    AsmaName(number: 81, arabic: 'الْمُنْتَقِمُ', transliteration: 'El-Müntakim', meaning: 'Mazlumun hakkını zalimden adaletiyle alan.', recommendedCount: 630),
    AsmaName(number: 82, arabic: 'الْعَفُوُّ', transliteration: 'El-Afüvv', meaning: 'Günahları kökünden silip affeden.', recommendedCount: 156),
    AsmaName(number: 83, arabic: 'الرَّؤُوفُ', transliteration: 'Er-Raûf', meaning: 'Çok şefkatli ve pek merhametli olan.', recommendedCount: 287),
    AsmaName(number: 84, arabic: 'مَالِكُ الْمُلْكِ', transliteration: 'Mâlikü\'l-Mülk', meaning: 'Mülkün ebedi sahibi.', recommendedCount: 212),
    AsmaName(number: 85, arabic: 'ذُو الْجَلَالِ وَالْإِكْرَامِ', transliteration: 'Zü\'l-Celâli ve\'l-İkrâm', meaning: 'Hem büyüklük hem de fazl u kerem sahibi.', recommendedCount: 1100),
    AsmaName(number: 86, arabic: 'الْمُقْسِطُ', transliteration: 'El-Muksit', meaning: 'Bütün işlerini denk ve adaletle yapan.', recommendedCount: 209),
    AsmaName(number: 87, arabic: 'الْجَامِعُ', transliteration: 'El-Câmi', meaning: 'İstediğini istediği zaman ve yerde toplayan.', recommendedCount: 114),
    AsmaName(number: 88, arabic: 'الْغَنِيُّ', transliteration: 'El-Ganiyy', meaning: 'Çok zengin ve hiçbir şeye muhtaç olmayan.', recommendedCount: 1060),
    AsmaName(number: 89, arabic: 'الْمُغْنِي', transliteration: 'El-Muğnî', meaning: 'Dilediği kulunu zengin ve müstağni kılan.', recommendedCount: 1100),
    AsmaName(number: 90, arabic: 'الْمَانِعُ', transliteration: 'El-Mâni', meaning: 'Hikmeti gereği zararlı veya takdir edilmemiş şeylere engel olan.', recommendedCount: 161),
    AsmaName(number: 91, arabic: 'الضَّارُّ', transliteration: 'Ed-Dârr', meaning: 'Hikmetiyle imtihan ve elem verici şeyleri yaratan.', recommendedCount: 1001),
    AsmaName(number: 92, arabic: 'النَّافِعُ', transliteration: 'En-Nâfi', meaning: 'Hayır ve menfaat verici şeyleri yaratan.', recommendedCount: 201),
    AsmaName(number: 93, arabic: 'النُّورُ', transliteration: 'En-Nûr', meaning: 'Âlemleri ve gönülleri nurlandıran.', recommendedCount: 256),
    AsmaName(number: 94, arabic: 'الْهَادِي', transliteration: 'El-Hâdî', meaning: 'Hidayet veren, doğru yolu gösteren.', recommendedCount: 20),
    AsmaName(number: 95, arabic: 'الْبَدِيعُ', transliteration: 'El-Bedî', meaning: 'Örneksiz ve benzersiz harikalar yaratan.', recommendedCount: 86),
    AsmaName(number: 96, arabic: 'الْبَاقِي', transliteration: 'El-Bâkî', meaning: 'Varlığının sonu olmayan, ebedi olan.', recommendedCount: 113),
    AsmaName(number: 97, arabic: 'الْوَارِثُ', transliteration: 'El-Vâris', meaning: 'Her şey fani olduktan sonra mülkün gerçek sahibi olarak kalan.', recommendedCount: 707),
    AsmaName(number: 98, arabic: 'الرَّشِيدُ', transliteration: 'Er-Reşîd', meaning: 'Bütün işleri isabetli ve hikmetli bir nizama göre yürüten.', recommendedCount: 514),
    AsmaName(number: 99, arabic: 'الصَّبُورُ', transliteration: 'Es-Sabûr', meaning: 'Çok sabırlı olan, kullarına tevbe için mühlet tanıyan.', recommendedCount: 298),
  ];

  @override
  State<EsmaulHusnaScreen> createState() => _EsmaulHusnaScreenState();
}

class _EsmaulHusnaScreenState extends State<EsmaulHusnaScreen> {
  final TextEditingController _search = TextEditingController();
  final Map<int, int> _counts = <int, int>{};
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<AsmaName> get _filtered {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return EsmaulHusnaScreen.names;
    return EsmaulHusnaScreen.names
        .where(
          (AsmaName item) =>
              item.transliteration.toLowerCase().contains(q) ||
              item.meaning.toLowerCase().contains(q) ||
              item.arabic.contains(q) ||
              '${item.number}' == q,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<AsmaName> items = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Esmaül Hüsna (99 İsim)')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _search,
              onChanged: (String v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'İsim veya anlam ara (ör. Er-Rahmân, Şefkat)',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final AsmaName item = items[index];
                final int count = _counts[item.number] ?? 0;
                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.emerald600.withValues(
                                  alpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${item.number}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emerald500,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                item.transliteration,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              item.arabic,
                              textDirection: TextDirection.rtl,
                              style: AppTheme.arabic(
                                theme.textTheme,
                                size: 24,
                                color: AppColors.gold600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(item.meaning, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Zikir adedi: $count / ${item.recommendedCount}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Paylaş',
                              onPressed: () => SharePlus.instance.share(
                                ShareParams(
                                  text:
                                      '${item.arabic} — ${item.transliteration}\n'
                                      '${item.meaning}\n'
                                      '(Zikir adedi: ${item.recommendedCount} · Ezan)',
                                ),
                              ),
                              icon: const Icon(
                                Icons.ios_share_rounded,
                                size: 18,
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setState(
                                  () => _counts[item.number] = count + 1,
                                );
                              },
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Zikret'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
