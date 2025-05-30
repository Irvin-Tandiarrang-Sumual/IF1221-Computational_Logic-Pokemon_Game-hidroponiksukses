:- use_module(library(random)).
:- dynamic(myTurn/0).
:- dynamic(situation/1).
:- dynamic(statusKita/6).
:- dynamic(statusLawan/6).
:- dynamic(defendStatus/2).
:- dynamic(statusEfekKita/1).
:- dynamic(statusEfekLawan/1).
:- dynamic(cooldown_kita/2).
:- dynamic(cooldown_lawan/2).


random_between(Low, High, R) :-
    Range is High - Low + 1,
    random(XFloat),
    XInt is floor(XFloat * 1000000),
    R0 is XInt mod Range,
    R is Low + R0.

% pokeSkill(Nama, Skill1, Skill2)
pokeSkill(charmander, scratch, ember).
pokeSkill(squirtle, tackle, water_gun).
pokeSkill(pidgey, tackle, gust).
pokeSkill(charmeleon, ember, fire_spin).
pokeSkill(wartortle, water_gun, bubble).
pokeSkill(pikachu, thunder_shock, quick_attack).
pokeSkill(geodude, tackle, rock_throw).
pokeSkill(snorlax, tackle, rest).
pokeSkill(articuno, gust, ice_shard).

buat_lawan :-
    pokeRandomizer(Nama),
    
    % Ambil remaining moves
    remaining_moves(Remaining),

    % Hitung batas level berdasarkan remaining_moves
    LevelMin is min(14, max(2, round(2 + (20 - Remaining) / 2))),
    LevelMax is min(14, max(LevelMin, round(4 + (20 - Remaining) / 1.5))),
    random_between(LevelMin, LevelMax, Level),

    base_stats(HPBase, ATKBase, DEFBase, Nama),
    MaxHP is HPBase + 2 * Level,
    ATK is ATKBase + 1 * Level,
    DEF is DEFBase + 1 * Level,

    retractall(statusLawan(_,_,_,_,_,_)),
    assertz(statusLawan(MaxHP, MaxHP, ATK, DEF, Nama, 99)),

    LevelDisplay is Level + 1,
    pokemon(ID, Nama, _),
    pokemon_ascii(ID),
    write('Kamu melawan '), write(Nama), write('.'), nl,
    write('Level: '), write(LevelDisplay), nl,
    write('HP: '), write(MaxHP), nl,
    write('ATK: '), write(ATK), nl,
    write('DEF: '), write(DEF), nl, nl,
    write('Pilih Pokemon mu dari party!'), nl,


    retractall(defendStatus(_, _)),
    assertz(defendStatus(1, 1)).

% Pilih pokemon secara acak berdasarkan rarity
pokeRandomizer(Nama) :-
    random_between(1, 100, Roll),
    (
        Roll =< 60 ->
            findall(N, pokemon(_, N, common), CommonList),
            random_member(Nama, CommonList)
    ;
        Roll =< 85 ->
            findall(N, pokemon(_, N, rare), RareList),
            random_member(Nama, RareList)
    ;
        Roll =< 95 ->
            findall(N, pokemon(_, N, epic), EpicList),
            random_member(Nama, EpicList)
    ;
        findall(N, pokemon(_, N, legendary), LegendaryList),
        random_member(Nama, LegendaryList)
    ).


battle :-
    retractall(situation(_)),
    assertz(situation(ongoing)),
    buat_lawan,
    base_stats(HPBase, ATKBase, DEFBase, pikachu),
    LevelKita = 5,
    MaxHPKita is HPBase + 2 * LevelKita,
    ATKKita is ATKBase + 1 * LevelKita,
    DEFKita is DEFBase + 1 * LevelKita,
    retractall(statusKita(_,_,_,_,_,_)),
    assertz(statusKita(MaxHPKita, MaxHPKita, ATKKita, DEFKita, pikachu, 1)),
    retractall(myTurn),
    assertz(myTurn),
    turn,
    retractall(cooldown_kita(_, _)),
    retractall(cooldown_lawan(_, _)),
    assertz(cooldown_kita(0, 0)),
    assertz(cooldown_lawan(0, 0)),
    true.

turn :-
    situation(ongoing), !,
    apply_turn_effects,
    reset_defend,
    ( myTurn ->
        statusKita(CurHP, _, _, _, Name, _),
        cekBattleStatus(Name, CurHP)
    ;
        statusLawan(CurHP, _, _, _, Name, _),
        cekBattleStatus(Name, CurHP),
        enemy_action
    ),
    toggle_turn,
    true.

turn :-
    write('Battle sudah selesai.'), nl,
    true.

reset_defend :-
    ( myTurn ->
        retract(defendStatus(DefMulKita, DefMulLawan)),
        assertz(defendStatus(DefMulKita, 1))
    ;
        retract(defendStatus(DefMulKita, DefMulLawan)),
        assertz(defendStatus(1, DefMulLawan))
    ).

