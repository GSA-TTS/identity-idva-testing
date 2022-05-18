[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

# IDVA Load Testing

## Why this project

In order to ensure the IDVA system is working correctly, it is necessary to test not only it's individual components,
but that those components work when accessed by its users. This project will aim to satisfy the following goals:

- Allow IDVA to test the correctness of new and existing features
- Monitor failures introduced by changes to IDVA services
- Test how much traffic IDVA can handle before breaking
- Identify areas within IDVA that can be improved (performance or otherwise)

## Installation
To install the IDVA Load Testing tooling locally, use the following:
```shell
git clone https://github.com/18F/identity-idva-load-testing
cd identity-idva-load-testing
python -m venv .venv
python -m pip install -r requirements.txt
```

## Usage

### Configure

The following variables need to be configured to run locust.

 - `ENVIRONMENT` - environment name
 - `SK_API_KEY` - api key for app to be used
 - `CSV_FILE` - path to file containing test data. Use empty string if no file is needed.
 - `TASK_ARG` - locust argument that determines which test to run. Specify a locustfile and optionally a set of tags to select which load tests are run.

        -f ./locustfiles/loadtest.py
        -f ./locustfiles/usps.py -T usps_ok
        -f ./locustfiles/usps.py -T usps_missing_param
        -f ./locustfiles/usps.py -T usps_not_found

### Local
The tool can be run with `locust --host https://idva-api-<ENVIRONMENT>.app.cloud.gov <TASK_ARG>`. Locust will also look for `SK_API_KEY` and `CSV_FILE` environment variables.

### Cloud
Run on Locust in the cloud.gov environment with:
```
cf push --vars-file .\vars.yaml

```
**vars.yaml:**
```
---
ENVIRONMENT: dev
SK_API_KEY: <API_KEY>
TASK_ARG: -f ./locustfiles/usps.py -T usps_ok
CSV_FILE: ./test_data.csv
```

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide
are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are
agreeing to comply with this waiver of copyright interest.
