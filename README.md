# docker-compose搭建fastDFS-nginx环境

1. 得先安装docker和docker-compose，具体教程百度

2. 首先克隆项目到本地

> git clone https://github.com/xiaozhi747/nginx-fastdfs.git

3. 修改docker-compose文件里面的TRACKER_SERVER ip地址

```
version: '2'
services:
  tracker-server:
    image: beaock/nginx-fastdfs
    network_mode: "host"
    command: "./tracker.sh" 
 
  storage-server:
    image: beaock/nginx-fastdfs
    volumes:
      - "./docker/storage_base_path:/data/fast_data"
    environment:
      TRACKER_SERVER: "192.168.65.3:22122" <注意这里要改成自己tracker server的地址>
      GROUP_NAME: "M00"
    network_mode: "host"
    command: "./storage.sh"
  
```

4. 执行 `docker-compose up` 命令

5. 执行java代码测试环境搭建是否成功

```java
import com.github.tobato.fastdfs.domain.StorePath;
import com.github.tobato.fastdfs.domain.ThumbImageConfig;
import com.github.tobato.fastdfs.service.FastFileStorageClient;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;

@SpringBootTest
@RunWith(SpringRunner.class)
public class FastDFSTest {

    @Autowired
    private FastFileStorageClient storageClient;

    @Autowired
    private ThumbImageConfig thumbImageConfig;

    @Test
    public void testUpload() throws FileNotFoundException {
        // 要上传的文件
        File file = new File("C:\\Users\\LZ\\Pictures\\Snipaste_2020-05-17_21-11-17.png");
        // 上传并保存图片，参数：1-上传的文件流 2-文件的大小 3-文件的后缀 4-可以不管他
        StorePath storePath = this.storageClient.uploadFile(
                new FileInputStream(file), file.length(), "jpg", null);
        // 带分组的路径
        System.out.println(storePath.getFullPath());
        // 不带分组的路径
        System.out.println(storePath.getPath());
    }
}
```

测试结果：

```
M00/M00/00/00/wKgBBl7BOquASt2LAAAWdydAsEA756.jpg
M00/00/00/wKgBBl7BOquASt2LAAAWdydAsEA756.jpg
```

6. 通过nginx访问上传的图片

![image-20200517222358961](assets\image-20200517222358961.png)



**如果测试失败报错位：**com.github.tobato.fastdfs.exception.FdfsServerException: 错误码:2,错误信息

检查storage容器里的 /etc/fdfs/storage.conf 和 /etc/fdfs/client.conf 配置文件中 tracker_server的值是否为tracker_server所在机器的： **ip地址:22122** 

执行下面命令让配置生效

```
/usr/local/fdfs_monitor /etc/fdfs/client.conf
```

重新查看状态

```
/usr/local/fdfs_monitor /etc/fdfs/client.conf
```

正常应为：

```
ACTIVE
```

![image-20200517224142883](assets\image-20200517224142883.png)

### 查看TRACKER_SERVER容器ip地址的方法

1. 进入tracker容器内部

> docker exec -i -t <tracker容器的名字> /bin/bash

1. 一般要先执行

> apt-get update

1. 安装ifconfig命令

> apt-get install net-tools

1. 然后输入ifconfig 然后看到eth0的ip地址就是tracker的ip地址了 端口默认是22122

```
eth0      Link encap:Ethernet  HWaddr 02:50:00:00:00:01
          inet addr:192.168.65.3  Bcast:192.168.65.255  Mask:255.255.255.0
          inet6 addr: fe80::50:ff:fe00:1/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:530127 errors:0 dropped:0 overruns:0 frame:0
          TX packets:231123 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:776445648 (776.4 MB)  TX bytes:13768969 (13.7 MB)
```

