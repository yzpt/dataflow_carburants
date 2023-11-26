from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator


default_args = {
    'owner': 'admin',
    'retries': 1,
    'retry_delay': timedelta(seconds=5),
}


with DAG(
    dag_id='our_first_dag_v5',
    default_args=default_args,
    description='This is our first dag that we write',
    start_date=datetime(2021, 7, 29, 2),
    catchup=False,
    schedule_interval='*/5 * * * *'
) as dag:
    task1 = BashOperator(
        task_id='first_task',
        # bash_command="echo hello world, this is the first task!"
        bash_command="""
PROJECT_ID=carburants-dataflow
BUCKET_URL_INPUT_FILES=gs://$PROJECT_ID-input-files
BUCKET_URL_TEMP=gs://$PROJECT_ID-temp
DATASET_ID=carburants_dataset
REGION=europe-west9

SUFFIXE=light

# GCS input file
INPUT_FILE_PATTERN_URL=$BUCKET_URL_INPUT_FILES/instantane_$SUFFIXE.csv
JSON_SCHEMA_FILE=$BUCKET_URL_INPUT_FILES/table_schema_df_$SUFFIXE.json
UDF_PATH=$BUCKET_URL_INPUT_FILES/transform_csv_$SUFFIXE.js

# BQ output table
TABLE_ID=carbu_api_test_$SUFFIXE
BQ_OUTPUT_TABLE=$PROJECT_ID:$DATASET_ID.$TABLE_ID

# temporary directories
TEMP_BQ_LOCATION=$BUCKET_URL_TEMP/temp_dir_bq
TEMP_DF_LOCATION=$BUCKET_URL_TEMP/temp_dir_df

echo input file:$INPUT_FILE_PATTERN_URL
echo json schema:$JSON_SCHEMA_FILE
echo udf path:$UDF_PATH
echo output table:$BQ_OUTPUT_TABLE
echo temp bq location:$TEMP_BQ_LOCATION
echo temp df location:$TEMP_DF_LOCATION

# dataflow job with bigquery storage API support
gcloud dataflow flex-template run api-carbu-data-$SUFFIXE-ahah\
    --template-file-gcs-location gs://dataflow-templates-europe-west9/latest/flex/GCS_Text_to_BigQuery_Flex \
    --region $REGION \
    --additional-experiments {} \
    --parameters \
inputFilePattern=$INPUT_FILE_PATTERN_URL,\
JSONPath=$JSON_SCHEMA_FILE,\
outputTable=$BQ_OUTPUT_TABLE,\
javascriptTextTransformGcsPath=$UDF_PATH,\
javascriptTextTransformFunctionName=process,\
bigQueryLoadingTemporaryDirectory=$TEMP_BQ_LOCATION,\
useStorageWriteApi=true,\
javascriptTextTransformReloadIntervalMinutes=0
            """
    )

    # task2 = BashOperator(
    #     task_id='second_task',
    #     bash_command="echo hey, I am task2 and will be running after task1!"
    # )

    # task3 = BashOperator(
    #     task_id='thrid_task',
    #     bash_command="echo hey, I am task3 and will be running after task1 at the same time as task2!"
    # )

    # Task dependency method 1
    # task1.set_downstream(task2)
    # task1.set_downstream(task3)

    # Task dependency method 2
    # task1 >> task2
    # task1 >> task3

    # Task dependency method 3
    # task1 >> [task2, task3]