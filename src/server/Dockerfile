FROM centos:7
RUN rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm \
    && yum -y install dotnet-sdk-3.1 \
    && yum -y install shadow-utils   \
    && yum -y install util-linux     \
    && yum -y install vim-minimal    \
    && yum -y update                 \
    && yum clean all       
 
COPY . /app
COPY ./keys /.keys
COPY . /data/server/
 
# Configure Environment Variables
ENV LEAF_JWT_CERT /.keys/cert.pem
ENV LEAF_JWT_KEY  /.keys/leaf.pfx
ENV SERILOG_DIR   /logs
ENV ASPNETCORE_URLS=http://0.0.0.0:5001
ENV DOTNET_RUNNING_IN_CONTAINER true
ENV DOTNET_USE_POLLING_FILE_WATCHER true
ENV NUGET_XMLDOC_MODE skip
ENV LANG: en_US.UTF-8

WORKDIR /app/API
CMD [ "dotnet", "run" ]