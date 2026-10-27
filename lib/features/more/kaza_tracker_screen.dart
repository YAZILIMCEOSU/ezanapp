import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_theme.dart';
import '../../state/providers.dart';
import '../widgets/speak_button.dart';

/// Tekil hutbe / Cuma rehberi modeli.
@immutable
class KhutbahItem {
  const KhutbahItem({
    required this.id,
    required this.category,
    required this.title,
    required this.arabicHeader,
    required this.verseOrHadith,
    required this.summary,
    required this.fullText,
    required this.source,
  });

  final String id;
  final String category;
  final String title;
  final String arabicHeader;
  final String verseOrHadith;
  final String summary;
  final String fullText;
  final String source;
}

/// Kaza namazı/orucu takibi ve kapsamlı Cuma/Bayram hutbeleri ekranı.
class KazaTrackerScreen extends ConsumerStatefulWidget {
  const KazaTrackerScreen({super.key, this.initialTab = 0});

  final int initialTab;

  /// Kategoriler.
  static const List<String> categories = <String>[
    'Tümü',
    'İbadet & Namaz',
    'Ahlak & Takva',
    'Aile & Toplum',
    'Helal Kazanç & Kul Hakkı',
    'Kur\'an & Sünnet',
    'Mübarek Gün & Bayram',
    'Vatan & Kardeşlik',
    'Cuma Mesajları & Sünnetleri',
  ];

