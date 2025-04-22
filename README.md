# Spark-Minimal: Lightweight PySpark Development Environment

This Docker image provides a lightweight development environment with Python 3.9 and Apache Spark 3.5.2, supporting remote connection via SSH, ideal for data analysis and machine learning projects. It is designed for quickly launching Spark services locally while maintaining a clean environment and isolation from your system dependencies, making it perfect for development, testing, and learning purposes.

## 📋 Component Versions

- **Apache Spark**: 3.5.2 with Hadoop 3
- **Python**: 3.9.18
- **JDK/JRE**: OpenJDK 11
- **OS**: Debian 11 (slim)

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

### PyCharm Configuration

1. Add SSH interpreter in PyCharm
2. Host: `localhost`, Port: `8822`
3. Username: `root`, Password: `spark`
4. Python interpreter path: `/usr/bin/python`

## 🛠️ Advanced Configuration

### Environment Variables

```bash
docker run -d -p 8822:22 -e PYSPARK_DRIVER_MEMORY=2g --name spark-container lightcone0204/spark-minimal:latest
```

### Custom Spark Configuration

Mount Spark configuration directory:
```bash
docker run -d -p 8822:22 -v /local/spark/conf:/opt/spark/conf --name spark-container lightcone0204/spark-minimal:latest
```

### Persistent Spark History Server

```bash
docker run -d -p 8822:22 -p 18080:18080 -v /local/history/dir:/spark-events --name spark-container lightcone0204/spark-minimal:latest
```

## 📝 Notes

- Default SSH password is `spark`
- You may see warnings about native Hadoop libraries in the container, which won't affect most applications
- This image is optimized for local development and analysis, not recommended for production deployment

## 🔗 Related Links

- [Apache Spark Official Documentation](https://spark.apache.org/docs/latest/)
- [PySpark API Documentation](https://spark.apache.org/docs/latest/api/python/index.html)

## 📄 License

Released under Apache License 2.0

---

For questions or suggestions for improvement, please contact me on GitHub or DockerHub. 