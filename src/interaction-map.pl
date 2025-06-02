:- dynamic(remaining_moves/1).
:- dynamic(map/1).
:- dynamic(last_player_tile/1).

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

move(DX, DY) :-
    /* Check whether the player's stil have moves left */
    remaining_moves(MovesLeft),
    MovesLeft > 0,

    map(Matrix),
    findall((X,Y), (nth0(X, Matrix, Row), nth0(Y, Row, 'P')), [(OldX, OldY)]),
    NewX is OldX + DX,
    NewY is OldY + DY,
    check_valid_move(Matrix, NewX, NewY),
    nth0(NewX, Matrix, NewRow), nth0(NewY, NewRow, DestTile),

    /* Update position */
    ( last_player_tile(TileToRestore) -> true ; TileToRestore = ' ' ),
    replace_in_matrix(Matrix, (OldX, OldY), TileToRestore, TempMatrix),
    replace_in_matrix(TempMatrix, (NewX, NewY), 'P', NewMatrix),
    retractall(map(_)), assertz(map(NewMatrix)),
    retractall(last_player_tile(_)),
    assertz(last_player_tile(DestTile)),

    /* Update current moves left */
    NewMovesLeft is MovesLeft - 1,
    retract(remaining_moves(_)), assertz(remaining_moves(NewMovesLeft)),
    /* Print current moves left */
    format("Moves left: ~d~n", [NewMovesLeft]).

move(_, _) :-
    remaining_moves(0),
    write("No moves left! Initiate the fight."),
    fail.

/* Player's movement */
moveUp :- move(-2,0), check_player_pokemon, mapping.
moveLeft :- move(0,-2), check_player_pokemon, mapping.
moveDown :- move(2,0), check_player_pokemon, mapping.
moveRight :- move(0,2), check_player_pokemon, mapping.

/* Currently: Replace the old tile with 0 */
update_player_map(Matrix, (OldX, OldY), NewX, NewY, NewMatrix) :-
    replace_in_matrix(Matrix, (OldX, OldY), ' ', TempMatrix),
    replace_in_matrix(TempMatrix, (NewX, NewY), 'P', NewMatrix).

check_player_pokemon :-
    map(Matrix),
    findall((X,Y), (nth0(X, Matrix, Row), nth0(Y, Row, 'P')), [(PX, PY)]),
    pokemap(PokeList),
    (last_player_tile('#') ->
        write('Kamu memasuki semak-semak!'), nl, 
        (
            member((Type, (PX, PY)), PokeList) ->
                format("Kamu menemukan Pokemon rarity ~w!~n", [Type])
            ;
                write('Sepertinya tidak ada tanda-tanda kehidupan disini...'), nl
        )
    ;
        (
            member((Type, (PX, PY)), PokeList) ->
                format("Kamu menemukan Pokemon rarity ~w!~n", [Type])
            ;
                true
        )
     ).

player_on_any_pokemon(Type, (PX, PY)) :-
    map(Matrix),
    nth0(PX, Matrix, Row),
    nth0(PY, Row, 'P'),
    pokemap(PokeList),
    member((Type, (PX, PY)), PokeList).
