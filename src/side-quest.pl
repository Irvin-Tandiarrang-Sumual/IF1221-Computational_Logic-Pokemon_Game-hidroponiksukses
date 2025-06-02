/* Quiz pokemon */
quiz_pokemon(NamaPokemon) :-
    nl, nl,
    write('Apa tipe element dari pokemon yang akan kamu lawan?'), nl,
    read(Answer), nl,
    type(X, NamaPokemon),
    (X == Answer ->
        write('Jawaban benar!'), nl
    ;
        write('Jawaban salah. Tipe yang benar adalah: '), write(X), nl
    ).




















































































