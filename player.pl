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
    starter(X), starter(X),
    asserta(inventory(X)),
    asserta(inventory(Y)),
    base_stats(HP1, _, _, X),
    asserta(curr_health(1,HP1)),
    asserta(isSkillUsed_Self(1,0)),
    asserta(no_inventory(1,X)),
    asserta(jml_inventory(1)),
    base_stats(HP2, _, _, Y),
    asserta(curr_health(1,HP2)),
    asserta(isSkillUsed_Self(2,0)),
    asserta(no_inventory(2,Y)),
    asserta(jml_inventory(2)),
    write(X), write(' & '), write(Y), write(' is now your partner!'),nl, idAv(List), write(List), !.


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
    findall(X,no_inventory(N,X),ListInventory),
    sort(ListInventory,SortedList),
    showStatusList(SortedList). 

showStatusList(L) :-
    L = [H|T],
    base_stats(HP, _, _, H),
    type(Type,H),
    write('Name : '),
    write(H),nl,
    write('Health: '),
    write(HP),nl,
    write('Type: '),
    write(Type),nl,nl,
    showStatusList(T),!.
