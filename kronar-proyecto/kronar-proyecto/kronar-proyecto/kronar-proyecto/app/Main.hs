module Main where

import Kronar
import Data.List (words)

-- Convierte string a lista de enteros
parseTablero :: String -> [Int]
parseTablero input = map read (words input)

main :: IO ()
main = do
    putStrLn "Ingrese el tablero (numeros separados por espacios):"
    input <- getLine
    let tablero = parseTablero input
    
    let resultado = kronar tablero
    
    putStrLn ("Puntaje máximo: " ++ show resultado)
    
    exportarResultado tablero "resultado.json"
    
    putStrLn "Resultado exportado a resultado.json"