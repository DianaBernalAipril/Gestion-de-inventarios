# Sistema de Administración de Inventarios Farmacéuticos — POC

[cite_start]Este repositorio contiene la documentación técnica para la Prueba de Concepto (POC) de una arquitectura de datos diseñada para la gestión de inventarios[cite: 127]. [cite_start]El sistema garantiza la trazabilidad y analítica mediante la simulación de datos sintéticos[cite: 128, 132].

---

## 🏗️ Modelo de Red y Alcance
La infraestructura operativa se compone de:
* [cite_start]**1 Bodega Principal:** Centro de distribución centralizado[cite: 124].
* [cite_start]**5 Satélites (Puntos de Venta):** Ubicaciones que reciben abastecimiento y registran salidas[cite: 125].

[cite_start]**Flujo de Datos:** El sistema procesa exclusivamente solicitudes e ingresos en formato **JSON**, eliminando canales manuales para asegurar la estructura del dato desde el origen[cite: 135, 142].

---

## 🛠️ Stack Tecnológico (Arquitectura)
[cite_start]La arquitectura se organiza en capas de datos distribuidas de la siguiente manera[cite: 144]:

* **Capa RAW (S3 compatible):** [MinIO](https://min.io/) para el almacenamiento de archivos JSON originales.
* **Capas Bronze & Silver:** [Supabase](https://supabase.com/) (PostgreSQL) para la persistencia de datos normalizados, curados y validados.
* [cite_start]**Visualización:** [Grafana](https://grafana.com/) para el consumo de datos de la capa Gold mediante dashboards[cite: 147].



---

## 🥉 CAPA BRONZE: Dataset de Movimientos de Inventario

### 1. Propósito
[cite_start]Representa la transformación estructurada de los eventos **RAW JSON** provenientes de la bodega y los 5 satélites[cite: 4]. [cite_start]No se aplica lógica de negocio ni filtros en esta etapa[cite: 5, 45].

### 2. Tabla: `bronze_inventory_events`

| Column | Type | Description |
| :--- | :--- | :--- |
| **event_id** | string | [cite_start]Identificador único del evento [cite: 18] |
| **tenant_id** | string | [cite_start]Identificador opcional del tenant [cite: 19] |
| **ingestion_timestamp** | timestamp | [cite_start]Registro de entrada a la plataforma [cite: 20] |
| **event_type** | string | [cite_start]RECEIPT, DISPATCH, SALE, TRANSFER [cite: 21] |
| **product_id** | string | [cite_start]Identificador del medicamento [cite: 22] |
| **quantity** | int | [cite_start]Cantidad involucrada en el evento [cite: 24] |
| **source_location_id** | string | [cite_start]Ubicación origen (Bodega/Satélite) [cite: 26] |
| **destination_location_id**| string | [cite_start]Ubicación destino (Bodega/Satélite) [cite: 27] |
| **event_timestamp** | timestamp | [cite_start]Momento en que ocurrió el evento [cite: 32] |
| **run_id** | string | [cite_start]ID de ejecución del pipeline [cite: 34] |

---

## 🥈 CAPA SILVER: Dataset de Inventario Limpio (Supabase)

### 1. Propósito
[cite_start]Datos limpios y validados almacenados en **Supabase**[cite: 56]. [cite_start]Se eliminan duplicados y se estandarizan los identificadores de productos y ubicaciones entre los sistemas de la bodega y los satélites[cite: 57, 58, 80].

### 2. Tabla: `silver_inventory_movements`

| Column | Type | Description |
| :--- | :--- | :--- |
| **movement_id** | string | [cite_start]ID único del movimiento validado [cite: 67] |
| **product_id** | string | [cite_start]ID de producto normalizado [cite: 68] |
| **location_id** | string | [cite_start]ID canónico de la ubicación [cite: 70] |
| **movement_type** | string | [cite_start]Tipo de movimiento estandarizado [cite: 75] |
| **quantity** | int | [cite_start]Cantidad del movimiento [cite: 76] |
| **validated** | boolean | [cite_start]Indicador de validación de calidad [cite: 78] |

---

## 🥇 CAPA GOLD: Dashboards de Negocio (Grafana)

### 1. Propósito
[cite_start]Proporcionar visualizaciones optimizadas en **Grafana** para monitoreo operativo y toma de decisiones[cite: 92, 93, 147].

### 2. Lógica de Inventario
El stock se calcula mediante la fórmula:
[cite_start]`Recepciones + Transferencias Entrantes − Despachos − Ventas`[cite: 110].

---

## ✅ CONTROLES DE CALIDAD (Data Quality)

Se aplican las siguientes reglas para garantizar la integridad de la POC:
1. **Bronze:** Unicidad de `event_id` y formatos de marca de tiempo válidos.
2. [cite_start]**Silver:** Validación de catálogo maestro y marcado de registros inválidos (`validated = false`)[cite: 83].
3. **Registro:** Cada control se audita en la tabla `meta.controles_de_calidad` con el estado y marca de tiempo de la ejecución.
