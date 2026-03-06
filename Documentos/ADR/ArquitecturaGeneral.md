# ADR-0001 — Arquitectura General del Sistema

* **Estado:** Propuesto (MVP Académico)
* **Fecha:** 2026-02-28
* **Proyecto:** Sistema de Inventario Farmacéutico Distribuido (Hybrid Lakehouse)

---

## 1. Contexto
[cite_start]La operación farmacéutica requiere la gestión integral de movimientos entre **una bodega central y cinco puntos de venta satélites**[cite: 124, 158]. [cite_start]El sistema debe procesar exclusivamente eventos en formato **JSON** que registran ingresos de mercancía, transferencias y ventas[cite: 159, 160]. 

[cite_start]Se busca una arquitectura que combine la flexibilidad de un Data Lake con la capacidad analítica de una base de datos relacional (Lakehouse), garantizando trazabilidad y reproducibilidad mediante datos sintéticos[cite: 132, 133].

---

## 2. Decisión
Se adopta una **Arquitectura Hybrid Lakehouse** distribuida en tres planos fundamentales:

1.  [cite_start]**Plano de Datos (Storage):** Uso de **MinIO** (compatible con S3) para el almacenamiento inmutable de la capa **Raw**[cite: 144].
2.  **Plano de Cómputo (Processing):** Implementación de **Dask Distributed** para ejecutar pipelines ETL paralelos (Bronze, Silver, Gold).
3.  [cite_start]**Plano de Control y Servicio (Serving):** **Supabase (PostgreSQL)** actuará como el núcleo para metadatos, tablas de calidad y persistencia de capas curadas.
4.  [cite_start]**Visualización:** **Grafana** se conectará directamente a Supabase para la generación de dashboards operativos y analíticos[cite: 148, 164].

---

## 3. Arquitectura Propuesta

### Flujo de Datos
[cite_start]El flujo de información sigue la estructura de medallas del Lakehouse[cite: 144, 164]:
`JSON Event` → `Raw (MinIO)` → `Bronze (Supabase/Parquet)` → `Silver (Limpieza)` → `Gold (KPIs/Stock)` → `Grafana`.

### Diagrama de Arquitectura
```mermaid
graph LR
    subgraph Data_Plane [Plano de Datos - MinIO]
        Raw[Raw JSON]
    end

    subgraph Compute_Plane [Plano de Cómputo - Dask]
        ETL[Pipelines ETL]
    end

    subgraph Control_Plane [Plano de Servicio - Supabase]
        DB[(Postgres & Meta)]
        Grafana[Grafana Dashboards]
    end

    Raw --> ETL
    ETL --> DB
    DB --> Grafana
