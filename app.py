from flask import Flask, jsonify, request
from elasticsearch import Elasticsearch
import os

elasticsearch = os.environ.get('ELASTICSEARCH_HOST')

app = Flask(__name__)
es = Elasticsearch([elasticsearch+':9200'])

@app.route('/health')
def health():
    return 'OK'

@app.route('/city', methods=['POST'])
def add_or_update_city():
    city = request.json['city']
    population = request.json['population']
    es.index(index='cities', id=city, body={'population': population})
    return 'UPDATED'

@app.route('/city/<city>', methods=['GET'])
def get_city_population(city):
    res = es.get(index='cities', id=city)
    return jsonify({'city': city, 'population': res['_source']['population']})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
