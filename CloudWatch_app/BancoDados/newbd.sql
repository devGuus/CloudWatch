-- Tabela para armazenar informações dos usuários
-- Inclui dados básicos (nome, e-mail, senha) e o tipo de usuário (admin, técnico, externo)
CREATE TABLE users (
    id SERIAL PRIMARY KEY, -- Identificador único para cada usuário
    name VARCHAR(100) NOT NULL, -- Nome do usuário
    email VARCHAR(100) UNIQUE NOT NULL, -- E-mail único para login
    password VARCHAR(255) NOT NULL, -- Senha do usuário (criptografada na aplicação)
    role ENUM('admin', 'technician', 'external') NOT NULL -- Tipo de usuário
);

-- Tabela para armazenar os dispositivos (freezers/geladeiras) monitorados
-- Relacionada à tabela de usuários para identificar quem gerencia cada dispositivo
CREATE TABLE devices (
    id SERIAL PRIMARY KEY, -- Identificador único para cada dispositivo
    name VARCHAR(100) NOT NULL, -- Nome do dispositivo (e.g., Freezer 1)
    location VARCHAR(100), -- Local onde o dispositivo está instalado
    user_id INT REFERENCES users(id) ON DELETE CASCADE -- Relacionamento com o usuário responsável
);

-- Tabela para armazenar as leituras de temperatura coletadas pelos sensores
-- Relacionada à tabela de dispositivos
CREATE TABLE temperature_readings (
    id SERIAL PRIMARY KEY, -- Identificador único para cada leitura
    device_id INT REFERENCES devices(id) ON DELETE CASCADE, -- Relacionamento com o dispositivo que gerou a leitura
    temperature FLOAT NOT NULL, -- Valor da temperatura coletada
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Data e hora da coleta
);

-- Tabela para registrar eventos de abertura e fechamento de portas
-- Relacionada à tabela de dispositivos
CREATE TABLE door_events (
    id SERIAL PRIMARY KEY, -- Identificador único para cada evento
    device_id INT REFERENCES devices(id) ON DELETE CASCADE, -- Relacionamento com o dispositivo que registrou o evento
    event_type ENUM('open', 'close') NOT NULL, -- Tipo do evento (abertura ou fechamento)
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Data e hora do evento
);

-- Tabela para registrar alertas disparados pelo sistema
-- Relacionada à tabela de dispositivos
CREATE TABLE alerts (
    id SERIAL PRIMARY KEY, -- Identificador único para cada alerta
    device_id INT REFERENCES devices(id) ON DELETE CASCADE, -- Relacionamento com o dispositivo associado ao alerta
    alert_type ENUM('temperature', 'door') NOT NULL, -- Tipo do alerta (temperatura ou evento de porta)
    threshold_value FLOAT, -- Valor limite que acionou o alerta
    triggered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Data e hora em que o alerta foi acionado
);

-- Tabela opcional para registrar logs de manutenção realizados nos dispositivos
-- Relacionada à tabela de dispositivos
CREATE TABLE maintenance_logs (
    id SERIAL PRIMARY KEY, -- Identificador único para cada log de manutenção
    device_id INT REFERENCES devices(id) ON DELETE CASCADE, -- Relacionamento com o dispositivo que recebeu a manutenção
    performed_by INT REFERENCES users(id) ON DELETE SET NULL, -- Usuário (técnico) que realizou a manutenção
    description TEXT NOT NULL, -- Descrição detalhada da manutenção realizada
    maintenance_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Data e hora da manutenção
);
