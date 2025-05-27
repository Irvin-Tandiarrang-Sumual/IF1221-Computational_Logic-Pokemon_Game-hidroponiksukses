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

