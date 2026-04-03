module Main where

import Kronar

-- Programa de integración: genera el archivo resultado.json usando t1.
main :: IO ()
main = do
  let t1 :: Tablero
      t1 = [3, -2, -1, 4, 2]
  exportarResultado t1 "resultado.json"
  putStrLn $ "Resultado generado en resultado.json"
  putStrLn $ "Puntaje máximo para t1: " ++ show (kronar t1)
  putStrLn $ "Camino óptimo para t1: " ++ show (caminoOptimo t1)
