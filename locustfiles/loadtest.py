""" Locustfile for load testing IDVA functionality """
import os
from locust import HttpUser, task, constant_pacing, tag

HTTP_FLOW_PATH = f"/v1/company/wdK3fH48XuoXzvZyeNJEYFA9i8K72BZg/policy/836afc2a695ad63dda8ae2a5c76908f9/start"
SK_API_KEY = os.getenv("SK_API_KEY")


class SKLoadTestUser(HttpUser):
    """Load test SK"""

    wait_time = constant_pacing(1)

    @task(1)
    @tag("basic_load")
    def test_flow(self):
        """Invoke basic sk test flow"""

        self.client.post(HTTP_FLOW_PATH, headers={"x-sk-api-key": SK_API_KEY})
