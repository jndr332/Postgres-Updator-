# Postgres Updator
Este script automatiza la actualización de Postgres, desde la versión 9.6 a la versión 15, para este ejemplo postgres solo tenia una sola base de datos.

## Características
- Vacia el directorio de datos para Postgres 15.
- Inicializa el nuevo clúster de Postgres.
- Realiza un `pg_upgrade` desde Postgres 9.6 a Postgres 15.
- Reindexa la base de datos migrada.

## Requisitos
- Verificar la ruta de las versiones de Postgres
- Detener los servicios 
- Debe ejecutarse como root.
- Debe tener ya instalado dos versiones de postgres, la version antigua y la nueva. 

## Uso
0. Hacer un backup o snapshot antes de inciar 
1. Descarga el archivo
2. Cambia el propietario y grupo:
   ```bash
   sudo chown postgres:postgres /var/lib/pgsql/PostgresUpdator.sh
3. Ejecuta.
   ```bash
   [root@localhost ~]# bash PostgresUpdator.sh 
