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
    (Remaining > 0 ->
        Idx is 5 - Remaining,
        add_to_party(Idx, Pokemon),
        format('~w tertangkap dan masuk ke party!~n', [Pokemon])
    ;
        (   item_inventory(Index, pokeball(empty)) ->
            retract(item_inventory(Index, pokeball(empty))),
            assertz(item_inventory(Index, pokeball(filled(Pokemon)))),
            format('~w tertangkap dan disimpan di Poké Ball slot ~w~n', [Pokemon, Index])
        ;   
            format('Tidak ada Poke Ball kosong! Gagal menangkap ~w~n', [Pokemon]), fail
        )
    ).

/* Menampilkan inventori */
show_bag :-
    nl, write('=== Isi Inventori (40 slot) ==='), nl,
    show_inventory(0).

show_inventory(40) :- !.
show_inventory(Index) :-
    (   item_inventory(Index, Item) -> true ; Item = kosong ),
    format('Slot ~w: ', [Index]),
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
