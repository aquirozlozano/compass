import pandas as pd
from io import StringIO
import re 
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey, Float
from sqlalchemy.exc import OperationalError
from airflow.operators.dummy_operator import DummyOperator
from airflow.models import DAG
from airflow.utils.decorators import apply_defaults
from airflow.models import BaseOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash import BashOperator
from datetime import datetime
from datetime import timedelta
import json

default_args = {
    "owner": "compass",
    "depends_on_past": False,
    "start_date": datetime(2020, 7, 1),
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
}

dag = DAG(
    "run_spark_jobs_on_emr",
    catchup=False,
    max_active_runs=1,
    schedule_interval="@daily",
    default_args=default_args,
)

sh_execute_on_emr = "./scripts/run-pipelines-on-emr.sh "
pipeline="test01"



with dag:

    begin = DummyOperator(task_id="begin")

    t2 = BashOperator(
        task_id='run_on_emr',
        # "scripts" folder is under "/usr/local/airflow/dags"
        bash_command=sh_execute_on_emr,
        dag=dag)

    begin >>  t2