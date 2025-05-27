:- use_module(library(random)).
:- dynamic(myTurn/0).
:- dynamic(situation/1).
:- dynamic(statusKita/6).
:- dynamic(statusLawan/6).
:- dynamic(defendStatus/2).

poke(1, pidgey, common).
poke(2, articuno, legendary).
poke(3, pikachu, rare).
poke(4, snorlax, epic).
poke(5, geodude, rare).
poke(6, charmander, common).
poke(7, squirtle, common).
poke(8, charmeleon, common).
poke(9, wartortle, common).

pokeSkill(charmander, scratch, ember).
pokeSkill(squirtle, tackle, water_gun).
pokeSkill(pidgey, tackle, gust).
pokeSkill(charmeleon, ember, fire_spin).
pokeSkill(wartortle, water_gun, bubble).
pokeSkill(pikachu, thunder_shock, quick_attack).
pokeSkill(geodude, tackle, rock_throw).
pokeSkill(snorlax, tackle, rest).
pokeSkill(articuno, gust, ice_shard).

random_between(Low, High, R) :-
    Range is High - Low + 1,
    random(XFloat),         % XFloat = float antara 0..1 (bukan integer)
    XInt is floor(XFloat * 1000000),  % konversi float ke integer besar
    R0 is XInt mod Range,
    R is Low + R0.

/* buat_lawan: pilih random pokemon dan level, buat status */
buat_lawan :-
    random_between(1, 9, No),
    poke(No, Nama, _),
    write(Nama), nl,
    random_between(2, 14, Level),
    base_stats(HPBase, ATKBase, DEFBase, Nama),
    MaxHP is HPBase + 2 * Level,
    ATK is ATKBase + 1 * Level,
    DEF is DEFBase + 1 * Level,
    retractall(statusLawan(_,_,_,_,_,_)),
    assertz(statusLawan(MaxHP, MaxHP, ATK, DEF, Nama, 99)),
    retractall(defendStatus(_, _)),
    assertz(defendStatus(1,1)).

/* Inisiasi battle */
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
    turn.

/* Turn handling */
turn :-
    situation(ongoing), !,
    reset_defend,
    ( myTurn ->
        statusKita(CurHP, _, _, _, Name, _)
    ;
        statusLawan(CurHP, _, _, _, Name, _)
    ),
    cekBattleStatus(Name, CurHP),
    toggle_turn.

turn :-
    write('Battle sudah selesai.'), nl.

/* reset defend multiplier di awal giliran */
reset_defend :-
    ( myTurn ->
        retract(defendStatus(DefMulKita, DefMulLawan)),
        assertz(defendStatus(DefMulKita, 1))
    ;
        retract(defendStatus(DefMulKita, DefMulLawan)),
        assertz(defendStatus(1, DefMulLawan))
    ).

/* Toggle giliran */
toggle_turn :-
    ( myTurn -> retract(myTurn) ; assertz(myTurn) ).

/* defend: naikkan multiplier def 30% */
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

/* attack skill power 1 */
attack :-
    ( myTurn ->
        statusKita(_, _, _, _, NameAttacker, _),
        statusLawan(_, _, _, _, NameDefender, _),
        damage_skill(1)
    ;
        statusLawan(_, _, _, _, NameAttacker, _),
        statusKita(_, _, _, _, NameDefender, _),
        damage_skill(1)
    ),
    turn.

/* skill dengan power skill dari skill database */
skill(SkillNumber) :-
    myTurn,
    statusKita(_, _, _, NamaPokemon, _),
    pokeSkill(NamaPokemon, Skill1, Skill2),
    ( SkillNumber =:= 1 -> NamaSkill = Skill1
    ; SkillNumber =:= 2 -> NamaSkill = Skill2
    ; write('Skill tidak valid! Pilih 1 atau 2.'), nl, fail
    ),
    skill(NamaSkill, _Type, Power, _Ability, _AbilityChance),
    damage_skill(Power),
    turn.

/* damage_skill dengan mempertimbangkan defend multiplier */
damage_skill(SkillPower) :-
    integer(SkillPower) -> P = SkillPower ; P is round(SkillPower),
    ( myTurn ->
        statusKita(CurHPAtt, _, _, _, Attacker, _),
        statusLawan(CurHPDef, MaxHPDef, DefDef, _, Defender, _),
        defendStatus(_, DefMulLawan),
        DEFAdjFloat is DefDef * DefMulLawan,
        DEFAdj is max(1, round(DEFAdjFloat)),  % pastikan minimal 1 untuk menghindari pembagian 0
        statusLawan(CurHPDef, MaxHPDef, ATKL, DEFL, Defender, IDl),
        DamageFloat is P * ATKL / DEFAdj / 5,
        Damage is max(1, round(DamageFloat)),  % damage minimal 1 supaya attack terasa
        NewHP is max(0, CurHPDef - Damage),
        retract(statusLawan(CurHPDef, MaxHPDef, ATKL, DEFL, Defender, IDl)),
        assertz(statusLawan(NewHP, MaxHPDef, ATKL, DEFL, Defender, IDl)),
        write(Attacker), write(' menyerang '), write(Defender), write('!'), nl,
        write('Damage: '), write(Damage), nl,
        write('HP '), write(Defender), write(' tersisa: '), write(NewHP), nl, nl
    ;
        statusLawan(CurHPAtt, _, _, _, Attacker, _),
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

/* cekBattleStatus: cek status HP dan situasi battle */
cekBattleStatus(_Name, HP) :-
    HP > 0,
    ( myTurn -> write('(Giliran kamu.)') ; write('(Giliran monster lawan.)') ),
    nl.

cekBattleStatus(Defender, HP) :-
    HP =:= 0,
    retractall(situation(_)),
    ( myTurn ->
        write('(Kamu dikalahkan monster lawan.)'), nl,
        write('Noob amat bang...'), nl,
        assertz(situation(lose))
    ;
        write('(Kamu telah mengalahkan monster lawan.)'), nl,
        assertz(situation(win))
    ).
