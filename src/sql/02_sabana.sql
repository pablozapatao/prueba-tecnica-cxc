-- ============================================================================
-- CAPA ANALITICA - Sabana de Cuentas por Cobrar
-- ----------------------------------------------------------------------------
-- Aqui aplico las reglas de negocio sobre la capa staging ya tipada. Cada
-- variable derivada cita la regla que la define (R2, R3...) y, a traves de
-- ella, el hallazgo de la inspeccion que la justifica (B5, B8...).
--
-- Grano: obligacion de cobro (una fila = una CxC), justificacion B6.
-- Idempotente: CREATE OR REPLACE permite re-ejecutar sin duplicar.
-- ============================================================================

CREATE OR REPLACE TABLE sabana_cxc AS

-- Primero calculo la fecha de corte del portafolio: la aproximo con el maximo
-- de fecha_ultimo_pago, como proxy de la fecha de extraccion (regla R5, B2).
-- La dejo en un CTE para reutilizarla en el calculo de antiguedad.
WITH corte AS (
    SELECT MAX(fecha_ultimo_pago) AS fecha_corte
    FROM staging_cxc
)

SELECT
    -- ------------------------------------------------------------------------
    -- Variables originales (vienen tal cual de la staging)
    -- ------------------------------------------------------------------------
    s.cod_apli_prod,
    s.descri_cod_apli_prod,
    s.num_cta,
    s.fecha_creacion,
    s.fecha_ultimo_pago,
    s.vlr_original,
    s.vlr_pagado,
    s.vlr_pendiente_pago,
    s.cod_trn,
    s.descri_cod_trn,

    -- ------------------------------------------------------------------------
    -- R2. Estado de recuperacion, derivado de los MONTOS (no de las fechas).
    -- Justificacion: B5 (la fecha no dice si se pago), B8 (distribucion).
    -- Uso tolerancia de 0.01 para no equivocarme por redondeo de decimales.
    -- ------------------------------------------------------------------------
    CASE
        WHEN s.vlr_pendiente_pago <= 0.01 THEN 'PAGADA_TOTAL'
        WHEN s.vlr_pagado         <= 0.01 THEN 'SIN_PAGO'
        ELSE 'PAGO_PARCIAL'
    END AS estado_recuperacion,

    -- ------------------------------------------------------------------------
    -- R3. Tasa de recuperacion: proporcion del valor original ya recuperada.
    -- Manejo defensivo de division por cero (aunque hoy no hay montos en 0, B7/B11).
    -- ------------------------------------------------------------------------
    CASE
        WHEN s.vlr_original = 0 THEN NULL
        ELSE ROUND(s.vlr_pagado / s.vlr_original, 4)
    END AS tasa_recuperacion,

    -- ------------------------------------------------------------------------
    -- R4. Dias de gestion: dias entre creacion y ultimo pago.
    -- Solo tiene sentido cuando HUBO pago real; si no hubo pago (SIN_PAGO),
    -- lo dejo nulo porque la fecha no representa un pago (advertencia B3/B5).
    -- ------------------------------------------------------------------------
    CASE
        WHEN s.vlr_pagado > 0.01
            THEN date_diff('day', s.fecha_creacion, s.fecha_ultimo_pago)
        ELSE NULL
    END AS dias_gestion,

    -- ------------------------------------------------------------------------
    -- R5. Antiguedad: dias desde la creacion hasta la fecha de corte, y su banda.
    -- Justificacion: B2 (el portafolio cubre ~10 meses).
    -- ------------------------------------------------------------------------
    date_diff('day', s.fecha_creacion, c.fecha_corte) AS dias_desde_creacion,
    CASE
        WHEN date_diff('day', s.fecha_creacion, c.fecha_corte) <= 30 THEN '0-30'
        WHEN date_diff('day', s.fecha_creacion, c.fecha_corte) <= 60 THEN '31-60'
        WHEN date_diff('day', s.fecha_creacion, c.fecha_corte) <= 90 THEN '61-90'
        ELSE '91+'
    END AS banda_antiguedad,

    -- ------------------------------------------------------------------------
    -- R6. Flag de madurez / censura: obligaciones jovenes con poco tiempo para
    -- pagarse. Umbral inicial 90 dias (a afinar en la Actividad 2). B2.
    -- ------------------------------------------------------------------------
    CASE
        WHEN date_diff('day', s.fecha_creacion, c.fecha_corte) < 90 THEN 1
        ELSE 0
    END AS flag_reciente,

    -- ------------------------------------------------------------------------
    -- R8. Variable objetivo del modelo (Actividad 2): 1 si pago total, 0 si no.
    -- Justificacion: B8.
    -- ------------------------------------------------------------------------
    CASE
        WHEN s.vlr_pendiente_pago <= 0.01 THEN 1
        ELSE 0
    END AS pagada_total,

    -- ------------------------------------------------------------------------
    -- R7. Flags de control de calidad. Hoy salen en 0 (fuente limpia, B5/B7),
    -- pero los materializo para que el proceso sea robusto si la fuente cambia.
    -- ------------------------------------------------------------------------
    CASE
        WHEN ABS(s.vlr_original - (s.vlr_pagado + s.vlr_pendiente_pago)) > 0.01
        THEN 1 ELSE 0
    END AS flag_inconsistencia_contable,
    CASE
        WHEN s.fecha_ultimo_pago < s.fecha_creacion THEN 1 ELSE 0
    END AS flag_fecha_invertida,
    CASE
        WHEN s.vlr_pagado > s.vlr_original + 0.01 THEN 1 ELSE 0
    END AS flag_pago_mayor_original

FROM staging_cxc s
CROSS JOIN corte c;   -- CROSS JOIN: la fecha de corte es un solo valor que
                      -- pego a todas las filas (una sola fila en el CTE 'corte').
