# Containerized local development environment

The local virtual development environment offers convenient and consistent
cross-platform development experience that allows developers to run the modern
full-stack inside their own computer. It manages complex runtime dependencies
effectively to avoid pollution of host environment by leveraging container
technology. This approach makes good use of computing powers in developer's
laptop or workstation and creates sandboxes for safe experiments on the
software and dependencies. It also addresses the challenge to run clustered
middlewares (for example redis, kafka) as containers, which advertises
container IP addresses inaccessible from host. The localenv solves this problem
by carefully crafting the provision scripts that work cross-platform.
Additionally, localenv offers a single login (localenv) and password (localenv)
to access all middlewares or databases it manages, which minimizes the password
management burden.

# Setup

The localenv has been verified on Linux, MacOS, and Windows. Specifically, localenv
has been tested under:

- MacOS 15.3.2 on 2019 MacBookPro w/ Intel chip
- Windows 11 10.0.26100 w/ Intel chip
- Manjaro Zetar (5.15.179-1-MANJARO) on a 2022 Legend Legion w/ Intel chip

Instead of docker, localenv leverages [podman][18] to manage containers. The reasonale is that
podman is free and open-sourced and more secure due to its rootless approach, as indicated by [this
research][14]. Previous podman releases, specifically the versions prior to 4.6.0, don't support
healthy status check, leading to issues [startup hangs][12]. Therefore, a recent version of podman,
or at least 4.6.0 is mandatory to run localenv. Additionally, if you plan to use the companion
`tmux.sh` to setup a multi-window termnal development UI, it is hightly recommended you install the
follow optional tools on the host machine: facilitate development.

- mysql client
- redis client
- git
- tmux
- jq
- curl
- xxd

## Install dependencies

The minimal mandatory dependencies of localenv include Python 3.11+, podman 4.6.0+, and the two
Python packages required by podman-compose: dotenv and pyyaml.

### Install Python
You may install Python using the official release from [python.org][15] or using the OS-specific
package manager. Additionally, you may use the miniconda to setup virtual env for specific Python
version. The localenv has been tested with this approach.

### Install podman

On MacOS, the recommended method to install podman on MacOS is to utilize Homebrew:

    brew install podman

On Linux, you can utilize distribution-specific package manager. For example, on Debian/Ubuntu type:

    sudo apt-get update && sudo apt-get install podman

On Arch/Manjaro type:

    sudo pacman -S podman

On Windows, grab the Podman Windows installer from podman's github project and install podman with
the GUI installer. Alternatively, if you are comfortable with command line, you can type:

    winget install podman

### Setup podman-compose

