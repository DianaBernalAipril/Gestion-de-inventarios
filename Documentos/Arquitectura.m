graph TD
    User((Operador Logístico))
    
    subgraph System_Boundary [Sistema Inventory Hybrid Lakehouse]
        Main_System[Plataforma de Datos de Inventario]
    end

    JSON_Source[(Eventos JSON)]
    Bodega[Bodega Principal]
    Satelites[5 Puntos Satélites]
    Grafana_Dash[Grafana Dashboards]

    Bodega -- Genera --> JSON_Source
    Satelites -- Genera --> JSON_Source
    JSON_Source -- Ingesta --> Main_System
    User -- Consulta Stock --> Grafana_Dash
    Main_System -- Provee Datos --> Grafana_Dash
