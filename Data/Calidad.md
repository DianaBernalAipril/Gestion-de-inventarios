# Especificación del Data Lake — Inventarios Farmacéuticos

Este documento detalla la estructura, transformaciones y controles de calidad de las capas del Data Lake para la administración integral de inventarios.

---

## 🥉 CAPA BRONZE: Dataset de Movimientos de Inventario

### 1. Propósito
Representa la transformación estructurada y tipada de los eventos **RAW** provenientes de bodega y puntos de venta. Solo se permiten transformaciones determinísticas y normalización de esquema.

### 2. Tabla: `bronze_inventory_events`

| Column | Type | Description |
| :--- | :--- | :--- |
| **event_id** | string | Identificador único del evento |
| **tenant_id** | string | Identificador opcional del tenant |
| **ingestion_timestamp** | timestamp | Momento en que el evento entra a la plataforma |
| **event_type** | string | Tipo de evento (RECEIPT, DISPATCH, SALE, TRANSFER) |
| **product_id** | string | Identificador del medicamento |
| **product_name** | string | Nombre del medicamento desde el sistema origen |
| **quantity** | int | Cantidad involucrada en el evento |
| **unit** | string | Unidad de medida (caja, frasco, tableta) |
| **source_location_id** | string | Ubicación que envía inventario |
| **destination_location_id** | string | Ubicación que recibe inventario |
| **pharmacy_brand** | string | Marca de farmacia |
| **store_id** | string | Identificador del punto de venta |
| **batch_number** | string | Número de lote del medicamento |
| **expiration_date** | date | Fecha de vencimiento |
| **event_timestamp** | timestamp | Momento en que ocurrió el evento |
| **day** | date | Columna de partición |
| **run_id** | string | Identificador de ejecución del pipeline |

---

## 🥈 CAPA SILVER: Dataset de Inventario Limpio

### 1. Propósito
Datos validados e integrados. Se aplican reglas de calidad, normalización del catálogo de productos y estandarización de IDs canónicos.

### 2. Tabla: `silver_inventory_movements`

| Column | Type | Description |
| :--- | :--- | :--- |
| **movement_id** | string | Identificador único del movimiento |
| **product_id** | string | Identificador del medicamento |
| **product_name** | string | Nombre estandarizado del medicamento |
| **location_id** | string | Ubicación (bodega o farmacia) |
| **brand** | string | Marca de farmacia |
| **store_id** | string | Identificador del punto de venta |
| **batch_number** | string | Número de lote |
| **expiration_date** | date | Fecha de vencimiento |
| **movement_type** | string | RECEIPT, DISPATCH, SALE, TRANSFER |
| **quantity** | int | Cantidad del movimiento |
| **event_timestamp** | timestamp | Timestamp del evento |
| **validated** | boolean | Indicador de validación de calidad de datos |

---

## 🥇 CAPA GOLD: Dataset de Inventario de Negocio

### 1. Propósito
Datasets listos para consumo por dashboards y analítica. El inventario se calcula como: `Recepciones + Entradas - Despachos - Ventas`.

### 2. Tabla: `gold_inventory_balance`

| Column | Type | Description |
| :--- | :--- | :--- |
| **product_id** | string | Identificador del medicamento |
| **product_name** | string | Nombre del medicamento |
| **location_id** | string | Ubicación (bodega o farmacia) |
| **brand** | string | Marca de farmacia |
| **store_id** | string | Identificador del punto de venta |
| **current_stock** | int | Inventario disponible actual |
| **reserved_stock** | int | Inventario reservado |
| **expiration_nearest** | date | Fecha de vencimiento más cercana |

---

## ✅ CONTROLES DE CALIDAD DE LOS DATOS (Data Quality)

### 1. Chequeos de Bronze
* **Unicidad de `event_id`**
* `message_id` no nulo.
* Formatos de marca de tiempo válidos.
* **Política de fallos:** 🚨 **CRÍTICA**

### 2. Chequeos de Silver
* `pqrs_type` y `model_version` no nulos.
* Puntuación de prioridad entre 0 y 1.
* **Política de fallos:**
    * Falta `model_version` → **CRÍTICO**
    * Sentimiento faltante → **ADVERTENCIA**

### 3. Chequeos de Gold
* `total_emails` >= 0.
* No se permite la duplicación de `day` e `inquilino`.
* **Política de fallos:**
    * Desajuste de agregación → **CRÍTICO**
    * Anomalía de SLA → **ADVERTENCIA**

### 4. Registro de Metadatos
Cada chequeo se registra en la tabla `meta.controles_de_calidad` con los campos: `id_de_ejecución`, `capa`, `nombre_de_comprobación`, `estado`, `recuento_de_registros` y `marca_de_tiempo`.
