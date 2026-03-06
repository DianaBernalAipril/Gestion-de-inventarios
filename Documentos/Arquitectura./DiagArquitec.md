### Diagrama de Arquitectura
```mermaid
architecture-beta
    group control_plane(logos:supabase) [Plano de Control]
    group data_plane(logos:minio) [Plano de Datos]
    group compute_plane(logos:dask-icon) [Plano de Cómputo]

    service supabase_db(logos:postgresql) [Metadatos y Gold] in control_plane
    service minio_s3(logos:minio) [Raw / Bronze / Silver] in data_plane
    service dask_cluster(logos:dask-icon) [Dask ETL] in compute_plane
    service grafana_viz(logos:grafana) [Visualización] in control_plane

    dask_cluster:R -- Lee JSON --> minio_s3
    dask_cluster:L -- Registra Logs --> supabase_db
    dask_cluster:B -- Escribe Parquet --> minio_s3
    grafana_viz:T -- Consulta KPIs --> supabase_db
