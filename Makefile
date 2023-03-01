# =============================================================================
# Variables
# =============================================================================
.DEFAULT_GOAL:=help
.ONESHELL:
ENV_PREFIX=$(shell python3 -c "if __import__('pathlib').Path('.venv/bin/pip').exists(): print('.venv/bin/')")
USING_POETRY=$(shell grep "tool.poetry" pyproject.toml && echo "yes")
# grep .env if it exists else return empty string
USING_DOCKER=$(shell grep "USE_DOCKER=true" .env && echo "yes")
USING_PNPM=$(shell python3 -c "if __import__('pathlib').Path('pnpm-lock.yaml').exists(): print('yes')")
USING_YARN=$(shell python3 -c "if __import__('pathlib').Path('yarn.lock').exists(): print('yes')")
USING_NPM=$(shell python3 -c "if __import__('pathlib').Path('package-lock.json').exists(): print('yes')")
VENV_EXISTS=$(shell python3 -c "if __import__('pathlib').Path('.venv/bin/activate').exists(): print('yes')")
NODE_MODULES_EXISTS=$(shell python3 -c "if __import__('pathlib').Path('node_modules').exists(): print('yes')")
PYTHON_PACKAGES=$(shell if poetry --version > /dev/null; then poetry export -f requirements.txt  --without-hashes |cut -d'=' -f1 |cut -d ' ' -f1; fi)
VERSION := $(shell grep -m 1 version pyproject.toml | tr -s ' ' | tr -d '"' | tr -d "'" | cut -d' ' -f3)
FRONTEND_SRC_DIR=app/templates
FRONTEND_BUILD_DIR=$(FRONTEND_SRC_DIR)/dist
BACKEND_SRC_DIR=app/
BACKEND_BUILD_DIR=dist

.EXPORT_ALL_VARIABLES:

ifndef VERBOSE
.SILENT:
endif

REPO_INFO ?= $(shell git config --get remote.origin.url)
COMMIT_SHA ?= git-$(shell git rev-parse --short HEAD)


help: ## Display Help for Makefile
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: upgrade
upgrade: ## Upgrade all dependencies to the latest stable versions
	@if [ "$(USING_POETRY)" ]; then poetry update; fi
	@echo "Python Dependencies Updated"
	@if [ "$(USING_NPM)" ]; then npm upgrade --latest; fi
	@if [ "$(USING_YARN)" ]; then yarn upgrade; fi
	@if [ "$(USING_PNPM)" ]; then pnpm upgrade --latest; fi
	@echo "Node Dependencies Updated"

# =============================================================================
# Tests
# =============================================================================

coverage: ## Run coverage report
	env PYTHONPATH=app/ poetry run coverage run --source app -m pytest
	env PYTHONPATH=app/ poetry run coverage report -m

lint: ## run pre-commit hooks; includes ruff linting
	env PYTHONPATH=app/ poetry run pre-commit run --all-files

test: ## Run tests with coverage
	env PYTHONPATH=app/ poetry run pytest --cov-config .coveragerc --cov=app -l --tb=short tests/
	env PYTHONPATH=app/ poetry run coverage xml
	env PYTHONPATH=app/ poetry run coverage html

pytest: ## Run tests using pytest directly
	poetry run pytest tests

# =============================================================================
# App
# =============================================================================

.PHONY: install
install: ## Install in Dev Mode
	@if ! poetry --version > /dev/null; then echo 'poetry is required, installing from from https://install.python-poetry.org'; curl -sSL https://install.python-poetry.org | python3 -; fi
	@if [ "$(VENV_EXISTS)" ]; then echo "Removing existing virtual environment"; fi
	@if [ "$(NODE_MODULES_EXISTS)" ]; then echo "Removing existing node environment"; fi
	if [ "$(VENV_EXISTS)" ]; then rm -Rf .venv; fi
	if [ "$(USING_POETRY)" ]; then poetry config virtualenvs.in-project true  && poetry config virtualenvs.options.always-copy true && python3 -m venv .venv && source .venv/bin/activate && .venv/bin/pip install -U wheel setuptools cython pip && poetry install --with lint,dev,docs && mkdir -p ./app/ui/public; fi
	if [ "$(USING_NPM)" ]; then npm ci; fi
	if [ "$(USING_YARN)" ]; then yarn install; fi
	if [ "$(USING_PNPM)" ]; then pnpm install; fi
	@echo "=> Install complete.  ** If you want to re-install re-run 'make install'"

