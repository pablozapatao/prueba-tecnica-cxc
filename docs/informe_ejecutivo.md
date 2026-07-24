# Informe Ejecutivo — Diagnóstico y Estrategia de Recuperación de Cuentas por Cobrar

**Dirigido a:** Alta Dirección / Áreas de Negocio
**Tema:** Comprensión del comportamiento de las Cuentas por Cobrar (CxC) y palancas de
mejora basadas en evidencia.

---

## 1. Mensaje principal

El portafolio de cuentas por cobrar recupera el **84% de su valor**, pero **1 de cada 5
obligaciones enfrenta dificultad de recuperación**, y ese riesgo no está distribuido al
azar: se concentra en **tipos de transacción y rangos de monto específicos**. Esto abre
una oportunidad concreta de mejora operativa sobre **~22,2 millones pendientes**, sin
necesidad de nueva tecnología, redirigiendo el esfuerzo de cobranza donde el impacto es
mayor.

---

## 2. Situación

La operación genera diariamente cuentas por cobrar asociadas a transacciones de clientes.
Una parte se recupera con normalidad; otra presenta pagos parciales, tardíos o
permanencia en estado pendiente. Se analizó la base histórica (21.739 obligaciones, 800
titulares, ~10 meses, ~141,6 millones generados) para entender ese comportamiento y
proponer palancas de acción.

---

## 3. Hallazgos clave (basados en evidencia)

**H1. La recuperación es alta pero desigual.**
Se recupera el 84,3% del valor y el 79,7% de las obligaciones. El 20% restante se divide
en pago parcial (12,3%) y sin pago alguno (8,0%).

**H2. El no-pago se concentra en obligaciones de bajo monto.**
Que se recupere más valor (84%) que cantidad (80%) indica que las obligaciones que no se
pagan son, sobre todo, las pequeñas. Las grandes se pagan mejor.

**H3. Ciertos tipos de transacción se recuperan sistemáticamente peor.**
La recuperación varía de 37% a 98% según el tipo. El foco de mayor impacto es COMISION
TRANSFERENCIA EXTERNA B, que combina mala recuperación (15,5% sin pago) con alto volumen
(1.184 obligaciones).

**H4. La fuente de datos es confiable.**
Sin datos faltantes, contablemente consistente al 100% y sin anomalías de fechas. Las
decisiones se apoyan en información sólida.

---

## 4. Sobre el modelo predictivo (transparencia)

Se desarrolló un modelo para estimar la probabilidad de pago por obligación. El
diagnóstico fue honesto: con las variables disponibles (transaccionales), el modelo no
alcanza poder predictivo individual suficiente. La causa es que estas variables explican
el comportamiento **por grupo**, no caso por caso. En lugar de forzar un resultado, se
documentó la limitación y se identificó la vía de mejora futura: incorporar variables de
**comportamiento histórico del cliente**. El valor accionable inmediato proviene del
diagnóstico del portafolio, que sí es robusto.

---

## 5. Recomendaciones (palancas de mejora)

**R1. Gestión diferenciada por monto.**
Automatizar y abaratar la gestión de obligaciones pequeñas (donde se concentra el
no-pago pero el valor unitario es bajo) y reservar la gestión personalizada para las de
alto monto. Evita gastar recursos costosos en recuperar montos diminutos.

**R2. Priorización por tipo de transacción.**
Concentrar la gestión en los tipos que combinan mala recuperación y alto volumen, en vez
de tratar el portafolio de forma homogénea. Criterio de priorización: tasa de
no-recuperación × volumen × valor.

**R3. Enriquecer los datos para predicción futura.**
Capturar historial de pago por cliente habilitaría un modelo predictivo robusto, elevando
la gestión de reactiva a anticipada.

---

## 6. Indicadores para el seguimiento continuo

**Indicadores de resultado:** tasa de recuperación en valor, valor pendiente, % sin pago.
**Contraindicadores (alertas):** brecha valor-cantidad (eficiencia de la gestión),
concentración de riesgo por tipo de transacción y por titular, antigüedad del pendiente.

El tablero de seguimiento (Power BI) materializa estos indicadores para monitoreo
permanente y toma de decisiones por parte de las áreas de negocio.

---

## 7. Beneficios esperados

- Foco de la gestión de cobro donde el impacto en recuperación es mayor.
- Eficiencia operativa: menos esfuerzo desperdiciado en obligaciones de bajo retorno.
- Base analítica trazable y reproducible para decisiones futuras.
- Ruta clara hacia un modelo predictivo cuando se enriquezcan los datos.
