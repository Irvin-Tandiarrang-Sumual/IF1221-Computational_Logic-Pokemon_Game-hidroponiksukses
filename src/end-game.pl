:- dynamic(mewtwo_defeated/0).

/* Pembuka cerita di final stage */
print_end_game_opening :-
    nl,
    write('========================================'), nl,
    write('         FINAL STAGE - LAST BATTLE       '), nl,
    write('========================================'), nl,
    write('Selamat datang di final stage!!'), nl,
    write('Persiapkan dirimu!'), nl,
    write('Kamu akan melawan...'), nl,
    write('THE MIGHTY MEWTWO!!!'), nl, nl.

/* buat mewtwo */
buat_lawan_mewtwo :-
    Nama = mewtwo,
    Level = 20,
    Level1 is Level -1,
    base_stats(HPBase, ATKBase, DEFBase, Nama),
    MaxHP is HPBase + 2 * Level1,
    ATK is ATKBase + 1 * Level1,
    DEF is DEFBase + 1 * Level1,
    type(Type, Nama),
    retractall(statusLawan(_, _, _, _, _, _, _)),
    assertz(statusLawan(MaxHP, MaxHP, ATK, DEF, Nama, 99, Type)),
    retractall(enemy_level(_)),
    assertz(enemy_level(Level)),
    pokemon(ID, Nama, _),
    pokemon_ascii(ID),
    write('Kamu melawan '), write(Nama), write('.'), nl,
    write('Level: '), write(Level), nl,
    write('HP: '), write(MaxHP), nl,
    write('ATK: '), write(ATK), nl,
    write('DEF: '), write(DEF), nl, nl,
    write('Pilih Pokemon mu dari party!'), nl,
    daftar_party,
    pilih_pokemon,
    retractall(defendStatus(_, _)),
    assertz(defendStatus(1, 1)),
    true.

/* check keadaan end game */
check_endgame :-
    ( situation(win) -> print_win_message
    ; situation(lose) -> print_lose_message
    ; true
    ).


/* print pesan kekalahan */
print_lose_message :-
    nl,
    write('☠☠☠ GAME OVER ☠☠☠'), nl,
    write('KAMU KALAH HAHAHAHAHAHAHA'), nl,
    write('Silahkan mulai dari awal'), nl.

/* print pesan kemenangan */
print_win_message :-
    nl,
    write('🏆🏆🏆 SELAMAT! 🏆🏆🏆'), nl,
    write('Kamu telah mengalahkan semua lawan dan menjadi Juara Pokemon sejati!'), nl,
    write('Sampai jumpa di petualangan lainnya!'), nl.