toggle_turn :-
    ( myTurn -> retract(myTurn) ; assertz(myTurn) ).

defend :-
    ( myTurn ->
        retract(defendStatus(_, DefMulLawan)),
        assertz(defendStatus(1.3, DefMulLawan)),
        statusKita(CurHP, _, _, _, Name, _),
        write(Name), write(' bertahan! DEF naik 30% untuk 1 turn.'), nl,
        cekBattleStatus(Name, CurHP)
    ;
        retract(defendStatus(DefMulKita, _)),
        assertz(defendStatus(DefMulKita, 1.3)),
        statusLawan(CurHP, _, _, _, Name, _),
        write(Name), write(' bertahan! DEF naik 30% untuk 1 turn.'), nl,
        cekBattleStatus(Name, CurHP)
    ),
    turn.

attack :-
    damage_skill(1),
    turn.

skill(SkillNumber) :-
    myTurn,
    statusKita(_, _, _, NamaPokemon, _, Level),
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
    skill(NamaSkill, _Type, Power, Ability, Chance),
    damage_skill(Power),
    apply_ability(Ability, Chance),
    % Update cooldown setelah penggunaan
    ( SkillNumber =:= 1 ->
        retract(cooldown_kita(_, CD2)),
        assertz(cooldown_kita(NewCD1, CD2))
    ;
        retract(cooldown_kita(CD1, _)),
        assertz(cooldown_kita(CD1, NewCD2))
    ),
    turn.

damage_skill(SkillPower) :-
    integer(SkillPower) -> P = SkillPower ; P is round(SkillPower),
    ( myTurn ->
        statusKita(_, _, _, _, Attacker, _),
        statusLawan(CurHPDef, MaxHPDef, DefDef, _, Defender, _),
        defendStatus(_, DefMulLawan),
        DEFAdjFloat is DefDef * DefMulLawan,
        DEFAdj is max(1, round(DEFAdjFloat)),
        statusLawan(CurHPDef, MaxHPDef, ATKL, DEFL, Defender, IDl),
        DamageFloat is P * ATKL / DEFAdj / 5,
        Damage is max(1, round(DamageFloat)),
        NewHP is max(0, CurHPDef - Damage),
        retract(statusLawan(CurHPDef, MaxHPDef, ATKL, DEFL, Defender, IDl)),
        assertz(statusLawan(NewHP, MaxHPDef, ATKL, DEFL, Defender, IDl)),
        write(Attacker), write(' menyerang '), write(Defender), write('!'), nl,
        write('Damage: '), write(Damage), nl,
        write('HP '), write(Defender), write(' tersisa: '), write(NewHP), nl, nl
    ;
        statusLawan(_, _, _, _, Attacker, _),
        statusKita(CurHPDef, MaxHPDef, DefDef, _, Defender, _),
        defendStatus(DefMulKita, _),
        DEFAdjFloat is DefDef * DefMulKita,
        DEFAdj is max(1, round(DEFAdjFloat)),
        statusKita(CurHPDef, MaxHPDef, ATKK, DEFK, Defender, IDk),
        DamageFloat is P * ATKK / DEFAdj / 5,
        Damage is max(1, round(DamageFloat)),
        NewHP is max(0, CurHPDef - Damage),
        retract(statusKita(CurHPDef, MaxHPDef, ATKK, DEFK, Defender, IDk)),
        assertz(statusKita(NewHP, MaxHPDef, ATKK, DEFK, Defender, IDk)),
        write(Attacker), write(' menyerang '), write(Defender), write('!'), nl,
        write('Damage: '), write(Damage), nl,
        write('HP '), write(Defender), write(' tersisa: '), write(NewHP), nl, nl
    ),
    cekBattleStatus(Defender, NewHP).

cekBattleStatus(_, HP) :- HP > 0, ( myTurn -> write('(Giliran kamu.)') ; write('(Giliran monster lawan.)') ), nl.
cekBattleStatus(Defender, 0) :-
    retractall(situation(_)),
    ( myTurn ->
        write('(Kamu dikalahkan monster lawan.)'), nl,
        write('Noob amat bang...'), nl,
        assertz(situation(lose))
    ;
        write('(Kamu telah mengalahkan monster lawan.)'), nl,
        assertz(situation(win))
    ).

apply_ability(none, _) :- !.
apply_ability(_, Chance) :- random(X), X > Chance, !.
apply_ability(burn(T, D), _) :-
    ( myTurn -> assertz(statusEfekLawan(burn(T, D))) ; assertz(statusEfekKita(burn(T, D))) ),
    write('Efek burn diterapkan!'), nl.
