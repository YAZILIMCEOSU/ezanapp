# AI İslam Asistanı — bilgi tabanı ve yanıt kuralları

Bu belge, AI asistanının **nasıl cevap ürettiğini**, cevapların hangi kurallara
uymak zorunda olduğunu ve bilgi tabanına nasıl yeni kayıt ekleneceğini anlatır.

## 1. Yanıt zinciri

```
soru
 └─ 1) Yerel bilgi tabanı eşleştirmesi (çevrimdışı, anahtar kelime + başlık puanı)
     └─ eşleşme varsa: kaynaklı, mezhep notlu, uyarılı cevap  → AiAnswerMode.offline
 └─ 2) Backend `/ai/ask` (yalnızca EZANAI_API_BASE tanımlıysa)  → AiAnswerMode.remote
     └─ yanıt kaynaksız dönerse **kabul edilmez**, 3. adıma düşülür
 └─ 3) Dürüst "bilmiyorum" cevabı + öneri sorular
```

API anahtarı **hiçbir zaman** uygulamaya gömülmez; uzak çağrı yalnızca
`AppConfig.hasBackend` doğruysa ve kendi backend'iniz üzerinden yapılır
(`docs/RELEASE.md` §3). İnternet yoksa 1. adım devreye girer; uygulama
kullanılamaz hâle gelmez.

## 2. Değişmez içerik kuralları

Her kayıt şu kurallara uyar (testler bunu zorunlu kılar):

1. **Kaynak zorunlu**: en az bir künye (`citations`) olmadan kayıt eklenemez.
   Künye Kur'an, sahih hadis veya güvenilir fıkıh kaynağı olmalıdır.
2. **Kesin hüküm vermez**: her cevabın sonunda kullanıcıya "bu bilgi genel
   bilgilendirme amaçlıdır, kesin dini hüküm değildir" uyarısı gösterilir
   (`AiAnswer.disclaimer`).
3. **Mezhep farkları ayrılır**: ihtilaf bulunan konularda `madhabNotes` alanı
   doldurulur ve arayüzde ayrı bir bölüm olarak, kaynakla birlikte gösterilir.
4. **Mezhep belirtilir**: bir görüş yalnızca Hanefî'ye aitse "Hanefî'ye göre"
   denir; genel kural gibi yazılmaz.
5. **Uydurma yok**: eşleşme puanı eşiğin altındaysa cevap üretilmez; kullanıcıya
   "kaynakla doğrulayamadım" denir ve müftülüğe danışması önerilir.
6. **Tıbbi/hukuki kesinlik yok**: konu tıp, hukuk veya kişisel duruma bağlıysa
   uzman/müftü yönlendirmesi yapılır.

## 3. Kayıt şeması

`lib/data/ai/knowledge_base.dart` içindeki `KnowledgeEntry`:

| Alan | Tür | Açıklama |
|---|---|---|
| `id` | `String` | Benzersiz kimlik (örn. `vitir_teravih`), `related` bu kimliği kullanır |
| `title` | `String` | Kısa başlık; öneri listesinde kullanıcıya gösterilir |
| `keywords` | `List<String>` | Küçük harf, **aksansız** arama anahtarları |
| `answer` | `String` | 1-3 cümlelik doğrudan cevap |
| `details` | `List<String>` | Maddeli ayrıntılar |
| `citations` | `List<String>` | Künyeler (`Kur'an...`, `Buhârî...`, `Müslim...`) |
| `madhabNotes` | `List<String>` | Mezhep/ekol farkları (ihtilaf varsa zorunlu kabul edilir) |
| `related` | `List<String>` | İlişkili kayıt **kimlikleri**; cevapta başlığa çevrilip önerilir |
| `category` | `String` | `Namaz`, `Oruç`, `Mali İbadet`, `Kur'an`, `Hac`, `Fıkıh`… |

## 4. Eşleştirme puanlaması

`LocalKnowledgeSource`, her kayıt için bir puan hesaplar ve en yüksek puanı
`2,2`'nin üzerinde olan kaydı döndürür:

