from flask import Blueprint, jsonify
from .models import get_devices, get_temperature_readings, get_alerts, get_summary

bp = Blueprint('api', __name__)

@bp.route('/devices', methods=['GET'])
def devices():
    return jsonify(get_devices())

@bp.route('/temperature-readings', methods=['GET'])
def temperature_readings():
    return jsonify(get_temperature_readings())

@bp.route('/alerts', methods=['GET'])
def alerts():
    return jsonify(get_alerts())

@bp.route('/summary', methods=['GET'])
def summary():
    return jsonify(get_summary())
