:- dynamic(remaining_moves/1).
:- dynamic(map/1).

/* User's messages interface */
boundaries_message :-
    write('Oh no! You are at the boundaries. Try other options rather than your current one.'), nl.

fight_message :-
    nl.

init_moves(N) :-
    retractall(remaining_moves(_)),
    assertz(remaining_moves(N)).

/* Tools to check whether or not a player's move valid */
check_valid_move(Matrix, NewX, NewY) :-
    length(Matrix, Rows),
    nth0(0, Matrix, FirstRow),
    length(FirstRow, Cols),
    NewX >= 0, NewX < Rows,
    NewY >= 0, NewY < Cols,
    nth0(NewX, Matrix, Row),
    nth0(NewY, Row, Tile),
    Tile \= "|",
    Tile \= "-".

check_valid_move(_, _, _) :-
    boundaries_message,
    fail.

move(DX,DY):-
    /* Check whether the player's stil have moves left */
    remaining_moves(MovesLeft),
    MovesLeft > 0,

    /* Update position */
    map(Matrix),
    findall((X,Y), (nth0(X, Matrix, Row), nth0(Y, Row, 'P')), [(OldX, OldY)]),
    NewX is OldX + (DX),
    NewY is OldY + (DY),
    check_valid_move(Matrix, NewX, NewY),
    update_player_map(Matrix, (OldX, OldY), NewX, NewY, NewMatrix),

    /* Update current moves left */
    NewMovesLeft is MovesLeft - 1,
    retract(remaining_moves(_)),
    assertz(remaining_moves(NewMovesLeft)),
    retract(map(_)),
    assertz(map(NewMatrix)),
    
    /* Print current moves left */
    format("Moves left: ~d~n", [NewMovesLeft]).

move(_, _) :-
    remaining_moves(0),
    write("No moves left! Initiate the fight."),
    fail.

/* Player's movement */
moveUp :- move(-2,0), mapping.
moveLeft :- move(0,-2), mapping.
moveDown :- move(2,0), mapping.
moveRight :- move(0,2), mapping.

/* Currently: Replace the old tile with 0 */
update_player_map(Matrix, (OldX, OldY), NewX, NewY, NewMatrix) :-
    replace_in_matrix(Matrix, (OldX, OldY), '0', TempMatrix),
    replace_in_matrix(TempMatrix, (NewX, NewY), 'P', NewMatrix).
