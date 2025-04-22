# Spark-Minimal: Lightweight PySpark Development Environment

This Docker image provides a lightweight development environment with Python 3.9 and Apache Spark 3.5.2, supporting remote connection via SSH, ideal for data analysis and machine learning projects. It is designed for quickly launching Spark services locally while maintaining a clean environment and isolation from your system dependencies, making it perfect for development, testing, and learning purposes.

---

For questions or suggestions for improvement, please contact me on [GitHub](https://github.com/lightconeSpace/spark-minimal) or [DockerHub](https://hub.docker.com/r/lightcone0204/spark-minimal). 

---

## 📋 Component Versions

- **Apache Spark**: 3.5.2 with Hadoop 3
- **Python**: 3.9.18
- **JDK/JRE**: OpenJDK 11
- **OS**: Debian 11 (slim)
- **Database Drivers**: MySQL, PostgreSQL, MS SQL Server, MongoDB, Oracle

## 🚀 Quick Start

### Basic Usage

```bash
docker run -d -p 8822:22 --name spark-container lightcone0204/spark-minimal:latest
```

### Mounting Local Directory

```bash
docker run -d -p 8822:22 -v /local/path:/app/data --name spark-container lightcone0204/spark-minimal:latest
```

### SSH Connection to Container

```bash
ssh root@localhost -p 8822
# Password: spark
```

## 🗄️ Database Connection

The image comes with pre-installed database drivers and connectors that are automatically loaded, allowing you to connect to various databases:

### Connection in Code

You can specify connection details directly in your code:

```python
from pyspark.sql import SparkSession

jar_path = "/opt/spark/jars/db-drivers/mysql-connector.jar"
driver_name = "com.mysql.cj.jdbc.Driver"

# Create SparkSession
spark = SparkSession.builder \
    .appName("Database Connection") \
    .config("spark.jars", jar_path) \
    .getOrCreate()

# Connect to MySQL 
jdbc_url = "jdbc:mysql://your-db-server:3306/your_database" # If your are using local db, your db host should be docker0 ip 172.17.0.1, not localhost.
jdbc_properties = {
    "user": "username",
    "password": "password",
    "driver": driver_name
}

# Read data
df = spark.read.jdbc(url=jdbc_url, table="your_table", properties=jdbc_properties)
```

### Available Database Drivers

The following drivers are pre-installed:

- **MySQL**: jar_path="/opt/spark/jars/db-drivers/mysql-connector.jar",  driver_name="com.mysql.cj.jdbc.Driver"
- **PostgreSQL**: jar_path="/opt/spark/jars/db-drivers/postgresql-connector.jar",  driver_name="org.postgresql.Driver"
- **MS SQL Server**: jar_path="/opt/spark/jars/db-drivers/mssql-connector.jar",  driver_name="com.microsoft.sqlserver.jdbc.SQLServerDriver"
- **Oracle**: jar_path="/opt/spark/jars/db-drivers/oracle-connector.jar",  driver_name="oracle.jdbc.driver.OracleDriver"
- **MongoDB**: jar_path="/opt/spark/jars/db-drivers/mongodb-connector.jar",  driver_name="org.mongodb.spark.sql.connector.MongoTableProvider"

### Using Custom Database Drivers

```bash
docker run -d -p 8822:22 \
  -v /path/to/your/drivers:/opt/spark/jars/custom \
  --name spark-container lightcone0204/spark-minimal:latest
```

## 💻 Usage Examples

### Run PySpark Interactive Environment

```bash
docker exec -it spark-container pyspark
```

### Submit Spark Applications

Save your script in the mounted directory, then execute:

```bash
docker exec -it spark-container spark-submit /app/data/your_script.py
```

### Example Script (Save as `/app/data/test.py`)

```python
from pyspark.sql import SparkSession

# Create SparkSession
spark = SparkSession.builder \
    .appName("SimpleExample") \
    .getOrCreate()

# Create simple data
data = [("Spark", 2022), ("Python", 3.9), ("Analysis", 100)]
df = spark.createDataFrame(data, ["Name", "Version"])

# Display data
print("Data Preview:")
df.show()

# Stop SparkSession
spark.stop()
```

## 🔄 Data Analysis Workflow

1. **Mount Local Data Directory**:
   ```bash
   docker run -d -p 8822:22 -v /local/data/dir:/app/data --name spark-container lightcone0204/spark-minimal
   ```

2. **Place Data Files in Mounted Directory**:
   Copy CSV, JSON, or Parquet files to your local mounted directory

3. **Write and Run Spark Code**:
   ```python
   from pyspark.sql import SparkSession
   
   spark = SparkSession.builder.appName("DataAnalysis").getOrCreate()
   df = spark.read.csv("/app/data/your_file.csv", header=True, inferSchema=True)
   df.printSchema()
   df.show(5)
   
   # Process data...
   
   result = df.groupBy("category").count()
   result.write.parquet("/app/data/results.parquet")
   ```

## 🔌 IDE Integration

### PyCharm Configuration - Detailed Guide

#### Prerequisites
- PyCharm Professional Edition (SSH interpreters are not available in Community Edition)
- Docker container running from this image
- SSH port exposed (e.g., 8822)

#### Step 1: Open Project Settings
1. Open your PyCharm project
2. Navigate to **File → Settings** (Windows/Linux) or **PyCharm → Preferences** (macOS)
3. In the Settings/Preferences dialog, select **Project → Python Interpreter**

#### Step 2: Add SSH Interpreter
1. Click the gear icon ⚙️ next to the Python Interpreter dropdown
2. Select **Add...** from the dropdown menu
3. In the left panel of the "Add Python Interpreter" dialog, select **SSH Interpreter**
4. Choose **New server configuration**

#### Step 3: Configure SSH Connection
Configure the SSH connection details:
- **Host**: `localhost` (or your server IP if running on remote machine)
- **Port**: `8822` (or your custom SSH port)
- **Username**: `root`
- **Authentication type**: Password
- **Password**: `spark`
- Click **Next**

#### Step 4: Set Python Interpreter Path
1. In the next screen, for **Python interpreter path**, enter: `/usr/bin/python`
2. Click **Next**

#### Step 5: Configure Path Mappings
1. In the path mappings screen, set up the synchronization between your local project and the container:
   - **Local path**: `/path/to/your/local/project`
   - **Remote path**: `/app/data`
   - If you mounted a volume using `-v /local/path:/app/data`, ensure your path mappings reflect this

2. Click **Finish**

#### Step 6: Verify Interpreter
1. Wait for PyCharm to complete the interpreter setup and indexing
2. You should see the interpreter listed as "Python 3.9 (Remote SSH)" or similar
3. In the interpreter details, you should see PySpark and related packages

#### Step 7: Configure Run Configuration
1. Go to **Run → Edit Configurations...**
2. Click the **+** button and select **Python**
3. Configure your run settings:
   - **Script path**: Select your Python script
   - **Python interpreter**: Select the SSH interpreter you just created
   - **Working directory**: Set to your project directory

#### Step 8: Running PySpark Code
1. Open or create a Python file with PySpark code (like the example above)
2. Right-click in the editor and select **Run**
3. PyCharm will execute the code on the remote SSH interpreter in the Docker container

## 🛠️ Advanced Configuration

### Environment Variables

```bash
docker run -d -p 8822:22 -e PYSPARK_DRIVER_MEMORY=2g --name spark-container lightcone0204/spark-minimal:latest
```

### Custom Spark Configuration

Mount Spark configuration directory:
```bash
docker run -d -p 8822:22 -v /local/spark/conf:/opt/spark/conf/custom --name spark-container lightcone0204/spark-minimal:latest
```

### Persistent Spark History Server

```bash
docker run -d -p 8822:22 -p 18080:18080 -v /local/history/dir:/spark-events --name spark-container lightcone0204/spark-minimal:latest
```

## 📝 Notes

- Default SSH password is `spark`
- You may see warnings about native Hadoop libraries in the container, which won't affect most applications
- This image is optimized for local development and analysis, not recommended for production deployment
- Database drivers are always loaded automatically
- Connection details can be provided directly in your code

## 🔗 Related Links

- [Apache Spark Official Documentation](https://spark.apache.org/docs/latest/)
- [PySpark API Documentation](https://spark.apache.org/docs/latest/api/python/index.html)
- [Spark JDBC Programming Guide](https://spark.apache.org/docs/latest/sql-data-sources-jdbc.html)

## 📄 License

Released under Apache License 2.0