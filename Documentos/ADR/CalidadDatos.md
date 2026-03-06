# ADR-0008 — Estrategia de Calidad de Datos

* **Estado:** Propuesto (MVP Académico)
* **Fecha:** 2026-02-28
* **Proyecto:** Sistema de Inventario Farmacéutico Distribuido (Hybrid Lakehouse)

---

## 1. Contexto
[cite_start]En un sistema de inventario farmacéutico distribuido (1 bodega y 5 satélites), la integridad de los datos es crítica para evitar quiebres de stock falsos o dispensación de medicamentos vencidos[cite: 124, 125, 220]. [cite_start]Al utilizar un **Hybrid Lakehouse**, la calidad debe validarse en cada salto de capa (Bronze, Silver, Gold) para asegurar que los dashboards en **Grafana** reflejen la realidad operativa[cite: 144, 215].

---

## 2. Decisión
[cite_start]Implementar una estrategia de calidad de datos multidimensional basada en validaciones por capa y una política de **fail-fast** para registros que violen reglas críticas de negocio[cite: 222].

### Validaciones por Capa:
1.  **Capa Bronze (Estructura):**
    * [cite_start]Validación de tipos de datos contra el esquema JSON original[cite: 4, 7, 212].
    * [cite_start]Verificación de nulidad en campos obligatorios (`product_id`, `event_type`, `quantity`)[cite: 18, 21, 22, 24].
2.  **Capa Silver (Integridad Referencial):**
    * [cite_start]Validación de existencia de productos y ubicaciones en los maestros de **Supabase**[cite: 58, 81, 82].
    * [cite_start]Control de duplicidad de `event_id`[cite: 80].
    * [cite_start]Marcado de registros mediante la columna `validated` (Boolean)[cite: 78, 83].
3.  **Capa Gold (Lógica de Negocio):**
    * [cite_start]**Stock No Negativo:** El inventario calculado por producto y ubicación no puede ser inferior a cero[cite: 224].
    * [cite_start]**Validación de Fechas:** Verificación de coherencia entre `event_timestamp` y `expiration_date`[cite: 224].

---

## 3. Matriz de Controles de Calidad
| Dimensión | Regla de Validación | Acción en caso de Fallo |
| :--- | :--- | :--- |
| **Completitud** | Campos críticos no nulos | Registro en `quarantine` (MinIO) |
| **Consistencia** | `location_id` debe existir en maestros | Registro marcado como `validated = false` |
| **Validez** | `event_type` dentro de valores permitidos | Rechazo inmediato del registro |
| **Integridad** | El stock resultante debe ser >= 0 | Alerta crítica en Grafana |

---

## 4. Flujo de Control de Calidad
```mermaid
graph TD
    A[Ingesta JSON] --> B{Check Bronze}
    B -- Invalido --> C[Quarantine - MinIO]
    B -- Valido --> D[Bronze Table]
    D --> E{Check Silver}
    E -- Error Referencial --> F[Validated = False]
    E -- Exito --> G[Silver Table]
    G --> H{Check Gold - Reglas Negocio}
    H -- Stock Negativo --> I[Alerta Critica Grafana]
