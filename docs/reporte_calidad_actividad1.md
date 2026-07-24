# Reporte de calidad y exploración de datos — Actividad 1

**Proyecto:** Análisis de Cuentas por Cobrar (CxC)
**Fuente:** base SQLite histórica, tabla `tabla1`
**Alcance:** inspección, control de calidad y construcción de la sábana analítica.

---

## 1. Resumen ejecutivo

Se analizó un portafolio de **21.739 obligaciones de cobro** pertenecientes a **800
titulares**, generadas entre el **11/oct/2024 y el 13/ago/2025** (~10 meses), por un
valor total de **~141,6 millones**.

La fuente presenta **alta calidad**: sin valores faltantes, contablemente consistente
en el 100% de los registros y sin fechas inválidas. El único ajuste estructural
necesario fue la conversión de las fechas, que venían como número entero.

Hallazgo central de negocio: el **79,7% de las obligaciones se recupera totalmente**,
pero un **20% presenta dificultad** (12,3% pago parcial, 8,0% sin pago). Medida en
dinero, la recuperación es del **84,3%**, lo que indica que el no-pago se concentra en
obligaciones de menor monto. Quedan **~22,2 millones pendientes** de recuperar.

---

## 2. Perfil general de la fuente

| Aspecto | Resultado |
|---|---|
| Total de obligaciones (filas) | 21.739 |
| Titulares distintos (`num_cta`) | 800 |
| Columnas originales | 13 |
| Periodo (fecha de creación) | 11/oct/2024 – 13/ago/2025 |
| Grano de la tabla | Obligación de cobro (no cliente) |

El grano se validó comparando filas contra cuentas distintas: cada titular genera ~27
obligaciones en promedio. La unidad de análisis es, por tanto, la **obligación**, con
posibilidad de agregar a nivel titular.

---

## 3. Controles de calidad aplicados

| Control | Resultado | Interpretación |
|---|---|---|
| Completitud (nulos) | 0 nulos en todas las columnas | Fuente completa |
| Consistencia contable (`original = pagado + pendiente`) | 0 registros descuadrados | Los montos son fuente de verdad |
| Validez de fechas (último pago ≥ creación) | 100% válidas, 0 invertidas | Cronología correcta |
| Formato de fechas | Enteros AAAAMMDD | Requiere conversión (resuelto en staging) |

**Nota metodológica:** una validación preliminar de fechas reportó falsamente un 100%
de inconsistencia. Se auditó y se identificó un error en la regla (comparación de texto
contra número), no en los datos. Aprendizaje: todo control de calidad debe validarse a
sí mismo antes de reportar hallazgos.

---

## 4. Comportamiento de recuperación

### Por estado (cantidad de obligaciones)

| Estado | Cantidad | % |
|---|---|---|
| Pagada total | 17.323 | 79,69% |
| Pago parcial | 2.669 | 12,28% |
| Sin pago | 1.747 | 8,04% |

### Recuperación en cantidad vs. en valor

- Recuperación en **cantidad** de obligaciones: **79,7%**
- Recuperación en **valor** ($): **84,3%**

La brecha indica que las obligaciones no recuperadas tienden a ser las de **menor
monto**; las grandes se pagan mejor. Implicación de negocio: conviene una estrategia
diferenciada (gestión masiva/automática para las pequeñas, personalizada para las
grandes).

### Distribución de montos

Distribución fuertemente sesgada a la derecha: mediana 2.218 frente a promedio 6.512;
máximo 446.887. El monto típico se describe mejor con la mediana. Los valores extremos
deberán tratarse en el modelo (Actividad 2).

---

## 5. Concentración y foco de gestión

- **Producto:** AHORRO concentra ~99% (21.491); CORRIENTE ~1% (248, poco robusto para
  análisis).
- **Transacciones:** CARGO FISCAL TRANSACCIONAL (31,4%) y COBRO SERVICIO TRANSPORTE
  (17%) concentran casi la mitad del volumen (Pareto).
- **Peor recuperación por tasa:** TRANSFERENCIA CANAL FISICO (36,7% pagada total) y
  CARGO FISCAL IVA A, ambos de bajo volumen.
- **Foco de mayor impacto (mala tasa + alto volumen):** COMISION TRANSFERENCIA EXTERNA
  B (15,5% sin pago sobre 1.184 obligaciones).

**Criterio de priorización propuesto:** combinar tasa de no-recuperación × volumen ×
valor, no solo la tasa.

---

## 6. Sábana analítica construida

Se construyó una sábana a grano de obligación con **20 columnas** (10 originales + 10
derivadas), mediante una arquitectura por capas (cruda → staging → analítica) y un
pipeline en Python (POO) reproducible con un solo comando.

Variables derivadas: `estado_recuperacion`, `tasa_recuperacion`, `dias_gestion`,
`dias_desde_creacion`, `banda_antiguedad`, `flag_reciente`, `pagada_total` y tres flags
de control de calidad.

Cada variable es trazable hasta la regla de negocio que la define y el hallazgo que la
justifica (ver `reglas_negocio.md` y `modelo_conceptual.md`).

---

## 7. Supuestos y limitaciones documentados

- Las fechas se interpretan como formato AAAAMMDD.
- La fecha de corte del portafolio se aproxima con el máximo `fecha_ultimo_pago`, a
  falta de una fecha de extracción explícita.
- Para obligaciones sin pago, `dias_gestion` se deja nulo (la fecha de pago no
  representa un pago real).
- El producto CORRIENTE (248 casos) tiene bajo volumen para conclusiones robustas.
- El periodo de ~10 meses implica censura: las obligaciones recientes han tenido poco
  tiempo para pagarse; se marcan con `flag_reciente` para el modelo.

---

## 8. Insumos para la Actividad 2

La sábana queda lista con la variable objetivo (`pagada_total`) y el marcador de censura
(`flag_reciente`), habilitando la construcción del modelo de probabilidad de pago.