apply_ability(lower_atk(N), _) :-
    ( myTurn ->
        statusLawan(HP, MaxHP, ATK, DEF, Nama, ID),
        NewATK is max(1, ATK - N),
        retract(statusLawan(HP, MaxHP, ATK, DEF, Nama, ID)),
        assertz(statusLawan(HP, MaxHP, NewATK, DEF, Nama, ID)),
        write(Nama), write(' ATK berkurang sebanyak '), write(N), nl
    ;
        statusKita(HP, MaxHP, ATK, DEF, Nama, ID),
        NewATK is max(1, ATK - N),
        retract(statusKita(HP, MaxHP, ATK, DEF, Nama, ID)),
        assertz(statusKita(HP, MaxHP, NewATK, DEF, Nama, ID)),
        write(Nama), write(' ATK berkurang sebanyak '), write(N), nl
    ).
apply_ability(paralyze, _) :-
    ( myTurn -> assertz(statusEfekLawan(paralyze)) ; assertz(statusEfekKita(paralyze)) ),
    write('Efek paralysis diterapkan! Mungkin gagal menyerang.'), nl.
apply_ability(heal(Ratio), _) :-
    statusKita(CurHP, MaxHP, ATK, DEF, Nama, ID),
    Heal is round(MaxHP * Ratio),
    NewHP is min(MaxHP, CurHP + Heal),
    retract(statusKita(CurHP, MaxHP, ATK, DEF, Nama, ID)),
    assertz(statusKita(NewHP, MaxHP, ATK, DEF, Nama, ID)),
    write(Nama), write(' memulihkan '), write(Heal), write(' HP!'), nl.

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
        statusKita(_, _, _, _, _, ID),
        apply_burn(ID),
        apply_paralyze(ID)
    ;
        statusLawan(_, _, _, _, _, ID),
        apply_burn(ID),
        apply_paralyze(ID)
    ).

reduce_cooldown :-
    ( myTurn ->
        cooldown_kita(CD1, CD2),
        CD1N is max(0, CD1 - 1),
        CD2N is max(0, CD2 - 1),
        retract(cooldown_kita(_, _)),
        assertz(cooldown_kita(CD1N, CD2N))
    ;
        cooldown_lawan(CD1, CD2),
        CD1N is max(0, CD1 - 1),
        CD2N is max(0, CD2 - 1),
        retract(cooldown_lawan(_, _)),
        assertz(cooldown_lawan(CD1N, CD2N))
    ).

% Burn Effect
apply_burn(ID) :-
    efek_pokemon(ID, burn(T, D)),
    status_pokemon(ID, CurHP, MaxHP, ATK, DEF, Nama),
    NewHP is max(0, CurHP - D),
    retract(status_pokemon(ID, CurHP, MaxHP, ATK, DEF, Nama)),
    assertz(status_pokemon(ID, NewHP, MaxHP, ATK, DEF, Nama)),
    write(Nama), write(' terkena burn! -'), write(D), write(' HP'), nl,
    T1 is T - 1,
    retract(efek_pokemon(ID, burn(T, D))),
    (T1 > 0 -> assertz(efek_pokemon(ID, burn(T1, D))) ; true), !.
apply_burn(_).  % fallback bila tidak ada efek burn

% Paralyze Effect
apply_paralyze(ID) :-
    efek_pokemon(ID, paralyze),
    random_float(X),
    ( X < 0.2 ->
        status_pokemon(ID, _, _, _, _, Nama),
        write(Nama), write(' terserang paralysis! Tidak bisa menyerang.'), nl,
        fail  % menghentikan aksi berikutnya (misal: menyerang)
    ; true ), !.
apply_paralyze(_).  % fallback bila tidak ada efek paralyze

enemy_action :-
    statusLawan(_, _, _, _, NamaPokemon, Level),
    cooldown_lawan(CD1, CD2),
    pokeSkill(NamaPokemon, Skill1, Skill2),
    findall(A,
        ( member(A, [1,2,3,4]),
          ( A = 3 -> CD1 =:= 0
          ; A = 4 -> CD2 =:= 0, Level >= 5
          ; true
          )
        ),
        Actions),
    ( Actions == [] -> Action = 2 ; random_member(Action, Actions) ),
    (
        Action =:= 1 -> defend
    ;
        Action =:= 2 -> attack
    ;
        Action =:= 3 ->
            enemy_use_skill(Skill1),
            retract(cooldown_lawan(_, CD2)),
            assertz(cooldown_lawan(1, CD2))
    ;
        Action =:= 4 ->
            enemy_use_skill(Skill2),
            retract(cooldown_lawan(CD1, _)),
            assertz(cooldown_lawan(CD1, 2))
    ).

enemy_use_skill(NamaSkill) :-
    skill(NamaSkill, _Type, Power, Ability, Chance),
    damage_skill(Power),
    apply_ability(Ability, Chance),
    turn.
