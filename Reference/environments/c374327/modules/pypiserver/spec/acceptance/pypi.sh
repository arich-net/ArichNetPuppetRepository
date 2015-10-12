# !/usr/bin/env bash
set -eu

curl https://pypi.python.org/packages/source/c/cov-core/cov-core-1.7.tar.gz | tar -xvz -C /tmp
cd /tmp/cov-core-1.7/
python setup.py sdist register -r internal
