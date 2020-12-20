# docker-compose搭建fastDFS-nginx环境

1. 得先安装docker和docker-compose，具体教程百度

2. 首先克隆项目到本地

> git clone https://github.com/xiaozhi747/nginx-fastdfs.git

3. 利用 Dokcerfile 构建镜像

```shell script
docker build -t nginx-fastdfs:lz .
```

4. 执行 `docker-compose up` 命令

5. 执行java代码测试环境搭建是否成功（我自己的环境是基于springcloud搭建的）

配置文件 application.yml （根据自己需求修改）
```yaml
server:
  port: 8082
spring:
  application:
    name: upload-service
  servlet:
    multipart:
      max-file-size: 5MB # 限制文件上传的大小
# Eureka
eureka:
  client:
    service-url:
      defaultZone: http://127.0.0.1:10086/eureka
  instance:
    lease-renewal-interval-in-seconds: 5 # 每隔5秒发送一次心跳
    lease-expiration-duration-in-seconds: 10 # 10秒不发送就过期
fdfs:
  so-timeout: 1501 # 超时时间
  connect-timeout: 601 # 连接超时时间
  thumb-image: # 缩略图
    width: 60
    height: 60
  tracker-list: # tracker地址：你的虚拟机服务器地址+端口（默认是22122）
    - 172.19.0.3:22122
```
测试代码：
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

![image-20200517222358961](https://github.com/xiaozhi747/nginx-fastdfs/blob/master/assets/image-20200517222358961.png)



**如果测试失败报错位：**com.github.tobato.fastdfs.exception.FdfsServerException: 错误码:2,错误信息

检查storage容器里的 /etc/fdfs/storage.conf 和 /etc/fdfs/client.conf 配置文件中 tracker_server的值是否为tracker_server所在机器的： **ip地址:22122** 

执行下面命令让配置生效

```
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf
```

重新查看状态

```
/usr/bin/fdfs_monitor /etc/fdfs/client.conf
```

正常应为：

```
ACTIVE
```

![image-20200517224142883](https://github.com/xiaozhi747/nginx-fastdfs/blob/master/assets/image-20200517224142883.png)

### 查看TRACKER_SERVER容器ip地址的方法
新： docker inspect 命令查看即可

旧：
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

