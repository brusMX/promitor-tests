FROM python:3

WORKDIR /usr/src/app

COPY postgresql-python-app/requirements.txt ./
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt


COPY postgresql-python-app/client.py ./
COPY postgresql-python-app/__init__.py ./
ADD postgresql-python-app/classes ./classes

CMD [ "python", "./client.py" ]