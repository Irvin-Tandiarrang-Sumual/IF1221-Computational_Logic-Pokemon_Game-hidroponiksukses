:- use_module(library(random)).
:- dynamic(myTurn/0).
:- dynamic(situation/1).
:- dynamic(statusKita/8).
:- dynamic(statusLawan/7).
:- dynamic(defendStatus/2).
:- dynamic(statusEfekKita/1).
:- dynamic(statusEfekLawan/1).
:- dynamic(cooldown_kita/2).
:- dynamic(cooldown_lawan/2).
:- dynamic(player_level/1).
:- dynamic(enemy_level/1).
:- dynamic(atkindex/1).

random_between(Low, High, R) :-
    Range is High - Low + 1,
    random(XFloat),
    XInt is floor(XFloat * 1000000),
    R0 is XInt mod Range,
    R is Low + R0.

daftar_party :-
    findall(Index-Nama, party(Index, Nama), List),
    sort(List, Sorted),
    write('Daftar Pokémon dalam party kamu:'), nl,
    tampilkan_party(Sorted).

has_alive_pokemon :-
    party(Index, Name),
    curr_health(Index, Name, HP, 1),
    HP > 0, !.

tampilkan_party([]).
tampilkan_party([Index-Nama | T]) :-
    % Ambil data max HP
    poke_stats(HPMax, _, _, _, Index, 1),
    % Ambil data current HP
    (curr_health(Index, Nama, CurrHP, 1) -> true ; CurrHP = 0),
    % Ambil data lainnya
    % Tampilkan data
    format('~w: ~w (~w/~w HP)~n', [Index, Nama, CurrHP, HPMax]),
    tampilkan_party(T).


pilih_pokemon :-
    repeat,
    write('Masukkan indeks Pokémon yang ingin kamu gunakan: '), nl,
    write('>> '),
    read(Index),
    (
        valid_pokemon_choice(Index),
        party(Index, Name),
        curr_health(Index, Name, HP, 1),
        HP > 0 ->
            format('Kamu memilih ~w sebagai Pokemon utama!~n', [Name]),
            retractall(atkindex(_)), asserta(atkindex(Index)), init_poke(Index),!
        ;
        write('Pilihan tidak valid atau Pokémon sudah tumbang, silakan pilih lagi.'), nl,
        fail
    ).

valid_pokemon_choice(Index) :-
    party(Index, Name),
    curr_health(Index, Name, HP, 1),
    HP > 0.

init_poke(Index) :-
    atkindex(Index),
    party(Index, Nama),
    level(LevelKita,Nama,Index, _, 1),
    poke_stats(MaxHPKita, ATKKita, DEFKita, Nama, Index, 1),
    curr_health(Index, Nama, CurrHPKita, 1),
    type(Type, Nama),
    retractall(statusKita(_, _, _, _, _, _, _, Index)),
    assertz(statusKita(CurrHPKita, MaxHPKita, ATKKita, DEFKita, Nama, ID, Type, Index)),
    retractall(player_level(_)),
    assertz(player_level(LevelKita)).

buat_lawan(Rarity) :-
    pokeRandomizer(Rarity, Nama),
    
    % Ambil remaining moves
    remaining_moves(Remaining),

    % Hitung batas level berdasarkan remaining_moves
    LevelMin is min(15, max(2, round(2 + (20 - Remaining) / 2))),
    LevelMax is min(15, max(LevelMin, round(4 + (20 - Remaining) / 1.5))),
    random_between(LevelMin, LevelMax, Level),
    Level1 is Level - 1,
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

get_status(HP, MaxHP, ATK, DEF, Nama, ID) :-
    ( myTurn ->
        atkindex(Index),
        statusKita(CurrHPKita, MaxHPKita, ATKKita, DEFKita, Nama, ID, Type, Index)
    ; 
        statusLawan(MaxHP, MaxHP, ATK, DEF, Nama, 99, Type)
    ).

update_status(HP, MaxHP, ATK, DEF, Nama, ID) :-
    ( myTurn ->
        atkindex(Index),
        retractall(statusKita(_, _, _, _, _, ID, Type, Index)),
        assertz(statusKita(HP, MaxHP, ATK, DEF, Nama, ID, Type, Index))
    ; 
        retractall(statusLawan(_, _, _, _, _, ID, _)),
        assertz(statusLawan(HP, MaxHP, ATK, DEF, Nama, ID, Type))
    ).

