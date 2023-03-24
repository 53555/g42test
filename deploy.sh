#! /bin/bash
# Check if helm installed else Install
VERSION=0.1.0

function check_install_helm() {
  if ! command -v helm &> /dev/null; then
    echo "Helm not found. Installing..."
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    echo "Helm installed successfully."
  else
    echo "Helm already installed."
  fi
}


function package_and_deploy_es() {
  chart_path=$1
  release_name=$2
  namespace=$3
  values_file=$4

  # Package the chart
  helm package $chart_path

  # Install or upgrade the chart
  if helm status $release_name --namespace $namespace  &> /dev/null; then
    helm upgrade $release_name $chart_path --values $values_file --namespace $namespace
  else
    helm install $release_name $chart_path --values $values_file --namespace $namespace
  fi
  sleep 10
  rm -rf ${release_name}-${VERSION}.tgz
}

function package_and_deploy_myapp() {
  chart_path=$1
  release_name=$2
  namespace=$3
  values_file=$4

  # Package the chart
  helm package $chart_path

  # Install or upgrade the chart
  if helm status $release_name --namespace $namespace  &> /dev/null; then
    helm upgrade $release_name $chart_path --values $values_file --namespace $namespace
  else
    helm install $release_name $chart_path --values $values_file --namespace $namespace
  fi
  sleep 10
  rm -rf ${release_name}-${VERSION}.tgz
}

validate_endpoints() {
  url=$1

  echo "Validating /health endpoint..."
  health_response=$(curl -s -o /dev/null -w "%{http_code}" $url/health)
  if [ "$health_response" == "200" ]; then
    echo "Health check succeeded"
  else
    echo "Health check failed"
  fi

  echo "Validating /city endpoint..."
  city_response=$(curl -X POST -s -H "Content-Type: application/json" -d '{"city": "Bangalore", "population": 22000000}' $url/city)
  if [ "$city_response" == "UPDATED" ]; then
    echo "City population updated successfully"
  else
    echo "City population update failed"
  fi

  echo "Validating /city/Bangalore endpoint..."
  population_response=$(curl -s $url/city/Bangalore)
  population=$(echo $population_response | jq '.population')
  if [ "$population" == "22000000" ]; then
    echo "Population retrieved successfully"
  else
    echo "Population retrieval failed"
  fi
}

# Invoke the Functions
check_install_helm
package_and_deploy_es kubernetes/elasticsearch elasticsearch default kubernetes/elasticsearch/values.yaml
package_and_deploy_myapp kubernetes/myapp myapp default kubernetes/myapp/values.yaml

# Forward traffic to the application running inside Kubernetes
kubectl port-forward svc/myapp-myapp 5000 & &> /dev/null

# Wait for the port forward to establish
sleep 10

# Call the function to validate endpoints
validate_endpoints http://localhost:5000

# Kill the port forward
pkill kubectl

