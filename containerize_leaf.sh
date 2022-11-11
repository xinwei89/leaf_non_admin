set -e

# Set configurable stuff
SA_PASSWORD=Th3PA55--8zz       # DB password
DB_SERVER=host.docker.internal # Use 'host.docker.internal' if mac, else '127.0.0.1' if linux 
                               # see: (https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach)
LEAF_ROOT=$PWD
LEAF_JWT_CERT="$PWD"/keys/cert.pem
LEAF_JWT_KEY="$PWD"/keys/key.pem
LEAF_JWT_KEY_PW=password

# Check ENV variables
if [ -z ${SA_PASSWORD+x}    ]; then echo "LEAFDB_SA_PW is unset!"    exit; fi
if [ -z ${LEAF_JWT_CERT+x}   ]; then echo "LEAF_JWT_CERT is unset!"   exit; fi
if [ -z ${LEAF_JWT_KEY+x}    ]; then echo "LEAF_JWT_KEY is unset!"    exit; fi
if [ -z ${LEAF_JWT_KEY_PW+x} ]; then echo "LEAF_JWT_KEY_PW is unset!" exit; fi

# Extract cert/key path from ENVs
KEYS_PATH=$(dirname "$LEAF_JWT_CERT")
if [ -z ${KEYS_PATH+x} ]; then echo "Couldn't find cert+key path! Are you sure LEAF_JWT_CERT is a valid path?" && exit; fi

#--------------
# DB
#--------------
docker run -d -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=$SA_PASSWORD" -p 1433:1433 \
                -v leaf_sqlvolume:/var/opt/mssql \
                --name leaf_db_demo mcr.microsoft.com/mssql/server:2017-latest 

sleep 10

docker_sqlcmd() {
    path="$1"
    shift  # get the remaining arguments
    docker run --rm\
      -v "$PWD"/src/db/build/:/sql \
      mcr.microsoft.com/mssql-tools \
      /opt/mssql-tools/bin/sqlcmd -S 'host.docker.internal' -U SA -P "$SA_PASSWORD" "$@" -i /sql/"$path"
}

docker_getDbs() {
  docker run --rm \
         -v "$PWD"/src/db/build/:/sql \
         mcr.microsoft.com/mssql-tools \
         /opt/mssql-tools/bin/sqlcmd -S 'host.docker.internal' -U SA -P "$SA_PASSWORD" -Q "sp_databases"
}

if docker_getDbs | grep -q LeafDB; then
  echo "LeafDB installed"
else
  echo "LeafDB not installed, installing..."
  docker_sqlcmd LeafDB.sql
  docker_sqlcmd LeafDB.Init.sql -d LeafDB
  docker_sqlcmd TestDB.sql
  if docker_getDbs | grep -q LeafDB; then
    echo "LeafDB installed"
  else
    echo "!!! LeafDB still NOT installed"
  fi
fi

#--------------
# API
#--------------
cd $LEAF_ROOT/src/server
docker build -t leaf_api .
cd $LEAF_ROOT
docker run \
    -e "LEAF_APP_DB=Server=$DB_SERVER,1433;Database=LeafDB;uid=sa;Password=$SA_PASSWORD" \
    -e "LEAF_CLIN_DB=Server=$DB_SERVER,1433;Database=TestDB;uid=sa;Password=$SA_PASSWORD" \
    -e "LEAF_JWT_KEY_PW=$LEAF_JWT_KEY_PW" \
    -e "UnsecuredIsAdmin"="true" \
    -p 5001:5001 \
    -v ${PWD}/src/server:/app \
    -v ${KEYS_PATH}:/.keys \
    -v ${SERILOG_DIR}:/logs \
    --name leaf_api_demo \
    -d \
    leaf_api
