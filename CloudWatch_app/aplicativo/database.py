import psycopg2
from psycopg2.extras import RealDictCursor

def init_db(app):
    """
    Configura a conexão ao banco de dados.
    """
    app.config['DB_CONN'] = psycopg2.connect(
        dbname=app.config['DB_NAME'],
        user=app.config['DB_USER'],
        password=app.config['DB_PASSWORD'],
        host=app.config['DB_HOST'],
        port=app.config['DB_PORT']
    )

def get_db_connection(app):
    """
    Retorna uma nova conexão com o banco de dados.
    """
    return app.config['DB_CONN']
