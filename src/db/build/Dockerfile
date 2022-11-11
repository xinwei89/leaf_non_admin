FROM mcr.microsoft.com/mssql/server:2017-latest

ARG sapw

RUN mkdir data

# Include schema and initial data
COPY ./LeafDB.sql ./LeafDB.Init.sql ./TestDB.sql ./

# Accept EULA
ENV ACCEPT_EULA Y

# Dev SA Password
ENV MSSQL_SA_PASSWORD ${sapw}

# Volumize somewhere to interact with host if needed
VOLUME /bak

# Set up database
# RUN /opt/mssql/bin/sqlservr & sleep 10 \
RUN ( /opt/mssql/bin/sqlservr --accept-eula & ) | grep -q "Service Broker manager has started" \
    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${MSSQL_SA_PASSWORD} -i ./LeafDB.sql \
    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${MSSQL_SA_PASSWORD} -i ./LeafDB.Init.sql -d LeafDB \
    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${MSSQL_SA_PASSWORD} -i ./TestDB.sql \
    && pkill sqlservr