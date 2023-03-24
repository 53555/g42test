# g42test

# Python Flask Application with Elasticsearch Backend

This is a simple web application that allows users to search for cities and view their population data. The application uses Elasticsearch as its backend database to store and search for city data.

## Requirements
* Python 3.6 or higher
* Elasticsearch 7.10.2 
* Flask 2.0.2 or higher
* Elasticsearch module for Python 7.10.2 

## Deployment of Elasticsearch on Kubernetes using Helm
1. Clone the repository
```sh
git clone https://github.com/53555/g42test.git
```
2. package the Elasticsearch using helm
```sh
cd g42test/kubernetes/elasticsearch
helm package .
```
3. deploy the Elasticsearch package on kubernetes
```sh
helm install elasticsearch elasticsearch-0.1.0.tgz
```
4. Validate Elasticsearch
```sh
kubectl get po
```
make sure elasticsearch pod up and running fine. Run the below commands to validate elasticsearch health
```sh
kubectl port-forward svc/elasticsearch 9200
curl -XGET 'http://localhost:9200/_cluster/health?pretty=true'
```
by running the above commands, cluster heath status can be retrived and status should be green.

## Deployment of myapp(city/population) on Kubernetes using Helm

1. Clone the repository
```sh
git clone https://github.com/53555/g42test.git
```
2. package the myapp using helm
```sh
cd g42test/kubernetes/myapp
helm package .
```
3. deploy the myapp package on kubernetes
```sh
helm install myapp ./myapp-0.1.0.tgz
```
4. Validate myapp
```sh
kubectl get po
```
make sure myapp pod up and running fine.

## Usage

Here's what each endpoint does:

* `/health:` Returns 'OK' to indicate that the application is running.
```sh
curl http://localhost:5000/health
```
* `/city:` Accepts a POST request with two parameters: city and population. It stores or updates the population of the specified city in Elasticsearch.
```sh
curl -X POST -H "Content-Type: application/json" -d '{"city": "Bangalore", "population": 22000000}' http://localhost:5000/city
```
* `/city/<city>:` Accepts a GET request with a single parameter: city. It retrieves the population of the specified city from Elasticsearch and returns it.
```sh
curl http://localhost:5000/city/Bangalore
```

## Deploying myapp with Elasticsearch as docker container
1. Deploy Elasticsearch
```sh
docker run -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.10.2
```
2. Deploy myapp
```sh
docker run -d --name myapp -p 5000:5000 -e ELASTICSEARCH_HOST=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' elasticsearch) myapp
```
3. Access the application (usage)

* `/health:` Returns 'OK' to indicate that the application is running.
```sh
curl http://localhost:5000/health
```
* `/city:` Accepts a POST request with two parameters: city and population. It stores or updates the population of the specified city in Elasticsearch.
```sh
curl -X POST -H "Content-Type: application/json" -d '{"city": "Bangalore", "population": 22000000}' http://localhost:5000/city
```
* `/city/<city>:` Accepts a GET request with a single parameter: city. It retrieves the population of the specified city from Elasticsearch and returns it.
```sh
curl http://localhost:5000/city/Bangalore
```

