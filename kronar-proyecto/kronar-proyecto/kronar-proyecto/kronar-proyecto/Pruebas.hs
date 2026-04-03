module Main where

import Kronar

-- Pruebas propias con justificación en comentarios.
-- Caso 1: camino directo con buena suma, sin bono de Éter.
-- Tablero: [2, -5, 4, 1]
-- Caminos relevantes:
--   [0,3] = 2 + 1 = 3
--   [0,1,3] = 2 - 5 + 1 = -2

--Este comentario está mal:
--   [0,2,3] = 2 + 4 + 1 = 7  -> ganador
-- El camino [0,1,2,3] da bruto=2 (par) → bono +10 → total 12, que es el máximo real. Los tests de Prueba 1 fallarían al ejecutarlos.

prueba1Tablero :: Tablero
prueba1Tablero = [2, -5, 4, 1]

prueba1Esperado :: Int
prueba1Esperado = 12

-- Caso 2: bono de Éter activado por puntaje bruto par y llegada al final exacto.
-- Tablero: [6, -1, 2, 4]
-- Caminos relevantes:
--   [0,3] = 6 + 4 = 10, bonus = 10 => 20
--   [0,1,3] = 6 - 1 + 4 = 9, bonus = 0 => 9
--   [0,2,3] = 6 + 2 + 4 = 12, bonus = 10 => 22  -> ganador
prueba2Tablero :: Tablero
prueba2Tablero = [6, -1, 2, 4]

prueba2Esperado :: Int
prueba2Esperado = 22

imprimirResultado :: String -> Bool -> IO ()
imprimirResultado nombre ok =
  putStrLn $ nombre ++ ": " ++ if ok then "OK" else "FALLÓ"

main :: IO ()
main = do
  imprimirResultado "Prueba 1 kronar" (kronar prueba1Tablero == prueba1Esperado)

-- imprimirResultado "Prueba 1 camino" (caminoOptimo prueba1Tablero == [0,2,3]) 
-- Para [2, -5, 4, 1], el camino [0,1,2,3] da bruto=2 (par) → bono +10 → total 12, que es el máximo real. 
-- Los tests de Prueba 1 fallarían al ejecutarlos.

  imprimirResultado "Prueba 1 camino" (caminoOptimo prueba1Tablero == [0,1,2,3])

  imprimirResultado "Prueba 2 kronar" (kronar prueba2Tablero == prueba2Esperado)
  imprimirResultado "Prueba 2 camino" (caminoOptimo prueba2Tablero == [0,2,3])
  putStrLn $ "Puntaje bruto prueba 2 camino óptimo: " ++ show (puntajeBruto prueba2Tablero [0,2,3])
  putStrLn $ "Penalizacion Zafiro prueba 2 camino óptimo: " ++ show (penalizacionZafiro prueba2Tablero [0,2,3])
  putStrLn "Caminos generados prueba 1:"
  print (caminos prueba1Tablero 0)
  putStrLn "Puntajes de cada camino:"
  mapM_ (\c -> print (c, puntajeBruto prueba1Tablero c)) (caminos prueba1Tablero 0)