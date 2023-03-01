[![ci](https://github.com/JacobCoffee/starlite-barebones-template/actions/workflows/ci.yml/badge.svg)](https://github.com/JacobCoffee/starlite-barebones-template/actions/workflows/ci.yml)
[![docs](https://github.com/JacobCoffee/starlite-barebones-template/actions/workflows/docs.yml/badge.svg)](https://github.com/JacobCoffee/starlite-barebones-template/actions/workflows/docs.yml)

# [Starlite API Framework](https://github.com/starlite-api/starlite) Barebones Template

## WIP

#### Provides a basic template for a Starlite API Framework project including these options out-of-the-box:
- [x] Starlite API Framework plus some extras:
    * [`uvicorn`](https://www.uvicorn.org/)
    * [`python-dotenv`](https://github.com/theskumar/python-dotenv)
    * [`structlog`](https://www.structlog.org/en/stable/)
    * [`TailwindCSS`](https://tailwindcss.com/)
- [x] CI via GitHub Actions
    - [x] CI Testing
    - [x] Document Generation

#### Optional Extras:
- [redis](https://redis.io/) with `poetry install --with cache`
- [saq](https://github.com/tobymao/saq/) with `poetry install --with worker`
- [sqlalchemy](https://www.sqlalchemy.org/) , [asyncpg](https://magicstack.github.io/asyncpg/) with `poetry install --with db`
- all extras with `poetry install --all-extras`

___

## Getting Started
1. Run `poetry install` (optionally, you can pass in addons listed above [Optional Extras](#optional-extras))
2. Run `uvicorn app.asgi:app --reload` to start the app.
3. Visit `localhost:8000`

### Media
Home Page

**Light Mode**
![image](https://user-images.githubusercontent.com/45884264/222229312-c7601954-8bb1-44b5-a861-55f191e68310.png)

**Dark Mode**
![image](https://user-images.githubusercontent.com/45884264/216846442-5f06f3df-2457-420b-beb9-7c043ebbfcc0.png)

API - Swagger
![image](https://user-images.githubusercontent.com/45884264/216846490-4fce9db7-4b52-4be9-bd25-ae12bc417d77.png)



### Makefile
This project includes a `Makefile` with some useful commands (available by running `make help`)

```shell
Usage:
  make <target>

  Targets:
      help                    Display Help for Makefile
      upgrade                 Upgrade all dependencies to the latest stable versions

      coverage                Run coverage report
      lint                    run pre-commit hooks; includes ruff linting
      test                    Run tests with coverage
      pytest                  Run tests using pytest directly

      install                 Install in Dev Mode
      runtime-only            Install in Prod Mode
      migrations              Run DB Migrations
      migrate                 Migrate DB
      squash-migrations       Squash DB Migrations
      clean                   File Cleanup

      download-backend-deps   Get Dependencies for Backend
      build-frontend          Build Dependencies for Frontend; includes API schema and tailwind
      build-backend           Build Dependencies for Backend using poetry
      build                   Build Backend and Frontend
      pre-release             Run the pre-release cycle; builds docs, cleans stale files, bumps version

      docs-clean              Dump the existing built docs
      docs-serve              Serve the docs locally
      docs                    Dump the existing built docs and rebuild them
```


___

## Documentation
All documentation is generated under the `/docs` folder

To run or build the docs locally, you need to first install the required dependencies:

`poetry install --with docs`

Then you can serve the documentation with `make docs-serve`, or (re)build them with `make docs`

___

## Contributing
To contribute to this project, please read the [contributing guidelines](CONTRIBUTING.md).
