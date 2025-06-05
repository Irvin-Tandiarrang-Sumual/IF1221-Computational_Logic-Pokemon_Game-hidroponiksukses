:- use_module(library(random)).
:- dynamic(myTurn/0).
:- dynamic(situation/1).
:- dynamic(statusKita/7).
:- dynamic(statusLawan/7).
:- dynamic(defendStatus/2).
:- dynamic(statusEfekKita/1).
:- dynamic(statusEfekLawan/1).
:- dynamic(cooldown_kita/2).
:- dynamic(cooldown_lawan/2).
:- dynamic(player_level/1).
:- dynamic(enemy_level/1).


random_between(Low, High, R) :-
    Range is High - Low + 1,
    random(XFloat),
    XInt is floor(XFloat * 1000000),
    R0 is XInt mod Range,
    R is Low + R0.

daftar_party :-
    findall(Index-Nama, party(Index, Nama), List),
    sort(List, Sorted), % sort biar urut indeks
    write('Daftar Pokémon dalam party kamu:'), nl,
    tampilkan_party(Sorted).

tampilkan_party([]).
tampilkan_party([Index-Nama | T]) :-
    format('~w: ~w~n', [Index, Nama]),
    tampilkan_party(T).

pilih_pokemon :-
    write('Masukkan indeks Pokémon yang ingin kamu gunakan: '), nl,
    write('>> '),
    read(Index),
    (   party(Index, Nama) ->
        level(LevelKita,Nama,Index, _, 1),
        base_stats(HPBase, ATKBase, DEFBase, Nama),
        Level1 is LevelKita -1,
        MaxHPKita is HPBase + 2 * Level1,
        ATKKita is ATKBase + 1 * Level1,
        DEFKita is DEFBase + 1 * Level1,
        type(Type, Nama),
        retractall(statusKita(_, _, _, _, _, _, _)),
        assertz(statusKita(MaxHPKita, MaxHPKita, ATKKita, DEFKita, Nama, LevelKita, Type)),
        retractall(player_level(_)),
        assertz(player_level(LevelKita)),
        format('Kamu memilih ~w sebagai Pokemon utama!~n', [Nama])
    ;   write('Indeks tidak ditemukan dalam party.'), nl,
        pilih_pokemon  % Ulangi jika salah input
    ).

buat_lawan(Rarity) :-
    pokeRandomizer(Rarity, Nama),
    
    % Ambil remaining moves
    remaining_moves(Remaining),

    % Hitung batas level berdasarkan remaining_moves
    LevelMin is min(14, max(2, round(2 + (20 - Remaining) / 2))),
    LevelMax is min(14, max(LevelMin, round(4 + (20 - Remaining) / 1.5))),
    random_between(LevelMin, LevelMax, Level),
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

% Pilih pokemon secara acak berdasarkan rarity
pokeRandomizer(common, Nama) :-
    findall(N, pokemon(_, N, common), CommonList),
    random_member(Nama, CommonList).

pokeRandomizer(rare, Nama) :-
    findall(N, pokemon(_, N, rare), RareList),
    random_member(Nama, RareList).

pokeRandomizer(epic, Nama) :-
    findall(N, pokemon(_, N, epic), EpicList),
    random_member(Nama, EpicList).

pokeRandomizer(legendary, Nama) :-
    findall(N, pokemon(_, N, legendary), LegendaryList),
    random_member(Nama, LegendaryList).

battle(Rarity) :-
    retractall(situation(_)),
    assertz(situation(ongoing)),

    buat_lawan(Rarity),

    base_stats(HPBase, ATKBase, DEFBase, PokemonKita),
    retractall(myTurn),
    assertz(myTurn),

    random_between(1, 10, R),
    (R >= 9 ->
        statusLawan(_, _, _, _, NamaLawan, _, _),
        quiz_pokemon(NamaLawan)
    ; true),

    % Inisialisasi cooldown
    retractall(cooldown_kita(_, _)),
    retractall(cooldown_lawan(_, _)),
    assertz(cooldown_kita(0, 0)),
    assertz(cooldown_lawan(0, 0)),

    % Mulai giliran
    turn.

get_status(HP, MaxHP, ATK, DEF, Nama, ID, Type) :-
    ( myTurn -> statusKita(HP, MaxHP, ATK, DEF, Nama, ID, Type)
    ; statusLawan(HP, MaxHP, ATK, DEF, Nama, ID, Type) ).

update_status(NewHP, MaxHP, ATK, DEF, Nama, ID, Type) :-
    ( myTurn ->
        retract(statusKita(_, _, _, _, _, _, _)),
        assertz(statusKita(NewHP, MaxHP, ATK, DEF, Nama, ID, Type))
    ; 
        retract(statusLawan(_, _, _, _, _, _, _)),
        assertz(statusLawan(NewHP, MaxHP, ATK, DEF, Nama, ID, Type))
    ).