  /// 32 kapsamlı Diyanet üslubunda Cuma, Bayram ve Kandil hutbesi arşivi.
  static const List<KhutbahItem> khutbahCatalog = <KhutbahItem>[
    // 1. İBADET & NAMAZ (5)
    KhutbahItem(
      id: 'ibadet_namaz_mirac',
      category: 'İbadet & Namaz',
      title: 'Cuma Hutbesi: Namaz — Müminin Miracı ve Huzur Kaynağı',
      arabicHeader: 'إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ',
      verseOrHadith: '“Şüphesiz namaz, insanı hayasızlıktan ve kötülükten alıkoyar.” (Ankebût, 29/45) · “Namaz dinin direğidir.” (Tirmizî, Îmân, 8)',
      summary: 'Namaz, kulun Rabbiyle günde beş vakit buluşması, ruhun dinlenmesi ve kötülüklerden arınmasıdır.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Okuduğum âyet-i kerîmede Yüce Rabbimiz, namazın mümini her türlü kötülükten ve çirkinlikten koruyan bir kalkan olduğunu haber vermektedir. Sevgili Peygamberimiz (s.a.v.) ise namazı gözünün nuru ve dinin direği olarak nitelendirmiştir.\n\n'
          'Aziz Müminler!\n'
          'Günde beş vakit okunan ezan-ı Muhammedi, bizleri dünya telaşından sıyrılıp Rabbimizin huzuruna davet eder. Abdestle maddi ve manevi kirlerden arınan mümin, kıbleye yönelerek “Allâhü Ekber” dediğinde bütün dünyevi endişeleri elinin tersiyle geride bırakır. Kıyamda doğruluk, rükûda tevazu, secdede ise Rabbine en yakın olmanın huzurunu yaşar.\n\n'
          'Kıymetli Kardeşlerim!\n'
          'Namazlarımızı yalnız kendi nefsimiz için değil, ailemiz ve evlatlarımız için de hayat pınarı kılalım. “Ehline namazı emret ve kendin de ona sabırla devam et” (Tâhâ, 20/132) ilahi emrine uyarak hanelerimizi namazla nurlandıralım. Hutbemi, İbrahim (a.s.)’ın duasıyla bitiriyorum: “Ey Rabbim! Beni ve soyumdan gelecekleri namazı dosdoğru kılanlardan eyle! Dualarımızı kabul buyur!”',
      source: 'Ankebût Suresi, 45 · Tâhâ Suresi, 132 · Buhârî, Mevâkît, 5',
    ),
    KhutbahItem(
      id: 'ibadet_cuma_fazileti',
      category: 'İbadet & Namaz',
      title: 'Cuma Hutbesi: Cuma Gününün Bereketi ve Cemaat Şuuru',
      arabicHeader: 'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا نُودِيَ لِلصَّلَاةِ مِن يَوْمِ الْجُمُعَةِ فَاسْعَوْا إِلَىٰ ذِكْرِ اللَّهِ',
      verseOrHadith: '“Ey iman edenler! Cuma günü namaz için çağrı yapıldığı zaman, hemen Allah’ın zikrine koşun ve alışverişi bırakın.” (Cum’a, 62/9)',
      summary: 'Cuma, müminlerin haftalık bayramı, duaların kabul olduğu icâbet saatinin bulunduğu mübarek toplanma günüdür.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Üzerine güneşin doğduğu en hayırlı gün olan Cuma gününe bizleri bir kez daha kavuşturan Yüce Rabbimize hamdolsun. Cuma; müminlerin omuz omuza saf tuttuğu, gönüllerin birleştiği haftalık bayramımızdır.\n\n'
          'Aziz Kardeşlerim!\n'
          'Peygamber Efendimiz (s.a.v.), Cuma gününde öyle bir saat vardır ki mümin kul o saatte Allah’tan hayırlı bir şey isterse Allah ona istediğini mutlaka verir buyurmuştur. Cuma ezanı okunduğunda dünyevi meşguliyetlere ara verip camiye koşmak, hutbeyi can kulağıyla dinlemek ve kardeşlerimizle selamlaşmak imanımızın gereğidir.\n\n'
          'Geliniz, bu mübarek Cuma gününü tövbe, istiğfar, salavat-ı şerife ve Kehf Suresi tilavetiyle ihya edelim; kırgınlıkları giderip gönülleri yapalım. Rabbimiz Cumamızı mübarek, ibadetlerimizi makbul eylesin.',
      source: 'Cum\'a Suresi, 9–10 · Müslim, Cum\'a, 13',
    ),
    KhutbahItem(
      id: 'ibadet_cami_cemaat',
      category: 'İbadet & Namaz',
      title: 'Cuma Hutbesi: Camilerimiz — Şehrin Kalbi ve Kardeşlik Ocağı',
      arabicHeader: 'إِنَّمَا يَعْمُرُ مَسَاجِدَ اللَّهِ مَنْ آمَنَ بِاللَّهِ وَالْيَوْمِ الْآخِرِ',
      verseOrHadith: '“Allah’ın mescitlerini ancak Allah’a ve ahiret gününe iman eden, namazı dosdoğru kılan, zekâtı veren ve Allah’tan başkasından korkmayan kimseler imar eder.” (Tevbe, 9/18)',
      summary: 'Camiler sadece taş ve tuğladan ibaret yapılar değil; cemaatle ve çocuk sesleriyle şenlenen ilim ve kardeşlik merkezleridir.',
      fullText:
          'Aziz Müminler!\n'
          'Mescitler ve camiler, yeryüzünde Allah’a en sevimli mekânlar, Kâbe-i Muazzama’nın birer şubesidir. Bir beldede yükselen minareler ve okunan ezanlar, o beldenin İslam yurdu olduğunun en gür şahididir.\n\n'
          'Kıymetli Müslümanlar!\n'
          'Camileri imar etmek yalnızca maddi inşaatla değil; saflarını müminlerle doldurmakla, gençlerimizi ve çocuklarımızı caminin huzur iklimiyle buluşturmakla mümkündür. Cemaatle kılınan namazın tek başına kılınan namazdan yirmi yedi derece daha faziletli olduğunu unutmayalım. Çocuklarımızı camide tebessümle karşılayalım ki kalpleri secdeyle büyüsün.',
      source: 'Tevbe Suresi, 18 · Buhârî, Ezân, 30',
    ),
    KhutbahItem(
      id: 'ibadet_zekat_infak',
      category: 'İbadet & Namaz',
      title: 'Cuma Hutbesi: Zekât ve İnfak — Malı Arındıran Bereket Köprüsü',
      arabicHeader: 'وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ وَأَقْرِضُوا اللَّهَ قَرْضًا حَسَنًا',
      verseOrHadith: '“Mallarını Allah yolunda harcayanların durumu, yedi başak bitiren ve her başakta yüz dane bulunan bir tohum gibidir.” (Bakara, 2/261)',
      summary: 'Zekât ve sadaka malı eksiltmez; bilakis bereketlendirir, toplumdaki sevgi ve dayanışmayı güçlendirir.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'İslam’ın beş temel esasından biri olan zekât, zenginlerin mallarında yoksul ve muhtaçların ilahi olarak belirlenmiş hakkıdır. İnfak ise müminin cömertlik ahlakının tezahürüdür.\n\n'
          'Aziz Kardeşlerim!\n'
          'Sevgili Peygamberimiz (s.a.v.), “Sadaka maldan hiçbir şey eksiltmez” (Müslim, Birr, 69) buyurarak veren elin alan elden üstün olduğunu bildirmiştir. Zekât ve sadakalarımızı verirken incitmeden, başa kakmadan, akraba ve komşularımızdan başlayarak ihtiyaç sahiplerine ulaştıralım. Unutmayalım ki paylaştığımız bizimdir, biriktirdiğimiz ise mirasçılarımızındır.',
      source: 'Bakara Suresi, 261–262 · Müslim, Birr, 69',
    ),
    KhutbahItem(
      id: 'ibadet_dua_zikir',
      category: 'İbadet & Namaz',
      title: 'Cuma Hutbesi: Dua ve Zikir — Kalplerin Huzur Bulduğu İlahi Kapı',
      arabicHeader: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      verseOrHadith: '“Bilesiniz ki, kalpler ancak Allah’ı anmakla huzur bulur.” (Ra’d, 13/28) · “Dua, ibadetin özüdür.” (Tirmizî, Deavât, 1)',
      summary: 'Darlıkta ve bollukta Rabbini zikreden ve O\'na el açıp dua eden kul, yalnızlık ve çaresizlikten kurtulur.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Yüce Rabbimiz Bakara Suresi’nde, “Kullarım sana beni sorduklarında söyle onlara: Ben çok yakınım; bana dua ettiği vakit dua edenin dileğine karşılık veririm” (Bakara, 2/186) buyurmaktadır.\n\n'
          'Kıymetli Kardeşlerim!\n'
          'Dua, sadece dara düştüğümüzde hatırladığımız bir sığınak değil; bollukta şükrümüzün, darlıkta sabrımızın ifadesidir. Dilimizi her daim tesbih, tahmid, tekbir ve istiğfarla ıslak tutalım. Seher vakitlerinde, farz namazların akabinde ve bu mübarek Cuma saatinde ellerimizi semaya açarak kendimiz, ailemiz ve tüm İslam âlemi için hayır niyaz edelim.',
      source: 'Ra\'d Suresi, 28 · Bakara Suresi, 186 · Tirmizî, Deavât, 1',
    ),

    // 2. AHLAK & TAKVA (5)
    KhutbahItem(
      id: 'ahlak_ihlas_takva',
      category: 'Ahlak & Takva',
      title: 'Cuma Hutbesi: İhlas, Takva ve Güzel Ahlak',
      arabicHeader: 'إِنَّ أَكْرَمَكُمْ عِندَ اللَّهِ أَتْقَاكُمْ',
      verseOrHadith: '“Allah katında en değerli olanınız, O’na karşı en çok takva sahibi olanınızdır.” (Hucurât, 49/13) · “Ameller niyetlere göredir.” (Buhârî, Bed’ü’l-Vahy, 1)',
      summary: 'Amelleri Allah katında değerli kılan ihlastır; müminin en büyük sermayesi takva ve güzel ahlaktır.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'İhlas; ibadet ve iyiliklerimizi gösterişten, riyadan ve dünyevi çıkar beklentisinden uzak tutarak yalnızca Allah’ın rızasını kazanmak amacıyla yapmaktır. Takva ise Allah’ın emirlerine sarılıp yasaklarından sakınarak O’nun koruyucu rahmetine sığınmaktır.\n\n'
          'Aziz Müminler!\n'
          'Peygamber Efendimiz (s.a.v.), “Allah sizin dış görünüşünüze ve mallarınıza bakmaz; ancak kalplerinize ve amellerinize bakar” (Müslim, Birr, 34) buyurmuştur. Mizanda en ağır basacak amel güzel ahlaktır. Sözümüzde doğru, işimizde dürüst, insanlara karşı güler yüzlü ve merhametli olalım.',
      source: 'Hucurât Suresi, 13 · Müslim, Birr, 34',
    ),
    KhutbahItem(
      id: 'ahlak_emanet_dogruluk',
      category: 'Ahlak & Takva',
      title: 'Cuma Hutbesi: Doğruluk (Sıdk) ve Emanet Bilinci',
      arabicHeader: 'فَاسْتَقِمْ كَمَا أُمِرْتَ وَمَن تَابَ مَعَكَ',
      verseOrHadith: '“Emrolunduğun gibi dosdoğru ol!” (Hûd, 11/112) · “Doğruluk iyiliğe, iyilik de cennete götürür.” (Buhârî, Edeb, 69)',
      summary: 'Müslüman, elinden ve dilinden herkesin emin olduğu, sözü senet olan güvenilir insandır.',
      fullText:
          'Aziz Müminler!\n'
          'Sevgili Peygamberimiz (s.a.v.), peygamberlik vazifesinden önce bile Mekke toplumunda “Muhammedü’l-Emîn” (Güvenilir Muhammed) sıfatıyla tanınmıştı. O, “Bizi aldatan bizden değildir” (Müslim, Îmân, 164) buyurarak müminin hayatında yalana ve hileye yer olamayacağını ilan etmiştir.\n\n'
          'Kıymetli Kardeşlerim!\n'
          'Bedenimiz, ömrümüz, ailemiz, görevimiz ve çevremiz bize tevdi edilmiş birer emanettir. Söz verdiğimizde sözümüzde duralım, emanete hıyanet etmeyelim; her işimizde dosdoğru olalım.',
      source: 'Hûd Suresi, 112 · Buhârî, Edeb, 69 · Müslim, Îmân, 164',
    ),
    KhutbahItem(
      id: 'ahlak_sabir_sukur',
      category: 'Ahlak & Takva',
      title: 'Cuma Hutbesi: Müminin İki Kanadı — Sabır ve Şükür',
      arabicHeader: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      verseOrHadith: '“Ey iman edenler! Sabır ve namazla Allah’tan yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.” (Bakara, 2/153)',
      summary: 'Mümin nimete kavuştuğunda şükrederek, musibetle karşılaştığında sabrederek her hâlükârda kazançlı çıkar.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Dünya hayatı bir imtihan yurdudur; bazen varlıkla, bazen darlıkla sınanırız. Resûl-i Ekrem (s.a.v.) Efendimiz şöyle buyurur: “Müminin durumu ne hoştur! Her işi kendisi için hayırlıdır. Ona sevindirici bir şey gelirse şükreder, bu onun için hayır olur; başına bir sıkıntı gelirse sabreder, bu da onun için hayır olur.” (Müslim, Zühd, 64)\n\n'
          'Aziz Kardeşlerim!\n'
          'Şükür, nimetin sahibini bilmek ve nimeti O’nun razı olduğu yolda kullanmaktır; sabır ise zorluklar karşısında ümitsizliğe düşmeden azimle çalışmak ve Allah’a tevekkül etmektir. Rabbimiz bizleri şükreden ve sabreden kullarından eylesin.',
      source: 'Bakara Suresi, 153 · İbrahim Suresi, 7 · Müslim, Zühd, 64',
    ),
    KhutbahItem(
      id: 'ahlak_dilin_afetleri',
      category: 'Ahlak & Takva',
      title: 'Cuma Hutbesi: Dilin Afetleri — Gıybet, İftira ve Kötü Sözden Sakınmak',
      arabicHeader: 'وَلَا يَغْتَب بَّعْضُكُم بَعْضًا',
      verseOrHadith: '“Birbirinizin kusurlarını araştırmayın ve biriniz diğerinizi arkasından çekiştirmesin (gıybet etmesin).” (Hucurât, 49/12)',
      summary: 'Gıybet, iftira ve suizan kardeşliği kemiren manevi hastalıklardır; mümin ya hayır söyler ya da susar.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Yüce Rabbimiz Hucurât Suresi’nde gıybeti, ölmüş kardeşinin etini yemeye benzeterek bu günahın çirkinliğini gözler önüne sermiştir. Sevgili Peygamberimiz (s.a.v.) ise “Allah’a ve ahiret gününe iman eden kimse ya hayır söylesin ya da sussun” (Buhârî, Edeb, 31) buyurmuştur.\n\n'
          'Aziz Kardeşlerim!\n'
          'Özellikle sosyal medya ve dijital mecralarda doğruluğunu araştırmadan haber yaymak, insanların mahremiyetini ifşa etmek ve kalp kırmak ağır bir vebaldir. Dilimizi gıybetten, kalbimizi suizandan koruyalım; yapıcı, birleştirici ve tatlı dilli olalım.',
      source: 'Hucurât Suresi, 12 · Buhârî, Edeb, 31',
    ),
    KhutbahItem(
      id: 'ahlak_tevazu_merhamet',
      category: 'Ahlak & Takva',
      title: 'Cuma Hutbesi: Tevazu, Hoşgörü ve Merhamet Ahlakı',
      arabicHeader:
          'وَعِبَادُ الرَّحْمَٰنِ الَّذِينَ يَمْشُونَ عَلَى الْأَرْضِ هَوْنًا',
      verseOrHadith: '“Rahmân’ın has kulları, yeryüzünde vakar ve tevazu ile yürüyen kimselerdir.” (Furkân, 25/63) · “Kim Allah için tevazu gösterirse Allah onu yüceltir.” (Müslim, Birr, 69)',
      summary: 'Kibir şeytanın, tevazu ve merhamet ise peygamberlerin ve salih müminlerin vasfıdır.',
      fullText:
          'Aziz Müminler!\n'
          'Yeryüzündekilere merhamet etmeyene göktekilerin merhamet etmeyeceğini bildiren bir dinin mensuplarıyız. Kalbinde zerre kadar kibir bulunanın cennete giremeyeceğini haber veren Peygamberimiz (s.a.v.), insanlara karşı daima alçakgönüllü ve şefkatli olmuştur.\n\n'
          'Kıymetli Kardeşlerim!\n'
          'Makam, mevki ve servet geçicidir; baki olan Allah katındaki takva ve insanlara bıraktığımız hoş sedadır. Büyüklerimize hürmet, küçüklerimize şefkat, tüm yaratılmışlara Yaradan’dan ötürü merhamet gösterelim.',
      source: 'Furkân Suresi, 63 · Lokmân Suresi, 18 · Müslim, Birr, 69',
    ),

    // 3. AİLE & TOPLUM (5)
    KhutbahItem(
      id: 'aile_huzur_yuvasi',
      category: 'Aile & Toplum',
      title: 'Cuma Hutbesi: Aile — Sevgi, Merhamet ve Sekînet Yuvası',
      arabicHeader: 'وَمِنْ آيَاتِهِ أَنْ خَلَقَ لَكُم مِّنْ أَنفُسِكُمْ أَزْوَاجًا لِّتَسْكُنُوا إِلَيْهَا وَجَعَلَ بَيْنَكُم مَّوَدَّةً وَرَحْمَةً',
      verseOrHadith: '“Kendileriyle huzur bulasınız diye sizin için türünüzden eşler yaratması ve aranızda bir sevgi ve merhamet var etmesi de O’nun varlığının delillerindendir.” (Rûm, 30/21)',
      summary: 'Aile; meveddet (sevgi), rahmet (şefkat) ve sekînet (huzur) üzerine kurulan en mukaddes kurumdur.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Aile, insanın dünyadaki cenneti, toplumun en sağlam kalesidir. Kur’an-ı Kerîm eşleri birbirinin “libâsı” (koruyucu örtüsü) olarak tanımlar. Sevgili Peygamberimiz (s.a.v.) de “Sizin en hayırlınız, ailesine karşı en hayırlı olanınızdır” (Tirmizî, Menâkıb, 63) buyurmuştur.\n\n'
          'Aziz Kardeşlerim!\n'
          'Ailede huzur; karşılıklı saygı, sabır, anlayış ve tatlı dille korunur. Evlerimizi öfke ve kırgınlıktan uzak tutalım; eşimize ve evlatlarımıza tebessümle, merhametle ve güzel örnek olarak yaklaşalım.',
      source: 'Rûm Suresi, 21 · Tirmizî, Menâkıb, 63',
    ),
    KhutbahItem(
      id: 'aile_anne_baba',
      category: 'Aile & Toplum',
      title: 'Cuma Hutbesi: Anne-Babaya İhsan ve Sıla-i Rahîm',
      arabicHeader: 'وَقَضَىٰ رَبُّكَ أَلَّا تَعْبُدُوا إِلَّا إِيَّاهُ وَبِالْوَالِدَيْنِ إِحْسَانًا',
      verseOrHadith: '“Rabb’in, kendisinden başkasına asla ibadet etmemenizi, anne ve babaya iyi davranmanızı kesin olarak emretti.” (İsrâ, 17/23)',
      summary: 'Allah\'ın rızası anne-babanın rızasında, akrabalık bağlarını gözetmek (sıla-i rahîm) ise ömrün ve rızkın bereketindedir.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Yüce Rabbimiz kendisine kulluk emrinin hemen ardından anne-babaya ihsanı zikretmiş; onlara “öf!” bile dememeyi, üzerlerine merhamet kanatlarını germeyi ve “Rabbim! Küçüklüğümde onlar beni nasıl şefkatle büyüttülerse, şimdi Sen de onlara öyle merhamet et!” diye dua etmeyi emretmiştir.\n\n'
          'Aziz Müminler!\n'
          'Hayattaysalar anne-babamızın gönüllerini ve hayır dualarını alalım; ahirete irtihal etmişlerse sadaka-i cariye, Kur’an ve istiğfarla ruhlarını şad edelim. Akrabalarımızı ziyaret ederek sıla-i rahîmi ihmal etmeyelim.',
      source: 'İsrâ Suresi, 23–24 · Buhârî, Edeb, 1 · Müslim, Birr, 20',
    ),
    KhutbahItem(
      id: 'aile_genclik_evlat',
      category: 'Aile & Toplum',
      title: 'Cuma Hutbesi: Evlatlarımız — Göz Aydınlığımız ve İstikbalimiz',
      arabicHeader: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ',
      verseOrHadith: '“Hiçbir baba, çocuğuna güzel terbiyeden daha üstün bir miras bırakamaz.” (Tirmizî, Birr, 33)',
      summary: 'Çocuklarımız ve gençlerimiz bize Allah\'ın emanetidir; onlara bırakacağımız en büyük miras iman ve güzel ahlaktır.',
      fullText:
          'Aziz Müminler!\n'
          'Evlatlarımız dünya hayatının süsü ve ahiret azığımızdır. Peygamber Efendimiz (s.a.v.), insan öldüğünde amel defterinin kapanacağını, ancak kendisine dua eden hayırlı bir evlat bırakanın sevabının kesintisiz devam edeceğini müjdelemiştir.\n\n'
          'Kıymetli Anne-Babalar!\n'
          'Gençlerimizi ve çocuklarımızı zararlı alışkanlıklardan ve manevi boşluktan korumanın yolu; onları dinlemekten, sevgimizi hissettirmekten ve Kur’an ile Sünnet ahlakını bizzat yaşayarak örnek olmaktan geçer.',
      source: 'Furkân Suresi, 74 · Müslim, Vasiyyet, 14 · Tirmizî, Birr, 33',
    ),
    KhutbahItem(
      id: 'aile_komsuluk_hukuku',
      category: 'Aile & Toplum',
      title: 'Cuma Hutbesi: Komşuluk Hukuku ve Toplumsal Dayanışma',
      arabicHeader: 'وَاعْبُدُوا اللَّهَ وَلَا تُشْرِكُوا بِهِ شَيْئًا وَبِالْوَالِدَيْنِ إِحْسَانًا وَبِذِي الْقُرْبَىٰ وَالْيَتَامَىٰ وَالْمَسَاكِينِ وَالْجَارِ ذِي الْقُرْبَىٰ وَالْجَارِ الْجُنُبِ',
      verseOrHadith: '“Cebrâil bana komşu hakkını o kadar tavsiye etti ki, komşuyu komşuya mirasçı kılacak zannettim.” (Buhârî, Edeb, 28)',
      summary: 'Komşusu açken tok yatan bizden değildir; komşuluk hakkını gözetmek iman olgunluğunun göstergesidir.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'İslam medeniyeti, komşusuyla selamlaşan, sevincini ve kederini paylaşan, tenceresinde pişen aşın kokusunu dahi komşusunu gözeterek paylaşan bir komşuluk ahlakı inşa etmiştir.\n\n'
          'Aziz Kardeşlerim!\n'
          'Apartman ve şehir hayatının bizleri yalnızlaştırmasına izin vermeyelim. Komşularımızı rahatsız edecek davranışlardan sakınalım; yaşlı, hasta ve ihtiyaç sahibi komşularımızın kapısını çalıp hâllerini soralım.',
      source: 'Nisâ Suresi, 36 · Buhârî, Edeb, 28 · Müslim, Îmân, 73',
    ),
    KhutbahItem(
      id: 'aile_yetim_mazlum',
      category: 'Aile & Toplum',
      title:
          'Cuma Hutbesi: Yetimlerin Başını Okşamak ve Mazluma Kol Kanat Germek',
      arabicHeader: 'فَأَمَّا الْيَتِيمَ فَلَا تَقْهَرْ ۝ وَأَمَّا السَّائِلَ فَلَا تَنْهَرْ',
      verseOrHadith: '“Öyleyse sakın yetimi ezme! El açıp isteyeni de azarlama!” (Duhâ, 93/9–10) · “Ben ve yetimi himaye eden kimse cennette şöyle yan yanayız.” (Buhârî, Talâk, 25)',
      summary: 'Yetimi, öksüzü ve kimsesizi koruyup gözetmek kalbi yumuşatır ve Peygamber Efendimiz\'e cennette komşu kılar.',
      fullText:
          'Aziz Müminler!\n'
          'Kendisi de dünyaya yetim olarak teşrif eden Rahmet Peygamberi (s.a.v.), yetime ve mazluma kol kanat germeyi cennetin anahtarı olarak göstermiştir. Kalbinin katılığından şikâyet eden bir sahâbîye, “Yetimin başını okşa ve yoksulu doyur” tavsiyesinde bulunmuştur.\n\n'
          'Kıymetli Kardeşlerim!\n'
          'Çevremizdeki yetimleri, kimsesizleri ve darda kalan kardeşlerimizi yalnız bırakmayalım; onların yüzündeki bir tebessümün ahirette bizim için kurtuluş vesilesi olacağını unutmayalım.',
      source: 'Duhâ Suresi, 9–10 · Buhârî, Talâk, 25',
    ),

    // 4. HELAL KAZANÇ & KUL HAKKI (4)
    KhutbahItem(
      id: 'kazanc_helal_lokma',
      category: 'Helal Kazanç & Kul Hakkı',
      title: 'Cuma Hutbesi: Helal Kazanç, Alın Teri ve Bereket',
      arabicHeader:
          'يَا أَيُّهَا النَّاسُ كُلُوا مِمَّا فِي الْأَرْضِ حَلَالًا طَيِّبًا',
      verseOrHadith: '“Ey insanlar! Yeryüzündeki şeylerin helal ve temiz olanlarından yiyin!” (Bakara, 2/168) · “Hiç kimse kendi elinin emeğinden daha hayırlı bir lokma yememiştir.” (Buhârî, Büyû, 15)',
      summary: 'Duaların kabulü ve ibadetlerin feyzi helal lokmaya bağlıdır; alın teriyle kazanılan az rızık, haramın çokluğundan hayırlıdır.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Helal kazanç, ibadetlerin kabulünün ve nesillerin salahının temel şartıdır. Peygamber Efendimiz (s.a.v.), yediği haram, içtiği haram, giydiği haram olan bir kimsenin ellerini göğe kaldırıp “Yâ Rabbî!” diye dua etmesi hâlinde duasının nasıl kabul edileceğini sorarak bizleri uyarmıştır.\n\n'
          'Aziz Kardeşlerim!\n'
          'Soframıza ve evlatlarımızın kursağına haram ve şüpheli tek bir lokma dahi girmemesine titizlik gösterelim. Faizden, kumar ve şans oyunlarından, rüşvetten, stokçuluktan ve fahiş fiyattan uzak duralım; bereketi helal alın terinde arayalım.',
      source: 'Bakara Suresi, 168 · Buhârî, Büyû, 15 · Müslim, Zekât, 65',
    ),
    KhutbahItem(
      id: 'kazanc_kul_hakki',
      category: 'Helal Kazanç & Kul Hakkı',
      title: 'Cuma Hutbesi: Kul Hakkı ve Ahiret Hesabı',
      arabicHeader: 'وَيْلٌ لِّلْمُطَفِّفِينَ ۝ الَّذِينَ إِذَا اكْتَالُوا عَلَى النَّاسِ يَسْتَوْفُونَ',
      verseOrHadith: '“Ölçüde ve tartıda hile yapanların vay hâline!” (Mutaffifîn, 83/1) · “Kimin üzerinde kardeşinin onuru veya malıyla ilgili bir hak varsa, altın ve gümüşün geçmeyeceği gün gelmeden önce helalleşsin.” (Buhârî, Mezâlim, 10)',
      summary: 'Allah Teâlâ kendi hakkını dilerse affeder; ancak kul hakkını hak sahibi helal etmedikçe bağışlamaz.',
      fullText:
          'Aziz Müminler!\n'
          'Resûlullah (s.a.v.) bir gün ashabına “Müflis kimdir?” diye sormuş ve gerçek müflisin; kıyamet gününe namaz, oruç ve zekâtla geldiği hâlde, dünyada şuna sövmüş, buna iftira etmiş, ötekinin malını yemiş olduğu için bütün sevapları hak sahiplerine dağıtılan kimse olduğunu bildirmiştir.\n\n'
          'Kıymetli Kardeşlerim!\n'
          'İşçi ve işveren hakkına, miras adaletine, borçlarımızı zamanında ödemeye ve kamu malına (beytülmâle) el uzatmamaya son derece dikkat edelim. Üzerimizde hakkı bulunan kardeşlerimizle dünya hayatındayken helalleşelim.',
      source: 'Mutaffifîn Suresi, 1–3 · Buhârî, Mezâlim, 10 · Müslim, Birr, 59',
    ),
    KhutbahItem(
      id: 'kazanc_israf_kanaat',
      category: 'Helal Kazanç & Kul Hakkı',
      title: 'Cuma Hutbesi: İsraftan Sakınmak, İktisat ve Kanaat Zenginliği',
      arabicHeader: 'وَكُلُوا وَاشْرَبُوا وَلَا تُسْرِفُوا ۚ إِنَّهُ لَا يُحِبُّ الْمُسْرِفِينَ',
      verseOrHadith: '“Yiyin, için fakat israf etmeyin. Çünkü Allah israf edenleri sevmez.” (A’râf, 7/31) · “Gerçek zenginlik mal çokluğu değil, gönül tokluğudur.” (Buhârî, Rikâk, 15)',
      summary: 'Su, ekmek, enerji ve zaman nimetlerini israf etmemek; kanaat ve iktisatla yaşamak müminin şükür borcudur.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Rabbimizin bizlere bahşettiği her nimet bir emanet ve imtihandır. Nehrin kenarında abdest alırken dahi suyu israf etmemeyi emreden Peygamberimiz (s.a.v.), “İktisat eden (tutumlu olan) fakir düşmez” buyurmuştur.\n\n'
          'Aziz Kardeşlerim!\n'
          'Soframızdaki bir dilim ekmekten musluğumuzdan akan bir damla suya, vaktimizden sağlığımıza kadar hiçbir nimeti heba etmeyelim. Gösteriş ve tüketim çılgınlığına kapılmadan kanaat ve şükürle yaşayalım.',
      source: 'A\'râf Suresi, 31 · İsrâ Suresi, 26–27 · Buhârî, Rikâk, 15',
    ),
    KhutbahItem(
      id: 'kazanc_is_ahlaki',
      category: 'Helal Kazanç & Kul Hakkı',
      title: 'Cuma Hutbesi: İslam\'da İş Ahlakı, Liyakat ve İhsan',
      arabicHeader: 'إِنَّ اللَّهَ يَأْمُرُكُمْ أَن تُؤَدُّوا الْأَمَانَاتِ إِلَىٰ أَهْلِهَا',
      verseOrHadith: '“Allah, sizden birinizin yaptığı işi sağlam ve en güzel şekilde (ihsan ile) yapmasından hoşnut olur.” (Taberânî, el-Mu’cemü’l-Evsat, I, 275)',
      summary: 'Yaptığı işi sağlam yapmak, işçinin ücretini alın teri kurumadan vermek ve ticarette dürüst olmak ibadettir.',
      fullText:
          'Aziz Müminler!\n'
          'İslam’da çalışma ve üretim, helal dairesinde ve güzel niyetle yapıldığında nafile ibadet sevabı kazandırır. Doğru sözlü ve güvenilir tüccarın ahirette peygamberler, sıddıklar ve şehitlerle beraber olacağı müjdelenmiştir.\n\n'
          'Kıymetli Kardeşlerim!\n'
          'Hangi meslekte olursak olalım işimizi ihsan bilinciyle, sanki Allah’ı görüyormuşçasına sağlam ve dürüst yapalım. Çalışanlarımızın emeğini ve hakkını alın teri kurumadan eksiksiz ödeyelim.',
      source: 'Nisâ Suresi, 58 · Tirmizî, Büyû, 4 · İbn Mâce, Ruhûn, 4',
    ),

    // 5. KUR'AN & SÜNNET (4)
    KhutbahItem(
      id: 'kuran_hayat_kitabi',
      category: 'Kur\'an & Sünnet',
      title:
          'Cuma Hutbesi: Kur\'an-ı Kerîm — Şifa, Rahmet ve Hidayet Rehberimiz',
      arabicHeader: 'إِنَّ هَٰذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ',
      verseOrHadith: '“Şüphesiz bu Kur’an, insanları en doğru ve en sağlam yola iletir.” (İsrâ, 17/9) · “Sizin en hayırlınız, Kur’an’ı öğrenen ve öğretendir.” (Buhârî, Fedâilü’l-Kur’ân, 21)',
      summary: 'Kur\'an, sadece okunmak için değil; anlaşılmak, kalplere şifa olmak ve hayatımıza rehber kılınmak için indirilmiştir.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Kur’an-ı Kerîm, Yüce Rabbimizin insanlığa gönderdiği son ilahi mesaj, karanlıkları aydınlatan nur ve müminler için rahmet kaynağıdır. O, tutunduğumuzda asla kopmayacak olan “hablullah” (Allah’ın sağlam ipi)dir.\n\n'
          'Aziz Kardeşlerim!\n'
          'Kur’an’a karşı görevimiz; onu tecvid ve edeple okumak, meal ve tefsiriyle anlamını tefekkür etmek ve ahkâmını hayatımıza tatbik etmektir. Evlerimizi Kur’an tilavetiyle şenlendirelim; her gün en az bir sayfa da olsa Rabbimizin kelamıyla buluşalım.',
      source: 'İsrâ Suresi, 9 ve 82 · Buhârî, Fedâilü\'l-Kur\'ân, 21',
    ),
    KhutbahItem(
      id: 'kuran_peygamber_sevgisi',
      category: 'Kur\'an & Sünnet',
      title: 'Cuma Hutbesi: Hz. Muhammed (s.a.v.) — En Güzel Örnek (Üsve-i Hasene)',
      arabicHeader:
          'لَّقَدْ كَانَ لَكُمْ فِي رَسُولِ اللَّهِ أُسْوَةٌ حَسَنَةٌ',
      verseOrHadith: '“Andolsun, Allah’ın Resûlü’nde sizin için; Allah’a ve ahiret gününe kavuşmayı umanlar için güzel bir örnek vardır.” (Ahzâb, 33/21)',
      summary: 'Peygamber Efendimiz\'i sevmek, O\'nun yaşayan Kur\'an olan ahlakını ve Sünnet-i Seniyyesini hayatımıza taşımaktır.',
      fullText:
          'Aziz Müminler!\n'
          'Alemlere rahmet olarak gönderilen Sevgili Peygamberimiz Hz. Muhammed Mustafa (s.a.v.), “Ben güzel ahlakı tamamlamak için gönderildim” buyurmuştur. Hz. Âişe validemizin ifadesiyle O’nun ahlakı Kur’an idi.\n\n'
          'Kıymetli Kardeşlerim!\n'
          'Resûlullah’ı sevmek, sadece dil ile salavat getirmekten ibaret değildir; O’nun ibadet aşkını, merhametini, adaletini, aile hayatındaki nezaketini ve insanlığa olan şefkatini kuşanmaktır. Rabbimiz bizleri dünyada Sünnet-i Seniyyesinden, ahirette şefaatinden ayırmasın.',
      source: 'Ahzâb Suresi, 21 · Kalem Suresi, 4 · Müslim, Müsâfirîn, 139',
    ),
    KhutbahItem(
      id: 'kuran_ilim_hikmet',
      category: 'Kur\'an & Sünnet',
      title: 'Cuma Hutbesi: İlim, Hikmet ve Tefekkür — "Oku!" Emrinin İzinde',
      arabicHeader: 'قُلْ هَلْ يَسْتَوِي الَّذِينَ يَعْلَمُونَ وَالَّذِينَ لَا يَعْلَمُونَ',
      verseOrHadith: '“De ki: Hiç bilenlerle bilmeyenler bir olur mu?” (Zümer, 39/9) · “Kim ilim tahsil etmek için bir yola girerse, Allah ona cennetin yolunu kolaylaştırır.” (Müslim, Zikir, 38)',
      summary: 'İlk emri "Oku!" olan İslam, ilmi ve hikmeti müminin yitiği saymış; faydalı ilmi sadaka-i cariye kılmıştır.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'İslam dini ilim, akıl ve tefekkür dinidir. İlk vahyin “Yaratan Rabbinin adıyla oku!” (Alak, 96/1) emriyle başlaması, dinimizin bilgiye ve öğrenmeye verdiği eşsiz değeri gösterir.\n\n'
          'Aziz Kardeşlerim!\n'
          'Hem dini ilimlerde hem de insanlığa fayda sağlayan fen ve teknoloji alanlarında en ileri seviyede olmak müminlerin sorumluluğudur. Peygamberimiz (s.a.v.) gibi her daim “Allah’ım! Faydasız ilimden Sana sığınırım, ilmimi artır!” diye dua edelim.',
      source: 'Alak Suresi, 1–5 · Zümer Suresi, 9 · Müslim, Zikir, 38',
    ),
    KhutbahItem(
      id: 'kuran_tovbe_istigfar',
      category: 'Kur\'an & Sünnet',
      title: 'Cuma Hutbesi: Tövbe ve İstiğfar — Rahmet Kapısından Dönüş',
      arabicHeader: 'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ',
      verseOrHadith: '“De ki: Ey kendi nefisleri aleyhine haddi aşan kullarım! Allah’ın rahmetinden ümidinizi kesmeyin. Şüphesiz Allah bütün günahları bağışlar.” (Zümer, 39/53)',
      summary: 'Her insan hata edebilir; hata edenlerin en hayırlısı ise samimi bir kalple (nasûh tövbesiyle) Rabbine yönelendir.',
      fullText:
          'Aziz Müminler!\n'
          'İnsanoğlu beşerdir, zaman zaman nefsine uyup hata ve günaha düşebilir. Ancak Yüce Rabbimizin Tevvâb ve Gafûr isimleri, pişmanlıkla kapısına gelen hiçbir kulunu geri çevirmez. Peygamber Efendimiz (s.a.v.), “Günahından samimiyetle tövbe eden kimse, hiç günah işlememiş gibidir” (İbn Mâce, Zühd, 30) buyurmuştur.\n\n'
          'Kıymetli Kardeşlerim!\n'
          'Tövbeyi yarına ertelemeyelim. Bu mübarek Cuma vaktinde geçmiş hatalarımıza pişman olup bir daha dönmemeye söz verelim; “Estağfirullâhe’l-azîm ve etûbü ileyh” diyerek kalbimizi arındıralım.',
      source: 'Zümer Suresi, 53 · Tahrîm Suresi, 8 · İbn Mâce, Zühd, 30',
    ),

    // 6. MÜBAREK GÜN & BAYRAM HUTBELERİ (5)
    KhutbahItem(
      id: 'mubarek_ramazan_oruc',
      category: 'Mübarek Gün & Bayram',
      title: 'Ramazan Hutbesi: Oruç, Kur\'an ve Takva Mevsimi Ramazan-ı Şerif',
      arabicHeader: 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُتِبَ عَلَيْكُمُ الصِّيَامُ كَمَا كُتِبَ عَلَى الَّذِينَ مِن قَبْلِكُمْ لَعَلَّكُمْ تَتَّقُونَ',
      verseOrHadith: '“Kim inanarak ve sevabını yalnızca Allah’tan bekleyerek Ramazan orucunu tutarsa geçmiş günahları bağışlanır.” (Buhârî, Îmân, 28)',
      summary: 'Başı rahmet, ortası mağfiret, sonu cehennem ateşinden kurtuluş olan Ramazan; nefsi terbiye ve paylaşma ayıdır.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'On bir ayın sultanı Ramazan-ı Şerif; Kur’an-ı Kerîm’in indirildiği, cennet kapılarının sonuna kadar açıldığı, rahmet ve mağfiret iklimidir. Oruç ibadeti, sadece midemizi yeme-içmeden değil; gözümüzü, dilimizi ve kalbimizi her türlü günahtan koruma mektebidir.\n\n'
          'Aziz Müminler!\n'
          'Sahurun bereketini, iftarın sevincini, teravih namazlarının ve mukabelelerin huzurunu ailece yaşayalım. Fitre, zekât ve iftar sofralarımızla ihtiyaç sahiplerinin yüzünü güldürelim.',
      source: 'Bakara Suresi, 183–185 · Buhârî, Îmân, 28',
    ),
    KhutbahItem(
      id: 'mubarek_kadir_gecesi',
      category: 'Mübarek Gün & Bayram',
      title: 'Özel Hutbe: Bin Aydan Daha Hayırlı Gece — Kadir Gecesi',
      arabicHeader: 'إِنَّا أَنزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ ۝ وَمَا أَدْرَاكَ مَا لَيْلَةُ الْقَدْرِ ۝ لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ',
      verseOrHadith: '“Kadir Gecesi bin aydan daha hayırlıdır. O gecede melekler ve Rûh, Rablerinin izniyle her bir iş için iner de iner. O gece, tan yeri ağarıncaya kadar esenliktir.” (Kadr, 97/3–5)',
      summary: 'Bir ömre bedel olan Kadir Gecesi, Kur\'an\'ın indirildiği, af ve mağfiret kapılarının ardına kadar açıldığı gecedir.',
      fullText:
          'Aziz Müminler!\n'
          'İçinde Kadir Gecesi bulunmayan seksen küsur yıllık bir ömürden daha hayırlı olan bu mübarek gece, Kur’an-ı Kerîm’in yeryüzünü şereflendirdiği gecedir.\n\n'
          'Sevgili Peygamberimiz (s.a.v.), Hz. Âişe validemize Kadir Gecesi’nde şu duayı çokça okumasını tavsiye etmiştir: “Allâhümme inneke afüvvün kerîmün tuhibbü’l-afve fa’fü annî” (Allah’ım! Sen çok affedicisin, kerem sahibisin, affetmeyi seversin; beni de affet!). Bu geceyi namaz, Kur’an ve samimi yakarışlarla ihya edelim.',
      source: 'Kadr Suresi, 1–5 · Tirmizî, Deavât, 84',
    ),
    KhutbahItem(
      id: 'mubarek_ramazan_bayrami',
      category: 'Mübarek Gün & Bayram',
      title:
          'Bayram Hutbesi: Ramazan Bayramı — Sevinç, Kardeşlik ve Sıla-i Rahîm',
      arabicHeader: 'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ لَا إِلَٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ وَلِلَّهِ الْحَمْدُ',
      verseOrHadith: '“Müminler ancak kardeştirler. Öyleyse kardeşlerinizin arasını düzeltin ve Allah’a karşı gelmekten sakının ki size merhamet edilsin.” (Hucurât, 49/10)',
      summary: 'Oruç ve ibadetle geçen Ramazan\'ın ardından kavuştuğumuz Bayram; küskünlerin barıştığı, büyüklerin ve yetimlerin sevindirildiği gündür.',
      fullText:
          'Aziz Müminler! Bayramınız Mübarek Olsun!\n'
          'Bir ay boyunca tuttuğumuz oruçlarla, kıldığımız teravihlerle ve okuduğumuz hatimlerle arındıktan sonra bizleri bayram sabahının sevincine kavuşturan Rabbimize sonsuz hamd ü senalar olsun.\n\n'
          'Kıymetli Kardeşlerim!\n'
          'Bayramlar; dargınlıkların son bulduğu, anne-babaların ellerinin öpüldüğü, çocukların, yetimlerin ve yaşlıların sevindirildiği müstesna günlerdir. Ramazan’da kazandığımız ibadet ve güzel ahlak bilincini yılın tamamına yayalım; bayram sevincimizi bütün gönüllere taşıyalım.',
      source: 'Hucurât Suresi, 10 · Bakara Suresi, 185',
    ),
    KhutbahItem(
      id: 'mubarek_kurban_bayrami',
      category: 'Mübarek Gün & Bayram',
      title: 'Bayram Hutbesi: Kurban Bayramı — Teslimiyet, Takva ve Paylaşma',
      arabicHeader: 'لَن يَنَالَ اللَّهَ لُحُومُهَا وَلَا دِمَاؤُهَا وَلَٰكِن يَنَالُهُ التَّقْوَىٰ مِنكُمْ',
      verseOrHadith: '“Onların (kurbanların) ne etleri ne de kanları Allah’a ulaşır; fakat O’na sadece sizin takvanız ulaşır.” (Hac, 22/37)',
      summary: 'Kurban; Hz. İbrahim\'in sadakatini, Hz. İsmail\'in teslimiyetini kuşanmak ve kardeşlerimizle paylaşarak Allah\'a yaklaşmaktır.',
      fullText:
          'Muhterem Müslümanlar! Kurban Bayramınız Mübarek Olsun!\n'
          'Kurban, kelime anlamı itibarıyla Allah’a yakınlaşmak (kurbiyyet) demektir. Hz. İbrahim (a.s.) ve oğlu Hz. İsmail (a.s.)’ın ilahi emre gösterdikleri eşsiz teslimiyetin asırlardır süren nişanesidir.\n\n'
          'Aziz Kardeşlerim!\n'
          'Kestiğimiz kurbanların etleri ve kanları değil; kalbimizdeki ihlas, takva ve paylaşma ruhu Rabbimize ulaşır. Teşrik tekbirleriyle yankılanan bu mübarek günlerde kurban paylarımızla yoksul, yetim ve komşularımızın sofralarını bereketlendirelim; çevre temizliğine ve kurban edeplerine riayet edelim.',
      source: 'Hac Suresi, 37 · Kevser Suresi, 1–3 · Sâffât Suresi, 102–107',
    ),
    KhutbahItem(
      id: 'mubarek_kandiller_mevlid',
      category: 'Mübarek Gün & Bayram',
      title:
          'Özel Hutbe: Üç Aylar ve Kandil Geceleri — Manevi Yenilenme Mevsimi',
      arabicHeader: 'وَمَا أَرْسَلْنَاكَ إِلَّا رَحْمَةً لِّلْعَالَمِينَ',
      verseOrHadith: '“(Ey Muhammed!) Biz seni ancak âlemlere rahmet olarak gönderdik.” (Enbiyâ, 21/107) · “Allah’ım! Receb ve Şaban’ı bize mübarek kıl ve bizi Ramazan’a ulaştır.” (Ahmed b. Hanbel, Müsned, I, 259)',
      summary: 'Regâib, Mi\'rac, Berat ve Mevlid geceleri; ömrümüzü muhasebe etmek ve gönül dünyamızı yenilemek için ilahi fırsatlardır.',
      fullText:
          'Aziz Müminler!\n'
          'Mübarek gün ve geceler, hızla akıp giden ömür sermayemizi gözden geçirdiğimiz, Rabbimize olan kulluk ahdimizi tazelediğimiz rahmet duraklarıdır. Regâib ile rağbetimizi Allah’a yöneltir, Mi’rac ile namaz hediyesine sarılır, Berat ile günahlardan beraat diler, Mevlid ile Rahmet Peygamberi’nin doğumunu salavatlarla idrak ederiz.\n\n'
          'Geliniz, bu mübarek vakitleri kaza namazları, Kur’an tilaveti, tövbe-istiğfar ve kırık gönülleri onarmakla değerlendirelim.',
      source: 'Enbiyâ Suresi, 107 · İsrâ Suresi, 1 · Duhân Suresi, 3',
    ),

    // 7. VATAN & KARDEŞLİK (4)
    KhutbahItem(
      id: 'vatan_kardeslik_birlik',
      category: 'Vatan & Kardeşlik',
      title: 'Cuma Hutbesi: İslam Kardeşliği, Birlik ve Beraberlik Ruhu',
      arabicHeader: 'وَاعْتَصِمُوا بِحَبْلِ اللَّهِ جَمِيعًا وَلَا تَفَرَّقُوا',
      verseOrHadith: '“Hep birlikte Allah’ın ipine sımsıkı sarılın, parçalanıp bölünmeyin!” (Âl-i İmrân, 3/103) · “Mümin, mümin için parçaları birbirini kenetleyen bir bina gibidir.” (Buhârî, Salât, 88)',
      summary: 'Müminleri birbirine bağlayan en güçlü bağ iman kardeşliğidir; tefrikadan uzak durup kenetlenmek izzetimizin şartıdır.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Yüce Rabbimiz Âl-i İmrân Suresi’nde bizleri Allah’ın ipine (Kur’an ve İslam’a) hep birlikte sımsıkı sarılmaya ve ayrılığa düşmemeye çağırmaktadır. Çünkü rahmet cemaatte ve birlikte, azap ise ayrılık ve tefrikadadır.\n\n'
          'Aziz Kardeşlerim!\n'
          'Renklerimiz, dillerimiz ve memleketlerimiz farklı olsa da kıblemiz bir, kitabımız bir, Peygamberimiz birdir. Fitne, haset ve kutuplaşmaya fırsat vermeyelim; birbirimizin derdiyle dertlenen gerçek kardeşler olalım.',
      source: 'Âl-i İmrân Suresi, 103 · Enfâl Suresi, 46 · Buhârî, Salât, 88',
    ),
    KhutbahItem(
      id: 'vatan_sehitlik_emanet',
      category: 'Vatan & Kardeşlik',
      title: 'Cuma Hutbesi: Vatan Sevgisi, Şehitlik ve Gazilik Ruhu',
      arabicHeader: 'وَلَا تَقُولُوا لِمَن يُقْتَلُ فِي سَبِيلِ اللَّهِ أَمْوَاتٌ ۚ بَلْ أَحْيَاءٌ وَلَٰكِن لَّا تَشْعُرُونَ',
      verseOrHadith: '“Allah yolunda öldürülenlere ‘ölüler’ demeyin. Bilakis onlar diridirler, lâkin siz anlayamazsınız.” (Bakara, 2/154)',
      summary: 'Minarelerinden ezanların yükseldiği hür vatanımız, aziz şehitlerimizin ve gazilerimizin bizlere en mukaddes emanetidir.',
      fullText:
          'Aziz Müminler!\n'
          'İbadetlerimizi hür ve güven içinde eda edebilmemiz, minarelerimizden ezan-ı Muhammedilerin yankılanması, mukaddes vatan toprağının varlığı sayesindedir. Vatanı korumak, imanı, namusu ve istiklali korumaktır.\n\n'
          'Kıymetli Kardeşlerim!\n'
          'Din, devlet, vatan ve mukaddesat uğrunda canlarını feda eden aziz şehitlerimizi ve ebediyete irtihal eden kahraman gazilerimizi her daim rahmet, minnet ve Fatiha’larla yâd edelim; vatanımıza ve birliğimize sahip çıkalım.',
      source: 'Bakara Suresi, 154 · Âl-i İmrân Suresi, 169',
    ),
    KhutbahItem(
      id: 'vatan_cevre_emaneti',
      category: 'Vatan & Kardeşlik',
      title: 'Cuma Hutbesi: Çevre Ahlakı, Tabiatı Korumak ve Merhamet',
      arabicHeader: 'وَلَا تُفْسِدُوا فِي الْأَرْضِ بَعْدَ إِصْلَاحِهَا',
      verseOrHadith: '“Kıyametin kopacağını bilseniz bile elinizdeki fidanı dikiniz!” (Ahmed b. Hanbel, Müsned, III, 184)',
      summary: 'Yeryüzü, ormanlar, sular ve tüm canlılar insanlığa emanettir; doğayı korumak ve ağaç dikmek sadaka-i cariyedir.',
      fullText:
          'Muhterem Müslümanlar!\n'
          'Yüce Allah kâinatı kusursuz bir ölçü ve denge (mîzân) ile yaratmıştır. Peygamber Efendimiz (s.a.v.), bir Müslümanın diktiği ağaçtan veya ektiği ekinden insan, kuş veya hayvan yediğinde bunun kendisi için sadaka olacağını müjdelemiştir.\n\n'
          'Aziz Kardeşlerim!\n'
          'Temizlik imanın yarısıdır. Sokaklarımızı, sularımızı ve ormanlarımızı temiz tutalım; yangınlara ve çevre kirliliğine karşı duyarlı olalım, dilsiz canlılara merhametle muamele edelim.',
      source: 'A\'râf Suresi, 56 · Rûm Suresi, 41 · Buhârî, Hars, 1',
    ),

    // 8. CUMA MESAJLARI & SÜNNETLERİ (5)
    KhutbahItem(
      id: 'cuma_sunnetleri_rehber',
      category: 'Cuma Mesajları & Sünnetleri',
      title: 'Cuma Rehberi: Cuma Gününün Sünnetleri ve Âdâbı',
      arabicHeader:
          'خَيْرُ يَوْمٍ طَلَعَتْ عَلَيْهِ الشَّمْسُ يَوْمُ الْجُمُعَةِ',
      verseOrHadith: '“Kim Cuma günü yıkanır (gusleder), erkenden camiye gider, imama yakın oturup hutbeyi sessizce dinlerse attığı her adıma bir yıllık nafile oruç ve namaz sevabı yazılır.” (Ebû Dâvûd, Tahâret, 127)',
      summary: 'Cuma guslü almak, güzel koku sürünmek, Kehf Suresi okumak ve bol salavat getirmek Cuma gününün başlıca sünnetleridir.',
      fullText:
          'Cuma Gününün Başlıca Sünnetleri ve Âdâbı:\n'
          '1. Cuma Guslü ve Temizlik: Cuma namazı için boy abdesti (gusül) almak, tırnak kesmek ve temiz kıyafetler giymek.\n'
          '2. Güzel Koku ve Misvak: Cemaati rahatsız edecek kokulardan kaçınıp güzel koku sürünmek ve ağız temizliğine dikkat etmek.\n'
          '3. Camiye Erken Gitmek: Ezan okunmadan önce camide hazır bulunmak, safları omuz üzerinden atlamadan doldurmak.\n'
          '4. Hutbeyi Dinlemek: İmam minbere çıktığında konuşmayı bırakıp hutbeyi huşû içinde dinlemek.\n'
          '5. Kehf Suresi ve Salavat: Perşembe akşamından Cuma ikindi vaktine kadar Kehf Suresi okumak ve Peygamber Efendimiz’e (s.a.v.) çokça salât ü selâm getirmek.',
      source:
          'Buhârî, Cum\'a, 6 · Müslim, Cum\'a, 27 · Ebû Dâvûd, Tahâret, 127',
    ),
    KhutbahItem(
      id: 'cuma_mesaj_rahmet',
      category: 'Cuma Mesajları & Sünnetleri',
      title: 'Cuma Tebrik Mesajı: Rahmet, Mağfiret ve Dua Günü',
      arabicHeader: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      verseOrHadith: '“Rabbimiz! Bize dünyada da iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru!” (Bakara, 2/201)',
      summary: 'Gönüllerimiz duada birleşsin, kalplerimiz Kur\'an ve sünnet nuruyla dolsun. Rabbimiz dualarımızı ve ibadetlerimizi kabul eylesin. Hayırlı Cumalar.',
      fullText:
          'Hayırlı ve Bereketli Cumalar!\n'
          '“Rabbimiz! Bize dünyada da iyilik ve güzellik ver, ahirette de iyilik ve güzellik ver; bizi cehennem azabından koru!” (Bakara, 2/201)\n\n'
          'Gönüllerimiz duada birleşsin, hanelerimiz huzur ve bereketle dolsun. Rabbimiz bu mübarek Cuma gününün hürmetine hastalarımıza şifa, dertlilerimize deva, borçlularımıza eda nasip eylesin. Cumanız mübarek olsun.',
      source: 'Bakara Suresi, 201 · Cum\'a Suresi, 9–10',
    ),
    KhutbahItem(
      id: 'cuma_mesaj_salavat',
      category: 'Cuma Mesajları & Sünnetleri',
      title: 'Cuma Tebrik Mesajı: Salavat-ı Şerife ve İcâbet Saati',
      arabicHeader: 'إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ ۚ يَا أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا',
      verseOrHadith: '“Kim bana bir defa salât getirirse, Allah da ona on kat rahmet eder.” (Müslim, Salât, 70)',
      summary: 'Salavatlarla nurlanan, duaların kabul olduğu icâbet saatine tevafuk eden mübarek bir Cuma dileriz.',
      fullText:
          'Allâhümme salli alâ seyyidinâ Muhammedin ve alâ âli seyyidinâ Muhammed.\n\n'
          '“Şüphesiz Allah ve melekleri Peygamber’e salât ederler. Ey iman edenler! Siz de O’na salât edin ve tam bir teslimiyetle selam verin.” (Ahzâb, 33/56)\n\n'
          'Rabbimiz bu mübarek Cuma gününde ettiğiniz tüm hayırlı duaları icâbet saatine denk getirsin; kalbinize inşirah, ömrünüze bereket ihsan eylesin. Hayırlı Cumalar!',
      source: 'Ahzâb Suresi, 56 · Müslim, Salât, 70',
    ),
    KhutbahItem(
      id: 'cuma_mesaj_insirah',
      category: 'Cuma Mesajları & Sünnetleri',
      title: 'Cuma Tebrik Mesajı: İnşirah ve Kolaylık Duası',
      arabicHeader:
          'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      verseOrHadith: '“Şüphesiz her güçlükle beraber bir kolaylık vardır. Gerçekten her güçlükle beraber bir kolaylık vardır.” (İnşirâh, 94/5–6)',
      summary: 'Rabbimiz gönlünüze İnşirah ferahlığı versin, her zorluğunuzu kolaylığa tebdil eylesin. Cumanız mübarek olsun.',
      fullText:
          'Bismillâhirrahmânirrahîm.\n'
          '“Muhakkak ki her zorlukla beraber bir kolaylık vardır.” (İnşirâh, 94/5–6)\n\n'
          'Yüce Rabbimiz daralan gönüllerimize İnşirah ferahlığı bahşetsin, çıkmazlarımızı hayırla açsın, ailemize ve sevdiklerimize sağlık, afiyet ve huzur nasip eylesin. Cumamız mübarek, dualarımız makbul olsun.',
      source: 'İnşirâh Suresi, 1–8',
    ),
    KhutbahItem(
      id: 'cuma_mesaj_hutbe_duasi',
      category: 'Cuma Mesajları & Sünnetleri',
      title: 'Cuma Hutbe Duası ve İmamların Minberde Okuduğu Ayet',
      arabicHeader: 'إِنَّ اللَّهَ يَأْمُرُ بِالْعَدْلِ وَالْإِحْسَانِ وَإِيتَاءِ ذِي الْقُرْبَىٰ وَيَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ وَالْبَغْيِ ۚ يَعِظُكُمْ لَعَلَّكُمْ تَذَكَّرُونَ',
      verseOrHadith: '“Şüphesiz Allah; adaleti, iyiliği (ihsanı), akrabaya yardım etmeyi emreder; çirkin işleri (fahşâyı), kötülüğü (münkeri) ve azgınlığı (bağyi) da yasaklar. O, düşünüp tutasınız diye size öğüt verir.” (Nahl, 16/90)',
      summary: 'Her Cuma hutbesinin sonunda minberden okunan Nahl Suresi 90. ayet-i kerîmesi, İslam ahlakının veciz özetidir.',
      fullText:
          'Minberden Her Cuma Yükselen İlahi Öğüt (Nahl Suresi, 90. Ayet):\n'
          '“Şüphesiz Allah; adaleti, iyiliği, akrabaya yardım etmeyi emreder; çirkin işleri, fenalık ve azgınlığı da yasaklar. O, düşünüp tutasınız diye size öğüt verir.”\n\n'
          'Hutbe Duası:\n'
          '“Allah’ım! İslam’a ve Müslümanlara yardım eyle! Vatanımızı, milletimizi ve bütün İslam beldelerini her türlü afet, musibet ve fitneden muhafaza eyle! Geçmişlerimize rahmet, hastalarımıza şifa, ordumuza ve güvenlik güçlerimize nusret ihsan eyle! Âmin.”',
      source: 'Nahl Suresi, 90',
    ),
  ];

