FROM python:3.8-slim-buster

# Install any necessary system packages
RUN apt-get update && apt-get install -y libpq-dev gcc curl iputils-ping net-tools

# Set the working directory
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the required Python modules
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code into the container
COPY . .

# Set the environment variables
ENV ELASTICSEARCH_HOST=localhost
ENV ELASTICSEARCH_PORT=9200

# Run the application
CMD ["python", "app.py"]
