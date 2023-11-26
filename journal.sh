# === Dataflow pipeline ========================================================================================

# === GCP configuration ========================================================================================
PROJECT_ID=carburants-dataflow
gcloud projects create $PROJECT_ID
gcloud config set project $PROJECT_ID
gcloud config list

# === IAM ======================================================================================================
# create a service account
SERVICE_ACCOUNT_NAME=SA-$PROJECT_ID
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME

# create a key for the service account
gcloud iam service-accounts keys create key-$SERVICE_ACCOUNT_NAME.json --iam-account=$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com

# add the service account to the project
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com --role roles/owner

# permissions for the service account
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com --role roles/storage.admin
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.admin
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com --role roles/dataflow.admin

# === Billing ==================================================================================================
# link the project to the billing account
BILLING_ACCOUNT_ID=$(gcloud billing accounts list --format='value(ACCOUNT_ID)' --filter='NAME="billing_account_2"')
gcloud billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT_ID


# === Storage =================================================================================================
# create the input files bucket
BUCKET_URL_INPUT_FILES=gs://$PROJECT_ID-input-files
gcloud storage buckets create $BUCKET_URL_INPUT_FILES

# create temporary bucket
BUCKET_URL_TEMP=gs://$PROJECT_ID-temp
gcloud storage buckets create $BUCKET_URL_TEMP

# desactivate python warnings using bq command
# /usr/lib/google-cloud-sdk/platform/bq/bq.py:17: DeprecationWarning: 'pipes' is deprecated and slated for removal in Python 3.13 import pipes
export PYTHONWARNINGS="ignore::DeprecationWarning"
# unset PYTHONWARNINGS

# === BigQuery =================================================================================================
# create a dataset
DATASET_ID=carburants_dataset
bq --location=EU mk --dataset $PROJECT_ID:$DATASET_ID

# create a table
# > table_schema.json
TABLE_ID=carbu_api_test_light
bq mk --table $PROJECT_ID:$DATASET_ID.$TABLE_ID ./table_schema_bq.json
# delete
bq rm -f -t $PROJECT_ID:$DATASET_ID.$TABLE_ID

# === Dataflow =================================================================================================
# enable the Dataflow API
gcloud services enable dataflow.googleapis.com

# transfert table_schema.json file to the bucket
gsutil cp ./table_schema.json $BUCKET_URL

# transfert instantane.csv file to the bucket
gsutil cp ./instantane_light.csv $BUCKET_URL_INPUT_FILES

# GCS input file
GCS_INPUT_FILE=$BUCKET_URL/PrixCarburants_instantane.xml

# GCS table_schema.json file
GCS_TABLE_SCHEMA_FILE=$BUCKET_URL/table_schema.json

# BQ output table
BQ_OUTPUT_TABLE=$PROJECT_ID:$DATASET_ID.$TABLE_ID

# temporary directory for bigquery loading process
TEMP_BQ_LOCATION=$BUCKET_URL/temp_dir_bq

# temporary directory for dataflow process
TEMP_DF_LOCATION=$BUCKET_URL/temp_dir_df

# command :
gcloud dataflow jobs run job-test \
    --gcs-location gs://dataflow-templates-europe-west9/latest/GCS_Text_to_BigQuery \
    --region europe-west9 \
    --staging-location gs://carburants-dataflow-temp/temp_dir_df \
    --additional-experiments {} \
    --parameters inputFilePattern=gs://carburants-dataflow-input-files/PrixCarburants_instantane.xml,JSONPath=gs://carburants-dataflow-input-files/table_schema.json,outputTable=carburants-dataflow:carburants_dataset.carburants_table,bigQueryLoadingTemporaryDirectory=gs://carburants-dataflow-temp/temp_dir_bq




# install node.js
# https://github.com/nodesource/distributions#installation-instructions


# https://github.com/GoogleCloudPlatform/DataflowTemplates/blob/main/v2/common/src/main/resources/udf-samples/transform_csv.js
# > transform_csv.js


#try avec transform_csv.js, input as csv file
# transfer js script to the bucket
gsutil cp ./transform_csv.js $BUCKET_URL_INPUT_FILES


