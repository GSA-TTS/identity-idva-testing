""" Locustfile for load testing GIVE functionality """
import os
import random
import uuid
from locust import HttpUser, task, constant, constant_pacing

CLIENT_SECRET = str(os.environ["LOCUST_CLIENT_SECRET"])
CLIENT_ID = str(os.environ["LOCUST_CLIENT_ID"])

SK_API_ROUTE = str(os.environ["SK_API_ROUTE"])
SK_API_KEY = str(os.environ["SK_API_KEY"])


class IdemiaUser(HttpUser):
    """Simulate user interaction to the idemia microservice"""

    wait_time = constant(1)
    bearer_token = None

    def on_start(self):
        """Generate the OAuth2.0 token for the user"""
        response = self.client.post(
            "/idemia/oauth2/token",
            data={
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "grant_type": "client_credentials",
                "scope": "rpname",
            },
        )
        json_response = response.json()
        self.bearer_token = f"token {json_response['access_token']}"

    @task
    def idemia_locations(self):
        """Perform GET on the Idemia /locations endpoint"""
        zipcode = random.randrange(10000, 99999)
        self.client.get(
            "/idemia/locations/%i" % zipcode,
            name="/locations/zipcode",
            headers={"Authorization": self.bearer_token},
        )

    @task
    def idemia_enrollment(self):
        """Perform create & read operarions on the Idemia /enrollment endpoint"""
        enrollment_uuid = uuid.uuid4()

        # Create
        self.client.post(
            "/idemia/enrollment/",
            data={
                "first_name": "Bob",
                "last_name": "Testington",
                "csp_user_uuid": enrollment_uuid,
            },
            headers={"Authorization": self.bearer_token},
        )

        # Read
        self.client.get(
            "/idemia/enrollment/%s" % enrollment_uuid,
            headers={"Authorization": self.bearer_token},
            name="/idemia/enrollment/uuid",
        )


class SKTestUser(HttpUser):  # pylint: disable=too-few-public-methods
    """Load test SK"""

    wait_time = constant_pacing(1)

    @task(1)
    def basic_http_flow(self):
        """Invoke basic sk http flow"""
        self.client.post(
            f"https://{SK_API_ROUTE}/v1/company/wdK3fH48XuoXzvZyeNJEYFA9i8K72BZg/flows/"
            "IU1iDIvviIth5jiYmNvgsS43Kg29RxyB/start",
            headers={"x-sk-api-key": SK_API_KEY},
        )
