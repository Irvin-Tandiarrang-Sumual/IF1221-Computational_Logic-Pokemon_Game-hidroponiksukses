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
    ( last_player_tile('H') -> pcenter ; true),

    /* Update current moves left */
    NewMovesLeft is MovesLeft - 1,
    retract(remaining_moves(_)), assertz(remaining_moves(NewMovesLeft)),
    /* Print current moves left */
    format("Moves left: ~d~n", [NewMovesLeft]),
    write('HP Pokemon dipulihkan sebanyak 20% dari total max HP masing-masing.'), nl.

move(_, _) :-
    remaining_moves(0),
    write("No moves left! Initiate the fight."),
    fail.

/* Player's movement */
moveUp :- write('Kamu bergerak ke atas'), move(-2,0), check_player_pokemon.
moveLeft :- write('Kamu bergerak ke kiri'), move(0,-2), check_player_pokemon.
moveDown :- write('Kamu bergerak ke bawah'), move(2,0), check_player_pokemon.
moveRight :- write('Kamu bergerak ke kanan'), move(0,2), check_player_pokemon.

/* PokeCenter's interaction feature */

pcenter :- pcenter_step(X).

pcenter_step(X) :-
    p_step(X),
    wait_enter,
    X1 is X + 1,
    (X1 =< 2 -> pcenter_step(X1); true).

p_step(0) :- pcenter_ascii.
p_step(1) :- nursejoy_ascii.
p_step(2) :- 
    nursejoy_w_ascii, 
    write('|    Type "heal." to interact with PokeCenter!'), nl, nl, 
    read(X),
    interactPcenter(X).

/* Interact with PokeCenter! */
interactPcenter(heal):-
    update_all_poke_hp_to_max,
    write('|    Nurse Joy: Here you go dear, I have recovered all of your pokemon to full HP!'),nl,nl.

interactPcenter(_):-
    write('|    Nurse Joy: Aww, alright then sweetie, have a great adventure!'),nl,nl.

update_all_poke_hp_to_max :-
    forall(
        ( retract(curr_health(Index, Party, _)),
          poke_stats(HP, _, _, _, Index, Party)
        ),
        assert(curr_health(Index, Party, HP))
    ).

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
            member((Rarity, (PX, PY)), PokeList) ->
                format("Kamu menemukan Pokemon rarity ~w! pilih opsi: ~n", [Rarity]),
                write('1.   Bertarung'), nl, write('2.   Tangkap'), nl, write('3.   Kabur(NOOB)'), nl, showMap, 
                write('>> '), read(Pilihan), handle_encounter_choice(Pilihan, Rarity, (PX, PY))
            ;
                write('Sepertinya tidak ada tanda-tanda kehidupan disini...'), nl, showMap
        )
    ;
        (
            member((Rarity, (PX, PY)), PokeList) ->
                format("Kamu menemukan Pokemon rarity ~w! pilih opsi: ~n", [Rarity]),
                write('1.   Bertarung'), nl, write('2.   Tangkap'), nl, write('3.   Kabur(NOOB)'), nl, showMap,
                write('>> '), read(Pilihan), handle_encounter_choice(Pilihan, Rarity, (PX, PY))
            ;
                showMap, true
        )
     ).

handle_encounter_choice(1, Rarity, _) :-
    write('Persiapkan dirimu!'), nl,
    write('Pertarungan yang epik baru saja dimulai!'), nl,
    battle(Rarity).

handle_encounter_choice(2, Rarity, Pos) :-
    write('Kamu memilih menangkap pokemon'), nl,
    catch_rate(Rarity, RateBase),
    random_between(0, 35, Rnd),
    CatchRate is RateBase + Rnd,
    write('Hasil catch rate: '), write(CatchRate), nl,
    ( CatchRate > 50 ->
        write('Kamu berhasil menangkap pokemon!'), nl,
        pokeRandomizer(Rarity, Nama),
        catch_pokemon(Nama)
    ; 
        write('Kamu gagal menangkap pokemon!'), nl,
        write('Persiapkan dirimu! Pertarungan yang epik baru saja dimulai!'), nl,
        battle(Rarity)
    ).

handle_encounter_choice(3, _, _) :-
    write('Kamu memilih kabur!'), nl,
    write('Skill issue.'), nl.

handle_encounter_choice(X, Rarity, Pos) :- \+ member(X, [1, 2, 3]),
    write('Pilihan tidak valid, coba lagi.'), nl,
    write('>> '), read(NewChoice),
    handle_encounter_choice(NewChoice, Rarity, Pos).

player_on_any_pokemon(Rarity, (PX, PY)) :-
    map(Matrix),
    nth0(PX, Matrix, Row),
    nth0(PY, Row, 'P'),
    pokemap(PokeList),
    member((Rarity, (PX, PY)), PokeList).

remove_pokemon_from_map(Pos) :-
    pokemap(PokeList),
    delete(PokeList, (_, Pos), NewList),
    retractall(pokemap(_)),
    assertz(pokemap(NewList)).