gcloud dataflow jobs run fzeafee \
    --gcs-location gs://dataflow-templates-europe-west9/latest/GCS_Text_to_BigQuery \
    --region europe-west9 \
    --staging-location gs://carburants-dataflow-temp/temp_dir_df/ \
    --additional-experiments {} \
    --parameters inputFilePattern=gs://carburants-dataflow-input-files/instantane.csv,JSONPath=gs://carburants-dataflow-input-files/table_schema.json,outputTable=carburants-dataflow:carburants_dataset.carburants_table,bigQueryLoadingTemporaryDirectory=gs://carburants-dataflow-temp/temp_dir_bq/,javascriptTextTransformGcsPath=gs://carburants-dataflow-input-files/transform_csv.js,javascriptTextTransformFunctionName=process,javascriptTextTransformFunctionName=process



# === dimanche 26 novembre =====================================================================================
# --> auto_dataflow.sh

# dataflow job failure on bigquery step:
# Root cause: org.apache.beam.sdk.util.UserCodeException: java.lang.RuntimeException: Error parsing schema

# -->
# https://cloud.google.com/dataflow/docs/guides/templates/provided/cloud-storage-to-bigquery
# Ensure that there is a top-level JSON array titled fields and that its contents follow the pattern:
# {"name": "COLUMN_NAME", "type": "DATA_TYPE"}. For example:
# {
#   "BigQuery Schema": [
#     {
#       "name": "location",
#       "type": "STRING"
#     },
#     {
#       "name": "name",
#       "type": "STRING"
#     },
#     {...



# with bigquery storage API support
# -> auto_dataflow.sh

# AVEC API OK    


# === Composer =================================================================================================
# with UI
# Accorder les autorisations requises au compte de service Cloud Composer
# Cloud Composer s'appuie sur Workload Identity  comme mécanisme d'authentification des API Google pour Airflow.

# Pour prendre en charge Workload Identity, Cloud Composer crée des liaisons de rôles IAM supplémentaires qui nécessitent le rôle Cloud Composer v2 API Service Agent Extension.


# Attribuez le rôle Cloud Composer v2 API Service Agent Extension au compte de service service-894984696845@cloudcomposer-accounts.iam.gserviceaccount.com.
# Le compte de service SA-carburants-dataflow@carburants-dataflow.iam.gserviceaccount.com sera utilisé comme ressource.

# creating...
# compsoer v2 non 2.5.1	2.6.3
# L'opération CREATE effectuée sur cet environnement a échoué il y a 10 minutes avec le message d'erreur suivant :
# Some of the GKE pods failed to become healthy. Please check the GKE logs for details, and retry the operation.

# The issue may be caused by missing IAM roles in the following Service Accounts:
#  - service-894984696845@cloudcomposer-accounts.iam.gserviceaccount.com in project 894984696845 is missing role roles/composer.ServiceAgentV2Ext

# The list of missing roles is generated without checking individual permissions in IAM custom roles. If any of the Service Accounts above uses custom IAM roles, its permissions may be sufficient and a corresponding warning may be ignored.

# === CLI DOC :
# https://cloud.google.com/composer/docs/how-to/managing/creating#gcloud



# === local Airflow ============================================================================================
python3 -m venv venv-airflow
source venv-airflow/bin/activate

pip install "apache-airflow[celery]==2.7.2" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.7.2/constraints-3.10.txt"

# init airflow
export AIRFLOW_HOME=$(pwd)
airflow db init
airflow users create --username admin --password admin --firstname Yohann --lastname Zapart --role Admin --email yohann@zapart.com

# airflow.cfg --> don't load example dags
sed -i 's/load_examples = True/load_examples = False/g' airflow.cfg

# New terminal
cd <project_path>
source venv-airflow/bin/activate
export AIRFLOW_HOME=$(pwd)
airflow scheduler

# New terminal
cd <project_path>
source venv-airflow/bin/activate
export AIRFLOW_HOME=$(pwd)
airflow webserver --port 8080

mkdir dags


bq query --use_legacy_sql=false 'SELECT * FROM `carburants-dataflow.carburants_dataset.carbu_api_test_light` LIMIT 1000'
# ok