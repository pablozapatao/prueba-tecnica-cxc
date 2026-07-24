# Prueba Técnica — Análisis de Cuentas por Cobrar (CxC)

Análisis, modelamiento y visualización del comportamiento de las cuentas por cobrar de
la operación bancaria, con el objetivo de comprender su recuperación, anticipar riesgo y
proponer palancas de mejora basadas en evidencia.

---

## Resumen del proyecto

Se analizó un portafolio histórico de **21.739 obligaciones de cobro** (800 titulares,
~10 meses, ~141,6 millones generados). El proyecto cubre tres actividades: diagnóstico y
construcción de una sábana analítica, un modelo de probabilidad de pago, y un dashboard
ejecutivo con su informe.

**Hallazgo principal:** se recupera el 84% del valor y el 80% de las obligaciones; el
no-pago se concentra en obligaciones de bajo monto y en tipos de transacción
específicos. Oportunidad cuantificada: ~22,2 millones pendientes.

---

## Estructura del repositorio

```text
prueba-tecnica-cxc/
├── README.md                     # este archivo
├── requirements.txt              # dependencias de Python
├── .gitignore
├── data/
│   ├── fuente_cxc.sqlite         # fuente cruda original
│   ├── analitica.duckdb          # base analítica (se regenera con el pipeline)
│   ├── sabana.parquet            # sábana exportada para Power BI
│   └── sabana.csv                # misma sábana en CSV (respaldo)
├── docs/
│   ├── reglas_negocio.md         # reglas de negocio (trazadas a hallazgos)
│   ├── modelo_conceptual.md      # arquitectura y diseño de la sábana
│   ├── reporte_calidad.md        # reporte de calidad y EDA (Actividad 1)
│   ├── informe_actividad2.md     # informe del modelo (Actividad 2)
│   ├── informe_ejecutivo.md      # informe C-level (Actividad 3)
│   ├── guia_powerbi.md           # guía de construcción del dashboard
│   ├── estructura_dashboard.md   # estructura y medidas del dashboard
│   └── preguntas_frecuentes_y_bitacora.md  # bitácora del proceso y glosario
├── notebooks/
│   ├── 01_exploracion.ipynb      # exploración y control de calidad
│   └── 02_modelo.ipynb           # modelo de probabilidad de pago
├── powerbi/
│   └── dashboard.pbix            # tablero interactivo
└── src/
    ├── pipeline.py               # pipeline POO que construye la sábana
    └── sql/
        ├── 01_staging.sql        # capa staging (tipado y fechas)
        └── 02_sabana.sql         # capa analítica (reglas de negocio)
```

---

## Requisitos

- Python 3.11 o superior
- Power BI Desktop (para abrir el dashboard, solo Windows)

---

## Cómo ejecutar

### 1. Preparar el entorno

```bash
# Crear y activar el entorno virtual
python -m venv venv
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt
```

### 2. Construir la sábana analítica

Un solo comando reconstruye toda la cadena de datos (staging + sábana + validación +
exportación para Power BI):

```bash
python src/pipeline.py
```

Esto genera `data/analitica.duckdb` y exporta `data/sabana.parquet` y `data/sabana.csv`.

### 3. Explorar el análisis

Abrir los notebooks en `notebooks/` para ver la exploración (Actividad 1) y el modelo
(Actividad 2), paso a paso.

### 4. Ver el dashboard

Abrir `powerbi/dashboard.pbix` en Power BI Desktop. Si se pide reconectar la fuente,
apuntar a `data/sabana.parquet` (o `data/sabana.csv`).

---

## Metodología por actividad

**Actividad 1 — Diagnóstico y sábana.** Inspección y control de calidad de la fuente,
definición de reglas de negocio y construcción de una sábana analítica mediante una
arquitectura por capas (cruda → staging → analítica) y un pipeline reproducible en
Python (POO), con transformaciones en SQL.

**Actividad 2 — Modelo de probabilidad de pago.** Regresión logística para estimar la
probabilidad de pago por obligación, con análisis de asociación previo, prevención de
fuga de información y separación entrenamiento/prueba agrupada por titular. Se documenta
con transparencia el alcance del modelo y las conclusiones de negocio.

**Actividad 3 — Dashboard e informe ejecutivo.** Tablero en Power BI organizado por
indicadores y contraindicadores de proceso, e informe ejecutivo con tono C-level.

---

## Decisiones y trazabilidad

Todas las decisiones, supuestos y hallazgos están documentados en `docs/`. Cada variable
de la sábana es trazable hasta la regla de negocio que la define y el hallazgo de
inspección que la justifica.

## Supuestos principales

- Las fechas se interpretan en formato AAAAMMDD.
- El estado de recuperación se deriva de los montos (no de las fechas).
- La fecha de corte del portafolio se aproxima con el máximo `fecha_ultimo_pago`.

## Autor

Pablo Zapata Ochoa
