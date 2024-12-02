from flask import Flask, jsonify
import psycopg2
from psycopg2 import sql

app = Flask(__name__)

# Configurações do banco de dados
DB_CONFIG = {
    "dbname": "nome_do_banco",
    "user": "usuario",
    "password": "senha",
    "host": "localhost",
    "port": "5432"
}

# Função para conectar ao banco de dados
def connect_to_db():
    """
    Estabelece a conexão com o banco de dados PostgreSQL.
    """
    try:
        connection = psycopg2.connect(**DB_CONFIG)
        cursor = connection.cursor()
        return connection, cursor
    except Exception as e:
        print(f"Erro ao conectar ao banco: {e}")
        return None, None

# Função para executar consultas
def execute_query(query, params=None):
    """
    Executa uma consulta SQL e retorna os resultados.
    """
    connection, cursor = connect_to_db()
    if not connection or not cursor:
        return None

    try:
        cursor.execute(query, params)
        results = cursor.fetchall()
        return results
    except Exception as e:
        print(f"Erro ao executar consulta: {e}")
        return None
    finally:
        cursor.close()
        connection.close()

# Endpoint: Dispositivos e responsáveis
@app.route('/devices', methods=['GET'])
def get_devices():
    """
    Endpoint que retorna a lista de dispositivos e seus responsáveis.
    """
    query = """
    SELECT 
        devices.id AS device_id, 
        devices.name AS device_name, 
        devices.location AS device_location, 
        users.name AS user_name
    FROM 
        devices
    INNER JOIN 
        users ON devices.user_id = users.id;
    """
    results = execute_query(query)
    if results is None:
        return jsonify({"error": "Erro ao buscar dispositivos"}), 500

    devices = [
        {
            "device_id": row[0],
            "device_name": row[1],
            "device_location": row[2],
            "user_name": row[3]
        } for row in results
    ]
    return jsonify(devices)

# Endpoint: Últimas leituras de temperatura
@app.route('/temperature-readings', methods=['GET'])
def get_temperature_readings():
    """
    Endpoint que retorna as últimas leituras de temperatura.
    """
    query = """
    SELECT 
        devices.name AS device_name, 
        MAX(temperature_readings.recorded_at) AS last_recorded_at, 
        temperature_readings.temperature
    FROM 
        temperature_readings
    INNER JOIN 
        devices ON temperature_readings.device_id = devices.id
    GROUP BY 
        devices.name, temperature_readings.temperature;
    """
    results = execute_query(query)
    if results is None:
        return jsonify({"error": "Erro ao buscar leituras de temperatura"}), 500

    readings = [
        {
            "device_name": row[0],
            "last_recorded_at": row[1],
            "temperature": row[2]
        } for row in results
    ]
    return jsonify(readings)

# Endpoint: Alertas críticos de temperatura
@app.route('/alerts', methods=['GET'])
def get_alerts():
    """
    Endpoint que retorna alertas críticos de temperatura.
    """
    query = """
    SELECT 
        devices.name AS device_name, 
        alerts.alert_type, 
        alerts.threshold_value, 
        alerts.triggered_at
    FROM 
        alerts
    INNER JOIN 
        devices ON alerts.device_id = devices.id
    WHERE 
        alerts.alert_type = 'temperature';
    """
    results = execute_query(query)
    if results is None:
        return jsonify({"error": "Erro ao buscar alertas"}), 500

    alerts = [
        {
            "device_name": row[0],
            "alert_type": row[1],
            "threshold_value": row[2],
            "triggered_at": row[3]
        } for row in results
    ]
    return jsonify(alerts)

# Endpoint: Resumo geral
@app.route('/summary', methods=['GET'])
def get_summary():
    """
    Endpoint que retorna um resumo geral do sistema.
    """
    query = """
    SELECT 
        (SELECT COUNT(*) FROM devices) AS total_devices,
        (SELECT COUNT(*) FROM temperature_readings) AS total_readings,
        (SELECT COUNT(*) FROM alerts) AS total_alerts,
        (SELECT COUNT(*) FROM maintenance_logs) AS total_maintenances;
    """
    results = execute_query(query)
    if results is None:
        return jsonify({"error": "Erro ao buscar resumo"}), 500

    summary = {
        "total_devices": results[0][0],
        "total_readings": results[0][1],
        "total_alerts": results[0][2],
        "total_maintenances": results[0][3]
    }
    return jsonify(summary)

# Inicia o servidor Flask
if __name__ == '__main__':
    app.run(debug=True)