ignore(Goal) :- call(Goal), !.
ignore(_).

turn :-
    situation(ongoing), !,
    apply_turn_effects,
    reset_defend,
    statusKita(HP1, _, _, _, Name1, _, _),
    statusLawan(HP2, _, _, _, Name2, _, _),
    ( HP1 =< 0 ->
        format('~w kamu kalah!~n', [Name1]),
        write('Noob amat bang...'), nl,
        assertz(situation(lose))
    ; HP2 =< 0 ->
        format('Pokemon ~w kalah! Kamu menang!~n', [Name2]),
        statusLawan(_, _, _, _, Nama, _, _), pokemon(_, Nama, Rarity), rarity(Rarity, _, Y, _),
        enemy_level(Z),
        X is Y + Z*2,
        ignore((party(1, Nama1), addExp(X, 1, Nama1))),
        ignore((party(2, Nama2), addExp(X, 2, Nama2))),
        ignore((party(3, Nama3), addExp(X, 3, Nama3))),
        ignore((party(4, Nama4), addExp(X, 4, Nama4)))
    ; myTurn ->
        handle_player_turn, nl
    ; handle_enemy_turn
    ).

turn :-
    situation(Status),
    format('Pertarungan selesai! Hasil: ~w~n', [Status]).

handle_player_turn :-
    statusEfekKita(sleep(T)), T > 0, !,
    NewT is T - 1,
    retract(statusEfekKita(sleep(T))),
    (NewT > 0 -> assertz(statusEfekKita(sleep(NewT))) ; true),
    statusKita(_, _, _, _, Name, _, _),
    write(Name), write(' sedang tidur... turn dilewati.'), nl.

handle_player_turn :-
    statusKita(CurHP, _, _, _, Name, _, _),
    write('Giliran kamu! Pilih aksi: attack. | defend. | skill(N).').

handle_enemy_turn :-
    statusEfekLawan(sleep(T)), T > 0, !,
    NewT is T - 1,
    retract(statusEfekLawan(sleep(T))),
    (NewT > 0 -> assertz(statusEfekLawan(sleep(NewT))) ; true),
    statusLawan(_, _, _, _, Name, _, _),
    write(Name), write(' sedang tidur... turn dilewati.'), nl.

handle_enemy_turn :-
    statusLawan(CurHP, _, _, _, Name, _, _),
    situation(ongoing),  % penting: lanjut hanya jika battle belum selesai
    enemy_action.

reset_defend :-
    ( myTurn ->
        retract(defendStatus(DefMulKita, DefMulLawan)),
        assertz(defendStatus(DefMulKita, 1))
    ;
        retract(defendStatus(DefMulKita, DefMulLawan)),
        assertz(defendStatus(1, DefMulLawan))
    ).

toggle_turn :-
    ( myTurn -> retractall(myTurn) ; assertz(myTurn) ).

defend :-
    ( myTurn ->
        defendStatus(DefMulKita, DefMulLawan),
        retractall(defendStatus(_, _)),
        assertz(defendStatus(1.3, DefMulLawan)),
        statusKita(CurHP, _, _, _, Name, _, _),
        write(Name), write(' bertahan! DEF naik 30% untuk 1 turn.'), nl
    ;
        defendStatus(DefMulKita, DefMulLawan),
        retractall(defendStatus(_, _)),
        assertz(defendStatus(DefMulKita, 1.3)),
        statusLawan(CurHP, _, _, _, Name, _, _),
        write(Name), write(' bertahan! DEF naik 30% untuk 1 turn.'), nl
    ), toggle_turn,
    turn.

attack :-
    damage_skill(1, neutral), toggle_turn,
    turn.

skill(SkillNumber) :-
    myTurn,
    statusKita(_, _, _, _, NamaPokemon, Level, _),
    cooldown_kita(CD1, CD2),
    pokeSkill(NamaPokemon, Skill1, Skill2),
    (
        SkillNumber =:= 1 ->
            ( CD1 > 0 ->
                write('Skill 1 masih cooldown '), write(CD1), write(' turn.'), nl, fail
            ;
                NamaSkill = Skill1,
                NewCD1 = 1
            )
    ;
        SkillNumber =:= 2 ->
            ( Level < 5 ->
                write('Skill 2 hanya dapat digunakan jika level minimal 5!'), nl, fail
            ;
                ( CD2 > 0 ->
                    write('Skill 2 masih cooldown '), write(CD2), write(' turn.'), nl, fail
                ;
                    NamaSkill = Skill2,
                    NewCD2 = 2
                )
            )
    ;
        write('Skill tidak valid! Pilih 1 atau 2.'), nl, fail
    ),
    % Jalankan
    skills(NamaSkill, AtkType, Power, Ability, Chance),
    format('~w used ~w!~n', [NamaPokemon, NamaSkill]),
    damage_skill(Power,  AtkType),
    apply_ability(Ability, Chance),
    % Update cooldown setelah penggunaan
    ( SkillNumber =:= 1 ->
        retract(cooldown_kita(_, CD2)),
        assertz(cooldown_kita(NewCD1, CD2))
    ;
        retract(cooldown_kita(CD1, _)),
        assertz(cooldown_kita(CD1, NewCD2))
    ), toggle_turn,
    turn.

