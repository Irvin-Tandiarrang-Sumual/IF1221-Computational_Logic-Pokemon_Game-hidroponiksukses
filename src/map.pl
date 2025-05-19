
:- dynamic(map/1).

print_matrix :-
    map(Matrix),
    print_matrix_rows(Matrix).

print_matrix_rows([]).
print_matrix_rows([Row|T]) :-
    print_row(Row),
    print_matrix_rows(T).

print_row([]) :- nl.
print_row([H|T]) :-
    write(H), write(' '),
    print_row(T).

generate_matrix(N, Matrix) :- retractall(map(_)),
    generate_rows(1, N, N, Matrix), 
    assertz(map(Matrix)).

generate_rows(I, N, _, []) :- I > N.
generate_rows(I, N, Size, [Row|T]) :-
    I =< N,
    generate_row(I, Size, Row),
    I1 is I + 1,
    generate_rows(I1, N, Size, T).

generate_row(RowIndex, Size, Row) :-
    1 is RowIndex mod 2,
    line(Size, Row).

generate_row(RowIndex, Size, Row) :-
    0 is RowIndex mod 2,
    tile(Size, Row).

line(0, []).
line(N, ['+'|T]) :-
    N > 0,
    N1 is N - 1,
    line_zero(N1, T).

line_zero(0, []).
line_zero(N, ['-'|T]) :-
    N > 0,
    N1 is N - 1,
    line(N1, T).

tile(0, []).
tile(N, ['|'|T]) :-
    N > 0,
    N1 is N - 1,
    tile_zero(N1, T).

tile_zero(0, []).
tile_zero(N, ['0'|T]) :-
    N > 0,
    N1 is N - 1,
    tile(N1, T).