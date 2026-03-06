# ADR-0005 — Modelo Formal de Inventario Farmacéutico

* [cite_start]**Estado:** Propuesto (MVP Académico) [cite: 180]
* [cite_start]**Fecha:** 2026-02-28 [cite: 181]
* [cite_start]**Proyecto:** Sistema de Inventario Farmacéutico Distribuido [cite: 182]

---

## 1. Contexto
[cite_start]El sistema debe gestionar la trazabilidad de inventarios en una red distribuida compuesta por **una bodega central y cinco puntos de venta satélites**[cite: 184]. Se requiere un modelo de datos que soporte el flujo de eventos desde la ingesta en **MinIO** hasta la persistencia y analítica en **Supabase**.

Este modelo debe permitir el cálculo dinámico del balance de stock y la gestión de alertas operativas basadas en datos sintéticos reproducibles.

---

## 2. Decisión: Modelo de Dominio
Se implementa un modelo de datos relacional dentro de **Supabase (PostgreSQL)** que interactúa con las capas del Lakehouse para representar las siguientes entidades y procesos:

### Entidades Principales
* [cite_start]**Producto:** Maestro de medicamentos (ID, nombre estandarizado, categoría)[cite: 140, 186].
* [cite_start]**Ubicación:** Identificación de la Bodega Central y los 5 Satélites[cite: 140, 186].
* [cite_start]**Movimiento de Inventario:** Registro de cada evento (Ingreso, Venta, Transferencia)[cite: 140, 186].
* [cite_start]**Stock:** Balance calculado por producto y ubicación[cite: 140].

### Relaciones de Flujo
* **Bodega → Satélite:** Transferencias de abastecimiento.
* **Satélite → Consumidor:** Ventas registradas.
* **Proveedor → Bodega:** Ingresos de mercancía.

---

## 3. Reglas de Negocio Implementadas
Para este MVP, se aplican las siguientes definiciones:
1.  [cite_start]**Cálculo de Stock:** El inventario disponible se deriva de la suma de ingresos y transferencias entrantes, restando los despachos y ventas[cite: 110].
2.  [cite_start]**Granularidad:** Aunque se mantiene la trazabilidad por lote (`batch_number`) para monitoreo de vencimientos, el descuento de stock operativo se visualiza a nivel de producto[cite: 111, 188].
3.  **Normalización:** Todos los eventos recibidos como JSON se normalizan a IDs canónicos antes de llegar a la capa **Silver**.

---

## 4. Diagrama del Modelo de Datos (ER)
```mermaid
erDiagram
    UBICACION ||--o{ MOVIMIENTO : "origen/destino"
    PRODUCTO ||--o{ MOVIMIENTO : "involucrado"
    PRODUCTO ||--o{ STOCK : "tiene"
    UBICACION ||--o{ STOCK : "almacena"

    PRODUCTO {
        string product_id PK
        string product_name
        string category
    }

    UBICACION {
        string location_id PK
        string type "Bodega/Satelite"
        string brand
    }

    MOVIMIENTO {
        string movement_id PK
        string event_type
        int quantity
        timestamp event_timestamp
    }
