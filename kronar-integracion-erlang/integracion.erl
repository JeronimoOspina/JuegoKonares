%% =============================================================
%%  integracion.erl
%%  Módulo Erlang para el Juego de los Kronares.
%%
%%  Lee el archivo resultado.json generado por Haskell
%%  y produce un reporte legible en consola.
%%
%%  Compilar : erlc integracion.erl
%%  Ejecutar : erl -noshell -s integracion main -s init stop
%% =============================================================

-module(integracion).
-export([main/0]).

%% Punto de entrada principal.
main() ->
    Archivo = "resultado.json",
    case file:read_file(Archivo) of
        {ok, Binario} ->
            Texto = binary_to_list(Binario),
            Datos = parsear_json(Texto),
            imprimir_reporte(Datos);
        {error, Razon} ->
            io:format("Error al leer '~s': ~p~n", [Archivo, Razon])
    end.

%% =============================================================
%%  PARSER JSON MANUAL
%%  Soporta: objetos {}, arreglos [], enteros, booleanos y strings.
%%  No depende de ninguna librería externa.
%% =============================================================

%% Punto de entrada del parser: espera un objeto JSON.
parsear_json(S) ->
    S1 = omitir_espacios(S),
    {Objeto, _Resto} = parsear_objeto(S1),
    Objeto.

%% Parsea un objeto JSON { "clave": valor, ... }
parsear_objeto([${ | Resto]) ->
    parsear_pares(omitir_espacios(Resto), []).

parsear_pares([$} | Resto], Acc) ->
    {lists:reverse(Acc), Resto};
parsear_pares([$, | Resto], Acc) ->
    parsear_pares(omitir_espacios(Resto), Acc);
parsear_pares(S, Acc) ->
    {Clave, S1} = parsear_cadena(omitir_espacios(S)),
    [$: | S2]   = omitir_espacios(S1),
    {Valor, S3} = parsear_valor(omitir_espacios(S2)),
    parsear_pares(omitir_espacios(S3), [{Clave, Valor} | Acc]).

%% Decide qué tipo de valor parsear según el primer carácter.
parsear_valor([$"  | _] = S) -> parsear_cadena(S);
parsear_valor([$[  | _] = S) -> parsear_arreglo(S);
parsear_valor("true"  ++ R)  -> {true,  R};
parsear_valor("false" ++ R)  -> {false, R};
parsear_valor(S)              -> parsear_entero(S, []).

%% Parsea un string JSON entre comillas dobles.
parsear_cadena([$" | Resto]) ->
    leer_cadena(Resto, []).

leer_cadena([$" | Resto], Acc) -> {lists:reverse(Acc), Resto};
leer_cadena([C  | Resto], Acc) -> leer_cadena(Resto, [C | Acc]).

%% Parsea un arreglo JSON [ v1, v2, ... ]
parsear_arreglo([$[ | Resto]) ->
    parsear_elementos(omitir_espacios(Resto), []).

parsear_elementos([$] | Resto], Acc) ->
    {lists:reverse(Acc), Resto};
parsear_elementos([$, | Resto], Acc) ->
    parsear_elementos(omitir_espacios(Resto), Acc);
parsear_elementos(S, Acc) ->
    {Val, S1} = parsear_valor(S),
    parsear_elementos(omitir_espacios(S1), [Val | Acc]).

%% Parsea un entero (positivo o negativo).
parsear_entero([], Acc) ->
    {list_to_integer(lists:reverse(Acc)), []};
parsear_entero([C | Resto] = S, Acc) ->
    if
        C >= $0, C =< $9        -> parsear_entero(Resto, [C | Acc]);
        C =:= $-, Acc =:= []    -> parsear_entero(Resto, [C | Acc]);
        true                     -> {list_to_integer(lists:reverse(Acc)), S}
    end.

%% Elimina espacios en blanco, saltos de línea y tabulaciones.
omitir_espacios([$  | R]) -> omitir_espacios(R);
omitir_espacios([$\n | R]) -> omitir_espacios(R);
omitir_espacios([$\r | R]) -> omitir_espacios(R);
omitir_espacios([$\t | R]) -> omitir_espacios(R);
omitir_espacios(S)          -> S.

%% Busca una clave en la lista de pares [{Clave, Valor}].
obtener(Clave, Pares) ->
    case lists:keyfind(Clave, 1, Pares) of
        {_, Valor} -> Valor;
        false      -> undefined
    end.

%% =============================================================
%%  GENERACIÓN DEL REPORTE
%% =============================================================

imprimir_reporte(Datos) ->
    Tablero       = obtener("tablero",              Datos),
    CaminoOptimo  = obtener("camino_optimo",        Datos),
    PuntajeFinal  = obtener("puntaje_final",        Datos),
    BonoEter      = obtener("bono_eter",            Datos),
    PenalZafiro   = obtener("penalizacion_zafiro",  Datos),
    ReglaVacio    = obtener("regla_vacio_aplicada", Datos),

    io:format("~n"),
    io:format("==========================================~n"),
    io:format("   REPORTE - EL JUEGO DE LOS KRONARES    ~n"),
    io:format("==========================================~n"),
    io:format("  Tablero             : ~s~n", [lista_a_texto(Tablero)]),
    io:format("  Camino optimo       : ~s~n", [lista_a_texto(CaminoOptimo)]),
    io:format("  Puntaje final       :  ~w puntos~n", [PuntajeFinal]),
    io:format("  Bono Eter           : +~w puntos~n", [BonoEter]),
    io:format("  Penalizacion Zafiro : -~w puntos~n", [PenalZafiro]),
    io:format("  Regla del Vacio     :  ~s~n",        [bool_texto(ReglaVacio)]),
    io:format("==========================================~n"),
    io:format("~n").

%% Convierte una lista de enteros al formato [x, y, z].
lista_a_texto(Lista) ->
    "[" ++ unir_coma(Lista) ++ "]".

unir_coma([])       -> "";
unir_coma([X])      -> integer_to_list(X);
unir_coma([X | Xs]) -> integer_to_list(X) ++ ", " ++ unir_coma(Xs).

%% Convierte booleano a texto descriptivo.
bool_texto(true)  -> "Si  (termino en casilla n-1 por Regla del Vacio)";
bool_texto(false) -> "No  (llego a la casilla final n normalmente)".
