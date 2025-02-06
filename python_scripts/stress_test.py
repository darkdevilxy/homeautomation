import locust
from locust import HttpUser, task, between
from locust import LoadTestShape
import json
import uuid
import logging
import argparse
import time
from typing import Dict, Any

class ELBStressTest(HttpUser):
    wait_time = between(1, 5)
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.base_headers = {
            'Content-Type': 'application/json',
            'X-Request-ID': str(uuid.uuid4())
        }
        self.logger = self.setup_logger()

    def setup_logger(self):
        logger = logging.getLogger('elb_stress_test')
        logger.setLevel(logging.INFO)
        file_handler = logging.FileHandler(f'elb_stress_test_{int(time.time())}.log')
        formatter = logging.Formatter('%(asctime)s - %(levelname)s: %(message)s')
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
        return logger

    @task(3)
    def health_check(self):
        with self.client.get("/health", 
                             headers=self.base_headers, 
                             catch_response=True) as response:
            if response.status_code == 200:
                response.success()
                self.logger.info(f"Health check successful: {response.status_code}")
            else:
                response.failure(f"Health check failed: {response.status_code}")

    @task(2)
    def create_user_request(self):
        payload = {
            "username": f"test_user_{uuid.uuid4()}",
            "email": f"user_{uuid.uuid4()}@example.com"
        }
        with self.client.post("/users", 
                              json=payload, 
                              headers=self.base_headers, 
                              catch_response=True) as response:
            if response.status_code in [200, 201]:
                response.success()
                self.logger.info(f"User creation successful: {response.status_code}")
            else:
                response.failure(f"User creation failed: {response.status_code}")

    @task(1)
    def complex_data_request(self):
        query_params = {
            "limit": 100,
            "offset": 0,
            "sort": "created_at"
        }
        with self.client.get("/complex-data", 
                             params=query_params, 
                             headers=self.base_headers, 
                             catch_response=True) as response:
            try:
                data = response.json()
                if response.status_code == 200 and isinstance(data, list):
                    response.success()
                    self.logger.info(f"Complex data retrieval: {len(data)} items")
                else:
                    response.failure("Invalid response format")
            except json.JSONDecodeError:
                response.failure("Response not JSON parseable")

class StressTestShape(LoadTestShape):
    """Custom load test shape to control user count over time"""
    def __init__(self, max_users, spawn_rate, duration):
        super().__init__()
        self.max_users = max_users
        self.spawn_rate = spawn_rate
        self.duration = duration
        self.current_time = 0

    def tick(self):
        run_time = self.get_run_time()
        
        if run_time < self.duration:
            self.current_time = run_time
            user_count = min(int(self.current_time * self.spawn_rate), self.max_users)
            return user_count, self.spawn_rate
        return None

def main():
    parser = argparse.ArgumentParser(description="ELB Stress Testing Tool")
    parser.add_argument('--host', required=True, help='ELB Hostname')
    parser.add_argument('--users', type=int, default=100, help='Max concurrent users')
    parser.add_argument('--spawn-rate', type=float, default=10, help='Users spawned per second')
    parser.add_argument('--duration', type=int, default=300, help='Test duration in seconds')
    
    args = parser.parse_args()

    # Use Locust's CLI to run the test
    print(f"Starting stress test on {args.host}")
    print(f"Max Users: {args.users}, Spawn Rate: {args.spawn_rate}, Duration: {args.duration}s")

if __name__ == "__main__":
    main()