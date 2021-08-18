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
To install the IDVA Load Testing tooling, use the following:
```shell
git clone https://github.com/18F/identity-idva-load-testing
cd identity-idva-load-testing
python -m venv .venv
python -m pip install -r requirements.txt
```

## Usage
Running the tool (after following the above install) can be done with `locust`

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide
are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are
agreeing to comply with this waiver of copyright interest.
