# Finance App Refactor Final

Perubahan utama:

- Semua reusable widget dipindah ke `lib/core/widgets/`.
- Theme global dipusatkan di `lib/core/app_theme.dart`.
- Text style global dipusatkan di `lib/core/app_text_styles.dart`.
- Warna global tetap di `lib/core/app_colors.dart`.
- Icon global tetap di `lib/core/app_icons.dart`.
- Screen Dashboard, Login, Register, Category, Transaction Form, dan Transaction List sudah memakai pola reusable widget yang sama.
- `transaction_form_screen.dart` dan `transaction_list_screen.dart` dipangkas cukup besar agar tidak terlalu banyak widget manual di screen.

## Struktur baru

```txt
lib/
  core/
    app_colors.dart
    app_icons.dart
    app_text_styles.dart
    app_theme.dart
    widgets/
      app_widgets.dart
      summary_card.dart
      transaction_tile.dart
```

## Cara custom icon menu Dashboard

Buka:

```txt
lib/screens/dashboard/dashboard_screen.dart
```

Contoh menu:

```dart
DashboardAction(
  title: 'Tambah',
  subtitle: 'Transaksi',
  icon: AppIcons.dashboardAdd,
  color: AppColors.primary,
  onTap: _openAddTransaction,
  // assetIcon: 'assets/icons/add.svg',
),
```

Untuk pakai logo sendiri:

1. Masukkan file icon ke `assets/icons/`.
2. Aktifkan `assetIcon`.
3. Daftarkan di `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/icons/
```

## Setelah replace folder lib

Jalankan:

```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```
