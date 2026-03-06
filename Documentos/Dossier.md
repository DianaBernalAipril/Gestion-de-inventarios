# Dossier Final: Inventory Hybrid Lakehouse — Implementación Completa

**Proyecto:** Sistema de Seguimiento y Analítica de Inventarios con Datos Sintéticos  
**Versión:** 1.0  
**Fecha:** 2026-02-25  
**Autor:** Equipo de Ingeniería de Datos

---

## 1. Introducción
Este dossier consolida el diseño y planificación del proyecto **Inventory Hybrid Lakehouse**. Sirve como guía técnica para la implementación de una plataforma híbrida que gestiona el inventario de una **bodega central y 5 puntos satélites**.

El sistema utiliza un enfoque de **Lakehouse moderno**, donde se combinan la flexibilidad del almacenamiento de objetos con la estructura de las bases de datos relacionales, procesando exclusivamente eventos en formato **JSON**.



---

## 2. Arquitectura General

### 2.1 Visión del Sistema
Basado en una arquitectura de tres planos para garantizar escalabilidad:
* **Plano de Control:** [Supabase](https://supabase.com/) (PostgreSQL) gestiona los metadatos, tablas de calidad y el servicio de datos final.
* **Plano de Datos:** [MinIO](https://min.io/) actúa como el almacenamiento de objetos (compatible con S3) para las capas Raw e inmutables.
* **Plano de Cómputo:** [Dask Distributed](https://dask.org/) realiza el procesamiento ETL paralelo y transformaciones pesadas.

### 2.2 Flujo de Datos
El dato viaja a través de las siguientes etapas:
1.  **Raw (JSON):** Eventos originales almacenados en MinIO.
2.  **Bronze (Parquet):** Datos tipados y normalizados en Supabase.
3.  **Silver (Curado):** Datos limpios, sin duplicados y con validación de integridad.
4.  **Gold (KPIs):** Agregaciones de negocio (Stock disponible, alertas de vencimiento).
5.  **Serving (Grafana):** Visualización analítica y operativa.



---

## 3. Especificaciones de Implementación

### 3.1 Modelo de Red
* **1 Nodo Central:** Bodega principal de distribución.
* **5 Nodos Satélites:** Farmacias/Puntos de venta que reciben y despachan mercancía.

### 3.2 Contratos de Datos
* **Entrada:** Únicamente solicitudes formateadas en JSON.
* **Simulación:** Generación determinista con semillas (seeds) para asegurar que los resultados sean reproducibles.

---

## 4. Paso a Paso de Implementación

### Paso 1: Despliegue de Infraestructura
1.  Navegar a `infra/docker/`.
2.  Ejecutar `docker-compose up -d`.
3.  **Servicios activos:** MinIO (Almacenamiento), Supabase (BD), Dask (Cómputo), Grafana (Dashboards).

### Paso 2: Generación de Datos Sintéticos
1.  Configurar el archivo `inventory_simulation_v1.yaml` con los parámetros de la bodega y satélites.
2.  Ejecutar: `python apps/simulator/generate_
