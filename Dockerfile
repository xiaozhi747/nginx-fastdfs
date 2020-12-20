FROM beaock/nginx-fastdfs:latest
# storage.sh 要在COPY前改为可执行文件，本机改或者直接在Dockerfile里改都行
COPY storage.sh /
