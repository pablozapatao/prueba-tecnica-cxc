-- ============================================================================
-- CAPA STAGING - Cuentas por Cobrar
-- ----------------------------------------------------------------------------
-- Responsabilidad unica de esta capa: limpieza estructural. Aqui NO aplico
-- reglas de negocio; solo dejo los datos bien tipados para la sabana.
--
-- Lo unico que transformo es lo que la inspeccion senalo como pendiente:
-- las fechas venian como numero entero AAAAMMDD y hay que volverlas fecha real
-- (regla R1, originada en el hallazgo B1).
--
-- Uso CREATE OR REPLACE para que el proceso sea idempotente: puedo re-ejecutarlo
-- las veces que quiera sin duplicar datos ni acumular basura.
-- ============================================================================

CREATE OR REPLACE TABLE staging_cxc AS
SELECT
    -- Identificacion y catalogos
    cod_apli_prod,
    descri_cod_apli_prod,
    num_cta,

    -- Conversion de fechas: paso el entero a texto y lo interpreto como AAAAMMDD.
    -- strptime devuelve un timestamp(date); con ::DATE me quedo solo con la fecha.
    strptime(CAST(f_creacion   AS VARCHAR), '%Y%m%d')::DATE AS fecha_creacion,
    strptime(CAST(f_ultimo_pago AS VARCHAR), '%Y%m%d')::DATE AS fecha_ultimo_pago,

    -- Montos (se conservan; ya validamos que cuadran contablemente, hallazgo B7)
    vlr_original,
    vlr_pagado,
    vlr_pendiente_pago,

    -- Transaccion (se conserva)
    cod_trn,
    descri_cod_trn

    -- Nota: descarto las columnas year/month/day de la fuente porque son
    -- redundantes con fecha_creacion. La fecha completa es la fuente de verdad;
    -- mantener duplicados solo abre la puerta a inconsistencias.
FROM fuente.tabla1;
