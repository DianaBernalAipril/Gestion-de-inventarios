Especificación del Data Lake de Inventarios Farmacéuticos
CAPA BRONZE — Especificación del Dataset de Movimientos de Inventario
1. Propósito
La capa Bronze representa la transformación estructurada y tipada de los eventos RAW de inventario provenientes de la bodega y de los puntos de venta de las farmacias.

No se aplica lógica de negocio.
No se realizan agregaciones ni cálculos de inventario.

Solo se permiten transformaciones determinísticas y normalización de esquema.
2. Fuente
Entrada: RAW-InventoryEvents.schema.json
(Eventos generados por operaciones de bodega y puntos de venta de farmacias)

Formato de salida: Parquet

Las fuentes incluyen:
- Sistema de recepción de bodega
- Sistema de despacho de bodega
- Sistema POS de farmacias
- Transferencias internas entre ubicaciones
3. Tabla: bronze_inventory_events
event_id | string | Identificador único del evento
tenant_id | string | Identificador opcional del tenant
ingestion_timestamp | timestamp | Momento en que el evento entra a la plataforma
event_type | string | Tipo de evento (RECEIPT, DISPATCH, SALE, TRANSFER)
product_id | string | Identificador del medicamento
product_name | string | Nombre del medicamento desde el sistema origen
quantity | int | Cantidad involucrada en el evento
unit | string | Unidad de medida (caja, frasco, tableta)
source_location_id | string | Ubicación que envía inventario
destination_location_id | string | Ubicación que recibe inventario
pharmacy_brand | string | Marca de farmacia
store_id | string | Identificador del punto de venta
batch_number | string | Número de lote del medicamento
expiration_date | date | Fecha de vencimiento
event_timestamp | timestamp | Momento en que ocurrió el evento
day | date | Columna de partición
run_id | string | Identificador de ejecución del pipeline de ingesta
4. Reglas de Transformación
Los nombres de productos se normalizan a MAYÚSCULAS.

Los identificadores de ubicación se normalizan a IDs canónicos.

Las fechas y timestamps se convierten a UTC.

La columna quantity se almacena como entero positivo.

El campo event_type debe pertenecer a los siguientes valores:
RECEIPT
DISPATCH
SALE
TRANSFER

No se permite filtrar datos en la capa Bronze.
5. Particionamiento
Estructura de particiones en almacenamiento:

bronze/inventory_events/source=<sistema>/day=YYYY-MM-DD/run_id=UUID/
6. Principios
Estructura ≠ Lógica de negocio

La capa Bronze almacena los eventos exactamente como fueron recibidos.

No se realizan cálculos de inventario.

Los datos deben ser reproducibles y trazables.
 
CAPA SILVER — Especificación del Dataset de Inventario Limpio
1. Propósito
La capa Silver representa datos de inventario limpios, validados e integrados.

En esta capa se aplican reglas de calidad de datos, normalización del catálogo de productos
y estandarización de identificadores de ubicación entre la bodega y los puntos de venta.
2. Fuente
Entrada: datasets de la capa Bronze

Formato de salida: Parquet

Fuentes:
- bronze_inventory_events
- bronze_products
- bronze_locations
3. Tabla: silver_inventory_movements
movement_id | string | Identificador único del movimiento
product_id | string | Identificador del medicamento
product_name | string | Nombre estandarizado del medicamento
location_id | string | Ubicación (bodega o farmacia)
brand | string | Marca de farmacia
store_id | string | Identificador del punto de venta
batch_number | string | Número de lote
expiration_date | date | Fecha de vencimiento
movement_type | string | RECEIPT, DISPATCH, SALE, TRANSFER
quantity | int | Cantidad del movimiento
event_timestamp | timestamp | Timestamp del evento
validated | boolean | Indicador de validación de calidad de datos
4. Reglas de Transformación
Se eliminan eventos duplicados.

El catálogo de productos se normaliza usando datos maestros.

Los identificadores de ubicación se mapean a IDs canónicos.

Los registros inválidos se marcan usando la columna validated.
5. Particionamiento
silver/inventory_movements/day=YYYY-MM-DD/
6. Principios
Datos limpios pero no agregados.

Se garantiza consistencia de identificadores entre sistemas.

Los datasets quedan preparados para cálculos de inventario.
 
CAPA GOLD — Especificación del Dataset de Inventario de Negocio
1. Propósito
La capa Gold proporciona datasets listos para negocio,
utilizados para analítica, dashboards, monitoreo y toma de decisiones operativas.
2. Fuente
Entrada: datasets de la capa Silver

Formato de salida: Parquet o tablas analíticas

Fuente principal:
- silver_inventory_movements
3. Tabla: gold_inventory_balance
product_id | string | Identificador del medicamento
product_name | string | Nombre del medicamento
location_id | string | Ubicación (bodega o farmacia)
brand | string | Marca de farmacia
store_id | string | Identificador del punto de venta
current_stock | int | Inventario disponible actual
reserved_stock | int | Inventario reservado
expiration_nearest | date | Fecha de vencimiento más cercana
4. Lógica de Negocio
El inventario se calcula mediante:

Recepciones + Transferencias Entrantes − Despachos − Ventas.

Se mantiene trazabilidad por lote para monitoreo de vencimientos.

Se generan alertas de bajo inventario cuando el stock
está por debajo de un umbral definido.
5. Particionamiento
gold/inventory_balance/day=YYYY-MM-DD/
6. Principios
Se aplica semántica de negocio.

Los datos están optimizados para dashboards y reportes.

Permite generar alertas operativas como:
- Bajo inventario
- Medicamentos próximos a vencer.
