# ADR-0006 — Observabilidad con Grafana

* [cite_start]**Estado:** Propuesto (MVP Académico) [cite: 192]
* [cite_start]**Fecha:** 2026-02-28 [cite: 193]
* [cite_start]**Proyecto:** Sistema de Inventario Farmacéutico Distribuido (Hybrid Lakehouse) [cite: 194]

---

## 1. Contexto
[cite_start]Se requiere una plataforma de visualización centralizada para monitorear métricas operativas y de negocio de la red de inventario (1 bodega y 5 satélites)[cite: 195, 196]. [cite_start]La arquitectura debe permitir observar tanto la salud del pipeline de datos como el estado real del inventario farmacéutico[cite: 196].

---

## 2. Decisión
[cite_start]Se adopta **Grafana** como la herramienta estándar de observabilidad. [cite_start]Grafana se conectará directamente a **Supabase (PostgreSQL)** para consumir los datos procesados en las capas **Silver** y **Gold**.

### Dashboards Definidos:
1.  **Dashboard Operativo de Inventario:**
    * [cite_start]Stock disponible por ubicación (Bodega vs. Satélites)[cite: 200].
    * [cite_start]Alertas de stock bajo basadas en umbrales de la capa Gold[cite: 200].
    * [cite_start]Trazabilidad de lotes próximos a vencer[cite: 119, 121].
2.  **Dashboard de Negocio:**
    * [cite_start]Ventas diarias y por punto de venta[cite: 200].
    * [cite_start]Índice de rotación de inventario[cite: 200].
    * [cite_start]Balance de transferencias entre bodega y satélites[cite: 110].
3.  **Monitoreo Técnico:**
    * [cite_start]Estado de las ejecuciones de los pipelines de Dask (vía metadatos en Supabase)[cite: 144, 146].
    * [cite_start]Métricas de calidad de datos (registros válidos vs. inválidos)[cite: 144].

---

## 3. Arquitectura de Observabilidad
```mermaid
graph LR
    subgraph Data_Source [Fuentes de Datos]
        DB[(Supabase - Capas Silver/Gold)]
    end

    subgraph Visualization [Capa de Visualización]
        G[Grafana Server]
    end

    subgraph Users [Consumidores]
        Admin((Administrador))
        Logistics((Logística))
    end

    DB -- Consultas SQL --> G
    G -- Dashboards Web --> Admin
    G -- Alertas Stock --> Logistics
