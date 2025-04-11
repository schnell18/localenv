# Containerized local development environment

The local virtual development environment offers convenient and consistent
cross-platform development experience that allows developers to run the modern
full-stack inside their own computer. It manages complex runtime dependencies
effectively to avoid pollution of host environment by leveraging container
technology. This approach makes good use of computing powers in developer's
laptop or workstation and creates sandboxes for safe experiments on the
software and dependencies. It also addresses the challenge to run clustered
middlewares (for example redis, kafka) as container, which advertises container
IP addresses inaccessible from host. The localenv solves this problem by
carefully crafting the provision scripts that work cross-platform.

The localenv includes following databases and middlewares:

* MariaDB
* MongoDB
* Redis
* RocketMQ
* RabbitMQ
* ElasticSearch
* nginx
* nacos
* etcd
* zookeeper
* kafka
* kafka4

Additional databases and middlewares can be included.

The databases and middlewares are accessible from the host via port mapping.
The service ports and admin URLs of these databases and middlewares are
presented in the table as follows:

|  Seq  | Middleware       | Port                | admin URL                   |
| ----- | ---------------- | ------------------- | --------------------------- |
|  01   | MariaDB          | 3306                |                             |
|  02   | MongoDB          | 27017               |                             |
|  03   | Redis(Cluster)   | 7001,7002,7003      |                             |
|  04   | Redis(Sentinel)  | 6379,6380,6381      |                             |
|  05   | etcd             | 2379,2380,2381      |                             |
|  06   | zookeeper        | 2181,2182,2183      |                             |
|  07   | RocketMQ         | 9876                | http://127.0.0.1:7080       |
|  08   | ElasticSearch    | 9200                | http://127.0.0.1:5601       |
|  09   | nacos            | 8848                | http://127.0.0.1:8848/nacos |
|  10   | rabbitmq         | 5672                | http://127.0.0.1:15672      |
|  11   | kafka-ui         | 9000                | http://127.0.0.1:9000       |
|  12   | kafka4           | 19092,29092,39092   | http://127.0.0.1:9000       |
|  13   | jaeger           | 16686               | http://127.0.0.1:16686      |

## Setup

The localenv has been verified on MacOS. It also works on Linux and Windows.
To use the localenv, please install podman 4.0.0 or above on the host machine.
Additionally, install the follow tools on the host machine.

- podman
- podman-dnsname
- aardvark-dns
- mysql client
- redis client
- git
- tmux
- jq
- curl
- xxd

The podman-compose tool is bundled in this project. No separate installation
is necessary. After successful installation of the aforementioned tools,
please clone the [localenv repository][2] by typing:

    cd ~
    git clone https://github.com/schnell18/localenv.git

Optionally, you pick a backend project and place it under the
`localenv/backends` folder. For example, you may add the imaginary project
`riemann` to the localenv as follows:

    cd ~/localenv
    mkdir backends
    cd backends
    git clone git@<your_git_server>/riemann.git

Additionally, if you want to add frontend project, you put it under the
`localenv/frontends` folder.

    cd ~/localenv
    mkdir frontends
    cd frontends
    git clone git@<your_git_server>/<your_frontend_project>.git

## Tested OSes

This project has been tested on the MacOS and Linux. Specifically, localenv
has been tested under:
- MacOS 15.3.2 on 2019 MacBookPro w/ Intel chip
- Manjaro Zetar (5.15.179-1-MANJARO) on a 2022 Legend Legion w/ Intel chip

## About the rootness of container

The philosophy of the localenv is to encourage exploration of the ins-and-outs
of complex tech stacks. To facilitate digging into the internals, the storage
files of the containerized middlewares are mapped to the host under the
`.state` folder in the localenv. Similarly, the project files are mapped into
the container under `/work` directory by convention. The containers in
localenv is intentionally running as root to ease the file sharing between
containers and host, since the root user in the container is mapped to user
running podman on the host, as discussed in [this article][11]. To ensure
security and transparency, all container images used by localenv are from
official upstream. For those customized by this project, the Dockerfiles are
located under the `Containerfiles` folder. These images are built
automatically thanks to the github action.

## Launch localenv

Although, the localenv can host multiple middlewares and databases, you start
only the necessary databases or middlewares to avoid excessive memory
consumption. The databases and middlewares are managed by the script
`infractl.sh`. This script should always be launched under the root directory
of localenv. You may list all supported databases or middlewares by typing:

    cd ~/localenv
    ./infractl.sh list

To start MariaDB only, type:

    ./infractl.sh start mariadb

To start MariaDB and Redis, type:

    ./infractl.sh start mariadb redis-cluster

To launch middleware that has dependencies, the dependencies must be specified
first in the argument list. For example, to start the nacos registry, mariadb
must be included as the first argument as follows:

    ./infractl.sh start mariadb nacos

