# Postgres Updator

Este script automatiza el proceso de actualización de Postgres desde la versión 9.6 a la versión 15.
Para un sola base de datos
## Características

- Detiene todas las versiones activas de Postgres.
- Vacia el directorio de datos para Postgres 15.
- Inicializa el nuevo clúster de Postgres.
- Realiza un `pg_upgrade` desde Postgres 9.6 a Postgres 15.
- Reindexa la base de datos migrada.

## Requisitos

- El script debe estar alojado en `/var/lib/pgsql/`.
- Debe ejecutarse como root.
- Debes tener instalado Postgres 9.6 y Postgres 15.

## Uso

1. Copia el script a `/var/lib/pgsql/`.
2. Cambia el propietario y grupo:
   ```bash
   sudo chown postgres:postgres /var/lib/pgsql/PostgresUpdator.sh
