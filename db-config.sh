#!/bin/bash

# Create database connection configuration file
CONFIG_FILE="/opt/spark/conf/db-connections.conf"
echo "# Auto-generated database configuration" > $CONFIG_FILE

# Add database driver class names - always add driver info for direct usage
echo "spark.driver.mysql=com.mysql.cj.jdbc.Driver" >> $CONFIG_FILE
echo "spark.driver.postgres=org.postgresql.Driver" >> $CONFIG_FILE
echo "spark.driver.sqlserver=com.microsoft.sqlserver.jdbc.SQLServerDriver" >> $CONFIG_FILE
echo "spark.driver.oracle=oracle.jdbc.driver.OracleDriver" >> $CONFIG_FILE
echo "spark.driver.mongodb=org.mongodb.spark.sql.connector.MongoTableProvider" >> $CONFIG_FILE
echo "Database driver classes registered"

# Add all driver JARs to Spark default JAR path
if ls /opt/spark/jars/db-drivers/*.jar 1> /dev/null 2>&1; then
  DB_JARS=$(find /opt/spark/jars/db-drivers -name "*.jar" | tr '\n' ',')
  echo "spark.jars ${DB_JARS}" >> $CONFIG_FILE
  echo "Database drivers loaded: ${DB_JARS}"
fi

# Add user custom drivers
if ls /opt/spark/jars/custom/*.jar 1> /dev/null 2>&1; then
  EXISTING_JARS=$(grep "spark.jars" $CONFIG_FILE | cut -d ' ' -f 2)
  CUSTOM_JARS=$(find /opt/spark/jars/custom -name "*.jar" | tr '\n' ',')
  
  if [ ! -z "$EXISTING_JARS" ]; then
    # Append to existing JAR configuration
    sed -i "s|spark.jars.*|spark.jars ${EXISTING_JARS}${CUSTOM_JARS}|" $CONFIG_FILE
  else
    # Create new JAR configuration
    echo "spark.jars ${CUSTOM_JARS}" >> $CONFIG_FILE
  fi
  
  echo "Custom JARs loaded: ${CUSTOM_JARS}"
fi

# Process custom Spark configuration files
if [ -d "/opt/spark/conf/custom" ] && [ "$(ls -A /opt/spark/conf/custom)" ]; then
  echo "Applying custom Spark configurations"
  cp /opt/spark/conf/custom/* /opt/spark/conf/
fi

echo "Database configuration completed, saved to $CONFIG_FILE"

# Merge database configuration into spark-defaults.conf
if [ -f "$CONFIG_FILE" ]; then
  cat $CONFIG_FILE >> /opt/spark/conf/spark-defaults.conf
  echo "Database settings merged into spark-defaults.conf"
fi 