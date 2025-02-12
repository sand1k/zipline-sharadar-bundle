#!/bin/bash
export PYTHON_VERSION=3.9
export VENV_NAME=zipline-reloaded-venv$PYTHON_VERSION
virtualenv -p /usr/bin/python$PYTHON_VERSION ~/$VENV_NAME
source ~/$VENV_NAME/bin/activate
python -m pip install --upgrade pip
export PYTHON_LIBS=~/$VENV_NAME/lib/python$PYTHON_VERSION/site-packages

# Install TA LIB
cd $PYTHON_LIBS
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar xvfz ta-lib-0.4.0-src.tar.gz
rm ta-lib-0.4.0-src.tar.gz
cd ta-lib
./configure
make

# Install zipline-reloaded with source code
cd $PYTHON_LIBS
git clone git@github.com:stefan-jansen/zipline-reloaded.git
cd zipline-reloaded
python setup.py build_ext --inplace
python setup.py install

# Install pyfolio-reloaded with source code
cd $PYTHON_LIBS
git clone git@github.com:stefan-jansen/pyfolio-reloaded
cd pyfolio-reloaded
python setup.py install

# Install TWS api
cd $PYTHON_LIBS
wget https://interactivebrokers.github.io/downloads/twsapi_macunix.1017.01.zip
unzip twsapi_macunix.1017.01.zip -d twsapi
rm twsapi_macunix.1017.01.zip
cd twsapi/IBJts/source/pythonclient
python setup.py install

sudo dnf install -y systemd-devel

# Install requirements
cd $PYTHON_LIBS
git clone git@github.com:alphaville76/sharadar_db_bundle.git


pip install jupyterlab

cd $PYTHON_LIBS/sharadar_db_bundle
git clone git@github.com:alphaville76/algo.git
pip install -r requirements.txt --no-deps
pip uninstall -y tables trading-calendars

# Workaround https://github.com/stefan-jansen/zipline-reloaded/issues/118
pip install iso3166==2.0.2
pip install exchange-calendars==3.6.3
python setup.py install
python test/basic_pipeline_sep_db.py

if [ "$?" -eq 0 ]
then
echo "INSTALLATION SUCCESSFUL"
else
echo "INSTALLATION FAILED"
fi
