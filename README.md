# Homme - Django Application - Dockerised and deployed to AWS Infrastructure built with Terraform

This project is a Python-based web application built with Django. It is designed to be scalable, secure, and cloud-native, leveraging Docker for containerisation and Terraform for infrastructure management on AWS. The application uses RDS for its database, S3 for storing static files, and Route 53 for domain management.

## Project Features

1. **Django Application**:
   - A Python-based web application using the Django framework.
   - Includes dynamic content generation and a basic e-commerce-like structure.

2. **Dockerised Deployment**:
   - The application is containerized with Docker for portability and ease of deployment.

3. **Infrastructure as Code**:
   - Infrastructure is provisioned and managed using Terraform.
   - Components include VPC, subnets, security groups, EC2 instances, RDS, S3, and more.

4. **Database**:
   - Uses Amazon RDS with PostgreSQL for database management.
   - Ensures reliability, scalability, and security.

5. **Static Files Hosting**:
   - Static files (e.g., CSS, JavaScript) are stored and served from an AWS S3 bucket.
   - Media files uploaded through the application are also stored in S3.

6. **Domain Management**:
   - DNS management is handled via Route 53.
   - Includes SSL certificates managed by AWS Certificate Manager (ACM) for secure HTTPS communication.

---

## Infrastructure Overview

### AWS Services Used

- **EC2**: Hosts the Dockerized Django application.
- **RDS**: PostgreSQL database backend.
- **S3**: Stores static and media files.
- **ACM**: Provides SSL certificates for secure HTTPS communication.
- **Route 53**: Manages DNS records for the domain.

### Key Terraform Resources

1. **Networking**:
   - Virtual Private Cloud (VPC) with public and private subnets.
   - Security groups for EC2 and ALB to manage traffic flow.

2. **Domain Management**:
   - DNS records configured in Route 53 for the domain and subdomain.
   - SSL certificate provisioned with ACM for HTTPS.

3. **Compute**:
   - Auto-scaling groups with launch templates for EC2 instances.
   - Dockerized application runs on these instances.

4. **Storage**:
   - S3 buckets for static and media files.
   - Database hosted on RDS for reliable and scalable data storage.

---

## Application Details

- **Framework**: Django 5.1.4
- **Database**: PostgreSQL
- **Static/Media Storage**: AWS S3
- **Load Balancer**: Application Load Balancer (HTTPS)
- **Monitoring**: AWS CloudWatch
- **Domain**: Managed via AWS Route 53

### Key Features

- Dynamic web pages with Django templates and views.
- Secure HTTPS communication using ACM.
- Scalable backend infrastructure with AWS Auto Scaling.

---

## Live Demo

You can access the live project here: [https://homme.co.nz/](https://homme.co.nz/)

---

## License

This project is open-source and available under the [MIT License](LICENSE).
