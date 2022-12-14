import json
from datetime import datetime
from airflow.models import DAG
from airflow.providers.http.sensors.http import HttpSensor
from airflow.providers.http.operators.http import SimpleHttpOperator
from airflow.operators.python import PythonOperator

def save_users(ti) -> None:
    users = ti.xcom_pull(task_ids=['get_users'])
    with open('/Users/yuan/airflow/data/users.json', 'w') as f:
        json.dump(users[0], f)

with DAG(
    dag_id='api_dag',
    schedule_interval='@daily',
    start_date=datetime(2022, 10, 1),
    catchup=False
) as dag:

    # 1. Check if the API is up
    task_is_api_active = HttpSensor(
        task_id='is_api_active',
        http_conn_id='api_users',
        endpoint='users/'
    )

    # 2. Get the users
    task_get_users = SimpleHttpOperator(
        task_id='get_users',
        http_conn_id='api_users',
        endpoint='users/',
        method='GET',
        response_filter=lambda response: json.loads(source_data_file),
        log_response=True
    )

    # 3. Save the users
    task_save = PythonOperator(
        task_id='save_users',
        python_callable=save_users
    )

task_is_api_active >> task_get_users >> task_save
