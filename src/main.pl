/* Variable dynamic */
/* init: kondisi start game */
:- dynamic(init/0).
/* player/7: (nama, pokemon 1, pokemon 2, pokemon 3, pokemon 4, X_pos, Y_pos) */
:- dynamic(player/7).
/* TODO */
:- dynamic(turn/1).

/* File lain */
:- include('ascii.pl').
:- include('variable.pl').
:- include('player.pl').
:- include('help.pl').
:- include('map.pl').
:- include('inventory.pl').

/* kondisi: gamestarted */
start:- init, write('Game already started'),!.
/* kondisi: game not started */
start:- \+init, assertz(init), asserta(turn(20)), assertz(player(ash, 0, 0, 0, 0, 0, 0)), title, created_by, startgame(0).

/* update_name: input name and change the dynamic variable */
update_name(NewName):- player(_, Poke1, Poke2, Poke3, Poke4, X_pos, Y_pos),
    retract(player(_, Poke1, Poke2, Poke3, Poke4, X_pos, Y_pos)),
    assertz(player(NewName, Poke1, Poke2, Poke3, Poke4, X_pos, Y_pos)).

/* print_name: output Name on console */
print_name:- player(Name, _, _, _, _, _, _),
    write(Name).

/* startgame: intiating sequences of game intro */
startgame(X) :-
    step(X),
    wait_enter,
    X1 is X + 1,
    (X1 =< 10 -> startgame(X1); true).

/* step: sequences */
step(0) :- nl.
step(1) :- oak, nl, nl, write('|    Hello there welcome to the World of POKeMON!').
step(2) :- write('|    My name is OAK').
step(3) :- write('|    People call me the POKeMON PROF!').
step(4) :- pikachu, nl, nl, write('|    This world is inhabited by creatures called POKeMON!').
step(5) :- write('|    For some people POKeMON are pets.').
step(6) :- write('|    Others use them for fights.').
step(7) :- write('|    Myself...').
step(8) :- write('|    I study POKeMON as a profession.').
step(9) :- set_name, wait_enter. 
step(10) :- starter_pokemon, init_map(17,32).

/* wait_enter: press ENTER to continue */
wait_enter :- get_char(_), nl.

/* set_name: asking for name input */
set_name:- red, nl, nl, write('|    First, what is your name?'), nl, read(X), nl, update_name(X), 
    write('|    Right! So your name is '), print_name, write('!'), nl.

/* starter_pokemon: asking to choose starter pokemon */
starter_pokemon:- write('|    Choose your starter POKeMON. '), print_name, write('!'), nl, chooseStarter.