.PHONY: runtime
runtime-only: ## Install in Prod Mode
	@if ! poetry --version > /dev/null; then echo 'poetry is required, installing from from https://install.python-poetry.org'; curl -sSL https://install.python-poetry.org | python3 -; fi
	@if [ "$(VENV_EXISTS)" ]; then echo "Removing existing environment"; fi
	if [ "$(VENV_EXISTS)" ]; then rm -Rf .venv; fi
	if [ "$(USING_POETRY)" ]; then poetry config virtualenvs.in-project true  && poetry config virtualenvs.options.always-copy true && python3 -m venv .venv && source .venv/bin/activate && .venv/bin/pip install -U wheel setuptools cython pip && poetry install --only main && mkdir -p ./app/public ; fi
	if [ "$(USING_NPM)" ]; then npm install; fi
	@echo "=> Install complete.  ** If you want to re-install re-run 'make runtime'"

.PHONY: migrations
migrations: ## Run DB Migrations
	@echo "ATTENTION: This operation will create a new database migration for any defined models changes."
	@while [ -z "$$MIGRATION_MESSAGE" ]; do read -r -p "Migration message: " MIGRATION_MESSAGE; done ;
	@env PYTHONPATH=app poetry run alembic -c app/db/alembic.ini revision --autogenerate -m "$${MIGRATION_MESSAGE}"

.PHONY: migrate
migrate: ## Migrate DB
	@echo "ATTENTION: Will apply all database migrations."
	@env PYTHONPATH=app/ .venv/bin/app manage upgrade-database

.PHONY: squash-migrations
squash-migrations: ## Squash DB Migrations
	@echo "ATTENTION: This operation will wipe all migrations and recreate from an empty state."
	@env PYTHONPATH=app/ poetry run app manage purge-database --no-prompt
	rm -Rf app/db/migrations/versions/*.py
	@while [ -z "$$MIGRATION_MESSAGE" ]; do read -r -p "Initial migration message: " MIGRATION_MESSAGE; done ;
	@env PYTHONPATH=app .venv/bin/alembic -c app/db/alembic.ini revision --autogenerate -m "$${MIGRATION_MESSAGE}"


.PHONY: clean
clean: ## File Cleanup
	rm -rf build/
	rm -rf dist/
	rm -rf .eggs/
	find . -name '*.egg-info' -exec rm -rf {} +
	find . -name '*.egg' -exec rm -f {} +
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -rf {} +
	find . -name '.ipynb_checkpoints' -exec rm -rf {} +
	rm -rf .tox/
	rm -rf .coverage
	rm -rf coverage.xml
	rm -rf coverage.json
	rm -rf htmlcov/
	rm -rf .pytest_cache
	rm -rf .mypy_cache
	rm -rf .ruff_cache
	rm -rf site
	rm -f app/static/generated/*


# ! TODO: Fix this
download-backend-deps: ## Get Dependencies for Backend
	@poetry export --without-hashes --only=main -f requirements.txt --output dist/requirements.txt && rm -Rf dist/wheels && poetry run pip download --no-binary=':all:'  -r dist/requirements.txt -d dist/wheels

build-frontend: $(FRONTEND_BUILD_DIR) ## Build Dependencies for Frontend; includes API schema and tailwind

$(FRONTEND_BUILD_DIR): $(shell find $(FRONTEND_SRC_DIR) -not -path "$(FRONTEND_BUILD_DIR)")
	@poetry run app manage export-openapi-schema --export-path ./app/templates/api/
	@npm run build

build-backend: $(BACKEND_BUILD_DIR) ## Build Dependencies for Backend using poetry

$(BACKEND_BUILD_DIR): $(shell find $(BACKEND_SRC_DIR))
	@poetry build

build: build-frontend build-backend ## Build Backend and Frontend

.PHONY: pre-release
pre-release: ## Run the pre-release cycle; builds docs, cleans stale files, bumps version
	make docs
	make clean
	poetry run bump2version $(increment)
	git describe --tags --abbrev=0
	head pyproject.toml | grep version

# =============================================================================
# Docs
# =============================================================================

docs-clean: ## Dump the existing built docs
	make clean

docs-serve: ## Serve the docs locally
	make clean
	poetry run mkdocs build
	poetry run mkdocs serve

docs: docs-clean ## Dump the existing built docs and rebuild them
	make clean
	poetry run mkdocs build


# =============================================================================
# Workflow
# =============================================================================
run-dev: ## Run the uvicorn server and TailwindCSS with hot reloading
	@npm run dev
