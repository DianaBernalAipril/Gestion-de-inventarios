# Definición del Alcance: MVP Inventory Hybrid Lakehouse (10 Días)

## 1. Objetivo
Entregar un MVP de plataforma de datos híbrida funcional en 10 días que:
* [cite_start]Simule un sistema realista de movimientos de inventario farmacéutico[cite: 122, 126].
* [cite_start]Implemente una arquitectura **Lakehouse** (MinIO + Supabase)[cite: 143, 144].
* [cite_start]Demuestre el procesamiento de datos mediante una red de **1 bodega principal y 5 satélites**[cite: 124, 125].
* [cite_start]Proporcione paneles operativos en **Grafana**[cite: 147, 148].
* [cite_start]Garantice ejecuciones reproducibles mediante datos sintéticos[cite: 149, 150].

---

## 2. Ámbito Funcional

### 2.1 Canal de Ingesta
* [cite_start]**Exclusivamente JSON:** Generación sintética de eventos de inventario (ingresos, ventas, transferencias)[cite: 9, 135].
* Sin canales externos (No WhatsApp, No Web).

### 2.2 Ingestión
* [cite_start]Generador determinista de eventos de inventario[cite: 150].
* [cite_start]**RAW Events:** Almacenamiento de JSON inmutable en **MinIO**[cite: 144].
* [cite_start]Validación de integridad y esquema inicial[cite: 7].

### 2.3 Capas del Lakehouse
* [cite_start]**Raw (MinIO):** JSON original inmutable[cite: 144].
* [cite_start]**Bronze (Supabase/Parquet):** Datos tipados y normalizados[cite: 4, 144].
* [cite_start]**Silver (Supabase/Parquet):** Datos curados, sin duplicados y con IDs canónicos[cite: 56, 57, 144].
* [cite_start]**Gold (Supabase/Postgres):** Tablas agregadas de stock y balance de inventario[cite: 90, 92, 144].

### 2.4 Modelo Operativo de Inventario
* [cite_start]Cálculo de Stock: `Recepciones + Transferencias Entrantes - Despachos - Ventas`[cite: 110].
* [cite_start]Seguimiento por lote (`batch_number`) y fecha de vencimiento (`expiration_date`)[cite: 30, 31, 73, 74].
* [cite_start]Gestión de ubicaciones: 1 Bodega Central y 5 Satélites definidos[cite: 124, 125].

### 2.5 Gobernanza y Metadatos
* [cite_start]`meta.runs`: Registro de ejecuciones[cite: 34].
* [cite_start]`meta.controles_de_calidad`: Logs de validación de datos[cite: 146].
* [cite_start]`meta.linaje`: Trazabilidad desde JSON RAW hasta la tabla Gold[cite: 145].

---

## 3. Alcance Técnico (Stack de Contenedores)

* **Almacenamiento (S3 Compatible):** MinIO.
* **Base de Datos y API:** Supabase (PostgreSQL).
* **Procesamiento:** Dask Scheduler + 2 Workers (mínimo) para transformaciones particionadas.
* **Orquestación:** Prefect Server o Dagster.
* [cite_start]**Visualización:** Grafana (Dashboards de stock y alertas de vencimiento)[cite: 147, 148].
* **Observabilidad:** Prometheus.

---

## 4. Fuera de Alcance (MVP)
* [cite_start]Integración con ERPs reales o sistemas de facturación[cite: 127].
* [cite_start]Buscador semántico o agentes de IA[cite: 141, 142].
* Clústeres de Spark o Kubernetes.
* Seguridad perimetral de nivel producción.

---

## 5. Definición de "Hecho" (Definition of Done)
El MVP se considera finalizado cuando:
1.  Una ejecución genera eventos JSON en **MinIO**.
2.  **Dask** procesa y transforma los datos a través de las capas Bronze y Silver en **Supabase**.
3.  Los KPIs de inventario (Gold) se visualizan correctamente en **Grafana**.
4.  [cite_start]Es posible reproducir exactamente el mismo stock final usando la misma semilla de datos sintéticos[cite: 150, 152].
5.  [cite_start]El sistema identifica y registra fallos de calidad de datos en la tabla de metadatos[cite: 146].

---

## 6. Restricción de Línea de Tiempo
* **Ventana total:** 10 días.
* **Prioridad:** Simplicidad del flujo de datos sobre complejidad de funciones.
* [cite_start]**Enfoque:** Demostrar la trazabilidad completa del medicamento desde la bodega a los satélites[cite: 133].
