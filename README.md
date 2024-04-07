# Docker_RabbitMQ

## 环境配置（依赖和工具）

1.git

    # 安装
    yum install git

    #验证
    [root@localhost ~]# git --version

2.查看服务器时区（这是个巨坑,一定要设置！设置！设置！）

    a.查看时区  date  或   hwclock
    b.列出时区  timedatectl list-timezones
    c.设置时区  timedatectl set-timezone Asia/Shanghai
    d.查看是否修改成功  date
    e.Centos8安装时间同步服务

    下面安装方式二选一进行安装即可：
    dnf install -y chrony
    yum install -y chrony

    更好的方式是让chronyd后台运行，自动同步时间：
    systemctl enable chronyd
    systemctl start chronyd

3.安装 Screen 服务（可用于 SSH 断开离线下载等会话操作）

    yum  install screen              #安装

    screen -S  tron-back             #创建screen会话(tron-back为会话名称)

    screen -ls                       #查看所有screen会话

    按键盘上面的Ctrl+a，然后再按d      #保存当前的screen会话

    exit   #退出screen

    screen -wipe  tron-back          #删除会话

4.Telnet 命令

    # AlmaLinux / Rocky Linux / CentOS / Fedora
    # sudo yum -y install telnet

    # Ubuntu / Debian
    # apt-get install telnet

5.安装 Amazon ECS 的 Docker

      1).更新实例上已安装的程序包和程序包缓存。

         sudo yum update -y

      2).安装最新的 Docker Engine 程序包。

         # Amazon Linux 2
         sudo amazon-linux-extras install docker

         # Amazon Linux
         sudo yum install docker

      3).启动 Docker 服务

         sudo service docker start

      4).将 ec2-user 添加到 docker 组，以便您能够执行 Docker 命令，而无需使用 sudo

         sudo usermod -a -G docker ec2-user

      5).退出，再重新登录以接受新的 docker 组权限。您可以关闭当前的 SSH 终端窗口并在新终端窗口中重新连接到实例，完成这一过程。您的新 SSH 会话将具有相应的 docker 组权限

      6).验证 ec2-user 是否能在没有 sudo 的情况下运行 Docker 命令。

         docker info

6.在 Amazon Linux 2 上安装 docker-compose 的步骤如下

    1>使用以下命令从 GitHub 的 docker/compose 仓库下载并安装最新版的 docker-compose

        sudo curl -L "https://github.com/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    2>为 docker-compose 命令设置执行权限

        sudo chmod +x /usr/local/bin/docker-compose

    3>执行以下命令验证 docker-compose 的版本

        docker-compose --version

## RabbitMQ在Docker环境生成环境的集群模式（适用于生产环境）

    1.Win操作系统（一般指的本地开发机）部署

        1>. 进入[rabbitmq_win]文件夹，找到docker-compse.yml文件后，执行如下命令

            docker-compose up -d

        2>. 3个节点启动后为单例模式（非集群），需要如下操作进行将节点串联起来

            ### Node 1
            docker exec -it rabbitmqCluster001 bash
            rabbitmqctl stop_app
            rabbitmqctl reset
            rabbitmqctl start_app

            ### Node 2
            docker exec -it rabbitmqCluster002 bash
            rabbitmqctl stop_app
            rabbitmqctl reset
            rabbitmqctl join_cluster --ram rabbit@rabbitmq001
            rabbitmqctl start_app

            ### Node 3
            docker exec -it rabbitmqCluster003 bash
            rabbitmqctl stop_app
            rabbitmqctl reset
            rabbitmqctl join_cluster --ram rabbit@rabbitmq001
            rabbitmqctl start_app
    
    2.AWS-Linux2操作系统（一般指的服务器的环境）部署

        1>. 进入[rabbitmq_linux]文件夹，找到docker-compse.yml文件后，将文件拷贝至于服务器的目录 /data/rabbitmq/ 下

        2>. 确认安装过docker和docker-compose后,执行命令 
            docker-compose up -d
        
        3>.

    99.关于docker-compose中特别需要注意的几点（！！！重要！！！）

        1>. 使用'hostname'定义每个服务的主机名。
        2>. 设置'RABBITMQ_ERLANG_COOKIE'以确保所有节点都有相同的Erlang cookie，这是集群节点间通信所必需的。
        3>. 'RABBITMQ_NODENAME'确定RabbitMQ节点的名称。
        4>. 'depends_on'确保依赖关系的服务首先启动。
        5>. 那个自动加入节点的SH文件好像问题不成功，最好使用手动连接

