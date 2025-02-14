import requests
import time

# Parameters
server_uri = 'shelly-129-eu.shelly.cloud'
device_id = '4091515803af'
auth_key = 'Mjk2ODM4dWlkD5CF0B9A85CDDE9ABDA887B4783CCB1D6DB25A2A7303E7D8F7BEE96988A7F332A23D70C6EF8ACE6F'

def light_control(turn):
    # POST request
    response = requests.post(
        f'https://{server_uri}/device/light/control', 
        data={
            'turn': turn,
            'id': device_id,
            'auth_key': auth_key
        }
    )
    

    # Print response
    print(response.text)
    print(response.status_code)