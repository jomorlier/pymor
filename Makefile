PYMOR_DOCKER_TAG?=3.6
PYMOR_PYTEST_MARKER?=None

.PHONY: README.rst README.txt README.html pylint test

all:
	./dependencies.py

# PyPI wants ReStructured text
README.rst: README.md
	pandoc -f markdown_github -t rst $< > $@

# I want HTML (to preview the formatting :))
README.html: README.md
	pandoc -f markdown_github -t html $< > $@

README.txt: README.md
	pandoc -f markdown_github -t plain $< > $@

README: README.txt README.html README.rst

pep8:
	pep8 ./src

flake8:
	flake8 ./src

test:
	python setup.py test

dockerrun:
	docker run --rm -it -v $(shell pwd):/src -e PYTEST_MARKER=$(PYMOR_PYTEST_MARKER) pymor/testing:$(PYMOR_DOCKER_TAG) bash

dockertest:
	PYMOR_DOCKER_TAG=$(PYMOR_DOCKER_TAG) PYMOR_PYTEST_MARKER=$(PYMOR_PYTEST_MARKER) ./.ci/travis/run_travis_builders.py

dockertestfull:
	./.ci/travis/run_travis_builders.py

fasttest:
	PYTEST_MARKER="not slow" python setup.py test

full-test:
	@echo
	@echo "Ensuring that all required pytest plugins are installed ..."
	@echo "--------------------------------------------------------------------------------"
	@echo
	pip install pytest-flakes
	pip install pytest-pep8
	pip install pytest-cov
	@echo
	@echo "--------------------------------------------------------------------------------"
	@echo
	py.test --flakes --pep8 --cov=pymor --cov-report=html --cov-report=xml src/pymortests

doc:
	PYTHONPATH=${PWD}/src/:${PYTHONPATH} make -C docs html

3to2:
	./3to2.sh src/
	./3to2.sh docs/
	python setup.py build_ext -i
