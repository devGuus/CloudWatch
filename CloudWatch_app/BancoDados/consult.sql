-- Consulta 1: Listar todos os dispositivos cadastrados e seus responsáveis
-- Isso mostra cada freezer ou geladeira, juntamente com o nome do usuário que o gerencia.
SELECT 
    devices.id AS device_id, 
    devices.name AS device_name, 
    devices.location AS device_location, 
    users.name AS user_name
FROM 
    devices
INNER JOIN 
    users ON devices.user_id = users.id;

-- Explicação:
-- Usamos INNER JOIN para conectar as tabelas `devices` e `users` pelo campo `user_id`.
-- Isso permite exibir informações sobre o dispositivo e o responsável por ele.

---------------------------------------

-- Consulta 2: Listar as últimas leituras de temperatura para cada dispositivo
-- Exibe o dispositivo, sua última temperatura registrada e o horário da leitura.
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

-- Explicação:
-- A função `MAX` retorna o registro mais recente de leitura de temperatura.
-- O `GROUP BY` agrupa os dados por dispositivo, exibindo a leitura mais recente.

---------------------------------------

-- Consulta 3: Consultar alertas críticos de temperatura
-- Mostra dispositivos que dispararam alertas de temperatura junto com o valor limite e quando ocorreu.
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

-- Explicação:
-- Filtramos alertas que são apenas do tipo `temperature`.
-- A consulta exibe o nome do dispositivo, o valor que acionou o alerta e a data/hora do alerta.

---------------------------------------

-- Consulta 4: Listar eventos de abertura e fechamento de portas
-- Registra quantas vezes a porta foi aberta ou fechada por dispositivo, dentro de um período de tempo.
SELECT 
    devices.name AS device_name, 
    door_events.event_type, 
    COUNT(door_events.event_type) AS event_count, 
    MIN(door_events.event_time) AS first_event, 
    MAX(door_events.event_time) AS last_event
FROM 
    door_events
INNER JOIN 
    devices ON door_events.device_id = devices.id
WHERE 
    door_events.event_time BETWEEN '2023-11-01' AND '2023-11-30'
GROUP BY 
    devices.name, door_events.event_type;

-- Explicação:
-- Contamos quantos eventos de abertura e fechamento ocorreram para cada dispositivo.
-- Os filtros no WHERE limitam a análise ao mês de novembro, e o GROUP BY organiza por dispositivo.

---------------------------------------

-- Consulta 5: Listar logs de manutenção realizados
-- Mostra as manutenções realizadas, detalhando o técnico, descrição e o dispositivo.
SELECT 
    maintenance_logs.id AS log_id, 
    devices.name AS device_name, 
    users.name AS technician_name, 
    maintenance_logs.description, 
    maintenance_logs.maintenance_date
FROM 
    maintenance_logs
INNER JOIN 
    devices ON maintenance_logs.device_id = devices.id
LEFT JOIN 
    users ON maintenance_logs.performed_by = users.id;

-- Explicação:
-- Conectamos as tabelas `maintenance_logs`, `devices` e `users` para exibir detalhes de manutenções.
-- Um LEFT JOIN é usado entre `maintenance_logs` e `users` porque a manutenção pode ser registrada sem técnico associado.

---------------------------------------

-- Consulta 6: Resumo geral: quantidade de dispositivos, leituras, alertas e manutenções
-- Um dashboard resumido para mostrar números gerais sobre o sistema.
SELECT 
    (SELECT COUNT(*) FROM devices) AS total_devices,
    (SELECT COUNT(*) FROM temperature_readings) AS total_readings,
    (SELECT COUNT(*) FROM alerts) AS total_alerts,
    (SELECT COUNT(*) FROM maintenance_logs) AS total_maintenances;

-- Explicação:
-- Subconsultas (`SELECT COUNT(*)`) são usadas para contar registros de cada tabela.
-- Isso fornece uma visão geral rápida do sistema.

---------------------------------------

-- Consulta 7: Relatório detalhado por dispositivo
-- Um relatório completo com informações sobre dispositivos, últimas leituras e eventos recentes.
SELECT 
    devices.name AS device_name, 
    users.name AS user_name, 
    MAX(temperature_readings.recorded_at) AS last_temperature_reading, 
    COUNT(door_events.id) AS total_door_events, 
    COUNT(alerts.id) AS total_alerts
FROM 
    devices
LEFT JOIN 
    temperature_readings ON devices.id = temperature_readings.device_id
LEFT JOIN 
    door_events ON devices.id = door_events.device_id
LEFT JOIN 
    alerts ON devices.id = alerts.device_id
INNER JOIN 
    users ON devices.user_id = users.id
GROUP BY 
    devices.name, users.name;