Due to implementation limitation, the order of middlewares in the above command
can't be reversed. In future release, this limitation may be removed.

The following table lists the supported middlewares and their dependencies:

|  Seq  | infra                       | dependencies               | Notes                           |
| ----- | --------------------------- | -------------------------- | ------------------------------- |
|  01   | elasticsearch               |                            | ElasticSearch                   |
|  02   | mariadb                     |                            | MariaDB                         |
|  03   | redis-cluster               |                            | Redis Cluster mode              |
|  04   | redis-sentinel              |                            | Redis Sentinel mode             |
|  05   | rocketmq                    |                            | RocketMQ                        |
|  06   | rabbitmq                    |                            | RabbitMQ                        |
|  07   | kafka                       | zookeeper                  | kafka 3                         |
|  08   | kafka4                      |                            | kafka 4                         |
|  09   | nacos                       | mariadb                    | Configuration and service reg   |
|  10   | etcd                        |                            | etcd                            |
|  11   | zookeeper                   |                            | zookeeper                       |
|  12   | mongodb                     |                            | mongodb                         |
|  13   | [jaeger][8]                 | elasticsearch              | jaeger distributed tracing      |
|  14   | filebeat                    | elasticsearch              | Log collector                   |
|  15   | fluentbit                   |                            | High performance log collector  |
|  16   | nginx                       |                            | High performance webserver      |

To check if the middlewares are working properly, you may type:

    ./infractl.sh status all

Or simply:

    ./infractl.sh status

## Build Container Image

The localenv supports multi-architecture image build. The container image build
files of the middlewares required by the localenv are included under the
`Containerfiles` folder. These images support the x86\_64 and arm64
architecture and run on Apple M1, M2, M3 and M4 chips.
To build these images on MacOS, the package `qemu-user-static` should be installed
in the virtual machine managed by podman. This is automatically handled when
you initialize the localenv using command:

    $ ./infractl.sh init

Alternatively, you can install it manually by running the following commands:

    $ podman machine ssh localenv
    $ rpm-ostree install qemu-user-static
    $ systemctl reboot
    $ podman system connection default localenv-root

## Redis

### Redis Cluster Mode

The redis instance supported by localenv is a 3-node redis cluster with port
range from 7001 to 7003. The cluster password is `abc123`.
To connect using the redis-cli, you can type:

    redis-cli -c -h 127.0.0.1 -p 7001 -a abc123

If you use tmux, then you may launch the `tmux.sh` which open the above session
in a separate window for you. You may use any other redis management tools to
interact with the redis cluster.

### Redis Sentinel Mode

The redis instance supported by localenv is a 3-slave 3-sentinel redis sentinel
on port 6379. The cluster password is `abc123`. To connect using the redis-cli,
you can type:

    redis-cli -h 127.0.0.1 -p 6379 -a abc123

You may use any other redis management tools to interact with the redis
cluster.

## MariaDB (MySQL)

The MariaDB (a MySQL variant) instance in the localenv can be accessed via
127.0.0.1:3306. For normal application access, use user name `mfg` and password
`abc` to connect to the database. For administrative access, use password
`root` for the root user. For tmux user, launching `tmux.sh` will open a
terminal window to open the mysql shell. If you prefer GUI client, use your
favorite tool to connect the database using the credentials as aforementioned.

The data files of MariaDB instance are stored under the folder
`.state/mariadb/data`. The data persist over environment restart as long as you
don't remove these files.

## Kafka4

[Kafka4][10] is an open-source distributed event streaming platform.
To start a 3-node kafka cluster in the localenv, type:

    ./infractl.sh start Kafka4

The 3 kafka nodes are exposed to the host on port 19092, 29092, and 39092
respectively.


## ETCD

[ETCD][9] is a strongly consistent, distributed key-value store for distributed
systems. To start a 3-node ETCD cluster in the localenv, type:

    ./infractl.sh start etcd

## ElasticSearch

The ElasticSearch instance in the localenv can be accessed via 127.0.0.1:9200.
The companion Kibana is serving on 5601. You can browse http://127.0.0.1:5601 to
access the web ui. Alternatively, you can type

    ./infractl.sh webui elasticsearch

to access the Kibana webui.

## RocketMQ

The [RocketMQ][4] instance includes a webui for administration. The admin URL
is http://127.0.0.1:7800. Alternatively, you can type

    ./infractl.sh webui rocketmq

to launch the administration webui. Register user name for the first use.

The data files of RocketMQ instance are stored under the folder
`.state/rocketmq/broker1/store`. The data survive environment restarts as long
as you don't remove these files.

## RabbitMQ

The [RabbitMQ][5] instance includes a webui for administration. The admin URL
is http://127.0.0.1:15672. Alternatively, you can type

    ./infractl.sh webui rabbitmq

to launch the administration webui. Use the guest/guest to login.

