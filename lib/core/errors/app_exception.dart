/// Uygulama genelinde kullanıcı dostu hata modeli.
class AppException implements Exception {
  const AppException(this.message, {this.detail, this.isRetryable = true});

  final String message;
  final String? detail;
  final bool isRetryable;

  factory AppException.network([String? detail]) => AppException(
    'İnternet bağlantısı kurulamadı. Çevrimdışı veriler kullanılıyor.',
    detail: detail,
  );

  factory AppException.timeout([String? detail]) => AppException(
    'Sunucu yanıt vermedi. Lütfen tekrar deneyin.',
    detail: detail,
  );

  factory AppException.permission(String permission) => AppException(
    '$permission izni verilmedi. Ayarlardan izin vererek bu özelliği kullanabilirsiniz.',
    isRetryable: false,
  );

  factory AppException.locationDisabled() => const AppException(
    'Konum servisleri kapalı. Lütfen cihaz ayarlarından konumu açın.',
    isRetryable: false,
  );

  factory AppException.notConfigured(String feature) => AppException(
    '$feature için yapılandırma eksik. Yönetici ayarlarını kontrol edin.',
    isRetryable: false,
  );

  factory AppException.parse(String detail) => AppException(
    'Veri okunamadı. Uygulama son başarılı veriyi göstermeye devam edecek.',
    detail: detail,
  );

  factory AppException.unexpected(Object error, [StackTrace? stackTrace]) =>
      AppException(
        'Beklenmeyen bir sorun oluştu. Lütfen tekrar deneyin.',
        detail: '$error\n${stackTrace ?? ''}',
      );

  @override
  String toString() => detail == null ? message : '$message ($detail)';
}

/// Sonuç tipi: hata yönetimini akış içinde taşımak için.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppException error) = Failure<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(:final T value) => value,
    Failure<T>() => null,
  };

  AppException? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final AppException error) => error,
  };

  bool get isSuccess => this is Success<T>;

  R when<R>({
    required R Function(T value) success,
    required R Function(AppException error) failure,
  }) => switch (this) {
    Success<T>(:final T value) => success(value),
    Failure<T>(:final AppException error) => failure(error),
  };
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppException error;
}
