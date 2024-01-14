FROM python:3.9 as mlflow_server

RUN pip install mlflow==2.9.2
RUN pip install psycopg2==2.9.9
RUN pip install boto3==1.34.15

# Set the working directory in the container
WORKDIR /mlflow

ENV MLFLOW_TRACKING_URI=postgresql://postgres:postgres@postgreSQL-server:5432/mlflow_db
ENV MINIO_S3_ENDPOINT_URL=http://127.0.0.1:9000
ENV AWS_ACCESS_KEY_ID=raghava_minioS3
ENV AWS_SECRET_ACCESS_KEY=Strong_Password@1234

# Command to run MLflow UI with the specified path prefix
CMD mlflow server \
--host 0.0.0.0 \
--port 5000 \
--artifacts-destination s3://mlflow-bucket \
--backend-store-uri postgresql://postgres:postgres@postgreSQL-server:5432/mlflow_db


# Use the official PostgresSQL image as the base image
FROM postgres:13 as postgresql_server

# Set environment variables
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=mlflow_db

# Create a volume for PostgresSQL data
VOLUME /var/lib/postgresql/data

# Expose PostgresSQL port
EXPOSE 5432

# Use the official MinIO image as the base image
FROM minio/minio as minio_s3_server

# Set environment variables
ENV MINIO_ROOT_USER=raghava_minioS3
ENV MINIO_ROOT_PASSWORD=Strong_Password@1234

# Expose MinIO ports
EXPOSE 9000
EXPOSE 9001

# Create a volume for MinIO data
VOLUME /data

# Specify the command to start MinIO server
CMD ["server", "--console-address", ":9001", "/data"]
