:- dynamic(item_inventory/1).

/*inventori 20 Poké Ball kosong dan 20 slot kosong*/
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

/* Menambahkan item ke slot kosong pertama*/
add_item(Item) :-
    item_inventory(Inventory),
    (   nth0(Index, Inventory, empty) ->
        replace_nth(Index, Inventory, Item, NewInventory),
        retract(item_inventory(Inventory)),
        assertz(item_inventory(NewInventory)),
        format('Item ~w ditambahkan ke slot ~d.~n', [Item, Index])
    ;   write('Inventori penuh! Tidak bisa menambahkan item.'), nl
    ).

/* Mengganti elemen ke-n dalam list*/
replace_nth(0, [_|T], Item, [Item|T]).
replace_nth(N, [H|T], Item, [H|NewT]) :-
    N > 0,
    N1 is N - 1,
    replace_nth(N1, T, Item, NewT).

/* Menggunakan Pokeball (kosong)*/
use_pokeball :-
    item_inventory(Inventory),
    (   nth0(Index, Inventory, pokeball(empty)) ->
        replace_nth(Index, Inventory, empty, NewInventory),
        retract(item_inventory(Inventory)),
        assertz(item_inventory(NewInventory)),
        write('Poké Ball digunakan.'), nl
    ;   write('Tidak ada Poké Ball kosong!'), nl
    ).
/* Menangkap Pokemon dan mengisi Pokeball*/
catch_pokemon(Pokemon) :-
    item_inventory(Inventory),
    (   nth0(Index, Inventory, pokeball(empty)) ->
        replace_nth(Index, Inventory, pokeball(filled(Pokemon)), NewInventory),
        retract(item_inventory(Inventory)),
        assertz(item_inventory(NewInventory)),
        format('~w tertangkap dan disimpan di slot ~d.~n', [Pokemon, Index])
    ;   write('Tidak ada Poké Ball kosong!'), nl
    ).
/* Menampilkan isi inventori*/
show_bag :-
    item_inventory(Inventory),
    format('~n=== Isi Inventori (40 slot) ===~n'),
    display_inventory(Inventory, 0).

display_inventory([], _).
display_inventory([Item|T], Index) :-
    format('Slot ~d: ', [Index]),
    (   Item == empty
    ->  write('Kosong')
    ;   write(Item)
    ),
    nl,
    NewIndex is Index + 1,
    display_inventory(T, NewIndex).

/* Contoh item tambahan (Potion, dll.)*/
item(pokeball).
item(potion).
item(super_potion).
item(hyper_potion).

/* Menangani drop item setelah pertarungan*/
handle_item_drop :-
    random(0.0, 1.0, Rand),
    (   Rand =< 0.75 ->
        random_item(Item),
        add_item(Item),
        format('Item ~w didapatkan!~n', [Item])
    ;   true
    ).

random_item(Item) :-
    Items = [potion, super_potion, hyper_potion, pokeball(empty)],
    random_member(Item, Items).