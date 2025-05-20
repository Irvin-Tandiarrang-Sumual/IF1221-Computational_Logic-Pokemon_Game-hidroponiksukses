/* Turn */
:- dynamic(myTurn/0).
/* Battle Situation (win, lose, ongoing) */
:- dynamic(situation/1).
/* Pokemon Status Lawan di Battle */
/* (HP, ATK, DEF, Nama, ID) */
:- dynamic(statusKita/5).
:- dynamic(statusLawan/5).
/*

/* Randomizer Pokemon Lawan */
buat_lawan :-
    random(0, )

/* Main Battle */
battle :-
    assertz(situation('ongoing')),
    damage_skill

/* Attack */
attack :-


/* Defend */
defend :-
    myTurn,
    statusKita(_, _, DEF, Name, _),
    NewDEF is (1.3 * DEF),
    retract(statuskita(HP, ATK, DEF, Name, ID)),
    assertz(statuskita(HP, ATK, NewDEF, Name, ID)),
    write(Name), write(' dalam posisi bertahan! Defense naik untuk 1 turn.'), nl, nl,
    cekBattleStatus(Name, HP).

/* Switch */
switch(IdxDeck, IdxTas) :-


/* Skill Turn */
skill(Input_Skill) :-
    


/* Damage Skill */
damage_skill(Attacker, Defender, Skill) :-
    # Pemasukan variabel
    type(DefType, Defender),
    poke_stats(_, AttAtk, _, Attacker, _),
    poke_stats(DefHP, _, DefDef, Defender, _),
    skill(Skill, SkillType, SkillPower, SkillAbil, SkillAbilCh),
    curr_health(DefCurHP, DefCapHP),

    # Perhitungan keefektifan type
    (superEffective(SkillType, DefType) -> ModTypeBase1 is 1.5; ModTypeBase1 is 1.0),
    (notEffective(SkillType, DefType) -> ModType is 0.5; ModType is ModTypeBase1),

    # Perhitungan damage dan HP lawan
    Damage is round(SkillPower * AttAtk / DefDef / 5 * ModType),
    DefHPAft is DefCurHP - Damage,
    (DefHPAft < 0) -> NewDefHP is 0; NewDefHP is DefHPAft,

    # Update HP lawan
    retract(curr_health(_, DefCapHP)),
    assertz(curr_health(NewDefHP, DefCapHP)),

    # Cetak hasil
    write(Attacker), write(' menyerang '), write(Defender), write('!'), nl,
    write('Damage: '), write(Damage), nl,
    write('HP '), write(Defender), write(' tersisa: '), write(HPLawanAft), write('/'), write(DefCapHP), nl, nl,
    cekBattleStatus(Defender, NewDefHP).

/* Cek status pertempuran */
cekBattleStatus(Defender, NewDefHP) :-
    NewDefHP =\= 0,
    (lawan(Defender) -> write('(Giliran monster lawan.)'); write('(Giliran pokemon kita.)')), nl.
cekBattleStatus(Defender, NewDefHP) :-
    NewDefHP =:= 0,
    retract(situation(_)),
    (lawan(Defender) -> write('(Kamu telah mengalahkan monster lawan.)'), assertz(situation('win')); write('(Kamu dikalahkan monster lawan.)'), nl, write('Noob amat bang...'), assertz(situation('lose'))).

