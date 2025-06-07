:- dynamic(item_inventory/2).

max_party_size(4).

/* Inisialisasi inventori */
initialize_inventory :-
    initialize_inventory(0).

initialize_inventory(40) :- !.
initialize_inventory(Index) :-
    (Index < 20 -> Item = pokeball(empty); Item = empty),
    assertz(item_inventory(Index, Item)),
    NextIndex is Index + 1,
    initialize_inventory(NextIndex).

/* Menambahkan item */
add_item(Item) :-
    (   item_inventory(Index, empty) ->
        retract(item_inventory(Index, empty)),
        assertz(item_inventory(Index, Item)),
        format('Item ~w ditambahkan ke slot ~w~n', [Item, Index])
    ;   write('Inventori penuh! Tidak bisa menambahkan item.'), nl
    ).

/* Menggunakan Poké Ball */
use_pokeball :-
    (   item_inventory(Index, pokeball(empty)) ->
        retract(item_inventory(Index, pokeball(empty))),
        assertz(item_inventory(Index, empty)),
        write('Poké Ball digunakan.'), nl
    ;   write('Tidak ada Poke Ball kosong!'), nl
    ).

/* Menangkap Pokémon */
catch_pokemon(Pokemon) :-
    party_slots_remaining(Remaining),
    remaining_moves(Remaining1),
    LevelMin is min(14, max(2, round(2 + (20 - Remaining1) / 2))),
    LevelMax is min(14, max(LevelMin, round(4 + (20 - Remaining1) / 1.5))),
    random_between(LevelMin, LevelMax, Level),
    base_stats(HPBase, ATKBase, DEFBase, Pokemon),
    HP is HPBase + 2 * Level,
    ATK is ATKBase + 1 * Level,
    DEF is DEFBase + 1 * Level,
    Leve1 is Level + 1,
    (Remaining > 0 ->
        Idx is 5 - Remaining, 
        assertz(poke_stats(HP, ATK, DEF, Pokemon, Idx, 1)),
        assertz(level(Leve1, Pokemon, Idx, 0, 1)), 
        add_to_party(Idx, Pokemon),
        assertz(curr_health(Idx,Pokemon,HP, 1)),
        format('~w tertangkap dan masuk ke party!~n', [Pokemon])
    ;
        (   item_inventory(Index, pokeball(empty)) ->
            retract(item_inventory(Index, pokeball(empty))),
            assertz(poke_stats(HP, ATK, DEF, Pokemon, Index, 0)),
            assertz(level(Leve1, Pokemon, Index, 0, 0)), 
            assertz(item_inventory(Index, pokeball(filled(Pokemon)))),
            assertz(curr_health(Index,Pokemon,HP, 0)),
            format('~w tertangkap dan disimpan di Poké Ball slot ~w~n', [Pokemon, Index])
        ;   
            format('Tidak ada Poke Ball kosong! Gagal menangkap ~w~n', [Pokemon]), fail
        )
    ).

/* Menampilkan inventori */
show_bag :-
    nl, write('=== Isi Inventory (40 slot) ==='), nl,
    show_inventory(0).

show_inventory(40) :- !.
show_inventory(Index) :-
    (   item_inventory(Index, Item) -> true ; Item = kosong ),
    Index1 is Index + 1,
    format('Slot ~w: ', [Index1]),
    (Item == empty -> write('Kosong') ; write(Item)),
    nl,
    Next is Index + 1,
    show_inventory(Next).

/* Handle item drop setelah pertarungan */
handle_item_drop :-
    random(0, 100, RandInt),
    Rand is RandInt / 100.0,
    (   Rand =< 0.75 ->
        random_item(Item),
        add_item(Item),
        format('Item ~w didapatkan!~n', [Item])
    ;   true
    ).

/* Item yang mungkin didapat */
random_item(Item) :-
    Items = [potion, super_potion, hyper_potion, pokeball(empty)],
    random_member(Item, Items).

/* Memilih elemen acak dari list */
random_member(Item, List) :-
    length(List, Length),
    random(0, Length, Index),
    nth0(Index, List, Item).


add_to_party(Index, Pokemon) :-
    findall(P, party(_, P), List),
    length(List, Len),
    max_party_size(Max),
    (Len < Max ->
        assertz(party(Index, Pokemon)),
        write(Pokemon), write(' telah ditambahkan ke party.'), nl
    ;
        write('Party penuh!'), nl, fail
    ).

party_slots_remaining(Remaining) :-
    findall(P, party(_, P), List),
    length(List, Len),
    max_party_size(Max),
    Remaining is Max - Len.

invenswitch(Inven, Party):-
    Party1 is Party + 1,
    poke_stats(HPi, ATKi, DEFi, Pokemoni, Inven, 0),
    poke_stats(HPp, ATKp, DEFp, Pokemonp, Party1, 1),
    curr_health(Inven, Pokemoni, CurrHpi, 0),
    curr_health(Party1, Pokemonp, CurrHpp, 1),
    level(Leveli, Pokemoni, Inven, Counteri, 0),
    level(Levelp, Pokemonp, Party1, Counterp, 1),
    party(Party1,Pokemonp),

    /* Ambil pokemon inven */
    retract(poke_stats(HPi, ATKi, DEFi, Pokemoni, Inven, 0)),
    retract(curr_health(Inven, Pokemoni, CurrHpi, 0)),
    retract(level(Leveli, Pokemoni, Inven, Counteri, 0)),

    /* replace pokemon party ke inven */
    assertz(poke_stats(HPp, ATKp, DEFp, Pokemonp, Inven, 0)),
    assertz(curr_health(Inven, Pokemonp, CurrHpp, 0)),
    assertz(level(Levelp, Pokemonp, Inven, Counterp, 0)),   

    /* Ambil pokemon party */
    retract(poke_stats(HPp, ATKp, DEFp, Pokemonp, Party1, 1)),
    retract(curr_health(Party1, Pokemonp, CurrHpp, 1)),
    retract(level(Levelp, Pokemonp, Party1, Counterp, 1)),
    retract(party(Party1,Pokemonp)),

    /* replace pokemon inven ke party */
    assertz(poke_stats(HPi, ATKi, DEFp, Pokemoni, Party1, 1)),
    assertz(curr_health(Party1, Pokemoni, CurrHpi, 1)),
    assertz(level(Leveli, Pokemoni, Party1, Counteri, 1)),
    assertz(party(Party1,Pokemoni)).