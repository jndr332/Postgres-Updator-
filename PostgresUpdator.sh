#!/bin/bash

# --- Variables ---
PG_OLD_VERSION=9.6
PG_NEW_VERSION=15
PG_OLD_DATA_DIR="/var/lib/pgsql/$PG_OLD_VERSION/data"
PG_NEW_DATA_DIR="/var/lib/pgsql/$PG_NEW_VERSION/data"
PG_OLD_BIN_DIR="/usr/pgsql-$PG_OLD_VERSION/bin"
PG_NEW_BIN_DIR="/usr/pgsql-$PG_NEW_VERSION/bin"

# RECUERDA AJUSTAR POR NOMBRE DE TU BASE DATOS
DB_NAME='testing'

# Funcion para verificar si las rutas existen
check_path_exists() {
  if [ ! -d "$1" ]; then
    echo "Error: La ruta $1 no existe, verifica la ruta de las versions de postgres"
    exit 1
  fi
}

echo -e "\n_________ Postgres Updator __________\n"
echo -e "by J Saenz \n"
echo -e "\nBuscando versiones disponibles . . .\n"

check_path_exists "$PG_OLD_DATA_DIR"
check_path_exists "$PG_NEW_BIN_DIR"
check_path_exists "$PG_OLD_BIN_DIR"

# Detener versiones activas de Postgres
for i in $(ls /usr/ | grep pgsql | tr -d "-"); do
  versiones=$(echo $i | sed 's/pgsql//g')
  systemctl stop postgresql-$versiones
  echo -e "\nDeteniendo servicio encontrado Postgres-$versiones\n"
done

# --- Confirmación del usuario ---
read -p "¿Es necesario vaciar $PG_NEW_DATA_DIR para proceder con la actualización? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
  echo "Cancelando actualización."
  exit 0
fi

# Ajustes de directorios
rm -rf $PG_NEW_DATA_DIR
sudo mkdir -p $PG_NEW_DATA_DIR
sudo chown postgres:postgres $PG_NEW_DATA_DIR
check_command "Creación de $PG_NEW_DATA_DIR"

su - postgres -c "
/usr/pgsql-$PG_NEW_VERSION/bin/initdb -D $PG_NEW_DATA_DIR

# Eliminar autenticación para evitar errores durante el upgrade
sed -i 's/\(md5\|scram-sha-256\)/trust/g' $PG_OLD_DATA_DIR/pg_hba.conf
sed -i 's/\(md5\|scram-sha-256\)/trust/g' $PG_NEW_DATA_DIR/pg_hba.conf

/usr/pgsql-$PG_NEW_VERSION/bin/pg_upgrade --old-datadir $PG_OLD_DATA_DIR --new-datadir $PG_NEW_DATA_DIR --old-bindir $PG_OLD_BIN_DIR --new-bindir $PG_NEW_BIN_DIR
"

# Copiar configuración antigua
cp $PG_OLD_DATA_DIR/postgresql.conf $PG_NEW_DATA_DIR/
cp $PG_OLD_DATA_DIR/pg_hba.conf $PG_NEW_DATA_DIR/

# Reiniciar y verificar el servicio
systemctl restart postgresql-$PG_NEW_VERSION
if systemctl is-active --quiet postgresql-$PG_NEW_VERSION; then
  echo "PostgreSQL $PG_NEW_VERSION iniciado correctamente."
else
  echo "Error al iniciar PostgreSQL $PG_NEW_VERSION."
  exit 1
fi

# Reindexar base de datos
su - postgres -c "psql -d $DB_NAME -c 'REINDEX DATABASE $DB_NAME;'"
check_command "Reindexación de la base de datos $DB_NAME"

# Restaurar permisos de autenticación
su - postgres -c "sed -i 's/\(trust\)/md5/g' $PG_NEW_DATA_DIR/pg_hba.conf"
check_command "Restauración de permisos en pg_hba.conf"

echo -e "\nMigración completada con éxito!!!\n"
echo -e "Compruebe la conexión con psql -h <address> -p <port> -U <user> -d <db>\n"
