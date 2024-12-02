from flask import Flask
from database import init_db

def create_app():
    """
    Factory para criar e configurar a aplicação Flask.
    """
    app = Flask(__name__)

    # Configurações gerais
    app.config.from_pyfile('../config.py')

    # Inicializar banco de dados
    init_db(app)

    # Registrar rotas
    with app.app_context():
        from .routes import bp
        app.register_blueprint(bp)

    return app
