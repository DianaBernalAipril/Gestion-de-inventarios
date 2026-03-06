### Diagrama de Arquitectura
```mermaid
graph TB
    subgraph Plano_Control [Plano de Control - Supabase]
        direction TB
        DB[(PostgreSQL & Metadatos)]
        Grafana[Grafana Dashboards]
    end

    subgraph Plano_Computo [Plano de Cómputo - Dask]
        direction TB
        ETL[Dask Clusters / ETL]
    end

    subgraph Plano_Datos [Plano de Datos - MinIO]
        direction TB
        Raw[Raw JSON]
        Bronze[Bronze Parquet]
        Silver[Silver Curado]
    end

    %% Flujos de datos
    Raw --> ETL
    ETL --> Bronze
    Bronze --> Silver
    Silver --> DB
    DB --> Grafana

    %% Estilos
    style Plano_Control fill:#f9f,stroke:#333,stroke-width:2px
    style Plano_Datos fill:#bbf,stroke:#333,stroke-width:2px
    style Plano_Computo fill:#dfd,stroke:#333,stroke-width:2px