## nacos

[nacos][6] is an open-source application configuration and service registry.
nacos requires relational database to operate. The localenv utilizes the
mariadb as the underlying database for nacos. Therefore, you need start mariadb
when you launch nacos:

    ./infractl.sh start mariadb nacos

This command opens the default web browser and navigates to the nacos
administration page. The default user and password are identical, which is
`nacos`.
To open the nacos administration page, you may type:

    ./infractl.sh webui nacos

which leads you to the administration UI.

## Jaeger

Jaeger is an open-source distributed tracing tool for modern microservices.
The Jaeger instance in the localenv uses ElasticSearch as storage, thus it requires
an ElasticSearch instance. To start Jaeger run:

    ./infractl.sh start elasticsearch jaeger

To open the Jaeger web ui manually, you may type:

    ./infractl.sh webui jaeger

## filebeat

Filebeat is a popular logs collection tool for modern microservices, especially
running as containers. The filebeat instance in the localenv uses ElasticSearch
as storage, thus it requires an ElasticSearch instance. To start filebeat run:

    ./infractl.sh start elasticsearch filebeat

To open the Kibana ui manually, you may type:

    ./infractl.sh webui elasticsearch

## Load Data

The localenv provides tool to load data in .csv format for applications and
middlewares. The data files and schema definition should be organized according
to the following directory structure for applications:

    ./backends/riemann
    ├── Dockerfile
    ├── README.md
    ├── pom.xml
    └── schema
        ├── data
        │   ├── 001-shipper.csv
        └── schema.sql

And for the middlewares, a similar structure is assumed:

    .infra/nacos
    ├── descriptor.yml
    └── provision
        ├── schema
        │   ├── data
        │   │   ├── 01-roles.csv
        │   │   └── 02-users.csv
        │   └── schema.sql

The key is to put the `schema` directory under the `provision` directory.


### Load Application Data

When you updated the schema of the application or changed data, you may wish
to apply the new schema or refresh the new data. The localenv helps you to achieve
this goal with the `refresh-db` sub command. To refresh schemas and data for all
backend applications, type:

    ./appctl.sh refresh-db

To refresh individual application, say `riemann`, execute the following command:

    ./appctl.sh refresh-db riemann

### Load Middleware Data

Normally, localenv loads the data required by middlewares automatically.
In rare cases, you may need reload the data by typing the following command:

    ./infractl.sh refresh-db

This command removes existing data and recreates databases. Thus run this
command with extreme caution.


## Java Remote Debug

You can use localenv to debug Java program running inside the container from
your favorite IDE. This is an effective way to uncover bugs that are difficult
to reproduce using unit test approach. The debug capability is based on the
JDWP. To enable debug, you modify the `app-xxx.yml` file as
described in following sections.

### Setup Debugging

Open the application specific file `app-xxx.yml`, locate the
Java application to debug, and set environment variables as follows:

    environment:
      - JDWP_DEBUG=true
      - JDWP_PORT=5005

### Expose Debugging Port

The IDE runs in the host environment, making direct access to the Java program
running inside the container impossible. Therefore, the `JDWP_PORT` must be exposed
to the host environment. To map the `JDWP_PORT` to host environment, open the application
specific `docker-compose-app-xxx.yml` file, locate the Java application to debug and add
port mapping as follows:

    ports:
      - "5005:5005"

### Setup Remote Debug in IDE

Most main stream Java IDEs support remote debug. This section uses IntelliJ
Idea as an example. To setup remote debug in IntelliJ Idea, click the debug
configuration dropdown control on the tool bar to create a new debug
configuration.

![Create Remote JVM debug configuration](img/jdwp01.png "Create Remote Debug")

Type `127.0.0.1` in the `Host` text input, enter the `JDWP_PORT` into the `Port`
field. Then select the top-level project in the `Use module classpath` dropdown box.
Click `OK` to confirm the settings. To start debug, click the `Debug` button.
The output window should display:

    Connected to the target VM, address: '127.0.0.1:5005', transport: 'socket'

This means the IDE has connected to the Java program. Finally, set break points
and start the debug session.

## Accelerate Container Image Retrieval

To speedup container image download in China, you may modify
`~/.config/containers/registries.conf` to include the container image
registries as follows:

    unqualified-search-registries = ["docker.io"]

    [[registry]]
    prefix = "docker.io"
    insecure = false
    blocked = false
    location = "docker.xuanyuan.me"

[2]: https://github.com/schnell18/localenv.git
[3]: https://wiki.archlinux.org/title/Podman
[4]: https://rocketmq.apache.org/
[5]: https://www.rabbitmq.com/
[6]: https://nacos.io/
[8]: https://www.jaegertracing.io/
[9]: https://etcd.io/
[10]: https://kafka.apache.org/
[11]: https://opensource.com/article/19/2/how-does-rootless-podman-work
