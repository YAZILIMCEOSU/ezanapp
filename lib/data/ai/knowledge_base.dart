import 'package:flutter/foundation.dart';

/// AI asistanın yerel bilgi tabanı.
///
/// Bu taban, sık sorulan sorulara **kaynak göstererek** özet cevap verir.
/// Amaç kesin hüküm vermek değildir; her cevapta farklı görüşler ve mezhep
/// ayrılıkları açıkça belirtilir ve tereddüt hâlinde müftülüğe danışılması
/// önerilir.
@immutable
class KnowledgeEntry {
  const KnowledgeEntry({
    required this.id,
    required this.title,
    required this.keywords,
    required this.answer,
    required this.details,
    required this.citations,
    this.madhabNotes = const <String>[],
    this.related = const <String>[],
    this.category = 'İbadet',
  });

  final String id;
  final String title;

  /// Eşleştirme anahtar kelimeleri (küçük harf, diakritiksiz).
  final List<String> keywords;

  /// Kısa, doğrudan cevap.
  final String answer;

  /// Maddeli ayrıntılar.
  final List<String> details;

  /// Kaynak künyeleri (Kur'an, hadis, fıkıh).
  final List<String> citations;

  /// Mezhep/ekol farklılıkları.
  final List<String> madhabNotes;

  final List<String> related;
  final String category;
}

