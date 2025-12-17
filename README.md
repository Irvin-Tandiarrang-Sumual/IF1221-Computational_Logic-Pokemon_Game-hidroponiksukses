# Pokemon Game - Logika Komputasional (IF1221)

Game berbasis Prolog yang menampilkan petualangan Pokemon dengan sistem pertarungan turn-based, inventory, eksplorasi peta 8x8, dan melawan boss legendaris Mewtwo!

## 📋 Spesifikasi Tugas

Untuk detail lengkap spesifikasi tugas, silakan buka: [Spesifikasi Tubes IF1221](https://docs.google.com/document/u/2/d/12IfjPJJhemFAprsZS4v4qaOv9gwp5gyF81HyTbExHp4/mobilebasic?pli=1)

**Implementasi:** Tugas ini mengimplementasikan semua fitur yang terdapat dalam spesifikasi termasuk fitur bonus.


## 🚀 Cara Menjalankan

### Prerequisites
- GNU Prolog terinstall di sistem Anda
- Terminal/Command Prompt

### Langkah-langkah:

1. **Buka GNU Prolog**
   ```bash
   gprolog
   ```

2. **Load file main**
   ```prolog
   ?- consult('src/main.pl').
   ```

3. **Jalankan game**
   ```prolog
   ?- start.
   ```

4. **Keluar dari game**
   ```prolog
   ?- exit.
   ```

## 📁 Struktur Project

```
src/
├── main.pl              # File utama untuk menjalankan game
├── player.pl            # Logika pemain dan status
├── map.pl               # Sistem peta dunia 8x8
├── battle.pl            # Sistem pertarungan Pokemon turn-based
├── inventory.pl         # Sistem tas dengan 40 slot
├── side-quest.pl        # Quest dan misi tambahan
├── end-game.pl          # Logika boss akhir dan end game
├── interaction-map.pl   # Interaksi dengan peta dan Pokemon
├── help.pl              # Daftar command bantuan
├── ascii.pl             # ASCII art untuk visual Pokemon
└── variable.pl          # Variabel global dan dinamis
```


## 🎮 Daftar Command

### Command Dasar

| Command | Deskripsi |
|---------|-----------|
| `help` | Tampilkan semua command yang tersedia |
| `start` | Mulai permainan baru |
| `exit` | Keluar dari permainan |

### Command Eksplorasi

| Command | Deskripsi |
|---------|-----------|
| `moveUp` | Gerakkan pemain ATAS satu tile |
| `moveLeft` | Gerakkan pemain KIRI satu tile |
| `moveDown` | Gerakkan pemain BAWAH satu tile |
| `moveRight` | Gerakkan pemain KANAN satu tile |
| `showMap` | Tampilkan visualisasi peta 8x8 |
| `showBag` | Tampilkan isi tas/inventory |
| `status` | Lihat status semua Pokemon di party |
| `setParty` | Mengatur Pokemon pada party |

### Command Pertarungan (Battle)

| Command | Deskripsi |
|---------|-----------|
| `attack` | Lakukan serangan fisik standar |
| `defend` | Naikkan pertahanan 30% untuk 1 turn |
| `skill(N)` | Gunakan skill Pokemon (slot 1 atau 2) |
| `switch(IdxDeck, IdxTas)` | Ganti Pokemon aktif (hanya di ronde awal) |

### Command Interaksi

| Command | Deskripsi |
|---------|-----------|
| `heal` | Pulihkan semua Pokemon ke HP penuh di PokeCenter (Max 2x) |
| `interact` | Berinteraksi dengan Pokemon yang ditemukan |

## 👥 Contributors

| Nama | NIM |
|------|-----|
| Irvin Tandiarrang Sumual | 13524030 |
| Bernhard Aprilio Pramana | 13524074 |
| Moreno Syawali Sugita Ganda | 13524096 |
| Jennifer Khang | 13524110 |
| Nathaniel Christian | 13524122 |

## 📝 Catatan Pengembangan

- **Bahasa:** Prolog (GNU Prolog)
- **Implementasi Fitur Utama:** Rekurens, List, Cut, Fail, Loop
- **Status:** ✅ Semua fitur wajib telah diimplementasikan
- **Status Bonus:** ✅ Fitur bonus diimplementasikan