ignore(Goal) :- call(Goal), !.
ignore(_).

turn :-
    situation(ongoing), !,
    atkindex(Index),
    apply_turn_effects,
    reset_defend,
    statusKita(HP1, _, _, _, Name1, _, _, Index),
    statusLawan(HP2, _, _, _, Name2, _, _),
    (
        HP1 =< 0 ->
            format('~w tumbang!~n', [Name1]),
            party(Index, Name1),
            curr_health(Index, Name1, 0, 1),
            retractall(statusEfekKita(_)),
            ( has_alive_pokemon ->
                write('Pilih Pokémon pengganti:\n'),
                retract(statusKita(0, _, _, _, Name1, _, _, _)),
                daftar_party,
                pilih_pokemon,
                retractall(myTurn),
                assertz(myTurn),
                turn
            ;
                write('Semua Pokemonmu sudah kalah. Kamu kalah total...\n'),
                retractall(situation(_)),
                assertz(situation(lose))
            )
    ; HP2 =< 0 ->
        format('Pokemon ~w kalah! Kamu menang!~n', [Name2]),
        forall(
            (party(Index1, Name), curr_health(Index1, Name, HP, 1)),
            (
                enemy_level(X), rarity(Rarity, _, Y, _), Expgiven is Y + X*2,
                retractall(curr_health(Index1, Name, _,1)),
                assertz(curr_health(Index1, Name, HP, 1)),
                ignore(addExp(Expgiven, Index1, Name))
            )
        ),
        retractall(situation(_)), assertz(situation(win))
    ; myTurn ->
        nl, handle_player_turn, nl
    ; handle_enemy_turn
    ).

turn :-
    situation(Status),
    format('Pertarungan selesai! Hasil: ~w~n', [Status]).

find_next_alive_pokemon(CurrentIndex, NextIndex, PokemonName) :-
    party(NextIndex, PokemonName),
    NextIndex \= CurrentIndex,
    curr_health(NextIndex, PokemonName, HP),
    HP > 0, !.  % ! agar ambil yang pertama ketemu

handle_player_turn :-
    statusEfekKita(sleep(T)), T > 0, !,
    NewT is T - 1,
    retract(statusEfekKita(sleep(T))),
    (NewT > 0 -> assertz(statusEfekKita(sleep(NewT))) ; true),
    statusKita(_, _, _, _, Name, _, _, _),
    write(Name), write(' sedang tidur... turn dilewati.'), nl.

handle_player_turn :-
    statusKita(CurHP, _, _, _, Name, _, _, _),
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
        statusKita(CurHP, _, _, _, Name, _, _, _),
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
    atkindex(Index),
    statusKita(_, _, _, _, NamaPokemon, _, _, Index),
    level(Level, NamaPokemon, Index, _, 1),
    cooldown_kita(CD1, CD2),
    pokeSkill(NamaPokemon, Skill1, Skill2),
    (
        SkillNumber =:= 1 ->
            ( CD1 > 0 ->
                write('Skill 1 masih cooldown '), write(CD1), write(' turn.'), nl, fail
            ;
                NamaSkill = Skill1,
                NewCD1 = 2
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
                    NewCD2 = 4
                )
            )
    ;
        write('Skill tidak valid! Pilih 1 atau 2.'), nl, fail
    ),
    % Jalankan
    skills(NamaSkill, AtkType, Power, Ability, Chance),
    format('~w used ~w!~n', [NamaPokemon, NamaSkill]),
    
    ( Power > 0 ->
        damage_skill(Power, AtkType)
    ; true ),  % tidak menyerang jika Power = 0

    apply_ability(Ability, Chance),

    % Update cooldown setelah penggunaan
    ( SkillNumber =:= 1 ->
        retract(cooldown_kita(_, CD2)),
        assertz(cooldown_kita(NewCD1, CD2))
    ; SkillNumber =:= 2 ->
        retract(cooldown_kita(CD1, _)),
        assertz(cooldown_kita(CD1, NewCD2))
    ), 
    toggle_turn,
    turn.

