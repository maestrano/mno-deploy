# {{ ansible_managed }}
#
# Environment and deploy file
# For use with bin/server_deploy, bin/server_package etc.
DEPLOY_HOSTS="hostname1.net
              hostname2.net"

# Jobserver User
APP_USER={{ spark_user }}
APP_GROUP={{ spark_user }}

# optional SSH Key to login to deploy server
# SSH_KEY=/path/to/keyfile.pem

JMX_PORT=9999
INSTALL_DIR={{ spark_jobserver_lib_dir }}
LOG_DIR={{ spark_jobserver_log_dir }}
PIDFILE={{ spark_jobserver_run_dir }}/spark-jobserver.pid
JOBSERVER_MEMORY={{ spark_jobserver_memory }}
SPARK_VERSION={{ spark_version }}
MAX_DIRECT_MEMORY={{ spark_jobserver_direct_memory }}
SPARK_HOME={{ spark_lib_dir }}
SPARK_CONF_DIR={{ spark_conf_dir }}

# Only needed for Mesos deploys
SPARK_EXECUTOR_URI=/home/spark/spark-1.6.0.tar.gz

# Only needed for YARN running outside of the cluster
# You will need to COPY these files from your cluster to the remote machine
# Normally these are kept on the cluster in /etc/hadoop/conf
# YARN_CONF_DIR=/pathToRemoteConf/conf
# HADOOP_CONF_DIR=/pathToRemoteConf/conf
#
# Also optional: extra JVM args for spark-submit
# export SPARK_SUBMIT_OPTS+="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5433"
SCALA_VERSION={{ scala_version }}
