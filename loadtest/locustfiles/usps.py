""" Locustfile for load testing IDVA usps av functionality """
import os
import random
import uuid
import csv
import logging
import json
from locust import HttpUser, task, tag

FLOW_PATH = f"/v1/company/wdK3fH48XuoXzvZyeNJEYFA9i8K72BZg/flows/YYAzKlqe8gwmwyLfaM2e7jkuvikvzpDi/start"
SK_API_KEY = os.getenv("SK_API_KEY")
CSV_FILE = os.getenv("CSV_FILE")


class SKUSPSTestUser(HttpUser):

    with open(CSV_FILE) as csvfile:
        reader = csv.reader(csvfile)
        data = list(reader)

    @tag("usps", "usps_ok")
    @task(1)
    def usps_av_valid(self):
        """Invoke basic usps av flow"""

        index = random.randint(1, len(self.data) - 1)

        rdata = {
            "uid": str(uuid.uuid4()),
            "first_name": self.data[index][0],
            "last_name": self.data[index][2],
            "middle_name": self.data[index][1],
            "suffix": self.data[index][3],
            "delivery_address": self.data[index][4],
            "address_city_state_zip": self.data[index][5],
        }

        with self.client.post(
            FLOW_PATH,
            headers={"x-sk-api-key": SK_API_KEY},
            json=rdata,
            catch_response=True,
        ) as response:
            try:
                if response.json()["uid"] != rdata["uid"] or (
                    float(response.json()["confidence_indicator"])
                    != float(self.data[index][6])
                ):
                    response.failure("response values do not match expected")
                    logging.info(
                        f"response values do not match expected: {response.json()}"
                    )
            except Exception as e:
                response.failure("error in response")
                logging.info(f"error: {e}")
                logging.info(f"in response: {response.status_code} {response.text}")

    @tag("usps", "error", "usps_not_found")
    @task(1)
    def usps_av_not_found(self):
        """Invoke basic usps http flow with a person that does not exist"""

        index = random.randint(1, len(self.data) - 1)

        rdata = {
            "uid": str(uuid.uuid4()),
            "first_name": self.data[index][0],
            "last_name": self.data[index][2],
            "middle_name": self.data[index][1],
            "suffix": self.data[index][3],
            "delivery_address": self.data[index][4],
            "address_city_state_zip": self.data[index][5],
        }

        with self.client.post(
            FLOW_PATH,
            headers={"x-sk-api-key": SK_API_KEY},
            json=rdata,
            catch_response=True,
        ) as response:
            try:
                if (
                    response.json()["uid"] != rdata["uid"]
                    or response.json()["confidence_indicator"] is not None
                ):
                    response.failure("response values do not match expected")
                    logging.info(f"{response.json()}")
            except Exception as e:
                response.failure("error in response")
                logging.info(f"error: {e}")
                logging.info(
                    f"error in response: {response.status_code} {response.text}"
                )

    @tag("usps", "error", "usps_missing_param")
    @task(1)
    def usps_av_missing_parameter(self):
        """Invoke basic sk http flow"""

        index = random.randint(1, len(self.data) - 1)

        rdata = {
            "uid": str(uuid.uuid4()),
            "first_name": self.data[index][0],
            "last_name": self.data[index][2],
            "middle_name": self.data[index][1],
            "suffix": self.data[index][3],
            "delivery_address": self.data[index][4],
            "address_city_state_zip": self.data[index][5],
        }

        # Induce missing entry error
        blank = random.choice(
            ["first_name", "last_name", "delivery_address", "address_city_state_zip"]
        )
        rdata[blank] = ""

        with self.client.post(
            FLOW_PATH,
            headers={"x-sk-api-key": SK_API_KEY},
            json=rdata,
            catch_response=True,
        ) as response:
            try:
                message = response.json()["message"].split("-", 1)
                org_resp = json.loads(message[1])
                if (
                    int(message[0]) != 400
                    or org_resp["uid"] != rdata["uid"]
                    or not org_resp["error"].startswith("Mandatory field(s) missing")
                ):
                    response.failure("response values do not match expected")
                    logging.info(f"{response.json()}")
                else:
                    response.success()
            except Exception as e:
                response.failure("error in response")
                logging.info(f"error: {e}")
                logging.info(
                    f"error in response: {response.status_code} {response.text}"
                )
