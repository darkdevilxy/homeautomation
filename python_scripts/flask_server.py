from flask import Flask
import light_control
from flask_cors import CORS

app = Flask(__name__)
CORS(app)


@app.route('/turn-on', methods=['POST'])
def turn_on_light():
    print("Light ON")
    light_control.light_control('on')
    return {"status": "Light turned on"}, 200

@app.route('/turn-off', methods=['POST'])
def turn_off_light():
    light_control.light_control('off')
    return {"status": "Light turned off"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)  # Run on all interfaces, port 5000
