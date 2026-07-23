"""
Pipeline de construccion de la sabana de Cuentas por Cobrar.

Sigo una arquitectura por capas: leo la fuente cruda (SQLite), la paso por una
capa de staging (tipado y fechas) y despues construyo la sabana analitica. Todo
queda materializado en un unico archivo DuckDB persistente, para no depender de
la memoria y para que Power BI pueda leer la salida sin volver a correr nada.

Uso Programacion Orientada a Objetos (una clase) porque cada paso del proceso es
una responsabilidad separada y encapsulada; asi el pipeline es facil de leer,
probar y extender.
"""

import duckdb
from pathlib import Path


class ConstructorSabana:
    """Orquesta la construccion de la sabana de CxC, capa por capa."""

    def __init__(self, ruta_fuente_sqlite: str, ruta_bd_analitica: str):
        # Guardo las rutas como atributos para reutilizarlas en todos los metodos.
        # Uso Path para que las rutas funcionen igual en Windows, Mac o Linux.
        self.ruta_fuente = Path(ruta_fuente_sqlite)
        self.ruta_bd = Path(ruta_bd_analitica)
        self.con = None  # la conexion se abre en conectar()

    def conectar(self):
        """Abre la base analitica persistente y adjunta la fuente cruda."""
        # A diferencia de una conexion en memoria, este archivo .duckdb queda en
        # disco: el trabajo persiste entre ejecuciones.
        self.con = duckdb.connect(str(self.ruta_bd))

        # Cargo el conector de SQLite y adjunto la fuente en modo SOLO LECTURA,
        # para no arriesgarme a modificar por accidente los datos originales.
        # Uso IF NOT EXISTS para que re-ejecutar el pipeline no falle por estar
        # ya adjunta (la conexion es persistente y recuerda los ATTACH).
        self.con.execute("INSTALL sqlite; LOAD sqlite;")
        self.con.execute(
            f"ATTACH IF NOT EXISTS '{self.ruta_fuente}' AS fuente "
            f"(TYPE sqlite, READ_ONLY);"
        )
        print("Conectado. Fuente cruda adjunta como 'fuente' (solo lectura).")

    def _ejecutar_script(self, ruta_sql: str):
        """Lee un archivo .sql completo y lo ejecuta."""
        # Mantengo el SQL en archivos aparte (no incrustado en el Python) porque
        # asi el proceso queda mas legible y cualquiera puede auditar la logica
        # de transformacion sin leer codigo Python.
        sql = Path(ruta_sql).read_text(encoding="utf-8")
        self.con.execute(sql)
        print(f"Ejecutado: {ruta_sql}")

    def construir_staging(self):
        """Capa staging: tipado y estandarizacion de fechas (regla R1)."""
        self._ejecutar_script("src/sql/01_staging.sql")
        n = self.con.execute("SELECT COUNT(*) FROM staging_cxc").fetchone()[0]
        print(f"Staging construido: {n} filas.")

    def cerrar(self):
        """Cierra la conexion de forma ordenada."""
        if self.con:
            self.con.close()
            print("Conexion cerrada.")


if __name__ == "__main__":
    # Punto de entrada: si ejecuto este archivo directamente, corre el pipeline.
    # Las rutas son relativas a la raiz del repo (donde ejecuto el comando).
    constructor = ConstructorSabana(
        ruta_fuente_sqlite="data/fuente_cxc.sqlite",
        ruta_bd_analitica="data/analitica.duckdb",
    )
    constructor.conectar()
    constructor.construir_staging()
    constructor.cerrar()
