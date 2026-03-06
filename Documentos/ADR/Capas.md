# ADR-0002 — Estrategia de Capas en el Hybrid Lakehouse

* **Estado:** Propuesto (MVP Académico)
* **Fecha:** 2026-02-28
* **Proyecto:** Sistema de Inventario Farmacéutico Distribuido

---

## 1. Contexto
Se requiere una separación lógica y física de los datos para garantizar la trazabilidad total, permitir el reprocesamiento y optimizar el rendimiento. El sistema debe manejar grandes volúmenes de eventos JSON provenientes de 1 bodega y 5 satélites.

Anteriormente se contemplaba una solución puramente en Postgres, pero para escalar a un modelo de Lakehouse moderno, se ha decidido distribuir las capas entre almacenamiento de objetos y base de datos relacional.

---

## 2. Decisión
Implementar una estrategia de capas híbrida distribuida entre **MinIO** (Plano de Datos) y **Supabase** (Plano de Control/Servicio):

### Definición de Capas:

1.  **Raw Layer (MinIO):**
    * **Formato:** JSON inmutable.
    * **Descripción:** Almacena los eventos tal cual llegan de los sistemas origen. [cite_start]Es la "única fuente de verdad" para auditoría. [cite: 51, 144, 176]

2.  **Bronze Layer (Supabase / MinIO):**
    * **Formato:** Parquet / Tablas Postgres.
    * **Descripción:** Primera estructura tipada. [cite_start]Los datos se normalizan a esquemas definidos sin aplicar lógica de negocio. [cite: 4, 17, 176]

3.  **Silver Layer (Supabase):**
    * **Formato:** Tablas Postgres optimizadas.
    * **Descripción:** Datos limpios y validados. [cite_start]Se eliminan duplicados y se estandarizan identificadores de productos y ubicaciones. [cite: 56, 58, 176]

4.  **Gold Layer (Supabase):**
    * **Formato:** Vistas o Tablas Analíticas.
    * **Descripción:** Datos agregados listos para consumo por Grafana. [cite_start]Contiene los balances de inventario y alertas calculadas. [cite: 91, 118]

---

## 3. Diagrama de Flujo entre Capas
```mermaid
graph LR
    A[JSON RAW] -- Dask Ingest --> B(Bronze Layer)
    B -- Dask Clean --> C(Silver Layer)
    C -- Dask Aggregate --> D(Gold Layer)
    
    subgraph MinIO
        A
    end
    
    subgraph Supabase
        B
        C
        D
    end
