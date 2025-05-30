:- use_module(library(random)).
:- dynamic(myTurn/0).
:- dynamic(situation/1).
:- dynamic(statusKita/6).
:- dynamic(statusLawan/6).
:- dynamic(defendStatus/2).
:- dynamic(statusEfekKita/1).
:- dynamic(statusEfekLawan/1).

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

skill(ember, fire, 10, burn(2, 3), 1.0).
skill(fire_spin, fire, 12, burn(2, 5), 1.0).
skill(bubble, water, 8, lower_atk(3), 1.0).
skill(thunder_shock, electric, 10, paralyze, 0.2).
skill(rest, normal, 0, heal(0.4), 1.0).

random_between(Low, High, R) :-
    Range is High - Low + 1,
    random(XFloat),
    XInt is floor(XFloat * 1000000),
    R0 is XInt mod Range,
    R is Low + R0.

buat_lawan :-
    random_between(1, 9, No),
    poke(No, Nama, _),
    random_between(2, 14, Level),
    base_stats(HPBase, ATKBase, DEFBase, Nama),
    MaxHP is HPBase + 2 * Level,
    ATK is ATKBase + 1 * Level,
    DEF is DEFBase + 1 * Level,
    retractall(statusLawan(_,_,_,_,_,_)),
    assertz(statusLawan(MaxHP, MaxHP, ATK, DEF, Nama, 99)),
    Level1 is Level + 1,
    write('Kamu melawan '), write(Nama), nl,
    write('Level: '), write(Level1), nl,
    write('HP: '), write(MaxHP), nl,
    write('ATK: '), write(ATK), nl,
    write('DEF: '), write(DEF), nl,
    retractall(defendStatus(_, _)),
    assertz(defendStatus(1,1)).

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

turn :-
    situation(ongoing), !,
    apply_turn_effects,
    reset_defend,
    ( myTurn -> statusKita(CurHP, _, _, _, Name, _) ; statusLawan(CurHP, _, _, _, Name, _) ),
    cekBattleStatus(Name, CurHP),
    toggle_turn.

turn :-
    write('Battle sudah selesai.'), nl.

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
    statusKita(_, _, _, NamaPokemon, _),
    pokeSkill(NamaPokemon, Skill1, Skill2),
    ( SkillNumber =:= 1 -> NamaSkill = Skill1 ;
      SkillNumber =:= 2 -> NamaSkill = Skill2 ;
      write('Skill tidak valid! Pilih 1 atau 2.'), nl, fail ),
    skill(NamaSkill, _Type, Power, Ability, Chance),
    damage_skill(Power),
    apply_ability(Ability, Chance),
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

apply_turn_effects :-
    true.

apply_effect_to(EfekPred, StatusPred) :-
    true.