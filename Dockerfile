# Base image
FROM python:3.13.1-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

WORKDIR /app

COPY . /app/ 

# Install dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Command to run the application with Gunicornz
CMD ["gunicorn", "django_aws.wsgi:application", "--bind", "0.0.0.0:8080"]

EXPOSE ${PORT}