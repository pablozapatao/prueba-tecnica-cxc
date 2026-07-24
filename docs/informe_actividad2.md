# Actividad 2 — Modelo de probabilidad de pago: informe y conclusiones

## 1. Objetivo

Estimar, para cada obligación de cobro, la probabilidad de que se pague por completo,
como herramienta de priorización para la gestión de cobranza.

## 2. Enfoque metodológico (la narrativa)

El desarrollo siguió una lógica de diagnóstico e iteración, no de "forzar un resultado":

1. **Definición del problema:** clasificación binaria. Variable objetivo `pagada_total`
   (1 = se recupera el total, 0 = queda saldo). Se justificó frente a alternativas: para
   el negocio, una obligación con cualquier saldo pendiente sigue siendo gestión activa.

2. **Análisis de asociación previo:** antes de modelar, se midió la relación de cada
   variable con el pago. El tipo de transacción mostró la mayor asociación (tasa de pago
   de 36,7% a 98,1% según el tipo); el monto, señal débil; el producto, poca; la
   antigüedad, nula (99,9% en la misma banda, se descartó por varianza casi nula).

3. **Prevención de fuga de información:** se excluyeron como predictores `vlr_pagado`,
   `vlr_pendiente_pago`, `tasa_recuperacion` y `estado_recuperacion`, por contener la
   respuesta.

4. **Preparación técnica:** one-hot encoding de categóricas (variables dummy),
   transformación logarítmica del monto (por sesgo) y separación entrenamiento/prueba
   80/20 **agrupada por titular** (para que ninguna cuenta esté en ambos conjuntos y
   evitar fuga entre ellos).

5. **Modelo:** regresión logística, elegida por interpretabilidad y por ser el estándar
   de scoring de riesgo en banca, sobre una complejidad que no aportaría valor
   defendible.

## 3. Resultados del modelo (con honestidad técnica)

| Métrica | Resultado | Lectura |
|---|---|---|
| AUC-ROC | 0.553 | Poder discriminante bajo (0.5 = azar) |
| Recall clase "no paga" | 0.036 | Detecta solo 33 de 923 no-pagadas reales |
| Accuracy | 0.782 | Engañoso: refleja el desbalance, no el desempeño |

**Interpretación:** el modelo, con las variables disponibles, no logra predecir el pago
a nivel de obligación individual. El accuracy del 78% es un espejismo típico de clases
desbalanceadas: el modelo acierta prediciendo "paga" casi siempre, pero es ciego al
riesgo, que es lo único relevante.

## 4. Diagnóstico de la causa (el aporte analítico)

La causa no es la configuración del modelo, sino los datos: **las variables
transaccionales tienen señal agregada pero no poder predictivo individual.** El tipo de
transacción separa bien los grupos en promedio, pero dentro de cada tipo el
comportamiento individual es demasiado variable para predecir caso por caso.

Distinción técnica central: **asociación agregada ≠ capacidad predictiva individual.**
Reconocerlo, en lugar de inflar un número, es el hallazgo metodológico de esta actividad.

## 5. Decisión de alcance (criterio profesional)

Se identificaron rutas de mejora (ingeniería de variables con comportamiento histórico
del titular, ponderación de clases). Se documentan como trabajo futuro. Dado el tiempo
acotado de la prueba, se priorizó **entregar una historia completa, honesta y
accionable** por encima de iterar hacia un número marginalmente mejor. Saber dónde
detener el modelado es parte del criterio analítico.

## 6. Conclusión de negocio (el verdadero valor)

El valor accionable no depende de un modelo predictivo perfecto; proviene del
diagnóstico del portafolio (Actividad 1), que sí ofrece evidencia sólida:

- **El no-pago se concentra en obligaciones de bajo monto:** se recupera el 84,3% del
  valor pero solo el 79,7% de las obligaciones. Implica una estrategia diferenciada:
  gestión masiva y automatizada para las pequeñas, personalizada para las grandes.
- **Ciertos tipos de transacción se recuperan sistemáticamente peor:** TRANSFERENCIA
  CANAL FISICO (37% de recuperación) frente a otros por encima del 95%.
- **Foco de mayor impacto:** COMISION TRANSFERENCIA EXTERNA B combina mala tasa (15,5%
  sin pago) con alto volumen (1.184 obligaciones). Priorización = tasa × volumen × valor.
- **Oportunidad cuantificada:** ~22,2 millones pendientes de recuperación.

## 7. Recomendaciones

1. Priorizar la gestión por **tipo de transacción**, empezando por los de peor
   recuperación y mayor volumen, en vez de tratar el portafolio de forma homogénea.
2. Diferenciar la estrategia por **monto**: automatizar la gestión de obligaciones
   pequeñas (donde se concentra el no-pago) y personalizar la de las grandes.
3. Para un modelo predictivo robusto a futuro, **capturar variables de comportamiento**
   (historial de pago del titular, número de obligaciones previas, mora acumulada), que
   son las que aportan señal individual.
