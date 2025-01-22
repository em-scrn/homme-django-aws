# Homme - Django Application - Dockerised and deployed to AWS Infrastructure built with Terraform

## Project Overview

This project is a Django-based web application that is containerised using Docker and deployed to AWS. The infrastructure is managed using Terraform, with the following key components:

- **Database:** PostgreSQL hosted on Amazon RDS.
- **Static & Media Files:** Hosted on Amazon S3.
- **Container Registry:** Docker images stored on Amazon Elastic Container Registry (ECR).
- **Domain Management:** Fully integrated with Route 53 for DNS configuration.

## Features

- **Django Framework:** A robust backend for building web applications.
- **Dockerized Deployment:** Simplified setup and deployment process.
- **AWS Infrastructure:** Fully automated infrastructure setup using Terraform.
- **Domain Management:** Route 53 ensures seamless domain setup and certificate validation with ACM.

---

## Local Development Setup

### Prerequisites

Ensure you have the following installed on your local machine:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Environment Variables

Create a `.env` file in the project root with the following keys:

```env
SECRET_KEY=django-admin-secret-key
DB_PASSWORD=your-db-password

DB_NAME=your-db-name
DB_USER_NM=your-db-username
DB_USER_PW=your-db-password
DB_IP=your-db-endpoint
DB_PORT=5432

ECR_REPOSITORY_URL=your-ecr-app-url

AWS_S3_CUSTOM_DOMAIN=your-s3-bucket-url
```

---

## Running the Docker Image Locally

### 1. Build the Docker Image

If you have the source code, build the Docker image locally:

```bash
cd <path-to-django-project>
docker build -t django-aws .
```

### 2. Run the Docker Container

Run the container locally:

```bash
docker run -d -p 8000:8000 \
  -e SECRET_KEY="<your-secret-key>" \
  -e AWS_ACCESS_KEY_ID="<your-aws-access-key>" \
  -e AWS_SECRET_ACCESS_KEY="<your-aws-secret-key>" \
  -e AWS_STORAGE_BUCKET_NAME="<your-s3-bucket-name>" \
  homme-app
```

Replace the placeholder environment variables with your actual values.

### 3. Access the Application

Visit `http://localhost:8000/` in your browser to view the application.

---

## License

This project is licensed under the MIT License.
