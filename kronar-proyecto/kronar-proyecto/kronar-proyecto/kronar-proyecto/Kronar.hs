module Kronar
  ( Tablero
  , caminos
  , puntajeBruto
  , penalizacionZafiro
  , bonoEter
  , ajustarFinal
  , kronar
  , exportarResultado
  , caminoOptimo
  ) where

import System.IO (writeFile)
import Data.List (intercalate)

-- Representa el tablero como lista de enteros.
type Tablero = [Int]

-- Ajusta el índice final si la última casilla vale 0 (Regla del Vacío).
ajustarFinal :: Tablero -> Int
ajustarFinal [] = error "ajustarFinal: tablero vacio"
ajustarFinal tablero
  | length tablero < 2 = error "ajustarFinal: el tablero debe tener al menos 2 casillas"
  | last tablero == 0  = length tablero - 2
  | otherwise          = length tablero - 1

-- Genera todos los caminos válidos desde posActual hasta el final.
caminos :: Tablero -> Int -> [[Int]]
caminos tablero posActual = caminosDesde objetivo posActual
  where
    objetivo = ajustarFinal tablero

    caminosDesde :: Int -> Int -> [[Int]]
    caminosDesde fin pos
      | pos == fin = [[pos]]
      | pos >  fin = []
      | otherwise  = explorarPasos fin pos 1

    explorarPasos :: Int -> Int -> Int -> [[Int]]
    explorarPasos fin pos paso
      | paso > 3           = []
      | pos + paso > fin   = explorarPasos fin pos (paso + 1)
      | otherwise          = agregarActual pos (caminosDesde fin (pos + paso))
                             ++ explorarPasos fin pos (paso + 1)

    agregarActual :: Int -> [[Int]] -> [[Int]]
    agregarActual _ []     = []
    agregarActual x (c:cs) = (x : c) : agregarActual x cs

-- Suma los valores de las casillas visitadas.
puntajeBruto :: Tablero -> [Int] -> Int
puntajeBruto tablero camino = sumarCamino camino
  where
    sumarCamino :: [Int] -> Int
    sumarCamino []     = 0
    sumarCamino (i:is) = tablero !! i + sumarCamino is

-- Penalización de 5 por cada par consecutivo de casillas negativas.
penalizacionZafiro :: Tablero -> [Int] -> Int
penalizacionZafiro _ []        = 0
penalizacionZafiro _ [_]       = 0
penalizacionZafiro tablero (a:b:resto)
  | tablero !! a < 0 && tablero !! b < 0 = 5 + penalizacionZafiro tablero (b:resto)
  | otherwise                             = penalizacionZafiro tablero (b:resto)

-- Bono de +10 si el puntaje bruto es par y se llegó al final exacto.
bonoEter :: Int -> Int -> Int
bonoEter pb llegaAlFinalExacto
  | llegaAlFinalExacto == 1 && even pb = 10
  | otherwise                          = 0

-- Puntaje total de un camino aplicando las tres reglas.
puntajeTotalCamino :: Tablero -> [Int] -> Int
puntajeTotalCamino tablero camino = bruto - penalizacion + bono
  where
    bruto        = puntajeBruto tablero camino
    penalizacion = penalizacionZafiro tablero camino
    -- Éter solo aplica si NO se activó la Regla del Vacío y se llegó a n-1.
    llegaAlFinalExacto =
      if null camino || last tablero == 0 then 0
      else if last camino == length tablero - 1 then 1 else 0
    bono = bonoEter bruto llegaAlFinalExacto

-- Máximo propio sin usar maximum.
maximo :: [Int] -> Int
maximo []     = error "maximo: lista vacia"
maximo (x:xs) = maximoAux x xs
  where
    maximoAux :: Int -> [Int] -> Int
    maximoAux actual []     = actual
    maximoAux actual (y:ys)
      | y > actual = maximoAux y ys
      | otherwise  = maximoAux actual ys

-- Retorna el puntaje máximo posible.
kronar :: Tablero -> Int
kronar tablero = maximo (map (puntajeTotalCamino tablero) (caminos tablero 0))

-- Selecciona el mejor camino junto con su puntaje.
mejorCaminoConPuntaje :: Tablero -> ([Int], Int)
mejorCaminoConPuntaje tablero = mejorDeLista (caminos tablero 0)
  where
    mejorDeLista :: [[Int]] -> ([Int], Int)
    mejorDeLista []     = error "mejorCaminoConPuntaje: no hay caminos"
    mejorDeLista (c:cs) = recorrer c (puntajeTotalCamino tablero c) cs

    recorrer :: [Int] -> Int -> [[Int]] -> ([Int], Int)
    recorrer mc mp []     = (mc, mp)
    recorrer mc mp (c:cs)
      | pa > mp   = recorrer c  pa cs
      | otherwise = recorrer mc mp cs
      where pa = puntajeTotalCamino tablero c

-- Camino óptimo exportable.
caminoOptimo :: Tablero -> [Int]
caminoOptimo tablero = fst (mejorCaminoConPuntaje tablero)

-- Exporta el resultado al archivo JSON indicado.
exportarResultado :: Tablero -> FilePath -> IO ()
exportarResultado tablero ruta = writeFile ruta contenido
  where
    mejor         = mejorCaminoConPuntaje tablero
    camino        = fst mejor
    puntajeFinal  = snd mejor
    bruto         = puntajeBruto tablero camino
    penal         = penalizacionZafiro tablero camino
    vacioAplicado = last tablero == 0
    llegaAlFinalExacto =
      if null camino || vacioAplicado then 0
      else if last camino == length tablero - 1 then 1 else 0
    bono = bonoEter bruto llegaAlFinalExacto
    contenido = unlines
      [ "{"
      , "  \"tablero\": "             ++ listaEnteros tablero ++ ","
      , "  \"camino_optimo\": "       ++ listaEnteros camino  ++ ","
      , "  \"puntaje_final\": "       ++ show puntajeFinal    ++ ","
      , "  \"bono_eter\": "           ++ show bono            ++ ","
      , "  \"penalizacion_zafiro\": " ++ show penal           ++ ","
      , "  \"regla_vacio_aplicada\": " ++ boolJson vacioAplicado
      , "}"
      ]
    listaEnteros :: [Int] -> String
    listaEnteros xs = "[" ++ intercalate ", " (map show xs) ++ "]"
    boolJson :: Bool -> String
    boolJson True  = "true"
    boolJson False = "false"