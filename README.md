# Anvers Liman Teslimat Yönetim Sistemi

Belçika'nın Anvers Limanı'nda çalışan TIR şoförleri ve filo yöneticileri için geliştirilmiş, teslimat süreçlerinin dijital olarak yönetilmesini sağlayan Flutter tabanlı mobil/web uygulamasıdır.

## Proje Özeti

Anvers Liman Teslimat Yönetim Sistemi; şoförlerin teslimat kayıtlarını oluşturmasını, liman ücretlerini hesaplamasını, çok dilli teklif ve fatura belgeleri oluşturmasını ve yöneticilerin teslimat, şoför ve tarife bilgilerini merkezi olarak yönetmesini sağlayan bir uygulamadır.

Uygulama iki farklı kullanıcı rolüne sahiptir:

* **Şoför:** Teslimat oluşturma, hızlı teklif hesaplama, tarife görüntüleme, geçmiş kayıtları inceleme ve PDF teklif/fatura oluşturma
* **Yönetici:** Teslimatları görüntüleme ve yönetme, şoförleri takip etme ve sistem tarifelerini düzenleme

## Özellikler

* Firebase Authentication ile kullanıcı kayıt ve giriş işlemleri
* Şoför ve yönetici rolleri
* Yeni teslimat oluşturma
* Hızlı teklif ve fiyat hesaplama
* Haven, tünel, ADR, genset ve dizel ek ücretlerinin hesaplanması
* Km ve bölge bazlı tarife yönetimi
* Çok dilli teklif ve fatura oluşturma
* PDF oluşturma ve paylaşma
* Teslimat geçmişinin görüntülenmesi
* Yönetici dashboard'u
* Şoför yönetimi
* Sistem ve tarife ayarlarının yönetimi
* Uygulama içi bildirimler
* Responsive mobil ve web deneyimi
* Türkçe, Flemenkçe, Fransızca, İngilizce ve Almanca dil desteği

## Mimari

Proje, Flutter ekosistemine uygun **Clean Architecture** yaklaşımı kullanılarak geliştirilmiştir.

```text
lib/
├── core/
│   ├── constants/
│   ├── l10n/
│   ├── router/
│   ├── theme/
│   └── utils/
│
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── domain/
│   ├── entities/
│   └── usecases/
│
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
│
├── firebase_options.dart
└── main.dart
```

Uygulama içerisinde veri, domain ve presentation katmanları birbirinden ayrılarak daha düzenli ve sürdürülebilir bir yapı oluşturulmuştur. State management için Riverpod, sayfa yönlendirme ve yetkilendirme kontrolleri için GoRouter kullanılmaktadır.

## Kullanılan Teknolojiler

| Teknoloji                   | Kullanım Alanı                        |
| --------------------------- | ------------------------------------- |
| **Flutter**                 | Mobil ve web uygulama geliştirme      |
| **Dart**                    | Uygulama geliştirme dili              |
| **Riverpod**                | State management                      |
| **GoRouter**                | Sayfa yönlendirme ve auth guard       |
| **Firebase Authentication** | Kullanıcı kimlik doğrulama            |
| **Cloud Firestore**         | Veritabanı                            |
| **Firebase Storage**        | Dosya ve görsel depolama              |
| **Firebase Analytics**      | Kullanım analitikleri                 |
| **Firebase Remote Config**  | Dinamik sistem ve tarife ayarları     |
| **Hive**                    | Yerel veri depolama                   |
| **Shared Preferences**      | Yerel anahtar-değer depolama          |
| **PDF / Printing**          | PDF oluşturma ve paylaşma             |
| **Share Plus**              | Platformlar arası paylaşım            |
| **FL Chart**                | Grafik ve veri görselleştirme         |
| **Lottie**                  | Animasyonlar                          |
| **Dio**                     | HTTP istekleri                        |
| **Freezed**                 | Veri modeli ve immutable yapı desteği |

## Firebase Entegrasyonu

Uygulamada Firebase'in birden fazla servisi kullanılmaktadır:

* **Firebase Authentication** — Kullanıcı kayıt ve giriş işlemleri
* **Cloud Firestore** — Teslimat, kullanıcı, tarife ve fatura verilerinin saklanması
* **Firebase Storage** — Dosya ve görsel depolama
* **Firebase Analytics** — Kullanım verilerinin izlenmesi
* **Firebase Remote Config** — Ücret ve tarife bilgilerinin dinamik olarak yönetilmesi

## Veri Yapısı

Uygulamada temel olarak aşağıdaki veri yapıları kullanılmaktadır:

* **DeliveryModel** — Teslimat bilgileri, ücretler, tarife ve teklif durumları
* **UserProfileModel** — Kullanıcı rolü ve hesap aktivasyon bilgileri

Firestore içerisinde;

```text
deliveries/
users/
tariffs/
invoices/
companies/
havens/
```

koleksiyonları kullanılmaktadır.

## Çoklu Dil Desteği

Teklif ve fatura belgeleri aşağıdaki dillerde oluşturulabilmektedir:

* Türkçe
* Flemenkçe
* Fransızca
* İngilizce
* Almanca

## Platform Desteği

Uygulama aşağıdaki platformlar için tasarlanmıştır:

* Android
* iOS
* Web

## Geliştirici

**Berk Yüksel**

Bilgisayar Mühendisi
Frontend Developer

---

Anvers Limanı'ndaki teslimat süreçlerinin, fiyatlandırma işlemlerinin ve yönetim süreçlerinin dijital ortamda daha düzenli şekilde yürütülmesini amaçlayan bir yazılım projesidir.