damage_skill(Power, Elmt) :-
    calculate_damage(Power, Damage, Elmt),
    ( myTurn ->
        retract(statusLawan(CurHP, MaxHP, ATK, DEF, Defender, 99, Type)),
        NewHP is max(0, CurHP - Damage),
        assertz(statusLawan(NewHP, MaxHP, ATK, DEF, Defender, 99, Type))
    ; 
        retract(statusKita(CurHP, MaxHP, ATK, DEF, Defender, ID, Type)),
        NewHP is max(0, CurHP - Damage),
        assertz(statusKita(NewHP, MaxHP, ATK, DEF, Defender, ID, Type))
    ),
    format('Serangan memberikan ~w damage ke ~w. Sisa HP: ~w~n', [Damage, Defender, NewHP]).

calculate_damage(Power, Damage, Elmt) :-
    ( integer(Power) -> P = Power ; P is round(Power) ),
    ( myTurn ->
        statusKita(_, _, ATK, _, _, _, _),
        statusLawan(_, _, _, DEFD, _, _, Type),
        defendStatus(_, DefMul)
    ;
        statusLawan(_, _, ATK, _, _, _, _),
        statusKita(_, _, _, DEFD, _, _, Type),
        defendStatus(DefMul, _)
    ),
    ( superEffective(Elmt, Type) ->
        Mult = 1.5,
        write('It is very effective...'), nl
    ; notEffective(Elmt, Type) ->
        Mult = 0.5,
        write('It is not very effective...'), nl
    ;
        Mult = 1
    ),
    number(DEFD), number(DefMul),
    Temp is float(DEFD) * float(DefMul),
    TempRounded is round(Temp),
    DEFAdj is max(1, TempRounded),
    DamageFloat is Mult * P * ATK / float(DEFAdj) / 5,
    Damage is max(1, round(DamageFloat)).

apply_ability(none, _) :- !.
apply_ability(_, Chance) :- random(X), X > Chance, !.
apply_ability(Efek, _) :-
    ( myTurn -> do_effect(statusEfekLawan, Efek)
    ; do_effect(statusEfekKita, Efek)
    ).

do_effect(StatusEfek, burn(T, D)) :-
    Term =.. [StatusEfek, burn(T, D)],
    assertz(Term),
    write('Efek burn diterapkan!'), nl.


apply_ability(lower_atk(N), _) :-
    ( myTurn ->
        statusLawan(HP, MaxHP, ATK, DEF, Nama, ID, Type),
        NewATK is max(1, ATK - N),
        retract(statusLawan(HP, MaxHP, ATK, DEF, Nama, ID, Type)),
        assertz(statusLawan(HP, MaxHP, NewATK, DEF, Nama, ID, Type)),
        write(Nama), write(' ATK berkurang sebanyak '), write(N), nl
    ;
        statusKita(HP, MaxHP, ATK, DEF, Nama, ID, Type),
        NewATK is max(1, ATK - N),
        retract(statusKita(HP, MaxHP, ATK, DEF, Nama, ID, Type)),
        assertz(statusKita(HP, MaxHP, NewATK, DEF, Nama, ID, Type)),
        write(Nama), write(' ATK berkurang sebanyak '), write(N), nl
    ).
apply_ability(paralyze, _) :-
    ( myTurn -> assertz(statusEfekLawan(paralyze)) ; assertz(statusEfekKita(paralyze)) ),
    write('Efek paralysis diterapkan! Mungkin gagal menyerang.'), nl.
apply_ability(heal(Ratio), _) :-
    statusKita(CurHP, MaxHP, ATK, DEF, Nama, ID, Type),
    Heal is round(MaxHP * Ratio),
    NewHP is min(MaxHP, CurHP + Heal),
    retract(statusKita(CurHP, MaxHP, ATK, DEF, Nama, ID, Type)),
    assertz(statusKita(NewHP, MaxHP, ATK, DEF, Nama, ID, Type)),
    write(Nama), write(' memulihkan '), write(Heal), write(' HP!'), nl.