## RabbitMQ命令

    1.设置一个新的用户，并且设置该用户的权限

        rabbitmqctl add_user <username> <password>
        rabbitmqctl set_permissions -p / <username> ".*" ".*" ".*"

        上述命令首先创建一个新用户，并为其设置权限，允许其访问默认的虚拟主机(/)的所有资源。

## RabbitMQ(Docker 发布)

    1.拉取镜像

        docker pull rabbitmq:3.7-management

    2.启动一个默认配置的RabbitMQ

        docker run -d -p 5672:5672 -p 15672:15672 --name rabbitmq --restart=always --privileged=true rabbitmq:management

    3.启动RabbitMQ容器

        1.宿主机器为Linux操作系统下的docker启动命令

        docker run -d --hostname rabbitmq001 --name rabbitmqCluster001 -v /data/rabbitmq/cluster/001/config:/var/lib/rabbitmq/config -v /data/rabbitmq/cluster/001/mnesia:/var/lib/rabbitmq/mnesia -v /data/rabbitmq/cluster/001/schema:/var/lib/rabbitmq/schema -p 5672:5672 -p 15672:15672 -e RABBITMQ_ERLANG_COOKIE='rabbitmqCookie' --restart=always --privileged=true rabbitmq:management

        2.宿主机器为Window操作系统下的docker启动命令(需要在D盘的根目录下创建一个叫AppData的文件夹,再在AppData里创建一个Nginx文件夹,将相关映射文件移至内即可)

        docker run -d --hostname rabbitmq001 --name rabbitmqCluster001 -v /d/appdata/rabbitmq/cluster/001/config:/var/lib/rabbitmq/config -v /d/appdata/rabbitmq/cluster/001/mnesia:/var/lib/rabbitmq/mnesia -v /d/appdata/rabbitmq/cluster/001/schema:/var/lib/rabbitmq/schema -p 5672:5672 -p 15672:15672 -e RABBITMQ_ERLANG_COOKIE='rabbitmqCookie' --privileged=true rabbitmq:management

    4.docker简易搭建RabbitMQ集群

        1.普通集群模式

            a）拉取rabbitmq镜像

                docker pull rabbitmq:management

            b) 创建映射数据卷目录，启动rabbitmq容器

                cd /data/rabbitmq/cluster

                mkdir 001 002 003

            c）执行命令

                ######## Linux环境 ########

                docker run -d --hostname rabbitmq001 --name rabbitmqCluster001 -v /data/rabbitmq/cluster/001/config:/var/lib/rabbitmq/config -v /data/rabbitmq/cluster/001/mnesia:/var/lib/rabbitmq/mnesia -v /data/rabbitmq/cluster/001/schema:/var/lib/rabbitmq/schema -p 5672:5672 -p 15672:15672 -e RABBITMQ_ERLANG_COOKIE='rabbitmqCookie' --restart=always --privileged=true rabbitmq:management

                docker run -d --hostname rabbitmq002 --name rabbitmqCluster002 -v /data/rabbitmq/cluster/002/config:/var/lib/rabbitmq/config -v /data/rabbitmq/cluster/002/mnesia:/var/lib/rabbitmq/mnesia -v /data/rabbitmq/cluster/002/schema:/var/lib/rabbitmq/schema -p 5673:5672 -p 15673:15672 -e RABBITMQ_ERLANG_COOKIE='rabbitmqCookie' --restart=always --privileged=true --link rabbitmqCluster001:rabbitmq001 rabbitmq:management

                docker run -d --hostname rabbitmq003 --name rabbitmqCluster003 -v /data/rabbitmq/cluster/003/config:/var/lib/rabbitmq/config -v /data/rabbitmq/cluster/003/mnesia:/var/lib/rabbitmq/mnesia -v /data/rabbitmq/cluster/003/schema:/var/lib/rabbitmq/schema -p 5674:5672 -p 15674:15672 -e RABBITMQ_ERLANG_COOKIE='rabbitmqCookie' --restart=always --privileged=true --link rabbitmqCluster001:rabbitmq001 --link rabbitmqCluster002:rabbitmq002 rabbitmq:management

                ######## Window环境 ########

                docker run -d --hostname rabbitmq001 --name rabbitmqCluster001 -v /d/appdata/rabbitmq/cluster/001/config:/var/lib/rabbitmq/config -v /d/appdata/rabbitmq/cluster/001/mnesia:/var/lib/rabbitmq/mnesia -v /d/appdata/rabbitmq/cluster/001/schema:/var/lib/rabbitmq/schema -p 5672:5672 -p 15672:15672 -e RABBITMQ_ERLANG_COOKIE='rabbitmqCookie' --restart=always --privileged=true rabbitmq:management

                docker run -d --hostname rabbitmq002 --name rabbitmqCluster002 -v /d/appdata/rabbitmq/cluster/002/config:/var/lib/rabbitmq/config -v /d/appdata/rabbitmq/cluster/002/mnesia:/var/lib/rabbitmq/mnesia -v /d/appdata/rabbitmq/cluster/002/schema:/var/lib/rabbitmq/schema -p 5673:5672 -p 15673:15672 -e RABBITMQ_ERLANG_COOKIE='rabbitmqCookie' --restart=always --privileged=true --link rabbitmqCluster001:rabbitmq001 rabbitmq:management

                docker run -d --hostname rabbitmq003 --name rabbitmqCluster003 -v /d/appdata/rabbitmq/cluster/003/config:/var/lib/rabbitmq/config -v /d/appdata/rabbitmq/cluster/003/mnesia:/var/lib/rabbitmq/mnesia -v /d/appdata/rabbitmq/cluster/003/schema:/var/lib/rabbitmq/schema -p 5674:5672 -p 15674:15672 -e RABBITMQ_ERLANG_COOKIE='rabbitmqCookie' --restart=always --privileged=true --link rabbitmqCluster001:rabbitmq001 --link rabbitmqCluster002:rabbitmq002 rabbitmq:management

                注： --hostname 设置容器的主机名RABBITMQ_ERLANG_COOKIE 节点认证作用，部署集成时 需要同步该值

                启动容器成功后，读者可以访问
                http://192.168.1.22:15672/#/
                http://192.168.1.22:15673/#/
                http://192.168.1.22:15674/#/
                查看是否正常启动成功。账号/密码：guest / guest。
                读者登陆后，查看 overview Tab 页，可看到节点信息。

    5.启动环境变量

        # Unavailable in 3.9 and up
        RABBITMQ_DEFAULT_PASS_FILE
        RABBITMQ_DEFAULT_USER_FILE
        RABBITMQ_MANAGEMENT_SSL_CACERTFILE
        RABBITMQ_MANAGEMENT_SSL_CERTFILE
        RABBITMQ_MANAGEMENT_SSL_DEPTH
        RABBITMQ_MANAGEMENT_SSL_FAIL_IF_NO_PEER_CERT
        RABBITMQ_MANAGEMENT_SSL_KEYFILE
        RABBITMQ_MANAGEMENT_SSL_VERIFY
        RABBITMQ_SSL_CACERTFILE
        RABBITMQ_SSL_CERTFILE
        RABBITMQ_SSL_DEPTH
        RABBITMQ_SSL_FAIL_IF_NO_PEER_CERT
        RABBITMQ_SSL_KEYFILE
        RABBITMQ_SSL_VERIFY
        RABBITMQ_VM_MEMORY_HIGH_WATERMARK

    6.使用Docker-compose快速启动集群

        # Windown环境下

        1.创建外挂文件夹

        /d/appdata/rabbitmq/cluster/001/config
        /d/appdata/rabbitmq/cluster/001/config
        /d/appdata/rabbitmq/cluster/001/config

        /d/appdata/rabbitmq/cluster/002/config
        /d/appdata/rabbitmq/cluster/002/config
        /d/appdata/rabbitmq/cluster/002/config

        /d/appdata/rabbitmq/cluster/003/config
        /d/appdata/rabbitmq/cluster/003/config
        /d/appdata/rabbitmq/cluster/003/config

        2.在项目源代码的根目录下 \rabbitmq_win 文件夹里执行CMD命令

        docker-compose up -d

        3.将启动的3个实例进行集群链接

        ### Node 1
        docker exec -it rabbitmqCluster001 bash
        rabbitmqctl stop_app
        rabbitmqctl reset
        rabbitmqctl start_app

        ### Node 2
        docker exec -it rabbitmqCluster002 bash
        rabbitmqctl stop_app
        rabbitmqctl reset
        rabbitmqctl join_cluster --ram rabbit@rabbitmq001
        rabbitmqctl start_app

        ### Node 3
        docker exec -it rabbitmqCluster003 bash
        rabbitmqctl stop_app
        rabbitmqctl reset
        rabbitmqctl join_cluster --ram rabbit@rabbitmq001
        rabbitmqctl start_app

        至此登录可查看3个集群已经相同连接完毕

## 参考资料文献

    https://www.jianshu.com/p/14ffe0f3db94
    https://cloud.tencent.com/developer/article/1783899
    https://www.jianshu.com/p/835338fefbd4