/// Yerel bilgi tabanının tamamı.
abstract final class KnowledgeBase {
  /// Kaydı kimliğine göre bulur (yoksa `null`).
  ///
  /// İlişkili kayıt kimliklerini başlığa çevirmek için kullanılır.
  static KnowledgeEntry? byId(String id) {
    for (final KnowledgeEntry entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  static const List<KnowledgeEntry> entries = <KnowledgeEntry>[
    KnowledgeEntry(
      id: 'islam_sartlari',
      title: 'İslam\'ın şartları nelerdir?',
      keywords: <String>[
        'islamin sartlari',
        'islam sartlari',
        'islamin sarti',
        'islamin 5 sarti',
        'islamin bes sarti',
        'islamin esaslari',
        'islamin temel sartlari',
        'kelimei sehadet',
        'islamin sartlari nelerdir',
        'islamin sartlari kac tanedir',
      ],
      answer:
          'İslam\'ın şartları beştir ve Cibrîl hadisinde bildirilen sırasıyla şunlardır:\n'
          '1. Kelime-i şehâdet getirmek\n'
          '2. Namaz kılmak\n'
          '3. Zekât vermek\n'
          '4. Ramazan orucu tutmak\n'
          '5. Hacca gitmek',
      details: <String>[
        '1. Kelime-i şehâdet getirmek: "Eşhedü en lâ ilâhe illallah ve eşhedü enne Muhammeden abdühû ve resûlüh" diyerek Allah\'ın birliğini ve Hz. Muhammed\'in (s.a.v.) O\'nun kulu ve elçisi olduğunu kalben tasdik edip dil ile ikrar etmek.',
        '2. Namaz kılmak: Akıl-bâliğ olan her Müslümanın günde beş vakit (sabah, öğle, ikindi, akşam, yatsı) namazı vaktinde kılması.',
        '3. Zekât vermek: Nisab miktarı mala sahip olanların, üzerinden bir kamerî yıl geçtiğinde mallarının belli bir oranını (genelde %2,5) ihtiyaç sahiplerine vermesi.',
        '4. Ramazan orucu tutmak: Ramazan ayı boyunca imsak vaktinden akşam ezanına kadar yeme, içme ve orucu bozan hâllerden uzak durarak oruç tutmak.',
        '5. Hacca gitmek: Sağlık ve maddi imkânı elverenlerin ömründe bir kez Zilhicce ayında Kâbe\'yi ve kutsal mekânları ziyaret ederek hac ibadetini yerine getirmesi.',
      ],
      citations: <String>[
        'Buhârî, Îmân 1-2 (İbn Ömer ve Cibrîl hadisleri — İslam\'ın beş esas üzerine bina edilmesi)',
        'Müslim, Îmân 1, 19-22; Tirmizî, Îmân 3',
        'Kur\'an-ı Kerim, Bakara 2/43, 2/183; Âl-i İmrân 3/97',
        'Diyanet İşleri Başkanlığı, İlmihal I (İman ve İbadetler), İslam\'ın Şartları bölümü',
      ],
      madhabNotes: <String>[
        'Dört Sünnî mezhepte (Hanefî, Şâfiî, Mâlikî, Hanbelî) İslam\'ın beş temel şartı ve sıralaması üzerinde tam ittifak vardır.',
      ],
      related: <String>[
        'iman_sartlari',
        'namaz_rekat',
        'zekat',
        'imsak_orucu',
        'hac_umre',
      ],
      category: 'İman ve İslam',
    ),
    KnowledgeEntry(
      id: 'iman_sartlari',
      title: 'İmanın şartları nelerdir?',
      keywords: <String>[
        'imanin sartlari',
        'iman sartlari',
        'imanin sarti',
        'imanin 6 sarti',
        'imanin alti sarti',
        'iman esaslari',
        'amentu',
        'amentu esaslari',
        'imanin sartlari nelerdir',
        'imanin sartlari kac tanedir',
      ],
      answer:
          'İmanın şartları (Âmentü esasları) altıdır ve sırasıyla şunlardır:\n'
          '1. Allah\'a iman\n'
          '2. Meleklere iman\n'
          '3. Kitaplara iman\n'
          '4. Peygamberlere iman\n'
          '5. Âhiret gününe iman\n'
          '6. Kader ve kazâya (hayır ve şerrin Allah\'tan olduğuna) iman',
      details: <String>[
        '1. Allah\'a iman: Allah\'ın varlığına, birliğine (tevhid), eşi ve benzeri olmadığına, tüm kemal sıfatlarla muttasıf olduğuna inanmak.',
        '2. Meleklere iman: Allah\'ın nurdan yarattığı, günah işlemeyen ve emirlerini yerine getiren Cebrâil, Mîkâil, İsrâfil, Azrâil ve diğer meleklerine inanmak.',
        '3. Kitaplara iman: Allah\'ın peygamberlerine vahyettiği sahifelere ve dört büyük kitaba (Tevrat, Zebur, İncil ve son ilâhî kitap Kur\'an-ı Kerim) inanmak.',
        '4. Peygamberlere iman: İlk peygamber Hz. Âdem\'den son peygamber Hz. Muhammed\'e (s.a.v.) kadar gönderilen bütün peygamberlere ayrım yapmaksızın inanmak.',
        '5. Âhiret gününe iman: Kıyamete, ölümden sonra dirilişe (ba\'s), amellerin tartılmasına, cennet ve cehennem hayatına inanmak.',
        '6. Kader ve kazâya iman: Hayır ve şerrin, iyi ve kötünün Allah\'ın ilmi, iradesi, kudreti ve yaratmasıyla gerçekleştiğine; insanın cüz\'î iradesiyle yaptığı tercihlerden sorumlu olduğuna inanmak.',
      ],
      citations: <String>[
        'Müslim, Îmân 1 (Cibrîl hadisi — İmanın altı esası); Buhârî, Îmân 37',
        'Kur\'an-ı Kerim, Bakara 2/177, 2/285; Nisâ 4/136; Kamer 54/49',
        'Diyanet İşleri Başkanlığı, İlmihal I (İman ve İbadetler), İman Esasları bölümü',
      ],
      madhabNotes: <String>[
        'Ehl-i sünnet kelâm ekolleri (Mâtürîdiyye ve Eş\'ariyye) bu altı iman esasında müttefiktir; iman esasları bir bütündür, birini inkâr etmek imanı geçersiz kılar.',
      ],
      related: <String>['islam_sartlari', 'kuran_okuma', 'dua_adab'],
      category: 'İman ve İslam',
    ),
    KnowledgeEntry(
      id: 'namazin_sartlari',
      title: 'Namazın şartları (farzları) nelerdir?',
      keywords: <String>[
        'namazin sartlari',
        'namazin farzlari',
        'namazin rukunleri',
        'namazin 12 farzi',
        'hadesten taharet',
        'necasetten taharet',
        'setri avret',
        'istikbali kible',
        'iftitah tekbiri',
      ],
      answer:
          'Namazın farzları 12\'dir: 6\'sı namazın dışında (hazırlık şartları), '
          '6\'sı ise namazın içinde (rükünler) yer alır.',
      details: <String>[
        'Dışındaki 6 şart: 1) Hadesten tahâret (abdest/gusül), 2) Necâsetten tahâret (beden, elbise ve yerin temizliği), 3) Setr-i avret (örtünme), 4) İstikbâl-i kıble (Kâbe\'ye yönelme), 5) Vakit, 6) Niyet.',
        'İçindeki 6 rükün: 1) İftitah (başlama) tekbiri, 2) Kıyam (ayakta durmak), 3) Kıraat (Kur\'an okumak), 4) Rükû, 5) Sücûd (secde), 6) Ka\'de-i âhire (son oturuş).',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Bakara 2/43, 2/144, 2/238; Mâide 5/6; Müddessir 74/4',
        'Buhârî, Ezân 95; Müslim, Salât 45',
        'Diyanet İşleri Başkanlığı, İlmihal I, Namazın Farzları bölümü',
      ],
      madhabNotes: <String>[
        'Şâfiî mezhebinde niyet namazın içindeki rükünlerden sayılır ve Fâtiha okumak her rekâtta farzdır; Hanefî\'de ise mutlak kıraat farz, Fâtiha okumak vaciptir.',
      ],
      related: <String>['namaz_rekat', 'abdest', 'kible', 'islam_sartlari'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'gusul',
      title: 'Gusül (boy abdesti) nasıl alınır ve farzları nelerdir?',
      keywords: <String>[
        'gusul',
        'gusul abdesti',
        'boy abdesti',
        'guslun farzlari',
        'gusul nasil alinir',
        'cunupluk',
      ],
      answer:
          'Guslün (boy abdestinin) Hanefî mezhebine göre 3 farzı vardır: '
          '1) Ağza su alıp çalkalamak (mazmaza), 2) Burna su çekmek (istinşak), '
          '3) Bütün bedeni kuru yer kalmayacak şekilde yıkamak.',
      details: <String>[
        'Sünnete uygun gusül: Önce niyet ve besmele ile eller ve avret mahalli yıkanır, ardından namaz abdesti alınır.',
        'Sonra sırasıyla başa, sağ omuza ve sol omuza üçer defa su dökülüp bütün vücut ovularak yıkanır.',
        'Su geçirmeyen oje, boya veya yapışkan maddeler varsa gusülden önce çıkarılmalıdır.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Mâide 5/6; Nisâ 4/43',
        'Buhârî, Gusül 1; Müslim, Hayz 35',
        'Diyanet İşleri Başkanlığı, İlmihal I, Gusül bölümü',
      ],
      madhabNotes: <String>[
        'Hanefî\'de ağız ve burnun içini yıkamak farzdır; Şâfiî ve Mâlikî\'de ise niyet etmek farz, ağız ve burnu yıkamak sünnettir.',
      ],
      related: <String>['abdest', 'teyemmum', 'kadin_ozel_haller'],
      category: 'Temizlik',
    ),
    KnowledgeEntry(
      id: 'namaz_rekat',
      title: 'Vakit namazları kaç rekâttır?',
      keywords: <String>[
        'namaz',
        'rekat',
        'rekatlari',
        'namaz rekatlari',
        'aksam namazi',
        'sabah namazi',
        'yatsi',
        'ikindi',
        'ogle',
      ],
      answer:
          'Sünnetleriyle birlikte günlük vakit namazları toplam 40 rekâttır '
          '(sabah 4, öğle 10, ikindi 8, akşam 5, yatsı 13). Farzlar toplamı ise 17 rekâttır.',
      details: <String>[
        'Sabah: 2 sünnet + 2 farz',
        'Öğle: 4 sünnet + 4 farz + 2 son sünnet',
        'İkindi: 4 sünnet + 4 farz',
        'Akşam: 3 farz + 2 sünnet',
        'Yatsı: 4 sünnet + 4 farz + 2 son sünnet + 3 vitir',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, İsrâ 17/78; Hûd 11/114; Tâhâ 20/130',
        'Buhârî, Salât 1; Müslim, Îmân 1 (namazın farz oluşu)',
      ],
      madhabNotes: <String>[
        'Vitir namazı Hanefî’de vacib, diğer mezheplerde müekked sünnettir.',
        'İkindi ve yatsının ilk sünnetleri Hanefî’de sünnet-i gayr-i müekkede sayılır.',
      ],
      related: <String>['kaza_namaz', 'cuma_namazi', 'seferi_namaz'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'abdest',
      title: 'Abdest nasıl alınır?',
      keywords: <String>[
        'abdest',
        'nasil abdest',
        'abdest nasil alinir',
        'abdestin farzlari',
        'abdesti bozan',
      ],
      answer:
          'Abdest sırasıyla: elleri yıkamak, ağza ve burna su vermek, yüzü yıkamak, '
          'dirseklerle birlikte kolları yıkamak, başı mesh etmek, topuklarla birlikte ayakları yıkamaktır.',
      details: <String>[
        'Niyet kalptedir; besmele ile başlamak sünnettir.',
        'Yüz: alın saç çizgisinden çene altına, kulaklar arası.',
        'Kollar: dirsekler dahil; baş: ıslak elle mesh.',
        'Ayaklar: topuk ve parmak araları dahil.',
        'Abdesti bozan şeyler: idrar-dışkı-yel, uyku (dayanarak), ayık olmayan hâl, ağız dolusu kusma.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Mâide 5/6 (abdest ayeti)',
        'Müslim, Tahâret 2 (abdestin sırası)',
      ],
      madhabNotes: <String>[
        'Hanefî’de başı kaplama mesh sünnettir; Şâfiî’de mesh edilen alanın belli ölçüsü farzdır.',
      ],
      related: <String>['namaz_rekat', 'teyemmum'],
      category: 'Temizlik',
    ),
    KnowledgeEntry(
      id: 'teyemmum',
      title: 'Teyemmüm nasıl alınır, ne zaman yapılır?',
      keywords: <String>[
        'teyemmum',
        'su yok',
        'toprakla abdest',
        'gusul teyemmum',
        'su bulunmazsa',
      ],
      answer:
          'Su bulunmadığında veya suyu kullanmak sağlığa zararlı olduğunda teyemmüm '
          'yapılır: niyet edilir, temiz toprak/tozlu yüzeye eller vurulur, yüz mesh '
          'edilir; ikinci vuruşta dirseklerle birlikte kollar mesh edilir.',
      details: <String>[
        'Abdest veya gusül gereken durumlarda su yoksa teyemmüm ikisinin yerini tutar.',
        'Su bulununca ya da suyu kullanmaya engel ortadan kalkınca teyemmüm bozulur.',
        'Toprak bulunamazsa kum, taş gibi cinsinden temiz yüzeylere vurulabilir.',
        'Teyemmümle kılınan namaz, su bulunduğunda iade edilmez; sonraki vakitler için abdest alınır.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Mâide 5/6; Nisâ 4/43',
        'Buhârî, Teyemmüm 1; Müslim, Hayz 109',
      ],
      madhabNotes: <String>[
        'Hanefî ve Şâfiî: iki vuruş esastır (biri yüz, diğeri kollar için).',
        'Mâlikî: tek vuruşla yüz ve kollar birlikte mesh edilebilir.',
      ],
      related: <String>['abdest', 'namaz_rekat'],
      category: 'Temizlik',
    ),
    KnowledgeEntry(
      id: 'imsak_orucu',
      title: 'Oruç ne zaman başlar, imsak ne demektir?',
      keywords: <String>[
        'imsak',
        'oruc',
        'ifta',
        'sahur',
        'oruc ne zaman',
        'imsak vakti',
      ],
      answer:
          'Oruç, imsak vaktiyle başlar ve akşam (güneşin batışı) ile biter. '
          'İmsak, tan yerinin ağarmaya başlamasından (fecr-i sâdık) bir süre önceki tedbirli vakittir.',
      details: <String>[
        'Sahur yemeği imsak vaktine kadar yenilebilir.',
        'İftar, akşam ezanıyla (güneş battıktan sonra) yapılır.',
        'Uygulamada gösterilen vakitler Diyanet verisi ya da Diyanet’le kalibre edilmiş hesaptır.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Bakara 2/187 ("fecrin beyaz ipliği siyahından ayrılıncaya kadar")',
        'Buhârî, Savm 16; Müslim, Sıyâm 28',
      ],
      related: <String>['oruc_bozan', 'kadir_gecesi'],
      category: 'Oruç',
    ),
    KnowledgeEntry(
      id: 'oruc_bozan',
      title: 'Orucu bozan şeyler nelerdir?',
      keywords: <String>[
        'orucu bozan',
        'oruc bozulur',
        'kaza',
        'kasitli',
        'unutusuz',
      ],
      answer:
          'Orucu bozan başlıca durumlar: yeme-içme, cinsel ilişki, '
          'kan aldırıp kan dolaşımına ulaşan serum, unutarak yiyip içtikten sonra kasıtlı devam etme.',
      details: <String>[
        'Unutarak yiyip içmek orucu bozmaz; hatırladığında hemen bırakılır (Buhârî, Savm 26).',
        'Oruç bozulursa gün içinde imsak yapılır ve günü oruçlu gibi geçirip kaza edilir.',
        'Şüphe hâlinde yerel müftülükten görüş almak en doğrusudur.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Bakara 2/184-185',
        'Buhârî, Savm 26; Müslim, Sıyâm 33',
      ],
      madhabNotes: <String>[
        'Hanefî ve Şâfiî: unutarak yemek orucu bozmaz.',
        'Bazı görüşlerde diş fırçalama/macun yutulması ihtilaflıdır; titiz davranan kaza eder.',
      ],
      related: <String>['imsak_orucu'],
      category: 'Oruç',
    ),
    KnowledgeEntry(
      id: 'kaza_namaz',
      title: 'Sabah namazını kaçırdım, ne yapmalıyım?',
      keywords: <String>[
        'kaza',
        'kacirdim',
        'sabah namazi',
        'kaza namazi',
        'namazi kacirdim',
        'uyandim gecti',
      ],
      answer:
          'Vakti geçen namaz kaza edilir. Sabah namazını kaçıran kişi, hatırladığı '
          'anda 2 rekât farzı kılar; sünnetinin kazası ise ihtilaflıdır.',
      details: <String>[
        'Kaza namazı için özel bir vakit şartı yoktur; kerâhet vakitleri dışında kılınabilir.',
        'Uyku ve unutma mazeret sayılır: "Kim namazı unutur veya uyuyakalırsa, hatırladığında kılsın." (Müslim, Mesâcid 314)',
        'Kaza namazlarını belirli bir sıraya koymak (sabah-öğle-ikindi…) Hanefî’de tavsiye edilir.',
        'Kaç kaza olduğu kesin bilinmiyorsa kanaate göre hesap edilir ve çokça istiğfar edilir.',
      ],
      citations: <String>[
        'Müslim, Mesâcid 314 (uyku ve unutma hâli)',
        'Buhârî, Mevâkît 37',
      ],
      madhabNotes: <String>[
        'Hanefî: İmâm-ı Âzam’a göre sabah sünnetinin kazası yoktur; İmameyn ve diğer mezhepler sünnetlerin de kaza edilmesini uygun görür.',
        'Şâfiî: kaza namazlarında yalnızca farzlar kaza edilir, sünnet kılınmaz.',
      ],
      related: <String>['namaz_rekat', 'sabah_namazi_vakti'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'seferi_namaz',
      title: 'Seferî namaz nasıl kılınır?',
      keywords: <String>[
        'seferi',
        'yolculuk',
        'mukim',
        'yolcu',
        'seferi namaz',
      ],
      answer:
          'Hanefî’ye göre en az 90 km’lik bir mesafeye yolculuğa çıkan kişi, '
          '15 günden az kalmak şartıyla seferî sayılır: 4 rekâtlı farzları 2 rekât kılar.',
      details: <String>[
        'Sabah (2) ve akşam (3) farzları seferîlikte de aynen kılınır.',
        'Sünnetler isteğe bağlıdır; kılınabilir.',
        'Yolculuk bitince (memlekete dönünce) veya 15 gün kalmaya niyet edince mukim sayılır.',
        'Cemaate uyulursa imama uyulur; imam mukimse 4 rekât tamamlanır.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Nisâ 4/101',
        'Müslim, Salâtü\'l-müsâfirîn 1',
      ],
      madhabNotes: <String>[
        'Hanefî: 4 rekâtlı farzlar 2 kılınır (azîmet).',
        'Şâfiî/Mâlikî: seferîlikte kısaltma ruhsattır, tam kılmak da geçerlidir.',
      ],
      related: <String>['namaz_rekat', 'cuma_namazi'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'cuma_namazi',
      title: 'Cuma namazı hangi şartlarda farzdır?',
      keywords: <String>[
        'cuma',
        'cuma namazi',
        'hutbe',
        'cuma farz',
        'cuma kilinmaz',
      ],
      answer:
          'Cuma namazı; erkek, akıl-bâliğ, mukim (misafir olmayan), sağlıklı ve '
          'zorlukla karşılaşmayan Müslümanlara farzdır.',
      details: <String>[
        'Kılınışı: hutbe + 2 rekât farz; dört rekât ilk sünnet ve dört rekât son sünnet ile birlikte kılınır.',
        'Cuma, öğle namazının yerine geçer.',
        'Kadınlar, yolcular ve hastalar cuma yerine öğle namazı kılabilir.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Cum\'a 62/9',
        'Buhârî, Cum\'a 1; Müslim, Cum\'a 1-5',
      ],
      madhabNotes: <String>[
        'Hanefî: cumanın sahih olması için devlet izni/umumî yer şartı aranır.',
        'Şâfiî/Mâlikî: şartlar daha esnektir (cemaat sayısı vb.).',
      ],
      related: <String>['namaz_rekat'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'sabah_namazi_vakti',
      title: 'Sabah namazı vakti ne zaman başlar, ne zaman biter?',
      keywords: <String>[
        'sabah namazi',
        'sabah vakti',
        'tan yeri',
        'fecr',
        'sabah namazi ne zaman',
      ],
      answer:
          'Sabah namazı, tan yerinin ağarmasıyla (fecr-i sâdık) başlar ve güneşin '
          'doğuşuna kadar kılınır. İmsak vakti ise fecr-i sâdıktan bir süre önce '
          'alınan tedbirli vakittir; uygulama ikisini ayrı gösterir.',
      details: <String>[
        'Güneş doğduktan sonra sabah namazı kaza edilir.',
        'Sabah namazının sünneti farzdan önce kılınır; sabah ezanı okunduktan sonra vakti girer.',
        'Vaktin girmesinden hemen sonra değil, biraz geciktirerek kılmak da sünnete uygundur.',
        'Yatsıdan sonra teheccüd kılınıp sabah vakti girince sabah namazı kılınır.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, İsrâ 17/78; Tâhâ 20/130',
        'Müslim, Mesâcid 314; Buhârî, Mevâkît 27',
      ],
      related: <String>['namaz_rekat', 'kaza_namaz', 'imsak_orucu'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'zekat',
      title: 'Zekât oranı ve nisab nedir?',
      keywords: <String>[
        'zekat',
        'nisab',
        'zekat orani',
        'kirkta bir',
        'fitre',
        'sadaka',
      ],
      answer:
          'Zekât, nisab miktarına ulaşan malın üzerinden bir hicri yıl geçtikten sonra '
          'kırkta bir (%2,5) olarak verilir.',
      details: <String>[
        'Nisab: 80,18 gr altın veya eşdeğeri para (yaklaşık).',
        'Fitre (fıtır sadakası): Ramazan Bayramı’ndan önce, bir kişinin bir günlük gıda bedeli.',
        'Zekât; yoksullara, borçlulara, yolda kalmışlara verilir (Tevbe 60).',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Tevbe 9/60; Bakara 2/110',
        'Buhârî, Zekât 1; Müslim, Zekât 1',
      ],
      related: <String>['fitre'],
      category: 'Mali İbadet',
    ),
    KnowledgeEntry(
      id: 'fitre',
      title: 'Fitre (fıtır sadakası) nedir, ne zaman verilir?',
      keywords: <String>[
        'fitre',
        'fitir',
        'fitir sadakasi',
        'bayram sadakasi',
        'fitre ne kadar',
      ],
      answer:
          'Fitre, Ramazan orucunun ardından verilen ve bayram namazından önce eda '
          'edilmesi esas olan bir sadakadır. Kişi, kendisi ve bakmakla yükümlü '
          'olduğu kişiler için bir günlük gıda bedeli kadar verir.',
      details: <String>[
        'Kişi başı miktar her yıl Diyanet İşleri Başkanlığı tarafından ilan edilir.',
        'Bayram namazından önce verilmesi esastır; sonraya bırakılırsa eda vakti kaçırılmış olur.',
        'Zekât verilebilecek sınıflara verilir (Tevbe 9/60).',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Bakara 2/185',
        'Buhârî, Zekât 70-77; Müslim, Zekât 12',
      ],
      madhabNotes: <String>[
        'Hanefî: fitre kişi başı kıymet (bedel) olarak da verilebilir; hükmü vaciptir.',
        'Diğer mezheplerde miktar bir sâ\' (yaklaşık 2,5-3 kg) temel gıda maddesi ölçüsüdür.',
      ],
      related: <String>['zekat', 'imsak_orucu'],
      category: 'Mali İbadet',
    ),
    KnowledgeEntry(
      id: 'vitir_teravih',
      title: 'Vitir ve teravih namazı kaç rekâttır?',
      keywords: <String>[
        'vitir',
        'vitir namazi',
        'teravih',
        'teravih namazi',
        'gece namazi',
        'teheccud',
      ],
      answer:
          'Vitir namazı 3 rekâttır ve yatsıdan sonra kılınır. Teravih namazı 20 '
          'rekâttır (Hanefî’de sünnet) ve Ramazan’da yatsıdan sonra kılınır.',
      details: <String>[
        'Teravih ikişer rekât hâlinde kılınır; 20 rekât genel kabuldür.',
        'Vitir, yatsı namazından sonra ve sabah imsak vaktine kadar kılınabilir.',
        'Teheccüd: gece uyanıp kılınan nafile namazdır.',
      ],
      citations: <String>[
        'Buhârî, Terâvih 1; Müslim, Salâtü\'l-müsâfirîn 173',
        'Tirmizî, Salât 208',
      ],
      madhabNotes: <String>[
        'Teravih sayısı: Hanefî, Şâfiî, Mâlikî ve Hanbelî’de 20 rekât; bazı görüşlerde 8 veya 36.',
        'Vitir hükmü: Hanefî’de vacib, diğerlerinde sünnet.',
      ],
      related: <String>['namaz_rekat', 'kadir_gecesi'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'kadir_gecesi',
      title: 'Kadir Gecesi ne zaman ve nasıl değerlendirilir?',
      keywords: <String>['kadir', 'kadir gecesi', 'kadir kandili', 'bin aydan'],
      answer:
          'Kadir Gecesi Ramazan’ın son on gününde, özellikle 27. gecesinde aranır; '
          'bin aydan hayırlıdır.',
      details: <String>[
        'Bu geceyi namaz, Kur\'an okuma, zikir ve dua ile geçirmek tavsiye edilir.',
        'Peygamberimizin öğrettiği dua: "Allahümme inneke afüvvün tuhibbü’l-afve fa’fü annî".',
        'İtikâf, Ramazan’ın son on gününde sünnettir.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Kadir 97/1-5',
        'Buhârî, Fazlü Leyleti\'l-Kadr 1; Tirmizî, Deavât 84',
      ],
      related: <String>['vitir_teravih', 'imsak_orucu'],
      category: 'Ramazan',
    ),
    KnowledgeEntry(
      id: 'hac_umre',
      title: 'Hac ve umre arasındaki fark nedir?',
      keywords: <String>['hac', 'umre', 'ihram', 'tavaf', 'kabe'],
      answer:
          'Hac, belirli günlerde (Zilhicce) yapılan ve ömürde bir kez farz olan ibadettir. '
          'Umre ise yılın her zamanında yapılabilen, hacdan bağımsız bir ibadettir (sünnet).',
      details: <String>[
        'Hac: ihram, tavaf, sa\'y, Arafat vakfesi, şeytan taşlama, kurban ve tıraş.',
        'Umre: ihram, tavaf, sa\'y ve tıraş.',
        'Haccın farz olması için: Müslüman, akıl-bâliğ, sağlıklı ve maddi güç sahibi olmak; yolun güvenli olması.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Âl-i İmrân 3/97; Bakara 2/196',
        'Buhârî, Hac 1; Müslim, Hac 412',
      ],
      related: <String>['kurban'],
      category: 'Hac',
    ),
    KnowledgeEntry(
      id: 'kurban',
      title: 'Kurban ibadetinin hükmü ve şartları nelerdir?',
      keywords: <String>['kurban', 'kurban bayrami', 'kurban kesmek', 'akika'],
      answer:
          'Kurban, Hanefî’ye göre nisab sahibi ve mukim olan kişiye vacibtir; '
          'Kurban Bayramı’nın ilk üç gününde kesilir.',
      details: <String>[
        'Koyun-keçi: bir kişi için; sığır-deve: yedi kişiye kadar ortak olunabilir.',
        'Kesilecek hayvanın sağlıklı ve yaşı uygun olmalıdır (koyun 1, sığır 2, deve 5 yaş).',
        'Akika, çocuk için kesilen şükür kurbanıdır (sünnet).',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Kevser 108/2; Hac 22/36',
        'Tirmizî, Edâhî 1',
      ],
      related: <String>['hac_umre'],
      category: 'Mali İbadet',
    ),
    KnowledgeEntry(
      id: 'dua_adab',
      title: 'Duanın kabulü için nelere dikkat edilir?',
      keywords: <String>['dua', 'nasil dua', 'dua etmek', 'dua adabi', 'kabul'],
      answer:
          'Dua; ihlâsla, helâl lokmayla, hamd ve salavatla başlayıp bitirilerek, '
          'kıbleye yönelip yüksek sesle olmayacak şekilde yapılır.',
      details: <String>[
        'Kabulün gecikmesi, duanın reddedildiği anlamına gelmez.',
        'Kabule engel: haram kazanç, aceleci tutum ("duam kabul olmadı" demek).',
        'Sevilen vakitler: seher, iki hutbe arası, Ramazan, Kadir Gecesi, ezan ile kamet arası.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Bakara 2/186; Mü\'min 40/60',
        'Müslim, Zikir 91; Tirmizî, Deavât 1',
      ],
      related: <String>['kadir_gecesi'],
      category: 'Dua',
    ),
    KnowledgeEntry(
      id: 'kuran_okuma',
      title: 'Kur\'an okumanın fazileti ve âdâbı nedir?',
      keywords: <String>[
        'kuran',
        'kuran okumak',
        'tecvid',
        'hatim',
        'meal',
        'kurani kerim',
      ],
      answer:
          'Kur\'an okumak en faziletli zikirlerdendir; her harfine ayrı sevap vardır. '
          'Abdestli olmak, saygıyla ve anlamını düşünerek okumak âdâbtır.',
      details: <String>[
        'Hatim: Kur\'an’ın tamamını okumak; Ramazan’da geleneksel olarak tamamlanır.',
        'Meali okumak konuyu anlamaya yardımcıdır; ancak meal, Kur\'an\'ın kendisi yerine geçmez.',
        'Tilavet secdesi: secde âyeti okunduğunda yapılır.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Müzzemmil 73/4; Nahl 16/98',
        'Tirmizî, Fedâilü\'l-Kur\'ân 1',
      ],
      related: <String>['hatim'],
      category: 'Kur\'an',
    ),
    KnowledgeEntry(
      id: 'hatim',
      title: 'Hatim takibi nasıl yapılır?',
      keywords: <String>[
        'hatim',
        'hatmi',
        'hatim takibi',
        'hatim yapmak',
        'cuz',
        'kac cuz',
      ],
      answer:
          'Kur\'an 30 cüze ayrılmıştır. Günde bir cüz okuyarak bir ayda hatim tamamlanır; '
          'uygulamadaki hatim takibi bölümünden cüz durumunuzu işaretleyebilirsiniz.',
      details: <String>[
        'Cüz başlangıçları sûre/âyet numarasıyla bellidir (ör. 1. cüz: Fâtiha - Bakara 141).',
        'Hatim sonunda dua etmek müstehaptır.',
        'Yarıda kalan hatim, kaldığınız yerden devam edilerek tamamlanabilir.',
      ],
      citations: <String>['Tirmizî, Kırâât 13; Dârimî, Fedâilü\'l-Kur\'ân 33'],
      related: <String>['kuran_okuma'],
      category: 'Kur\'an',
    ),
    KnowledgeEntry(
      id: 'kible',
      title: 'Kıble yönü nasıl bulunur?',
      keywords: <String>[
        'kible',
        'kible yonu',
        'pusula',
        'kabe',
        'kabe yonu',
        'kabe hangi yonde',
        'namaz yonum',
      ],
      answer:
          'Türkiye’den Kâbe güneydoğu yönündedir (İstanbul için yaklaşık 152°, '
          'Ankara için yaklaşık 160°). Uygulamadaki Kıble ekranı pusula ile bu yönü gösterir.',
      details: <String>[
        'Pusula doğruluğu için telefonu 8 çizer gibi hareket ettirerek kalibre edin.',
        'Metâl eşyalardan ve mıknatıslardan uzak durun.',
        'Pusula yoksa güneşin konumundan da yön bulunabilir.',
      ],
      citations: <String>['Kur\'an-ı Kerim, Bakara 2/144'],
      related: <String>['namaz_rekat'],
      category: 'Kıble',
    ),
    KnowledgeEntry(
      id: 'kabir_ziyaret',
      title: 'Kabir ziyareti caiz mi, nasıl yapılır?',
      keywords: <String>['kabir', 'kabir ziyareti', 'mezarlik', 'ziyaret'],
      answer:
          'Kabir ziyareti sünnettir; ölümü hatırlatır ve âhirete hazırlığı artırır. '
          'Kabrin karşısında ayakta dua edilir; kabirden bir şey istenmez.',
      details: <String>[
        'Ziyaret eden kişi: "Esselâmü aleyküm ehle\'d-diyâri mine\'l-mü\'minîn…" der.',
        'Kabir üzerine taş dikmek, üzerine basmamak, mezarlığı temiz tutmak âdâbtır.',
        'Ölüden medet ummak, kabir için kurban kesip adakta bulunmak dinen caiz değildir.',
      ],
      citations: <String>['Müslim, Cenâiz 104', 'İbn Mâce, Cenâiz 47'],
      related: <String>['dua_adab'],
      category: 'Ahlak',
    ),
    KnowledgeEntry(
      id: 'faiz_ticaret',
      title: 'Faiz ve helâl kazanç konusunda temel ölçüler nedir?',
      keywords: <String>[
        'faiz',
        'helal',
        'haram',
        'ticaret',
        'bankayi',
        'kredi',
        'enflasyon',
      ],
      answer:
          'Faiz kesin olarak haramdır. Kazanç; ticaret, emek, ortaklık ve gelir ortaklığı '
          'gibi meşru yollarla olmalıdır.',
      details: <String>[
        'Alışverişte aldatıcılık, ölçü-tartıda hile haramdır.',
        'Katılım bankacılığı ürünleri bu ölçülere uygun kurgulanmıştır; ayrıntı için fetva alınmalıdır.',
        'Şüpheli durumlarda "şüpheli şeylerden kaçınmak" ilkesi esastır (Buhârî, Îmân 39).',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Bakara 2/275-279; Nisâ 4/161',
        'Müslim, Müsâkât 92',
      ],
      related: <String>['zekat'],
      category: 'Muamelat',
    ),
    KnowledgeEntry(
      id: 'kadin_ozel_haller',
      title: 'Kadınlara özel hâllerde ibadet nasıl olur?',
      keywords: <String>[
        'hayiz',
        'adet',
        'lohusa',
        'nifas',
        'kadin',
        'buyuk hal',
      ],
      answer:
          'Hayız ve nifas (lohusalık) hâlinde kılınmamış namazlar kaza edilmez, '
          'tutulamayan oruçlar ise kaza edilir.',
      details: <String>[
        'Bu hâllerde Kur\'an’a el sürmemek/harften okumamak gerekir; dua ve zikir serbesttir.',
        'Hâl sona erince gusül ile ibadetlere dönülür.',
        'İbadet vakitlerinin takibi uygulamadan hatırlatılabilir.',
      ],
      citations: <String>['Müslim, Hayz 65-69; Buhârî, Hayz 6'],
      related: <String>['abdest', 'oruc_bozan'],
      category: 'Fıkıh',
    ),
    KnowledgeEntry(
      id: 'mevlit_kandil',
      title: 'Kandil geceleri ve mevlit okumak',
      keywords: <String>[
        'kandil',
        'mevlid',
        'mevlut',
        'regib',
        'berat',
        'mirac',
        'kutlama',
      ],
      answer:
          'Kandil geceleri, ibadet ve dua ile değerlendirilmesi güzel olan mübarek zamanlardır. '
          'Bu gecelerde nafile namaz, Kur\'an ve salavat okunur.',
      details: <String>[
        'Recep (Regâib, Mîraç), Şaban (Berat) ve Ramazan aylarına ait gecelerdir.',
        'Toplu mevlid okumak, ibadet değil kültürel bir gelenektir; niyet ibadet olmamalıdır.',
        'Hicri ay başlangıçları uygulamada otomatik gösterilir.',
      ],
      citations: <String>[
        'Taberânî, el-Mu\'cemü\'l-Evsat',
        'Tirmizî, Deavât 84',
      ],
      related: <String>['kadir_gecesi', 'dua_adab'],
      category: 'Ramazan',
    ),
    KnowledgeEntry(
      id: 'namaz_vakti_hesap',
      title: 'Namaz vakitleri nasıl hesaplanır?',
      keywords: <String>[
        'vakit',
        'hesap',
        'yontem',
        'diyanet',
        'hesaplama',
        'vakitler nasil',
      ],
      answer:
          'Vakitler, güneşin konumuna göre astronomik olarak hesaplanır; '
          'Diyanet İşleri Başkanlığı temkin (tedbir) düzeltmeleri uygular.',
      details: <String>[
        'İmsak: şafak açısı (Diyanet ~18°), Yatsı ~17°.',
        'İkindi: gölge uzunluğuna göre (Hanefî’de 2 kat — asr-ı sânî).',
        'Yüksek enlemlerde (48° üzeri) gece ortası kuralı devreye girer.',
        'Uygulama resmî Diyanet verisini çeker, erişemezse cihazda hesaplar.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, İsrâ 17/78',
        'Diyanet İşleri Başkanlığı namaz vakitleri takvimi',
      ],
      related: <String>['namaz_rekat', 'imsak_orucu'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'kusluk_duha_namazi',
      title: 'Kuşluk (Duha) namazı nasıl kılınır, vakti ve rekâtı nedir?',
      keywords: <String>[
        'kusluk',
        'duha',
        'kusluk namazi',
        'duha namazi',
        'kusluk vakti',
        'kusluk kac rekat',
      ],
      answer:
          'Kuşluk (Duha) namazı, güneş doğup kerahet vakti çıktıktan (~45-50 dk sonra) '
          'öğle kerahet vaktine (öğleden ~45 dk öncesine) kadar kılınan, 2, 4, 8 veya 12 rekâtlık '
          'müstehap/sünnet bir nafile namazdır.',
      details: <String>[
        'En faziletli vakti gündüzün dörtte biri geçtiği (güneşten yaklaşık 2 saat sonrası) saattir.',
        'En az 2, genellikle 4 veya 8, en çok 12 rekât olarak ikişer veya dörder rekâtta bir selam verilerek kılınır.',
        'Hz. Peygamber (s.a.s.), insan vücudundaki 360 eklemin her biri için günlük sadaka gerektiğini ve 2 rekât Kuşluk namazının bunun yerine geçtiğini bildirmiştir.',
        'Vakitler ekranından Kuşluk (Duha) Namazı Alarmını tek dokunuşla açabilirsiniz.',
      ],
      citations: <String>[
        'Müslim, Müsâfirîn, 84',
        'Buhârî, Teheccüd, 31',
        'Tirmizî, Vitir, 15',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (Nafile Namazlar)',
      ],
      madhabNotes: <String>[
        'Hanefî ve Şâfiî mezheplerinde Kuşluk namazı müstehap/mendup kabul edilir; ikişer rekâtta bir selam verilmesi efdaldir.',
      ],
      related: <String>[
        'israk_namazi',
        'teheccud_gece_namazi',
        'evvabin_namazi',
      ],
      category: 'Nafile Namazlar',
    ),
    KnowledgeEntry(
      id: 'teheccud_gece_namazi',
      title: 'Teheccüd (Gece) namazı nasıl kılınır, vakti ve rekâtı nedir?',
      keywords: <String>[
        'teheccud',
        'gece namazi',
        'teheccud namazi',
        'seher namazi',
        'teheccud kac rekat',
        'teheccud vakti',
      ],
      answer:
          'Teheccüd (gece) namazı, yatsı namazından sonra biraz uyuyup gece yarısı ile '
          'imsak vakti arasında uyanılarak kılınan, farz namazlardan sonra en faziletli namazdır. '
          '2 ile 8 rekât arasında (ikişer rekâtta bir selam verilerek) kılınır.',
      details: <String>[
        'En faziletli vakti gecenin son üçte biri olan seher vaktidir (İmsak vaktinden ~60-90 dk öncesi).',
        'Niyet: "Niyet ettim Allah rızası için Teheccüd namazını kılmaya."',
        'Vitir namazı henüz kılınmadıysa Teheccüd namazının ardından Vitir namazı ile gece ibadeti tamamlanır.',
        'Vakitler ekranından Teheccüd (Seher) Alarmını aktif edebilirsiniz.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, İsrâ 17/79',
        'Kur\'an-ı Kerim, Müzzemmil 73/1-6',
        'Müslim, Sıyâm, 202',
        'Buhârî, Teheccüd, 1',
      ],
      madhabNotes: <String>[
        'Hanefîlere göre gece namazında ikişer veya dörder rekâtta bir, Şâfiîlere göre ise ikişer rekâtta bir selam verilmesi sünnettir.',
      ],
      related: <String>[
        'kusluk_duha_namazi',
        'vitir_teravih',
        'evvabin_namazi',
      ],
      category: 'Nafile Namazlar',
    ),
    KnowledgeEntry(
      id: 'evvabin_namazi',
      title: 'Evvâbîn namazı nedir, ne zaman ve kaç rekât kılınır?',
      keywords: <String>[
        'evvabin',
        'evvabin namazi',
        'aksamdan sonra nafile',
        'evvabin kac rekat',
      ],
      answer:
          'Evvâbîn namazı, akşam namazının farzı ve sünneti kılındıktan hemen sonra, '
          'yatsı vakti girmeden önce Allah\'a yönelen kulların (evvâbîn) kıldığı 2, 4 veya 6 rekâtlık nafile namazdır.',
      details: <String>[
        'Akşam namazının 2 rekât sünnetinden sonra kalkılarak 2, 4 veya 6 rekât olarak eda edilir.',
        'İkişer rekâtta bir selam verilerek kılınması daha faziletlidir.',
        'Vakitler ekranından Evvâbîn Namazı Alarmını (Akşam + 25 dk) açabilirsiniz.',
      ],
      citations: <String>[
        'Tirmizî, Mevâkît, 203',
        'İbn Mâce, İkâmet, 185',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (Evvâbîn Namazı)',
      ],
      related: <String>['kusluk_duha_namazi', 'teheccud_gece_namazi'],
      category: 'Nafile Namazlar',
    ),
    KnowledgeEntry(
      id: 'israk_namazi',
      title: 'İşrak namazı nedir, güneşten kaç dakika sonra kılınır?',
      keywords: <String>[
        'israk',
        'israk namazi',
        'israk vakti',
        'gunes dogduktan sonra namaz',
      ],
      answer:
          'İşrak namazı, sabah namazını kıldıktan sonra zikir ve tefekkürle meşgul olup '
          'güneş doğduktan ve kerahet vakti çıktıktan (yaklaşık 45-50 dakika sonra) hemen kılınan '
          '2 rekâtlık nafile namazdır (Kuşluk namazının başlangıç vaktidir).',
      details: <String>[
        'Güneş doğarken ve doğduktan sonraki ilk 45 dakika kerahet vaktidir; bu süre çıktıktan hemen sonra 2 rekât olarak kılınır.',
        'Hadis-i şerifte sabah namazını cemaatle kılıp güneş doğuncaya kadar zikirle meşgul olan ve ardından 2 rekât İşrak namazı kılan kimseye tam bir hac ve umre sevabı verileceği müjdelenmiştir.',
        'Vakitler ekranından İşrak Namazı Alarmını (Güneş + 47 dk) açabilirsiniz.',
      ],
      citations: <String>[
        'Tirmizî, Cum\'a, 59 (Hadis no: 586)',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (İşrak ve Kuşluk Namazı)',
      ],
      related: <String>['kusluk_duha_namazi', 'kerahet_vakitleri'],
      category: 'Nafile Namazlar',
    ),
    KnowledgeEntry(
      id: 'tahiyyetul_mescid',
      title: 'Tahiyyetü\'l-Mescid namazı nedir ve nasıl kılınır?',
      keywords: <String>[
        'tahiyyetul mescid',
        'tahiyyatul mescid',
        'mescid namazi',
        'camiye girince kilinan namaz',
      ],
      answer:
          'Tahiyyetü\'l-Mescid, bir camiye veya mescide girildiğinde oturmadan önce '
          'mescidin Rabbine saygı ve selamlama amacıyla kılınan 2 rekâtlık sünnet/müstehap namazdır.',
      details: <String>[
        'Kerahet vakitleri dışında camiye her girişte oturmadan önce 2 rekât olarak kılınır.',
        'Camiye girildiğinde cemaatle farz namaza başlanmışsa veya vakit namazının sünneti kılınırsa bu namaz Tahiyyetü\'l-Mescid yerine de geçer.',
        'Hutbe okunurken camiye giren kişi Hanefî mezhebine göre namaz kılmaz, oturup hutbeyi dinler; Şâfiî mezhebine göre ise kısa şekilde 2 rekât kılar.',
      ],
      citations: <String>[
        'Buhârî, Salât, 60; Teheccüd, 25',
        'Müslim, Müsâfirîn, 69-70',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1',
      ],
      madhabNotes: <String>[
        'Hanefî, Mâlikî ve Hanbelîlere göre cuma hutbesi esnasında camiye giren kişi Tahiyyetü\'l-Mescid kılmaz, hutbeyi dinler; Şâfiîlere göre ise hafif/kısa olarak 2 rekât kılar.',
      ],
      related: <String>['abdest_sukur_namazi', 'cuma_namazi'],
      category: 'Nafile Namazlar',
    ),
    KnowledgeEntry(
      id: 'abdest_sukur_namazi',
      title: 'Abdest şükür namazı nedir ve ne zaman kılınır?',
      keywords: <String>[
        'abdest sukur',
        'abdest namazi',
        'abdestten sonra namaz',
        'sukur namazi',
      ],
      answer:
          'Abdest şükür namazı, abdest veya gusül aldıktan hemen sonra, azalar henüz '
          'kurumadan (kerahet vakti değilse) kılınan 2 rekâtlık çok faziletli bir nafile namazdır.',
      details: <String>[
        'Hz. Peygamber (s.a.s.), Hz. Bilâl-i Habeşî\'ye cennette önünde ayak seslerini duyduğunu söyleyip hangi ameli yaptığını sorduğunda, Hz. Bilâl her abdest aldığında mutlaka 2 rekât namaz kıldığını belirtmiştir.',
        'Niyet: "Niyet ettim Allah rızası için abdest şükür namazı kılmaya."',
      ],
      citations: <String>[
        'Buhârî, Teheccüd, 17',
        'Müslim, Fedâilü\'s-Sahâbe, 108',
        'Ebû Dâvûd, Tahâret, 65',
      ],
      related: <String>['abdest', 'tahiyyetul_mescid'],
      category: 'Nafile Namazlar',
    ),
    KnowledgeEntry(
      id: 'bayram_namazi',
      title: 'Bayram namazı (Ramazan ve Kurban Bayramı) nasıl kılınır?',
      keywords: <String>[
        'bayram namazi',
        'ramazan bayrami namazi',
        'kurban bayrami namazi',
        'zaid tekbir',
        'bayram namazi kac rekat',
      ],
      answer:
          'Bayram namazı, Ramazan ve Kurban Bayramlarının 1. günü güneş doğup kerahet vakti '
          'çıktıktan (~45-50 dk sonra) cemaatle kılınan 2 rekâtlık namazdır ve 6 ilave (zâid) tekbir içerir.',
      details: <String>[
        '1. Rekât: İftitah tekbiri ve Sübhaneke\'den sonra eller kaldırılarak 3 kez ilave tekbir alınır (ilk ikisinde eller yana salınır, üçüncüsünde bağlanır); ardından imam açıktan Fâtiha ve sure okur.',
        '2. Rekât: İmam Fâtiha ve sureyi okuduktan sonra rükûya gitmeden önce yine eller kulak hizasına kaldırılarak 3 kez ilave tekbir alınır, dördüncü tekbirle rükûya gidilir.',
        'Namazdan sonra bayram hutbesi okunur; Kurban Bayramında Arefe günü sabah namazından bayramın 4. günü ikindi namazına kadar (23 vakit) farz namazların hemen ardından teşrik tekbirleri getirilir.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Kevser 108/2',
        'Buhârî, Îdeyn, 1-7',
        'Müslim, Salâtü\'l-Îdeyn, 1-9',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (Bayram Namazları)',
      ],
      madhabNotes: <String>[
        'Bayram namazı Hanefî mezhebine göre vâcip, Şâfiî ve Mâlikî mezheplerine göre müekked sünnet, Hanbelî mezhebine göre farz-ı kifâyedir.',
      ],
      related: <String>['cuma_namazi', 'kurban'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'cenaze_namazi',
      title: 'Cenaze namazı nasıl kılınır ve duaları nelerdir?',
      keywords: <String>[
        'cenaze namazi',
        'cenaze',
        'er kisi niyetine',
        'cenaze tekbir',
        'cenaze duasi',
      ],
      answer:
          'Cenaze namazı, rükû ve secdesi olmayan, ayakta 4 tekbirle kılınan ve vefat eden '
          'mümin için dua niteliği taşıyan farz-ı kifâye bir ibadettir.',
      details: <String>[
        '1. Tekbir: Eller kaldırılıp bağlanır, "ve celle senâük" ilavesiyle Sübhaneke okunur.',
        '2. Tekbir: Eller kaldırılmadan tekbir alınır, Salli ve Bârik duaları okunur.',
        '3. Tekbir: Eller kaldırılmadan tekbir alınır, cenaze duası (bilenmezse Rabbenâ âtinâ / الفاتحة dua niyetiyle) okunur.',
        '4. Tekbir: Eller kaldırılmadan tekbir alınır ve sağa-sola selam verilir.',
      ],
      citations: <String>[
        'Buhârî, Cenâiz, 54-65',
        'Müslim, Cenâiz, 63-85',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (Cenaze Namazı)',
      ],
      madhabNotes: <String>[
        'Hanefîlerde yalnızca ilk tekbirde eller kaldırılır; Şâfiîlerde ise dört tekbirin tamamında eller kaldırılır ve 1. tekbirden sonra Fâtiha okunur.',
      ],
      related: <String>['kabir_ziyaret', 'dua_adab'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'sehiv_secdesi',
      title: 'Sehiv (yanılma) secdesi nedir, ne zaman ve nasıl yapılır?',
      keywords: <String>[
        'sehiv secdesi',
        'sehiv',
        'namazda yanilma',
        'namazda sasirma',
        'vacipleri terk',
      ],
      answer:
          'Sehiv secdesi, namazda farzlardan birinin geciktirilmesi veya vâciplerden birinin '
          'unutularak terk edilmesi/geciktirilmesi durumunda namazın sonunda yapılan iki secdedir.',
      details: <String>[
        'Nasıl yapılır (Hanefî): Son oturuşta yalnız Ettehiyyâtü okunduktan sonra sağa (veya iki tarafa) selam verilir, hemen "Allâhu ekber" diyerek peş peşe iki secde yapılır; tekrar oturulup Ettehiyyâtü, Salli-Bârik ve Rabbenâ duaları okunarak iki tarafa selam verilir.',
        'Gerektiren başlıca durumlar: Fâtiha\'yı veya zamm-ı sureyi unutmak, ilk oturuşu unutarak üçüncü rekâta kalkmak, Kunut dualarını veya vitir/bayram tekbirlerini unutmak.',
      ],
      citations: <String>[
        'Buhârî, Sehv, 1-9',
        'Müslim, Mesâcid, 85-102',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (Sehiv Secdesi)',
      ],
      madhabNotes: <String>[
        'Hanefîlerde selamdan sonra, Şâfiîlerde ise son oturuşta selam vermeden hemen önce iki secde yapılır.',
      ],
      related: <String>['namazin_sartlari', 'namazi_bozanlar'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'tilavet_secdesi',
      title: 'Tilâvet secdesi nedir ve nasıl yapılır?',
      keywords: <String>[
        'tilavet secdesi',
        'secde ayeti',
        'kuran secde',
        'tilavet',
      ],
      answer:
          'Tilâvet secdesi, Kur\'an-ı Kerim\'deki 14 secde ayetinden biri okunduğunda veya '
          'dinlendiğinde abdestli ve kıbleye dönük olarak yapılan tek secdedir.',
      details: <String>[
        'Eller kaldırılmadan "Allâhu ekber" diyerek doğrudan secdeye gidilir, üç kez "Sübhâne Rabbiye\'l-a\'lâ" denir ve "Allâhu ekber" diyerek kalkılır; kalkarken "Gufrâneke Rabbenâ ve ileyke\'l-masîr" denmesi müstehaptır.',
        'Secde ayetlerinin bulunduğu 14 sure: A\'râf (206), Ra\'d (15), Nahl (49), İsrâ (107), Meryem (58), Hac (18), Furkân (60), Neml (25), Secde (15), Sâd (24), Fussilet (37), Necm (62), İnşikâk (21), Alak (19).',
      ],
      citations: <String>[
        'Buhârî, Sücûdü\'l-Kur\'ân, 1-12',
        'Müslim, Mesâcid, 103-114',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1',
      ],
      madhabNotes: <String>[
        'Tilâvet secdesi Hanefî mezhebine göre vâcip, Şâfiî ve Hanbelî mezheplerine göre sünnettir.',
      ],
      related: <String>['kuran_okuma', 'sehiv_secdesi'],
      category: 'Kur\'an',
    ),
    KnowledgeEntry(
      id: 'istihare_namazi',
      title: 'İstihare namazı ve duası nasıl yapılır?',
      keywords: <String>[
        'istihare',
        'istihare namazi',
        'istihare duasi',
        'hayirlisini istemek',
      ],
      answer:
          'İstihare, mübah olan önemli bir işin (evlilik, iş, yolculuk vb.) hakkında hayırlı '
          'olup olmadığını Allah\'tan dilemek için 2 rekât nafile namaz kılıp istihare duasını okumaktır.',
      details: <String>[
        'Önce konu hakkında bilenlerle istişare (danışma) yapılır, ardından 2 rekât istihare namazı kılınır (1. rekâtta Kâfirûn, 2. rekâtta İhlâs suresi okunması müstehaptır).',
        'Namazdan sonra Peygamber Efendimiz\'in öğrettiği "Allâhümme innî estehîrüke bi-ilmike..." istihare duası okunur.',
        'İstiharede mutlaka rüya görmek şart değildir; dua sonrası kalbin meylettiği ve gönül ferahlığı oluşan yön tercih edilir.',
      ],
      citations: <String>[
        'Buhârî, Teheccüd, 25; Deavât, 48',
        'Tirmizî, Vitir, 18',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (İstihare Namazı)',
      ],
      related: <String>['hacet_tovbe_namazi', 'dua_adab'],
      category: 'Nafile Namazlar',
    ),
    KnowledgeEntry(
      id: 'hacet_tovbe_namazi',
      title: 'Hacet namazı ve Tövbe namazı nasıl kılınır?',
      keywords: <String>[
        'hacet namazi',
        'tovbe namazi',
        'hacet duasi',
        'dilek namazi',
        'istigfar namazi',
      ],
      answer:
          'Hacet namazı dünyevî veya uhrevî bir dileğin gerçekleşmesi için 2 veya 4 rekât olarak; '
          'Tövbe namazı ise işlenen bir günahtan pişmanlık duyup af dilemek için 2 rekât olarak kılınan nafile namazlardır.',
      details: <String>[
        'Hacet namazından sonra Allah\'a hamd ve Resûlullah\'a salavat getirilerek hacet duası okunur.',
        'Tövbe namazında güzelce abdest alınıp 2 rekât namaz kılınır ve bir daha günaha dönmemeye azmedilerek istiğfar edilir.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Bakara 2/45, 153',
        'Tirmizî, Salât, 181; Vitir, 17',
        'Ebû Dâvûd, Vitir, 26',
      ],
      related: <String>['istihare_namazi', 'kul_hakki_tovbe'],
      category: 'Nafile Namazlar',
    ),
    KnowledgeEntry(
      id: 'tesbih_namazi',
      title: 'Tesbih namazı nasıl kılınır ve kaç rekâttır?',
      keywords: <String>[
        'tesbih namazi',
        'tesbih namazi nasil kilinir',
        '300 tesbih',
      ],
      answer:
          'Tesbih namazı, her rekâtında 75\'er defa olmak üzere toplam 300 defa '
          '"Sübhânallâhi ve\'l-hamdü lillâhi ve lâ ilâhe illallâhü vallâhu ekber" tesbihi okunarak kılınan 4 rekâtlık mendup bir nafile namazdır.',
      details: <String>[
        'Her rekâtta: Sübhaneke\'den sonra 15, zamm-ı sureden sonra ayakta 10, rükûda 10, rükûdan kalkınca 10, birinci secdede 10, iki secde arasında 10, ikinci secdede 10 kez (toplam 75 kez) tesbih okunur.',
        'Ömürde en az bir kez, mümkünse yılda, ayda veya haftada bir kılınması tavsiye edilmiştir.',
      ],
      citations: <String>[
        'Ebû Dâvûd, Tatavvu, 14',
        'Tirmizî, Vitir, 19',
        'İbn Mâce, İkâmet, 190',
      ],
      related: <String>['teheccud_gece_namazi', 'kadir_gecesi'],
      category: 'Nafile Namazlar',
    ),
    KnowledgeEntry(
      id: 'kerahet_vakitleri',
      title: 'Kerahet vakitleri (namaz kılınmayan vakitler) hangileridir?',
      keywords: <String>[
        'kerahet',
        'kerahet vakti',
        'kerahet vakitleri',
        'mekruh vakitler',
        'namaz kilinmayan saatler',
      ],
      answer:
          'Günün 3 vaktinde farz ve nafile hiçbir namaz kılınmaz (kerahet-i tahrîmiyye): '
          '1) Güneşin doğmasından itibaren yaklaşık 45-50 dakika, '
          '2) Güneş tam tepe noktasındayken (öğle ezanından önceki ~40-45 dakika — istivâ vakti), '
          '3) Güneşin sararıp batmaya yüz tutmasından akşam ezanına kadar olan ~45 dakika (yalnızca o günün ikindi farzı kılınabilir).',
      details: <String>[
        'Ayrıca imsak vaktinden güneş doğuncaya kadar sabah namazının sünneti dışında nafile namaz kılınmaz; ikindi farzından akşam ezanına kadar da nafile namaz kılınmaz (kaza namazı bu iki aralıkta kılınabilir, ancak 3 ana kerahet vaktinde kaza da kılınmaz).',
        'Güneş doğduktan ~47 dk sonra kerahet çıkar ve İşrak / Kuşluk vakti başlar.',
      ],
      citations: <String>[
        'Müslim, Müsâfirîn, 293',
        'Buhârî, Mevâkît, 30-31',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (Kerahet Vakitleri)',
      ],
      madhabNotes: <String>[
        'Şâfiî mezhebinde sebebi bulunan namazlar (Tahiyyetü\'l-Mescid, kaza namazı) kerahet vakitlerinde de kılınabilir; Hanefî mezhebinde ise 3 ana kerahet vaktinde kaza ve cenaze namazı dahil hiçbir namaz kılınmaz.',
      ],
      related: <String>['israk_namazi', 'kusluk_duha_namazi', 'kaza_namaz'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'abdesti_bozanlar',
      title: 'Abdesti bozan ve bozmayan durumlar nelerdir?',
      keywords: <String>[
        'abdesti bozan',
        'abdest bozulur mu',
        'kan abdesti bozar mi',
        'uyumak abdesti bozar mi',
        'aglamak abdesti bozar mi',
        'oje abdest',
        'dis dolgusu',
      ],
      answer:
          'Önden ve arkadan çıkan idrar, dışkı, yel, akıntı; ağız dolusu kusmak; '
          'uzanarak veya bir yere yaslanarak uyumak; bayılmak ve namazda yanındakinin duyacağı kadar gülmek (Hanefî\'de) abdesti bozar.',
      details: <String>[
        'Vücuttan çıkıp etrafına dağılan kan, irin ve sarı su Hanefî mezhebine göre abdesti bozar; Şâfiî mezhebine göre ise ön ve arka yol dışında vücuttan çıkan kan abdesti bozmaz.',
        'Ağlamak (gözyaşı), tırnak kesmek, saç tıraşı olmak, ağız dolusu olmayan kusmuk ve çıkmayıp yerinde kalan kan damlası abdesti bozmaz.',
        'Tırnak üzerindeki oje gibi su geçirmeyen tabakalar abdest ve gusle engeldir; ancak tedavi amaçlı diş dolgusu ve kaplama gusle/abdeste engel değildir.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Mâide 5/6',
        'Buhârî, Vudû, 34; Müslim, Hayz, 84-99',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (Abdesti Bozan Şeyler)',
      ],
      madhabNotes: <String>[
        'Hanefîlere göre vücuttan akıp yayılan kan abdesti bozar, karşı cinse dokunmak bozmaz; Şâfiîlere göre ise kan akması abdesti bozmaz, mahrem olmayan karşı cinse engelsiz ten teması abdesti bozar.',
      ],
      related: <String>['abdest', 'gusul', 'teyemmum'],
      category: 'Fıkıh',
    ),
    KnowledgeEntry(
      id: 'namazi_bozanlar',
      title: 'Namazı bozan durumlar nelerdir?',
      keywords: <String>[
        'namazi bozan',
        'namaz bozulur mu',
        'namazda konusmak',
        'namazda gulmek',
        'namazda aglamak',
      ],
      answer:
          'Namaz içindeyken konuşmak, bir şey yemek-içmek, kıbleden göğsü çevirmek, '
          'abdestin bozulması, özürsüz öksürük/ah-oh çekmek, dışarıdan bakanın namazda olmadığını sanacağı kadar hareket etmek (amel-i kesîr) namazı bozar.',
      details: <String>[
        'Allah korkusu, cennet veya cehennem düşüncesiyle sessizce ağlamak namazı bozmaz; dünya acısı veya ağrısı sebebiyle sesli ağlamak namazı bozar.',
        'Namazda önünden birinin geçmesi namazı bozmaz, ancak geçen kişi günaha girer; sütre koymak sünnettir.',
      ],
      citations: <String>[
        'Buhârî, Amel fi\'s-Salât, 1-18',
        'Müslim, Mesâcid, 33',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (Namazı Bozan Şeyler)',
      ],
      related: <String>['namazin_sartlari', 'sehiv_secdesi'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'cemaat_imama_uyma',
      title:
          'Cemaatle namaz ve imama sonradan yetişme (mesbuk) nasıl tamamlanır?',
      keywords: <String>[
        'mesbuk',
        'imama uymak',
        'cemaate sonradan yetismek',
        'ikinci rekata yetismek',
        'ucuncu rekata yetismek',
      ],
      answer:
          'İmama rükûda yetişen kişi o rekâta yetişmiş sayılır; sonradan yetişen (mesbuk), '
          'imam son oturuşta sağa selam verdikten sonra selam vermeden ayağa kalkar ve kaçırdığı rekâtları tek başına tamamlar.',
      details: <String>[
        '1 rekât kaçıran: İmam selam verince kalkar, Sübhaneke + Eûzü-Besmele + Fâtiha + zamm-ı sure okuyup rükû ve secdesini yapar, oturup duaları okuyarak selam verir.',
        '2 rekât kaçıran: Kalkıp iki rekâtı Fâtiha ve sure ile kılar (akşam namazında 2 rekât kaçıran kişi, kalktığı ilk rekâttan sonra bir kez oturup Ettehiyyâtü okur çünkü o onun ikinci rekâtıdır).',
        '3 rekât kaçıran (4 rekâtlı namazda): Kalkar, 1. rekâtı Fâtiha+sure ile kılar ve oturup Ettehiyyâtü okur; sonra kalkıp 2. rekâtı Fâtiha+sure ile, 3. rekâtı yalnız Fâtiha ile kılar ve son oturuşla tamamlar.',
      ],
      citations: <String>[
        'Buhârî, Ezân, 21; Müslim, Mesâcid, 151',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (Mesbukun Namazı)',
      ],
      related: <String>['cuma_namazi', 'namaz_rekat'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'namaz_dualari_sure_sirasi',
      title: 'Namazda okunan dualar ve kısa surelerin sırası nasıldır?',
      keywords: <String>[
        'sure sirasi',
        'namaz sureleri',
        'fil kureys maun kevser',
        'subhaneke ettehiyyatu',
        'kunut duasi',
      ],
      answer:
          'Namazda zamm-ı surelerin Mushaf\'taki sırasına (tertibine) uyularak okunması vâcip/müstehaptır: '
          'Asr → Hümeze → Fîl → Kureyş → Mâûn → Kevser → Kâfirûn → Nasr → Tebbet → İhlâs → Felak → Nâs.',
      details: <String>[
        'İkinci rekâtta birinci rekâtta okunan sureden daha önceki (üstteki) bir sureyi okumak mekruhtur (yanlışlıkla okunursa namaz bozulmaz ve sehiv secdesi gerekmez).',
        'Oturuşlarda sırasıyla: İlk oturuşta yalnız Ettehiyyâtü; son oturuşta Ettehiyyâtü + Allâhümme Salli + Allâhümme Bârik + Rabbenâ âtinâ ve Rabbenâğfirlî duaları okunur.',
      ],
      citations: <String>[
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (Kıraat ve Tertip)',
      ],
      related: <String>['namazin_sartlari', 'sehiv_secdesi'],
      category: 'Namaz',
    ),
    KnowledgeEntry(
      id: 'kaza_kefaret_fidye_oruc',
      title: 'Kaza orucu, kefaret orucu ve oruç fidyesi nedir?',
      keywords: <String>[
        'kaza orucu',
        'kefaret orucu',
        'fidye',
        'oruc fidyesi',
        '61 gun',
      ],
      answer:
          'Yolculuk, hastalık veya özel hâl gibi meşru bir mazeretle tutulamayan veya yanılarak bozulan '
          'Ramazan oruçları için gününe gün (1 gün) kaza gerekir; mazeretsiz olarak bilerek yeme-içme ile '
          'başlanmış Ramazan orucunu bozmak ise Hanefî\'ye göre hem 1 gün kaza hem 60 gün aralıksız kefaret gerektirir.',
      details: <String>[
        'Oruç Fidyesi: İyileşme ümidi olmayan kronik hastalar ve oruç tutamayacak kadar yaşlı kimseler, tutamadıkları her gün için bir fakiri doyuracak miktarda (fitre tutarında) fidye verirler.',
        'Uygulamanın "Kaza Takibi" ekranından kaza oruçlarınızı ve namazlarınızı kolayca takip edebilirsiniz.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Bakara 2/184-185',
        'Buhârî, Savm, 30; Müslim, Sıyâm, 81',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1 (Oruç Kefareti ve Fidye)',
      ],
      madhabNotes: <String>[
        'Hanefî ve Mâlikîlere göre mazeretsiz bilerek yeme-içme de kefaret gerektirir; Şâfiî ve Hanbelîlere göre ise yalnızca Ramazan orucunu cinsel ilişkiyle bozmak kefaret, yeme-içmeyle bozmak ise tövbe ve kaza gerektirir.',
      ],
      related: <String>['oruc_bozan', 'imsak_orucu', 'fitre'],
      category: 'Ramazan',
    ),
    KnowledgeEntry(
      id: 'adak_yemin_kefareti',
      title: 'Adak (nezir) ve yemin kefareti nedir?',
      keywords: <String>[
        'adak',
        'nezir',
        'yemin kefareti',
        'yemin bozmak',
        'adak kurbani',
      ],
      answer:
          'Adak (nezir), kişinin dinen yükümlü olmadığı ibadet cinsinden bir ameli Allah\'a söz vererek '
          'kendisine vâcip kılmasıdır; şart gerçekleştiğinde yerine getirilmesi vâciptir. '
          'Yemin kefareti ise Allah adına yapılan bir yeminin bozulması hâlinde 10 fakiri doyurmak/giydirmek, '
          'buna gücü yetmezse 3 gün oruç tutmaktır.',
      details: <String>[
        'Adak kurbanının etinden adayan kişi, eşi, anne-babası, dede-nineleri, çocukları ve torunları yiyemez; tamamı ihtiyaç sahiplerine dağıtılır.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Mâide 5/89; İnsan 76/7',
        'Buhârî, Eymân, 1-28',
        'Diyanet İşleri Başkanlığı İlmihali, Cilt 1-2',
      ],
      related: <String>['kurban', 'zekat'],
      category: 'Fıkıh',
    ),
    KnowledgeEntry(
      id: 'kul_hakki_tovbe',
      title: 'Kul hakkı, gıybet ve tövbe-istiğfar şartları nelerdir?',
      keywords: <String>[
        'kul hakki',
        'giybet',
        'dedikodu',
        'helallesmek',
        'tovbe sartlari',
      ],
      answer:
          'Allah kendi hakkı olan günahları samimi tövbe (nasûh tövbesi) ile bağışlar; ancak '
          'kul hakkı içeren günahlarda (haksız kazanç, gıybet, iftira, kalp kırma) tövbenin kabulü için '
          'hak sahibiyle helalleşmek ve maddi hakkı iade etmek şarttır.',
      details: <String>[
        'Tövbenin 4 şartı: 1) Günahı derhal terk etmek, 2) Yaptığına kalpten pişman olmak, 3) Bir daha dönmemeye azmetmek, 4) Kul hakkı varsa helalleşmek.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Hucurât 49/12; Tahrîm 66/8',
        'Buhârî, Mezâlim, 10; Rikâk, 48',
        'Müslim, Birr, 59',
      ],
      related: <String>['hacet_tovbe_namazi', 'faiz_ticaret'],
      category: 'Ahlak',
    ),
    KnowledgeEntry(
      id: 'nazar_korunma_dualari',
      title: 'Nazar ve korunma duaları hakkında İslam\'ın ölçüsü nedir?',
      keywords: <String>[
        'nazar',
        'nazar duasi',
        'buyu',
        'korunma duasi',
        'felak nas',
        'ayetel kursi',
      ],
      answer:
          'Nazar (göz değmesi) hadis-i şeriflerle sabit bir hakikattir; korunmak için Kur\'an\'dan '
          'Fâtiha, Âyetü\'l-Kürsî (Bakara 255), Kalem Suresi 51-52. ayetler ve Muavvizeteyn (İhlâs, Felak, Nâs) '
          'surelerini okumak ve Allah\'a sığınmak sünnettir.',
      details: <String>[
        'Nazar boncuğu, kurşun döktürmek veya muska/falcılardan medet ummak İslam\'da caiz değildir; şifa ve koruma yalnızca Allah\'tan beklenir.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Kalem 68/51-52; Felak 113/1-5; Nâs 114/1-6',
        'Buhârî, Tıb, 36; Müslim, Selâm, 41-42',
        'Diyanet İşleri Başkanlığı Din İşleri Yüksek Kurulu Kararları',
      ],
      related: <String>['dua_adab', 'kuran_okuma'],
      category: 'Dua',
    ),
  ];

  /// Kullanıcıya önerilen örnek sorular.
  static const List<String> suggestedQuestions = <String>[
    'Kuşluk (Duha) namazı nasıl kılınır, vakti ve rekâtı nedir?',
    'Teheccüd (Gece) namazı nasıl kılınır, vakti ve rekâtı nedir?',
    'Evvâbîn namazı nedir, ne zaman ve kaç rekât kılınır?',
    'İşrak namazı nedir, güneşten kaç dakika sonra kılınır?',
    'Tahiyyetü\'l-Mescid namazı nedir ve nasıl kılınır?',
    'Abdest şükür namazı nedir ve ne zaman kılınır?',
    'Bayram namazı (Ramazan ve Kurban Bayramı) nasıl kılınır?',
    'Sehiv (yanılma) secdesi nedir, ne zaman ve nasıl yapılır?',
    'İslam\'ın şartları nelerdir?',
    'İmanın şartları nelerdir?',
    'Abdesti bozan ve bozmayan durumlar nelerdir?',
    'Kerahet vakitleri (namaz kılınmayan vakitler) hangileridir?',
    'Cemaatle namaz ve imama sonradan yetişme (mesbuk) nasıl tamamlanır?',
    'Kaza orucu, kefaret orucu ve oruç fidyesi nedir?',
  ];

  static List<KnowledgeEntry> byCategory(String category) =>
      entries.where((KnowledgeEntry e) => e.category == category).toList();

  static List<String> get categories {
    final Set<String> values = <String>{
      for (final KnowledgeEntry e in entries) e.category,
    };
    return values.toList()..sort();
  }
}
