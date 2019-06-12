FROM python:3

WORKDIR /usr/src/app

COPY postgresql-python-app/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY postgresql-python-app/client.py ./

CMD [ "python", "./client.py" ]