apply_ability(sleep(Turns), _) :-
    ( myTurn ->
        assertz(statusEfekLawan(sleep(Turns))),
        statusLawan(_,_,_,_,Nama,_, _)
    ;
        assertz(statusEfekKita(sleep(Turns))),
        statusKita(_,_,_,_,Nama,_, _)
    ),
    write('Efek sleep diterapkan ke '), write(Nama),
    write('! Akan tertidur selama '), write(Turns), write(' turn.'), nl.

% ----------------------
% Fakta Dinamis
% ----------------------
:- dynamic(status_pokemon/6).
:- dynamic(efek_pokemon/2).

% ----------------------
% Efek Turn
% ----------------------

apply_turn_effects :-
    reduce_cooldown,
    ( myTurn ->
        apply_status_effects(statusEfekKita, statusKita)
    ;
        apply_status_effects(statusEfekLawan, statusLawan)
    ).

apply_status_effects(StatusEfek, Status) :-
    ( call(StatusEfek, burn(T, D)) ->
        get_status(HP, MaxHP, ATK, DEF, Nama, ID),
        NewHP is max(0, HP - D),
        update_status(NewHP, MaxHP, ATK, DEF, Nama, ID),
        NewT is T - 1,
        retract(call(StatusEfek, burn(T, D))),
        (NewT > 0 -> assertz(call(StatusEfek, burn(NewT, D))) ; true),
        format('~w terkena burn dan kehilangan ~w HP!~n', [Nama, D])
    ; true ),
    ( call(StatusEfek, paralyze) ->
        random(X), X < 0.3 -> write('Efek paralysis aktif! Tidak bisa menyerang kali ini.'), nl, fail
    ; true ).

reduce_cooldown :-
    ( myTurn ->
        cooldown_kita(CD1, CD2),
        NewCD1 is max(0, CD1 - 1),
        NewCD2 is max(0, CD2 - 1),
        retract(cooldown_kita(_, _)),
        assertz(cooldown_kita(NewCD1, NewCD2))
    ;
        cooldown_lawan(CD1, CD2),
        NewCD1 is max(0, CD1 - 1),
        NewCD2 is max(0, CD2 - 1),
        retract(cooldown_lawan(_, _)),
        assertz(cooldown_lawan(NewCD1, NewCD2))
    ).

% Burn Effect
apply_burn(ID) :-
    \+ immune_status(ID), 
    efek_pokemon(ID, burn(T, D)),
    status_pokemon(ID, CurHP, MaxHP, ATK, DEF, Nama),
    NewHP is max(0, CurHP - D),
    retract(status_pokemon(ID, CurHP, MaxHP, ATK, DEF, Nama)),
    assertz(status_pokemon(ID, NewHP, MaxHP, ATK, DEF, Nama)),
    NewT is T - 1,
    retract(efek_pokemon(ID, burn(T, D))),
    (NewT > 0 -> assertz(efek_pokemon(ID, burn(NewT, D))) ; true),
    write(Nama), write(' terkena burn! -'), write(D), write(' HP'), nl.
apply_burn(_) :- true.  % fallback bila tidak ada efek burn

% Paralyze Effect
apply_paralyze(ID) :-
    \+ immune_status(ID), 
    efek_pokemon(ID, paralyze),
    random_float(X),
    ( X < 0.2 ->
        status_pokemon(ID, _, _, _, _, Nama),
        write(Nama), write(' terserang paralysis! Tidak bisa menyerang.'), nl,
        fail  % menghentikan aksi berikutnya (misal: menyerang)
    ; true ), !.
apply_paralyze(_).  % fallback bila tidak ada efek paralyze

enemy_action :-
    statusLawan(_, _, _, _, NamaPokemon, Level, _),
    cooldown_lawan(CD1, CD2),
    pokeSkill(NamaPokemon, S1, S2),
    findall(A,
        ( member(A, [1,2,3,4]),
          ( A = 3 -> CD1 =:= 0 ; A = 4 -> CD2 =:= 0, Level >= 5 ; true )),
        Actions),
    ( Actions == [] -> Action = 2 ; random_member(Action, Actions) ),
    ( Action = 1 -> defend
    ; Action = 2 -> attack
    ; Action = 3 -> enemy_use_skill(S1), retract(cooldown_lawan(_, C2)), assertz(cooldown_lawan(1, C2))
    ; Action = 4 -> enemy_use_skill(S2), retract(cooldown_lawan(C1, _)), assertz(cooldown_lawan(C1, 2))
    ).

enemy_use_skill(NamaSkill) :-
    statusLawan(CurHP, _, _, _, Name, _, _),
    skills(NamaSkill, AtkType, Power, Ability, Chance),
    format('~w used ~w!~n', [Name, NamaSkill]),
    damage_skill(Power, AtkType),
    apply_ability(Ability, Chance),
    toggle_turn,
    turn.

