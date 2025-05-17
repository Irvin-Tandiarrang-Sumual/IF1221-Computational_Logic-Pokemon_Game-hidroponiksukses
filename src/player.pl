:- dynamic(listPoke/1).
:- dynamic(idAv/1).
:- dynamic(no_inventory/2).
:- dynamic(curr_health/2).
:- dynamic(isSkillUsed_Self/2).
:- dynamic(isHeal/1).

idAv([1, 2, 3, 4]).

chooseStarter:-  findall(X,starter(X),ListStarter),
    writeList(ListStarter),
    write('Choose your POKeMON'),nl,
    write('>> '), read(Starter1), write('>> '), read(Starter2),
    starterToInventory(Starter1, Starter2),!.

starterToInventory(X, Y) :- 
    starter(X), starter(Y),
    level(Lev,X, 0, 0),
    asserta(level(Lev,X, 1, 0)),
    level(Lev,Y, 0, 0),
    asserta(level(Lev,Y, 2, 0)),
    asserta(inventory(X)),
    asserta(inventory(Y)),
    base_stats(HP1, ATK1, DEF1, X),
    asserta(poke_stats(HP1, ATK1, DEF1, X, 1)),
    asserta(curr_health(1,HP1)),
    asserta(isSkillUsed_Self(1,0)),
    asserta(no_inventory(1,X)),
    asserta(jml_inventory(1)),
    base_stats(HP2, ATK2, DEF2, Y),
    asserta(poke_stats(HP2, ATK2, DEF2, Y, 2)),
    asserta(curr_health(1,HP2)),
    asserta(isSkillUsed_Self(2,0)),
    asserta(no_inventory(2,Y)),
    asserta(jml_inventory(2)),
    write(X), write(' & '), write(Y), write(' is now your partner!'),nl, !.


writeList([]) :- nl,!.
writeList([H|T]) :-
    pokemon(N, H, _),
    starter_ascii(N),
    write('|    '),
    write(N),
    write('. '), write(H),nl,
    type(X,H),
    write('|    Type: '), write(X), nl, nl, nl,
    writeList(T).

status :-
    write('Your Pokemon:'), nl,
    findall([N,X],no_inventory(N,X),ListInventory),
    sort(ListInventory,SortedList),
    showStatusList(SortedList). 

showStatusList(L) :-
    L = [[No_invenH|H]|T],
    no_inventory(No_invenH,XH), No_invenH >  0,
    poke_stats(HP, _, _, XH, No_invenH),
    pokemon(ID, XH, Rarity), rarity(Rarity, BaseEXP, _, _),
    type(Type,XH), level(Lev, XH, No_invenH, Exp),
    write('Name : '),
    write(XH),nl,
    write('Health: '),
    write(HP),nl,
    write('Type: '),
    write(Type), nl,
    write('Level: '),
    write(Lev), nl,
    write('Exp: '),
    ExpCap is BaseEXP*Lev,
    write(Exp), write('/'), write(ExpCap), nl, nl,
    showStatusList(T),!.

levelUp(X, No_inven) :- \+starter(X),!,fail.
levelUp(X, No_inven) :-
    no_inventory(No_inven, X),
    pokemon(ID, X, Rarity), level(Lev,X, No_inven, Exp),
    rarity(Rarity, BaseEXP, _, _), !,
    Exp >= (BaseEXP*Lev), statsUp(Lev, X, No_inven, BaseEXP).

statsUp(Lev, X, No_inven, BaseEXP):-
    retract(level(Lev, X, No_inven, Exp)),
    retract(poke_stats(HP, ATK, DEF, X, No_inven)),
    ExpCap is BaseEXP*Lev,
    NewExp is Exp - ExpCap,
    NewLev is Lev+1,
    asserta(level(NewLev, X, No_inven, NewExp)),
    ATK1 is ATK+1,
    HP1 is HP+2,
    DEF1 is DEF+1,
    asserta(poke_stats(HP1, ATK1, DEF1, X, No_inven)),
    write('Your '),write(X),write(' has leveled up!'),nl,
    write('Health: '), write(HP1),nl,
    write('ATK: '), write(ATK1),nl,
    write('DEF: '), write(DEF1),nl,!.