  @override
  ConsumerState<KazaTrackerScreen> createState() => _KazaTrackerScreenState();
}

class _KazaTrackerScreenState extends ConsumerState<KazaTrackerScreen>
    with SingleTickerProviderStateMixin {
  static const String _prefsKey = 'kaza_tracker_counts_v1';

  static const List<({String key, String title, String subtitle})>
  _kazaItems = <({String key, String title, String subtitle})>[
    (key: 'sabah', title: 'Sabah Namazı', subtitle: '2 rekât farz kaza namazı'),
    (key: 'ogle', title: 'Öğle Namazı', subtitle: '4 rekât farz kaza namazı'),
    (
      key: 'ikindi',
      title: 'İkindi Namazı',
      subtitle: '4 rekât farz kaza namazı',
    ),
    (key: 'aksam', title: 'Akşam Namazı', subtitle: '3 rekât farz kaza namazı'),
    (key: 'yatsi', title: 'Yatsı Namazı', subtitle: '4 rekât farz kaza namazı'),
    (
      key: 'vitir',
      title: 'Vitir Namazı',
      subtitle: '3 rekât vâcip kaza namazı (Hanefî)',
    ),
    (
      key: 'oruc',
      title: 'Ramazan Kaza Orucu',
      subtitle: 'Tutulamayan farz oruç gün sayısı',
    ),
  ];

  late final TabController _tabController = TabController(
    length: 2,
    initialIndex: widget.initialTab.clamp(0, 1),
    vsync: this,
  );
  final TextEditingController _searchController = TextEditingController();
  Map<String, int> _counts = <String, int>{};
  String _selectedCategory = 'Tümü';
  String _searchQuery = '';
  final Set<String> _expandedIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _load() {
    final Map<String, Object?>? raw = ref
        .read(runtimeProvider)
        .preferences
        .getJson(_prefsKey);
    if (raw == null) return;
    setState(() {
      _counts = <String, int>{
        for (final entry in raw.entries)
          if (entry.value is num) entry.key: (entry.value! as num).toInt(),
      };
    });
  }

  Future<void> _updateCount(String key, int delta) async {
    final int current = _counts[key] ?? 0;
    final int next = (current + delta).clamp(0, 99999);
    setState(() => _counts[key] = next);
    await ref.read(runtimeProvider).preferences.setJson(
      _prefsKey,
      <String, Object?>{
        for (final entry in _counts.entries) entry.key: entry.value,
      },
    );
  }

  Future<void> _addDaysForAllPrayers(int days) async {
    setState(() {
      for (final item in _kazaItems) {
        if (item.key == 'oruc') continue;
        _counts[item.key] = ((_counts[item.key] ?? 0) + days).clamp(0, 99999);
      }
    });
    await ref.read(runtimeProvider).preferences.setJson(
      _prefsKey,
      <String, Object?>{
        for (final entry in _counts.entries) entry.key: entry.value,
      },
    );
  }

  List<KhutbahItem> _filteredKhutbahs() {
    final String q = _searchQuery.trim().toLowerCase();
    return KazaTrackerScreen.khutbahCatalog
        .where((KhutbahItem item) {
          if (_selectedCategory != 'Tümü' &&
              item.category != _selectedCategory) {
            return false;
          }
          if (q.isEmpty) return true;
          return item.title.toLowerCase().contains(q) ||
              item.category.toLowerCase().contains(q) ||
              item.summary.toLowerCase().contains(q) ||
              item.verseOrHadith.toLowerCase().contains(q) ||
              item.fullText.toLowerCase().contains(q) ||
              item.source.toLowerCase().contains(q);
        })
        .toList(growable: false);
  }

  KhutbahItem _featuredWeeklyKhutbah() {
    final DateTime now = DateTime.now();
    final int dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final int weekIndex =
        (dayOfYear ~/ 7) % KazaTrackerScreen.khutbahCatalog.length;
    return KazaTrackerScreen.khutbahCatalog[weekIndex];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int totalRemaining = _kazaItems.fold<int>(
      0,
      (int sum, item) => sum + (_counts[item.key] ?? 0),
    );
    final List<KhutbahItem> filtered = _filteredKhutbahs();
    final KhutbahItem featured = _featuredWeeklyKhutbah();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaza Takibi & Hutbeler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            const Tab(text: 'Kaza Takibi'),
            Tab(
              text:
                  'Cuma Hutbeleri (${KazaTrackerScreen.khutbahCatalog.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          // SEKME 1: KAZA TAKİBİ
          ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.emerald700.withValues(alpha: 0.12),
                  borderRadius: AppRadius.allLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Toplam Kalan Kaza Borcu: $totalRemaining',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Kıldığınız her kaza namazı için (-) düğmesine dokunarak borcunuzdan düşebilirsiniz.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: () => _addDaysForAllPrayers(30),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('+1 Ay Namaz Borcu Ekle'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _addDaysForAllPrayers(365),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('+1 Yıl Namaz Borcu Ekle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final item in _kazaItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(item.subtitle),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Kaza kıldım (-1)',
                            onPressed: (_counts[item.key] ?? 0) <= 0
                                ? null
                                : () {
                                    HapticFeedback.selectionClick();
                                    _updateCount(item.key, -1);
                                  },
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                            ),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              '${_counts[item.key] ?? 0}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Borç ekle (+1)',
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              _updateCount(item.key, 1);
                            },
                            icon: const Icon(Icons.add_circle_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // SEKME 2: CUMA, BAYRAM VE KANDİL HUTBELERİ ARŞİVİ
          ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              // Haftanın Öne Çıkan Hutbesi Manşet Kartı
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[AppColors.emerald700, AppColors.emerald900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.allLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold400.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'HAFTANIN ÖNE ÇIKAN HUTBESİ',
                            style: TextStyle(
                              color: AppColors.gold400,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.mosque_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      featured.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      featured.summary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'Tümü';
                            _searchQuery = '';
                            _searchController.clear();
                            _expandedIds.add(featured.id);
                          });
                        },
                        icon: const Icon(Icons.menu_book_rounded, size: 16),
                        label: const Text('Tam Hutbeyi Aç'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Hutbe Arama Kutusu
              TextField(
                controller: _searchController,
                onChanged: (String value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText:
                      'Hutbe konusu, ayet, hadis veya anahtar kelime ara…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.clear_rounded),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Kategori Filtre Çipleri
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: KazaTrackerScreen.categories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (BuildContext context, int index) {
                    final String cat = KazaTrackerScreen.categories[index];
                    final bool selected = cat == _selectedCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text(
                      'Aramanızla eşleşen hutbe bulunamadı.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),

              for (final KhutbahItem khutbah in filtered)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _KhutbahCard(
                    khutbah: khutbah,
                    expanded: _expandedIds.contains(khutbah.id),
                    onToggleExpand: () {
                      setState(() {
                        if (_expandedIds.contains(khutbah.id)) {
                          _expandedIds.remove(khutbah.id);
                        } else {
                          _expandedIds.add(khutbah.id);
                        }
                      });
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KhutbahCard extends StatelessWidget {
  const _KhutbahCard({
    required this.khutbah,
    required this.expanded,
    required this.onToggleExpand,
  });

  final KhutbahItem khutbah;
  final bool expanded;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.emerald500.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    khutbah.category,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.emerald700,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.emerald500,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              khutbah.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Hutbe Arapça Serlevha Ayeti
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    khutbah.arabicHeader,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTheme.arabic(
                      theme.textTheme,
                      size: 19,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    khutbah.verseOrHadith,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              expanded ? khutbah.fullText : khutbah.summary,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Kaynak: ${khutbah.source}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              alignment: WrapAlignment.end,
              children: <Widget>[
                TextButton.icon(
                  onPressed: onToggleExpand,
                  icon: Icon(
                    expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                  ),
                  label: Text(expanded ? 'Özeti Göster' : 'Tam Hutbeyi Oku'),
                ),
                SpeakButton(
                  text:
                      '${khutbah.title}. ${khutbah.verseOrHadith}. '
                      '${khutbah.fullText} Kaynak: ${khutbah.source}.',
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final String text =
                        '${khutbah.title}\n\n${khutbah.arabicHeader}\n'
                        '${khutbah.verseOrHadith}\n\n${khutbah.fullText}\n\n'
                        'Kaynak: ${khutbah.source}';
                    await Clipboard.setData(ClipboardData(text: text));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hutbe metni panoya kopyalandı.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 15),
                  label: const Text('Kopyala'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(
                      text:
                          '${khutbah.title}\n\n${khutbah.arabicHeader}\n'
                          '${khutbah.verseOrHadith}\n\n${khutbah.fullText}\n\n'
                          '${khutbah.source} · (Ezan Vaktim Pro)',
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 16),
                  label: const Text('Hutbeyi / Mesajı Paylaş'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
