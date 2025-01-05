# Homme Django Project

This is the `Homme` Django-based e-commerce application, designed to showcase and sell earrings. The application uses AWS S3 for static and media file storage, and the infrastructure can be deployed to AWS using Terraform. The application is containerized using Docker for easy deployment.

## Features
- Django-based backend
- Admin interface for managing earrings
- Static and media file hosting on AWS S3
- Dockerized application for streamlined deployment

## Prerequisites
- [Docker](https://www.docker.com/get-started) installed on your machine
- AWS CLI configured with necessary permissions to access S3 and ECR
- An AWS S3 bucket set up for `static` and `media` files

---

## Running the Docker Image Locally

### 1. Build the Docker Image
If you have the source code, build the Docker image locally:
```bash
cd <path-to-homme-project>
docker build -t homme-app .
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

## Project Structure
```
homme-website/
|
├── homme/               # Django project folder
│   ├── homme/           # Settings, URLs, WSGI
│   ├── shop/            # E-commerce app
│   └── templates/       # HTML templates
|
├── static/              # Static files
├── media/               # Media files (uploaded images)
├── Dockerfile           # Docker configuration
├── requirements.txt     # Python dependencies
└── terraform/           # Terraform configuration for AWS
```

---

## Environment Variables
The following environment variables are required to run the application:
- `SECRET_KEY`: Django secret key
- `AWS_ACCESS_KEY_ID`: AWS access key ID
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key
- `AWS_STORAGE_BUCKET_NAME`: Name of the S3 bucket for static and media files

---

## Using Terraform for AWS Infrastructure
Terraform configuration files are stored in the `terraform/` directory. To deploy the infrastructure:

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Validate the configuration:
   ```bash
   terraform validate
   ```

3. Plan the infrastructure:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

---

## Deployment to AWS
1. Push the Docker image to AWS ECR.
2. Deploy the application using the Terraform-managed EC2 instance or ECS.
3. Ensure the static and media files are correctly stored in your S3 bucket.

---

## Troubleshooting

### Common Issues
- **Static files not loading**: Ensure `collectstatic` has been run and the files are present in the `static/` folder of your S3 bucket.
- **Media files not uploading**: Verify S3 permissions and the `MEDIA_URL` configuration in `settings.py`.
- **500 Server Error**: Check the logs for detailed error messages.
  ```bash
  docker logs <container-id>
  ```

---

## License
This project is licensed under the MIT License.

