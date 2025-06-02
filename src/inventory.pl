:- dynamic(item_inventory/1).

max_party_size(4).

/* Inisialisasi inventori */
initialize_inventory :-
    length(InitialItems, 40),
    fill_initial_items(InitialItems, 20),
    assertz(item_inventory(InitialItems)).

fill_initial_items(Items, N) :-
    fill_pokeballs(Items, N, 0).

fill_pokeballs([], _, _).
fill_pokeballs([pokeball(empty)|T], N, Count) :-
    Count < N,
    NewCount is Count + 1,
    fill_pokeballs(T, N, NewCount).
fill_pokeballs([empty|T], N, Count) :-
    fill_pokeballs(T, N, Count).

/* Menambahkan item */
add_item(Item) :-
    item_inventory(Inventory),
    (   nth0(Index, Inventory, empty) ->
        replace_nth(Index, Inventory, Item, NewInventory),
        retract(item_inventory(Inventory)),
        assertz(item_inventory(NewInventory)),
        write('Item '), write(Item), 
        write(' ditambahkan ke slot '), write(Index), nl
    ;   write('Inventori penuh! Tidak bisa menambahkan item.'), nl
    ).

/* Mengganti elemen ke-n dalam list */
replace_nth(0, [_|T], Item, [Item|T]).
replace_nth(N, [H|T], Item, [H|NewT]) :-
    N > 0,
    N1 is N - 1,
    replace_nth(N1, T, Item, NewT).

/* Menggunakan Poké Ball */
use_pokeball :-
    item_inventory(Inventory),
    (   nth0(Index, Inventory, pokeball(empty)) ->
        replace_nth(Index, Inventory, empty, NewInventory),
        retract(item_inventory(Inventory)),
        assertz(item_inventory(NewInventory)),
        write('Poké Ball digunakan.'), nl
    ;   write('Tidak ada Poké Ball kosong!'), nl
    ).

/* Menangkap Pokémon */
catch_pokemon(Pokemon) :-
    item_inventory(Inventory),
    (   nth0(Index, Inventory, pokeball(empty)) ->
        replace_nth(Index, Inventory, pokeball(filled(Pokemon)), NewInventory),
        retract(item_inventory(Inventory)),
        assertz(item_inventory(NewInventory)),
        write(Pokemon), write(' tertangkap dan disimpan di slot '), write(Index), nl
    ;   write('Tidak ada Poké Ball kosong!'), nl
    ).

/* Menampilkan inventori */
show_bag :-
    item_inventory(Inventory),
    nl, write('=== Isi Inventori (40 slot) ==='), nl,
    display_inventory(Inventory, 0).

display_inventory([], _).
display_inventory([Item|T], Index) :-
    write('Slot '), write(Index), write(': '),
    (   Item == empty
    ->  write('Kosong')
    ;   write(Item)
    ),
    nl,
    NewIndex is Index + 1,
    display_inventory(T, NewIndex).

/* Handle item drop setelah pertarungan */
handle_item_drop :-
    /* Generate random float antara 0.0 dan 1.0 */
    random(0, 100, RandInt),  % Angka integer 0-99
    Rand is RandInt / 100.0,   % Konversi ke float 0.0-0.99
    
    (   Rand =< 0.75 ->        /* 75% chance untuk dapat item */
        random_item(Item),
        add_item(Item),
        write('Item '), write(Item), write(' didapatkan!'), nl
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


add_to_party(X, Pokemon) :-
    findall(P, party(_, P), List),
    length(List, Len),
    max_party_size(Max),
    (Len < Max ->
        assertz(party(X, Pokemon)),
        format('~w telah ditambahkan ke party.~n', [Pokemon]);
        write('Party penuh! Tidak bisa menambahkan Pokémon lagi.'), nl, fail).

show_party :-
    write('=== Pokémon di Party ==='), nl,
    (party(_, _) ->
        forall(party(_, P), format('- ~w~n', [P]));
        write('Party kosong.'), nl).

party_slots_remaining(Remaining) :-
    findall(P, party(_, P), List),
    length(List, Len),
    max_party_size(Max),
    Remaining is Max - Len.
