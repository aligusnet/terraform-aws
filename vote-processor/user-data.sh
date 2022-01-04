#!/bin/bash

curl https://gist.githubusercontent.com/aligusnet/14995851b7a968a32291fa85876fe3df/raw/81a8272e2d2a5e340da764f9acf77e3dea2e492d/processor.py > processor.py
chmod +x processor.py
yum -y install python-pip
python -m pip install --user boto3
./processor.py
