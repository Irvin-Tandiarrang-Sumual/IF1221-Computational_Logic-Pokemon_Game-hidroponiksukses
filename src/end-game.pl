:- dynamic(final_mode/1).
:- dynamic(mewtwo_defeated/0).

/* cek udh end game atau belum */
final_mode(false).

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
    base_stats(HPBase, ATKBase, DEFBase, Nama),
    MaxHP is HPBase + 2 * Level,
    ATK is ATKBase + 1 * Level,
    DEF is DEFBase + 1 * Level,
    retractall(statusLawan(_,_,_,_,_,_)),
    assertz(statusLawan(MaxHP, MaxHP, ATK, DEF, Nama, 99)),
    write('Kamu melawan '), write(Nama), nl,
    write('Level: '), write(Level), nl,
    write('HP: '), write(MaxHP), nl,
    write('ATK: '), write(ATK), nl,
    write('DEF: '), write(DEF), nl,
    retractall(defendStatus(_, _)),
    assertz(defendStatus(1,1)).

/* Final battle */
start_final_battle :-
    \+ final_mode(true),
    print_end_game_opening,
    retractall(situation(_)),
    assertz(situation(ongoing)),
    final_battle, 
    retractall(final_mode(_)),
    assertz(final_mode(true)),
    quiz_pokemon(mewtwo),
    turn.

/* Battle endgame */
final_battle :-
    buat_lawan_mewtwo,
    player_level(LevelKita),
    base_stats(HPBase, ATKBase, DEFBase, pikachu),
    MaxHPKita is HPBase + 2 * LevelKita,
    ATKKita is ATKBase + 1 * LevelKita,
    DEFKita is DEFBase + 1 * LevelKita,
    retractall(statusKita(_,_,_,_,_,_)),
    assertz(statusKita(MaxHPKita, MaxHPKita, ATKKita, DEFKita, pikachu, 1)),
    retractall(myTurn),
    assertz(myTurn),
    retractall(cooldown_kita(_, _)),
    retractall(cooldown_lawan(_, _)),
    assertz(cooldown_kita(0, 0)),
    assertz(cooldown_lawan(0, 0)),
    true.

/* check keadaan end game */
check_endgame :-
    situation(win), !,
    print_win_message;
    situation(lose), !,
    print_lose_message,
    situation(ongoing), !,
    write('Pertarungan masih berlanjut . . .'), nl.

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