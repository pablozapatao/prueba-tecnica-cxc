# Catálogo de reglas de negocio — Sábana de Cuentas por Cobrar

Cada regla nace de un hallazgo de la fase de inspección. Entre paréntesis cito el
hallazgo que la justifica (los códigos B1, B5, etc. corresponden al documento de
preguntas frecuentes y bitácora). Esta trazabilidad permite auditar por qué existe
cada transformación.

Nivel de análisis: la sábana se construye a grano de **obligación de cobro** (cada
fila = una CxC individual). Un mismo titular (`num_cta`) puede tener varias
obligaciones (justificación: B6).

---

## R1. Estandarización de fechas

`f_creacion` y `f_ultimo_pago` vienen como número entero en formato AAAAMMDD
(ej.: 20250413). Se convierten a tipo fecha (DATE) para poder calcular tiempos y
ordenar cronológicamente.
- **Justificación:** B1.
- **Se resuelve en:** capa de staging (no en la inspección).

## R2. Estado de recuperación (derivado de los montos, no de las fechas)

El estado real de la obligación se deriva de los valores monetarios, porque la fecha
de pago no indica si la deuda se saldó (B5). Definición:
- `PAGADA_TOTAL`  → `vlr_pendiente_pago <= 0.01`
- `SIN_PAGO`      → `vlr_pagado <= 0.01`
- `PAGO_PARCIAL`  → cualquier otro caso (pagó algo pero aún debe)
- **Tolerancia de 0.01:** se usa un centavo en vez de comparar contra 0 exacto, para
  evitar falsas clasificaciones por errores de redondeo en decimales.
- **Justificación:** B5, B7, B8.

## R3. Tasa de recuperación

`tasa_recuperacion = vlr_pagado / vlr_original`. Es la proporción del valor original
que ya se recuperó (0 = nada, 1 = todo).
- **Manejo de división por cero:** si `vlr_original = 0`, la tasa se deja como nula.
  En la fuente actual el mínimo es 36.33 (no hay ceros), pero la regla se deja de
  forma defensiva por robustez.
- **Justificación:** B7, B11.

## R4. Días de gestión

`dias_gestion = fecha_ultimo_pago - fecha_creacion` (en días). Mide cuánto tardó en
producirse el último movimiento de pago desde que se creó la obligación.
- **Advertencia de interpretación:** para las obligaciones `SIN_PAGO` (pagado = 0),
  este campo existe pero NO representa un pago real; probablemente refleja una fecha
  de actualización del sistema. Por eso `dias_gestion` solo se interpreta como tiempo
  de recuperación en obligaciones con pago efectivo (pagado > 0).
- **Justificación:** B3, B5.

## R5. Antigüedad de la obligación (aging)

Como la base es un corte histórico, se define una **fecha de corte** = fecha máxima
de último pago observada en toda la tabla (proxy de la fecha de extracción de los
datos). A partir de ahí:
- `dias_desde_creacion = fecha_corte - fecha_creacion`
- `banda_antiguedad`: 0–30, 31–60, 61–90, 91+ días.
- **Supuesto documentado:** la fecha de corte se aproxima con el máximo de
  `fecha_ultimo_pago`, a falta de una fecha de extracción explícita.
- **Justificación:** B2.

## R6. Madurez / censura (para el modelo de la Actividad 2)

Las obligaciones creadas cerca de la fecha de corte han tenido poco tiempo para
pagarse; clasificarlas como "no pagadas" sería injusto (censura).
- `flag_reciente = 1` si `dias_desde_creacion` es menor a un umbral de maduración
  (a definir con la distribución de tiempos de pago; punto de partida sugerido: 90 días).
- Este flag NO altera la sábana descriptiva; sirve para decidir qué obligaciones son
  "observables" al entrenar el modelo.
- **Justificación:** B2.

## R7. Flags de control de calidad

Aunque la inspección mostró una fuente limpia, los controles se dejan materializados
en la sábana para que el proceso sea robusto y reproducible si la fuente cambia:
- `flag_inconsistencia_contable = 1` si `|vlr_original - (vlr_pagado + vlr_pendiente_pago)| > 0.01` (hoy: 0 casos, B7).
- `flag_fecha_invertida = 1` si `fecha_ultimo_pago < fecha_creacion` (hoy: 0 casos, B5).
- `flag_pago_mayor_original = 1` si `vlr_pagado > vlr_original + 0.01`.
- **Justificación:** B5, B7.

## R8. Variable objetivo para el modelo (Actividad 2)

`pagada_total = 1` si `estado_recuperacion = 'PAGADA_TOTAL'`, si no `0`.
- Se materializa en la sábana para tenerla disponible, pero su uso definitivo
  (y el filtro de censura de R6) se decide en la Actividad 2.
- **Justificación:** B8.

---

## Métricas agregables (para análisis y dashboard)

Además de las variables por obligación, la sábana permite calcular a nivel producto,
tipo de transacción o titular:
- Tasa de recuperación en **valor**: `SUM(vlr_pagado) / SUM(vlr_original)`.
- % de obligaciones por estado.
- Valor pendiente total (tamaño de la oportunidad de cobro).
- Priorización = tasa de no-recuperación × volumen × valor (B10, B12).