damage_skill(Power, Elmt) :-
    calculate_damage(Power, Damage, Elmt),
    ( myTurn ->
        retract(statusLawan(CurHP, MaxHP, ATK, DEF, Defender, 99, Type)),
        NewHP is max(0, CurHP - Damage),
        assertz(statusLawan(NewHP, MaxHP, ATK, DEF, Defender, 99, Type))
    ; 
        atkindex(Index),
        retract(statusKita(CurHP, MaxHP, ATK, DEF, Defender, ID, Type, Index)),
        NewHP is max(0, CurHP - Damage),
        assertz(statusKita(NewHP, MaxHP, ATK, DEF, Defender, ID, Type, Index)),
        retract(curr_health(Index, Defender, _, 1)), assertz(curr_health(Index, Defender, NewHP, 1))
    ),
    format('Serangan memberikan ~w damage ke ~w. Sisa HP: ~w~n', [Damage, Defender, NewHP]).

calculate_damage(Power, Damage, Elmt) :-
    ( integer(Power) -> P = Power ; P is round(Power) ),
    ( myTurn ->
        statusKita(_, _, ATK, _, _, _, _, _),
        statusLawan(_, _, _, DEFD, _, _, Type),
        defendStatus(_, DefMul)
    ;
        statusLawan(_, _, ATK, _, _, _, _),
        statusKita(_, _, _, DEFD, _, _, Type, _),
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
        atkindex(Index),
        statusKita(HP, MaxHP, ATK, DEF, Nama, ID, Type, Index),
        NewATK is max(1, ATK - N),
        retract(statusKita(HP, MaxHP, ATK, DEF, Nama, ID, Type, Index)),
        assertz(statusKita(HP, MaxHP, NewATK, DEF, Nama, ID, Type, Index)),
        write(Nama), write(' ATK berkurang sebanyak '), write(N), nl
    ).
apply_ability(paralyze, _) :-
    ( myTurn -> assertz(statusEfekLawan(paralyze)) ; assertz(statusEfekKita(paralyze)) ),
    write('Efek paralysis diterapkan! Mungkin gagal menyerang.'), nl.
apply_ability(heal(Ratio), _) :-
    atkindex(Index),
    statusKita(CurHP, MaxHP, ATK, DEF, Nama, ID, Type, Index),
    Heal is round(MaxHP * Ratio),
    NewHP is min(MaxHP, CurHP + Heal),
    retract(statusKita(CurHP, MaxHP, ATK, DEF, Nama, ID, Type, Index)),
    assertz(statusKita(NewHP, MaxHP, ATK, DEF, Nama, ID, Type, Index)),
    write(Nama), write(' memulihkan '), write(Heal), write(' HP!'), nl.
apply_ability(sleep(Turns), _) :-
    ( myTurn ->
        assertz(statusEfekLawan(sleep(Turns))),
        statusLawan(_,_,_,_,Nama,_, _)
    ;
        assertz(statusEfekKita(sleep(Turns))),
        statusKita(_,_,_,_,Nama,_, _, _)
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
    ; Action = 3 -> enemy_use_skill(S1), retract(cooldown_lawan(_, CD2)), assertz(cooldown_lawan(1, CD2))
    ; Action = 4 -> enemy_use_skill(S2), retract(cooldown_lawan(CD1, _)), assertz(cooldown_lawan(CD1, 2))
    ).

enemy_use_skill(NamaSkill) :-
    statusLawan(CurHP, _, _, _, Name, _, _),
    skills(NamaSkill, AtkType, Power, Ability, Chance),
    format('~w used ~w!~n', [Name, NamaSkill]),
    damage_skill(Power, AtkType),
    apply_ability(Ability, Chance),
    toggle_turn,
    turn.

ganti_pokemon_otomatis :-
    party(Index, _),              % Ambil index saat ini
    NextIndex is Index + 1,
    ( party(NextIndex, NextPokemon) ->
        player(_, _, _, _, _, _, LevelKita),
        base_stats(HPBase, ATKBase, DEFBase, NextPokemon),
        MaxHP is HPBase + 2 * LevelKita,
        ATK is ATKBase + 1 * LevelKita,
        DEF is DEFBase + 1 * LevelKita,
        retractall(statusKita(_,_,_,_,_,_)),
        assertz(statusKita(MaxHP, MaxHP, ATK, DEF, NextPokemon, 1)),
        retractall(party(_, _)),  % Reset index
        assertz(party(NextIndex, NextPokemon)),
        format("~n~w masuk ke arena!~n", [NextPokemon]),
        turn
    ;   write('Semua Pokemonmu sudah kalah. Kamu kalah total...\n'),
        retractall(situation(_)),
        assertz(situation(kalah))
    ).