- **Anahtar kelime katkısı**: soruda birebir geçme (`3 + uzunluk/12`) ve kelime
  örtüşmesi (tam eşleşme `2 × kelime sayısı`, kısmi `0,6 × kelime`) toplamı,
  terimin **ayırt ediciliğiyle** (IDF) çarpılır.
- **IDF**: bilgi tabanındaki tüm kayıtların anahtar kelimeleri ve başlıkları
  taranarak hesaplanır. Her kayıtta geçen "namaz" gibi kelimeler `0,35`,
  yalnız bir kayıtta geçen "vitir" gibi kelimeler `1,2` ağırlık alır
  (`_TermWeights`, ilk kullanımda bir kez kurulup önbelleğe alınır).
- **Başlık katkısı**: başlık kelimeleriyle **kök örtüşmesi** (Türkçe ekleri kaba
  biçimde kırpan `TextNormalizer.stem`) `0,9 × IDF` katkı sağlar.

Bu model, "Vitir namazı kaç rekâttır?" sorusunun genel "namaz rekatları"
kaydına değil **vitir** kaydına gitmesini sağlar; `test/data/knowledge_base_test.dart`
62 etiketli soruyla bu davranışı korur.

> Kural: bir kayda **genel soru kalıbı** (örn. "kaç rekat") anahtar kelime olarak
> eklenmez; kalıplar başka kayıtların konusunu gölgeler.

## 5. Yeni kayıt ekleme adımları

1. Konunun kaynakla doğrulanabilir olduğundan emin olun (Kur'an, sahih hadis,
   güvenilir fıkıh kaynağı). Emin değilseniz kayıt eklemeyin.
2. `KnowledgeBase.entries` listesine ilgili yere kaydı ekleyin (kimlik benzersiz,
   anahtar kelimeler küçük harf ve aksansız).
3. İhtilaf varsa `madhabNotes` doldurun; görüşleri mezhep adıyla ayırın.
4. `related` alanına **var olan** kimlikleri yazın.
5. Testleri çalıştırın:

```bash
flutter test test/data/knowledge_base_test.dart
```

Testler; kaynak zorunluluğunu, anahtar kelime hijyenini (ASCII + küçük harf),
geçerli `related` bağlantılarını, mezhep notu sayısını, eşleştirme doğruluğunu ve
"bilgi tabanı dışı soruya cevap vermeme" davranışını doğrular.

## 6. Uzak (backend) yanıt sözleşmesi

İstek — `POST {EZANAI_API_BASE}/ai/ask`:

```json
{
  "question": "Zekât kimlere verilir?",
  "language": "tr",
  "madhab": "hanefi",
  "history": [ { "role": "user", "text": "..." }, { "role": "assistant", "text": "..." } ]
}
```

Yanıt — 200 ve JSON nesnesi (`answer` yerine `text` de kabul edilir):

```json
{
  "answer": "Zekât, Tevbe 9/60'ta sayılan sekiz sınıfa verilir…",
  "sources": [
    "Kur'an-ı Kerim, Tevbe 9/60",
    { "label": "Buhârî, Zekât 1", "kind": "hadith", "detail": "Hadis kaynağı" }
  ],
  "madhab_notes": ["Hanefî'de …", "Şâfiî'de …"]
}
```

- `sources` boş veya eksikse istemci yanıtı **reddeder** (`FormatException`) ve
  yerel bilgi tabanından yanıtlar; bu davranış `AiService._askRemote` içinde
  zorunludur — kaynaksız cevap kullanıcıya gösterilmez.
- `sources` öğeleri düz metin (`"Buhârî, İlim 1"`) ya da nesne olabilir; nesnede
  `label` (zorunlu) ve `kind` (`quran` | `hadith` | `fiqh` | `other`), `detail`,
  `url` alanları okunur.
- İstek zaman aşımı ve hata durumlarında istemci çökmez; `AiService.ask` sırayla
  yerel tabana, ardından dürüst "bilmiyorum" yanıtına düşer.
- Backend yanıtları da aynı içerik kurallarına (kaynak, mezhep ayrımı, kesin
  hüküm vermeme) uymak zorundadır; istemci her cevaba uyarı metnini ekler.
