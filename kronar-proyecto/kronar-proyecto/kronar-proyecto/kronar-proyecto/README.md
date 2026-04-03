# El Juego de los Kronares

**Proyecto Integrador · Haskell + Erlang**

---

## 👥 Autores

* Jhonatan Alejandro Galindo Castañeda
* Jeronimo Lopez
* Emmanuel Peñuela Chica
* Johansebastian Osorio Saldarriaga

---

## Descripción del Proyecto

Este proyecto implementa el juego **Kronar**, una simulación estratégica donde un personaje (Dravek) debe recorrer un tablero lineal recolectando energía mientras maximiza su puntaje.

El jugador inicia en la casilla 0 y puede avanzar 1, 2 o 3 posiciones por turno hasta alcanzar el final del tablero.

El objetivo es encontrar el **camino óptimo** que produzca el mayor puntaje posible, considerando reglas especiales del juego.

---

## Reglas del Juego

### Regla del Zafiro

Si el jugador pisa **dos casillas consecutivas negativas**, recibe una penalización de **-5 puntos** por cada ocurrencia.

### Regla del Éter

Si el jugador llega exactamente a la casilla final y el puntaje bruto es **par**, recibe un bono de **+10 puntos**.

### Regla del Vacío

Si la última casilla del tablero tiene valor `0`, el juego termina automáticamente en la casilla anterior.

---

## Estructura del Proyecto

```
JuegoKronares/
│
├── kronar-proyecto/              ← Implementación en Haskell
│   ├── Kronar.hs                 # Lógica principal del juego
│   ├── Main.hs                   # Genera resultado.json con t1
│   ├── Pruebas.hs                # Casos de prueba propios
│   └── README.md                 # Este archivo
│
└── kronar-integracion-erlang/    ← Integración en Erlang
    ├── integracion.erl           # Código fuente Erlang
    ├── integracion.beam          # Bytecode compilado
    └── resultado.json            # Generado por Haskell, leído por Erlang
```

---

## Cómo ejecutar — Orden completo

### Paso 1 — Ejecutar pruebas de Haskell

Desde `kronar-proyecto/`:

```powershell
runghc Pruebas.hs
```

Salida esperada:

```
Prueba 1 kronar: OK
Prueba 1 camino: OK
Prueba 2 kronar: OK
Prueba 2 camino: OK
```

---

### Paso 2 — Generar resultado.json con Haskell

Desde `kronar-proyecto/`:

```powershell
runghc Main.hs
```

Esto genera `resultado.json` en `kronar-integracion-erlang/` con el tablero t1 = `[3, -2, -1, 4, 2]`.

Salida esperada:

```
Resultado generado en resultado.json
Puntaje máximo para t1: 18
Camino óptimo para t1: [0,2,3,4]
```

---

### Paso 3 — Compilar Erlang (solo la primera vez)

Desde `kronar-integracion-erlang/`:

```powershell
& "C:\Program Files\Erlang OTP\bin\erlc.exe" integracion.erl
```

---

### Paso 4 — Ejecutar Erlang

Desde `kronar-integracion-erlang/`:

```powershell
erl -noshell -s integracion main -s init stop
```

Salida esperada:

```
==========================================
   REPORTE - EL JUEGO DE LOS KRONARES
==========================================
  Tablero             : [3, -2, -1, 4, 2]
  Camino optimo       : [0, 2, 3, 4]
  Puntaje final       :  18 puntos
  Bono Eter           : +10 puntos
  Penalizacion Zafiro : -0 puntos
  Regla del Vacio     :  No  (llego a la casilla final n normalmente)
==========================================
```

> La comunicación entre Haskell y Erlang es exclusivamente a través del archivo `resultado.json`.

---

## Funciones principales

### `ajustarFinal`
Determina el índice final válido del tablero, considerando la Regla del Vacío.

### `caminos`
Genera recursivamente todos los caminos posibles desde la posición inicial hasta el final.

### `puntajeBruto`
Suma los valores de las casillas recorridas en un camino.

### `penalizacionZafiro`
Calcula penalizaciones por pares de casillas consecutivas negativas.

### `bonoEter`
Otorga un bono si se cumple la condición de puntaje par y llegada exacta al final.

### `kronar`
Evalúa todos los caminos posibles y retorna el puntaje máximo.

### `caminoOptimo`
Devuelve el camino que produce el mejor puntaje.

### `exportarResultado`
Genera el archivo `resultado.json` con la información del mejor resultado.

---

## Pruebas propias

### Prueba 1 — Tablero `[2, -5, 4, 1]`

| Camino        | Bruto | Bono Éter | Total  |
| ------------- | ----- | --------- | ------ |
| [0,2,3]       | 7     | 0         | 7      |
| [0,3]         | 3     | 0         | 3      |
| [0,1,3]       | -2    | 10        | 8      |
| **[0,1,2,3]** | 2     | 10        | **12** |

Camino óptimo: `[0,1,2,3]` — Puntaje final: `12`

---

### Prueba 2 — Tablero `[6, -1, 2, 4]`

| Camino    | Bruto | Bono Éter | Total  |
| --------- | ----- | --------- | ------ |
| [0,3]     | 10    | 10        | 20     |
| [0,1,3]   | 9     | 0         | 9      |
| **[0,2,3]** | 12  | 10        | **22** |

Camino óptimo: `[0,2,3]` — Puntaje final: `22`

---

## Nota importante

El camino con mayor suma directa no siempre es el óptimo, debido a la influencia de la Regla del Éter. El problema requiere evaluar completamente todas las combinaciones posibles.
