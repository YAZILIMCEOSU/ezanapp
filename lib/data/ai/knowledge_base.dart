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
  static const List<KnowledgeEntry> entries = <KnowledgeEntry>[
    KnowledgeEntry(
      id: 'namaz_rekat',
      title: 'Vakit namazları kaç rekâttır?',
      keywords: <String>[
        'namaz',
        'rekat',
        'rekatları',
        'kac rekat',
        'aksam namazi',
        'sabah namazi',
        'yatsi',
        'ikindi',
        'ogle'
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
        'gustül',
        'gusul',
        'teyemmum'
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
      id: 'imsak_orucu',
      title: 'Oruç ne zaman başlar, imsak ne demektir?',
      keywords: <String>[
        'imsak',
        'oruc',
        'ifta',
        'sahur',
        'oruc ne zaman',
        'imsak vakti'
      ],
      answer:
          'Oruç, imsak vaktiyle başlar ve akşam (güneşin batışı) ile biter. '
          'İmsak, tan yerinin ağarmaya başlamasından (fe cr-i sâdık) bir süre önceki tedbirli vakittir.',
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
        'kasıtlı',
        'unutusuz'
      ],
      answer: 'Orucu bozan başlıca durumlar: yeme-içme, cinsel ilişki, '
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
        'uyandim gecti'
      ],
      answer:
          'Vakti geçen namaz kaza edilir. Sabah namazı için: hatırlar hatırlamaz '
          '2 rekât farz kılınır; sünneti kaza edilmez (Hanefî’ye göre).',
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
        'Hanefî: kazada sünnetler de kaza edilirken farzlarla birlikte kılınabilir, sabah sünneti kaza edilmez.',
        'Şâfiî: kaza namazlarında sünnet kılınmaz, yalnızca farz kaza edilir.',
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
        'seferi namaz'
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
        'cumа farz',
        'cuma kilinmaz'
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
      id: 'zekat',
      title: 'Zekât oranı ve nisab nedir?',
      keywords: <String>[
        'zekat',
        'nisab',
        'zekat orani',
        'kirkta bir',
        'fitre',
        'sadaka'
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
      id: 'vitir_teravih',
      title: 'Vitir ve teravih namazı kaç rekâttır?',
      keywords: <String>['vitir', 'teravih', 'gece namazi', 'teheccud'],
      answer: 'Vitir 3 rekâttır ve yatsıdan sonra kılınır. Teravih 20 rekâttır '
          '(Hanefî’de sünnet), Ramazan’da yatsıdan sonra kılınır.',
      details: <String>[
        'Teravih 2’şer rekât hâlinde kılınır; 20 rekât genel kabuldür.',
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
          'Kadir gecesi Ramazan’ın son on gününde, özellikle 27. gecesinde aranır; '
          'bin aydan hayırlıdır.',
      details: <String>[
        'Bu geceyi namaz, Kur\'an okuma, zikir ve dua ile geçirmek tavsiye edilir.',
        'Peygamberimizin öğrettiği dua: "Allâhümme inneke afüvvün tuhibbü’l-afve fa’fü annî".',
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
        'Haccın farz olması için: Müslüman, akıl-bâliğ, hür, sağlıklı ve maddî güç.',
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
          'Kurban, Hanefî’ye göre nisab sahibi ve mukim olan kişiye vacibdir; '
          'Kurban Bayramı’nın ilk üç gününde kesilir.',
      details: <String>[
        'Koyun-keçi: bir kişi için; sığır-deve: yedi kişiye kadar ortak olunabilir.',
        'Kurban edilecek hayvanın sağlıklı ve yaşı uygun olmalıdır (koyun 1, sığır 2, deve 5 yaş).',
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
          'Dua; ihlasla, helâl lokmayla, hamd ve salavatla başlayıp bitirilerek, '
          'kıbleye yönelip yüksek sesle olmayacak şekilde yapılır.',
      details: <String>[
        'Kabulün gecikmesi, duanın reddedildiği anlamına gelmez.',
        'Kabule engel: haram kazanç, aceleci tutum ("duam kabul olmadı" demek).',
        'Sevilen vakitler: seher, iki hutbe arası, Ramazan, Kadir gecesi, ezan ile kamet arası.',
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
        'kurani kerim'
      ],
      answer:
          'Kur\'an okumak en faziletli zikirlerdendir; her harfine ayrı sevap vardır. '
          'Abdestli olmak, saygıyla ve anlamını düşünerek okumak âdâbtır.',
      details: <String>[
        'Hatim: Kur\'an’ın tamamını okumak; Ramazan’da geleneksel olarak tamamlanır.',
        'Meal okumak anlamı anlamaya yardımcıdır, Kur\'an hükmü yerine geçmez.',
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
      keywords: <String>['hatim', 'hatim takibi', 'cuz', 'kac cuz'],
      answer:
          'Kur\'an 30 cüze ayrılmıştır. Günde bir cüz okuyarak bir ayda hatim tamamlanır; '
          'uygulamadaki Hatim Takibi bölümünden cüz durumunuzu işaretleyebilirsiniz.',
      details: <String>[
        'Cüz başlangıçları sure/ayet numarasıyla bellidir (ör. 1. cüz: Fâtiha-Bakara 141).',
        'Hatim sonunda dua etmek müstehaptır.',
        'Yarıda kalan hatim, kaldığınız yerden devam edilerek tamamlanabilir.',
      ],
      citations: <String>[
        'Tirmizî, Kırâât 13; Dârimî, Fedâilü\'l-Kur\'ân 33',
      ],
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
        'kabe yonu',
        'namaz yonum'
      ],
      answer:
          'Türkiye’den Kâbe güneydoğu yönündedir (İstanbul için yaklaşık 152°, '
          'Ankara için yaklaşık 160°). Uygulamadaki Kıble ekranı pusula ile bu yönü gösterir.',
      details: <String>[
        'Pusula doğruluğu için telefonu 8 çizer gibi hareket ettirerek kalibre edin.',
        'Metâl eşyalardan ve mıknatıslardan uzak durun.',
        'Pusula yoksa güneşin konumundan da yön bulunabilir.',
      ],
      citations: <String>[
        'Kur\'an-ı Kerim, Bakara 2/144',
      ],
      related: <String>['namaz_rekat'],
      category: 'Kıble',
    ),
    KnowledgeEntry(
      id: 'kabir_ziyaret',
      title: 'Kabir ziyareti caiz mi, nasıl yapılır?',
      keywords: <String>['kabir', 'kabir ziyareti', 'mezarlik', 'ziyaret'],
      answer:
          'Kabir ziyareti sünnettir; ölümü hatırlatır ve ahirete hazırlığı artırır. '
          'Kabrin karşısında ayakta dua edilir; kabirden bir şey istenmez.',
      details: <String>[
        'Ziyaret eden kişi: "Esselâmü aleyküm ehle’d-diyâri mine’l-mü’minîn…" der.',
        'Kabir üzerine taş dikmek, üzerine basmamak, mezbeleyi temiz tutmak âdâbtır.',
        'Ölüden medet ummak, kurban kesip adakta bulunmak dinen caiz değildir.',
      ],
      citations: <String>[
        'Müslim, Cenâiz 104',
        'İbn Mâce, Cenâiz 47',
      ],
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
        'enflasyon'
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
        'büyük hâl'
      ],
      answer:
          'Hayız ve nifas (lohusalık) hâlinde kılınmamış namazlar kaza edilmez, '
          'tutulamayan oruçlar ise kaza edilir.',
      details: <String>[
        'Bu hâllerde Kur\'an’a el sürmemek/harften okumamak gerekir; dua ve zikir serbesttir.',
        'Hâl sona erince gusül ile ibadetlere dönülür.',
        'İbadet vakitlerinin takibi uygulamadan hatırlatılabilir.',
      ],
      citations: <String>[
        'Müslim, Hayz 65-69; Buhârî, Hayz 6',
      ],
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
        'regi̇b',
        'berat',
        'mirac',
        'kutlama'
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
        'vakitler nasil'
      ],
      answer: 'Vakitler, güneşin konumuna göre astronomik olarak hesaplanır; '
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
  ];

  /// Kullanıcıya önerilen örnek sorular.
  static const List<String> suggestedQuestions = <String>[
    'Akşam namazı kaç rekât?',
    'Abdest nasıl alınır?',
    'Sabah namazını kaçırdım ne yapmalıyım?',
    'Bugün iftar saat kaçta?',
    'Seferi namaz nasıl kılınır?',
    'Kıble yönü nasıl bulunur?',
    'Zekât oranı nedir?',
    'Kadir gecesi ne zaman?',
  ];

  static List<KnowledgeEntry> byCategory(String category) =>
      entries.where((KnowledgeEntry e) => e.category == category).toList();

  static List<String> get categories {
    final Set<String> values = <String>{
      for (final KnowledgeEntry e in entries) e.category
    };
    return values.toList()..sort();
  }
}
