# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install dependencies
RUN pip install Flask psycopg2-binary

# Copy the content of the local src directory to the working directory
COPY src/ . 

# Specify the command to run on container startup
CMD ["python", "app.py"]
