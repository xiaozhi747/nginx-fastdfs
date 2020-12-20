#!/bin/sh
    sed "s/^.*tracker_server=.*$/tracker_server=$TRACKER_SERVER/" /etc/fdfs/storage.conf > storage.conf
    sed "s/^.*group_name=.*$/group_name=$GROUP_NAME/" storage.conf > storage_.conf
    cp storage_.conf /etc/fdfs/storage.conf
    sed "s/^.*tracker_server=.*$/tracker_server=$TRACKER_SERVER/" /etc/fdfs/client.conf > client.conf
    cp client.conf /etc/fdfs/client.conf
    /data/fastdfs/storage/fdfs_storaged /etc/fdfs/storage.conf
    sed "s/^.*tracker_server=.*$/tracker_server=$TRACKER_SERVER/" /etc/fdfs/mod_fastdfs.conf > mod_fastdfs.conf
    sed "s/^.*group_name=.*$/group_name=$GROUP_NAME/" mod_fastdfs.conf > mod_fastdfs_.conf
    cp mod_fastdfs_.conf /etc/fdfs/mod_fastdfs.conf
    /etc/nginx/sbin/nginx
    tail -f /data/fast_data/logs/storaged.log