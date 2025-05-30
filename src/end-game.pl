
/* File lain */
:- include('variable.pl').
:- include('player.pl').
:- include('battle.pl').

/* Pembuka cerita di final stage */
print_end_game_opening :-
    nl,
    write('Selamat datang di final stage !!'), nl,
    write('Persiapkan dirimu !'), nl,
    write('Kamu akan melawan THE MIGHTY MEWTWO !!'), nl.

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
    write('Level: '), write(Level1), nl,
    write('HP: '), write(MaxHP), nl,
    write('ATK: '), write(ATK), nl,
    write('DEF: '), write(DEF), nl,
    retractall(defendStatus(_, _)),
    assertz(defendStatus(1,1)).

/* Final battle */
start_final_battle :-
    print_end_game_opening,
    retractall(situation(_)),
    assertz(situation(ongoing)),
    buat_lawan_mewtwo,
    battle, 
    turn.

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