# ADR-0007 — Contratos de Datos y Versionamiento

* [cite_start]**Estado:** Propuesto (MVP Académico) [cite: 204]
* [cite_start]**Fecha:** 2026-02-28 [cite: 205]
* [cite_start]**Proyecto:** Sistema de Inventario Farmacéutico Distribuido (Hybrid Lakehouse) [cite: 206]

---

## 1. Contexto
[cite_start]En una arquitectura distribuida con múltiples puntos de emisión (1 bodega y 5 satélites), los eventos de inventario en formato JSON pueden evolucionar estructuralmente con el tiempo[cite: 208]. [cite_start]Es crítico garantizar que los datos depositados en el **Plano de Datos (MinIO)** cumplan con un contrato mínimo antes de ser procesados por las capas superiores para evitar fallos en los pipelines de **Dask** o inconsistencias en los dashboards de **Grafana**.

---

## 2. Decisión
[cite_start]Se decide implementar una estrategia de **Contratos de Datos** basada en esquemas JSON (JSON Schema) y control de versiones para todos los eventos de inventario.

### Elementos de la Estrategia:
1.  [cite_start]**Contratos Formales:** Definición de archivos `.schema.json` para cada tipo de evento (RECEIPT, SALE, TRANSFER)[cite: 212].
2.  [cite_start]**Validación en la Ingesta:** El pipeline de **Dask** validará cada archivo JSON contra su esquema correspondiente antes de realizar la carga a la capa **Bronze** en **Supabase**[cite: 212].
3.  **Versionamiento Semántico:** Cada contrato incluirá un campo `version` (ej. `v1`, `v2`) para permitir la convivencia de diferentes estructuras durante periodos de transición.
4.  **Gestión de Rechazos:** Los eventos que no cumplan con el contrato serán desviados a una carpeta de `quarantine` en **MinIO** y registrados como fallos en los metadatos de calidad de **Supabase**.

---

## 3. Flujo de Validación de Contratos
```mermaid
graph LR
    A[Eventos JSON en MinIO] --> B{Validación de Contrato}
    B -- FAIL --> C[Carpeta Quarantine]
    B -- PASS --> D[Capa Bronze - Supabase]
    
    subgraph Dask_Processing
        B
    end
    
    subgraph Metadata_Registry
        C -- Log Error --> E[(meta.controles_de_calidad)]
        D -- Log Success --> E
    end
