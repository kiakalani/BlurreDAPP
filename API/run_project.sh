# Author: Kia Kalani
# A simple script for running the API application.

# Would be used for installing requirements if the
# environment did not exist beforehand
venv_n_exists=0

if [ "${VIRTUAL_ENV}" != "$(pwd)/.venv" ]; then
    # Create virtual environment if not there
    if [ ! -d ".venv" ]; then
        venv_n_exists=1
        python3 -m venv .venv
    fi
    # Activating the environment variable
    source ".venv/bin/activate"

    # Installing dependencies if first time running
    if [ "${venv_n_exists}" == 1 ]; then
        pip install -r requirements.txt
    fi
fi

if [ ! -f "db.db" ]; then
    touch db.db
fi

export SQLDB="db.db"
export SECRET_KEY="asec"

python __init__.py