The official podman-compose 1.3.0 has [a defect][16] which prevents it from reliably launching
containers depending on the successful startup of other containers. The [pull request PR #1184][17]
fixes this issue and is under review. To facilitate setup, the patched podman-compose from [PR
#1184][17] is bundled in this project. You don't have to install podman-compose separately. However,
you still need install the required Python packages dotenv and pyyaml.

### Setup localenv

Setup of localenv can only be performed after successful installation of the aforementioned tools
and libraries. You can install localenv simply by cloning the [localenv repository][2]. The localenv
is distributed as github project in source format. No binary package or will be installed on your
computer. The command to clone this project is as follows:

    cd ~
    git clone https://github.com/schnell18/localenv.git

Since you will interact localenv frequently using command line, put the localenv project under your
home directory is hightly recommended to avoid typing long directory names.

## Using localenv

The databases and middlewares, abstracted as infra in the localenv, are managed by the script
`infractl.sh` on MacOS/Linux, `infractl.ps1` on Windows. The two scripts should always be launched
under the root directory of localenv. The localenv isn't able to resolve dependencies between infras
so far. If you start infra with dependencies, you should the start them together and the
dependencies should go first in the argument list. This limitation may be removed in future release.

The infras managed by localenv are crafted with minimal memory consumption in mind. However, if you
start too many infras than necessary, you may render your laptop or workstation irresponsive due to
excessive memory consumption or high CPU usage.

### Initialize localenv

Depending on your OS, the localenv may require a intermediate virtual machine which is managed
automatically. Prior to you'd better initialize this virtual machine by using the `init` subcommand.

For example, on MacOS/Linux, type:

    cd ~/localenv
    ./infractl.sh init

On Windows, you execute the following commands in a Powershell terminal:

    cd localenv
    .\infractl.ps1 init

You skip this step and start the infras directly. The localenv will detect whether it needs
a virtual machine and initializes and starts it as necessary.

### Launch infras

It is straitforward to launch an infra in localenv. First, you change to the root directory where
localenv located, then type the `./infractl.sh` or `infractl.ps1` script followed by the names of
the infra. However, when the infra has dependencies, You should start infra and its dependencies
together. The dependencies should go first. For instance, to launch kafka which depends on
zookeeper, you execute commands on MacOS/Linux as follows:

    cd localenv
    ./infractl.sh zookeeper kafka

On Windows, open a Powershell terminal and type:

    cd localenv
    .\infractl.ps1 zookeeper kafka

If you want to know all supported databases or middlewares, you can type:

    ./infractl.sh list

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

    ./infractl.sh status

To login the container, type:

    ./infractl.sh attach <infra-component-name>

The <infra-component-name> is defined in the corresponding descriptor.yml file of the infra.
To check logs generated by the infra, type:

    ./infractl.sh longs <infra-component-name>

### Stop infra

To stop current running infras, type:

    ./infractl.sh stop


## Integrate backend or frontend projects

Once this infrastrure part of localenv is ready, you can integrate your backend or frontend projects
to take advantage of localenv. For backend projects, you put them under the `localenv/backends`
folder. For example, you may add the imaginary project `riemann` to the localenv as follows:

    cd ~/localenv
    mkdir backends
    cd backends
    git clone git@<your_git_server>/riemann.git

This directory layout makes the schema and data load functions available to any backend project
defines its database schema in the `schema/schema.sql` file and stores csv files under the
'schema/data' folder in the project.

Additionally, if you want to add frontend project, you put it under the
`localenv/frontends` folder.

    cd ~/localenv
    mkdir frontends
    cd frontends
    git clone git@<your_git_server>/<your_frontend_project>.git


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

## Build Container Image

The localenv supports multi-architecture image build. The container image build files of the
middlewares required by the localenv are included under the `Containerfiles` folder. These images
support the x86\_64 and arm64 architecture and run on Apple M1, M2, M3, and M4 chips. To build these
images on MacOS, the package `qemu-user-static` should be installed in the virtual machine managed
by podman. This is automatically handled when you initialize the localenv using command:

    $ ./infractl.sh init

Alternatively, you can install it manually by running the following commands:

    $ podman machine ssh localenv
    $ rpm-ostree install qemu-user-static
    $ systemctl reboot
    $ podman system connection default localenv-root

## Middleware Catalog
Currently, the localenv includes following databases and middlewares:

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
* NATS

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
|  14   | NATS             | 4222                | http://127.0.0.1:31311      |


### Redis Cluster Mode (redis-cluster)

The redis instance supported by localenv is a 3-node redis cluster with port
range from 7001 to 7003. The cluster password is `localenv`.
To connect using the redis-cli, you can type:

    redis-cli -c -h 127.0.0.1 -p 7001 -a localenv

If you use tmux, then you may launch the `tmux.sh` which open the above session
in a separate window for you. You may use any other redis management tools to
interact with the redis cluster.

### Redis Sentinel Mode (redis-sentinel)

The redis instance supported by localenv is a 3-slave 3-sentinel redis sentinel
on port 6379. The cluster password is `localenv`. To connect using the redis-cli,
you can type:

    redis-cli -h 127.0.0.1 -p 6379 -a localenv

You may use any other redis management tools to interact with the redis
cluster.

### MariaDB (MySQL replacement)

The MariaDB (a MySQL variant) instance in the localenv can be accessed via
127.0.0.1:3306. For normal application access, use user name `localenv` and
password `localenv` to connect to the database. For administrative access, use
password `root` for the root user. For tmux user, launching `tmux.sh` will open
a terminal window to open the mysql shell. If you prefer GUI client, use your
favorite tool to connect the database using the credentials as aforementioned.

The data files of MariaDB instance are stored under the folder
`.state/mariadb/data`. The data persist over environment restart as long as you
don't remove these files.

### Kafka4

[Kafka4][10] is an open-source distributed event streaming platform.
To start a 3-node kafka cluster in the localenv, type:

    ./infractl.sh start Kafka4

The 3 kafka nodes are exposed to the host on port 19092, 29092, and 39092
respectively.


### etcd

[etcd][9] is a strongly consistent, distributed key-value store for distributed
systems. To start a 3-node ETCD cluster in the localenv, type:

    ./infractl.sh start etcd

### ElasticSearch

The ElasticSearch instance in the localenv can be accessed via 127.0.0.1:9200.
The companion Kibana is serving on 5601. You can browse http://127.0.0.1:5601 to
access the web ui. Alternatively, you can type

    ./infractl.sh webui elasticsearch

to access the Kibana webui.

### RocketMQ

The [RocketMQ][4] instance includes a webui for administration. The admin URL
is http://127.0.0.1:7800. Alternatively, you can type

    ./infractl.sh webui rocketmq

to launch the administration webui. Register user name for the first use.

The data files of RocketMQ instance are stored under the folder
`.state/rocketmq/broker1/store`. The data survive environment restarts as long
as you don't remove these files.

### RabbitMQ

The [RabbitMQ][5] instance includes a webui for administration. The admin URL
is http://127.0.0.1:15672. Alternatively, you can type

    ./infractl.sh webui rabbitmq

to launch the administration webui. Use the guest/guest to login.

### nacos

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

### Jaeger

Jaeger is an open-source distributed tracing tool for modern microservices.
The Jaeger instance in the localenv uses ElasticSearch as storage, thus it requires
an ElasticSearch instance. To start Jaeger run:

    ./infractl.sh start elasticsearch jaeger

To open the Jaeger web ui manually, you may type:

    ./infractl.sh webui jaeger

### filebeat

Filebeat is a popular logs collection tool for modern microservices, especially
running as containers. The filebeat instance in the localenv uses ElasticSearch
as storage, thus it requires an ElasticSearch instance. To start filebeat run:

    ./infractl.sh start elasticsearch filebeat

To open the Kibana ui manually, you may type:

    ./infractl.sh webui elasticsearch

### NATS

NATS is a lightweight, high-performance open-source messaging system
designed for cloud-native applications, IoT, and microservices.

The NATS instance in the localenv is companioned by nui which offers an
intuitive webui to manage NATS. To start NATS run:

    ./infractl.sh start nats

Upon successful startup, the nui admin page will be displayed in your
default browser.

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

***This feature is under refactoring, it may not work out-of-box right now***

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
[12]: https://github.com/containers/podman-compose/issues/1178
[13]: https://github.com/containers/podman-compose/issues/1183
[14]: https://doi.org/10.1145/3458817.347618
[15]: https://www.python.org/downloads/
[16]: https://github.com/containers/podman-compose/issues/1183
[17]: https://github.com/containers/podman-compose/pull/1184
[18]: https://podman.io/
