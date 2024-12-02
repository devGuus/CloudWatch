from flask import current_app

def execute_query(query, params=None):
    """
    Executa uma consulta SQL e retorna o resultado.
    """
    connection = current_app.config['DB_CONN']
    with connection.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute(query, params)
        return cursor.fetchall()

def get_devices():
    """
    Consulta a lista de dispositivos e seus responsáveis.
    """
    query = """
    SELECT 
        devices.id AS device_id,
        devices.name AS device_name,
        devices.location AS device_location,
        users.name AS user_name
    FROM devices
    INNER JOIN users ON devices.user_id = users.id;
    """
    return execute_query(query)

def get_temperature_readings():
    """
    Consulta as últimas leituras de temperatura.
    """
    query = """
    SELECT 
        devices.name AS device_name,
        MAX(temperature_readings.recorded_at) AS last_recorded_at,
        temperature_readings.temperature
    FROM temperature_readings
    INNER JOIN devices ON temperature_readings.device_id = devices.id
    GROUP BY devices.name, temperature_readings.temperature;
    """
    return execute_query(query)

def get_alerts():
    """
    Consulta alertas críticos de temperatura.
    """
    query = """
    SELECT 
        devices.name AS device_name,
        alerts.alert_type,
        alerts.threshold_value,
        alerts.triggered_at
    FROM alerts
    INNER JOIN devices ON alerts.device_id = devices.id
    WHERE alerts.alert_type = 'temperature';
    """
    return execute_query(query)

def get_summary():
    """
    Consulta um resumo geral do sistema.
    """
    query = """
    SELECT 
        (SELECT COUNT(*) FROM devices) AS total_devices,
        (SELECT COUNT(*) FROM temperature_readings) AS total_readings,
        (SELECT COUNT(*) FROM alerts) AS total_alerts,
        (SELECT COUNT(*) FROM maintenance_logs) AS total_maintenances;
    """
    results = execute_query(query)
    return results[0]


DB_NAME = "nome_do_banco"
DB_USER = "usuario"
DB_PASSWORD = "senha"
DB_HOST = "localhost"
DB_PORT = "5432"
