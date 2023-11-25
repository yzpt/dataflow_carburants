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
TABLE_ID=carburants_table
bq mk --table $PROJECT_ID:$DATASET_ID.$TABLE_ID ./table_schema.json


# === Dataflow =================================================================================================
# enable the Dataflow API
gcloud services enable dataflow.googleapis.com

# transfert table_schema.json file to the bucket
gsutil cp ./table_schema.json $BUCKET_URL

# transfert instantane.csv file to the bucket
gsutil cp ./instantane.csv $BUCKET_URL_INPUT_FILES

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

# transfer js script to the bucket
gsutil cp ./udf.js $BUCKET_URL_INPUT_FILES

gcloud dataflow jobs run ahah \
    --gcs-location gs://dataflow-templates-europe-west9/latest/GCS_Text_to_BigQuery \
    --region europe-west9 \
    --staging-location gs://carburants-dataflow-temp/temp_dir_df/ \
    --additional-experiments {} \
    --parameters inputFilePattern=gs://carburants-dataflow-input-files/csv_to_json.js,JSONPath=gs://carburants-dataflow-input-files/table_schema.json,outputTable=carburants-dataflow:carburants_dataset.carburants_table,bigQueryLoadingTemporaryDirectory=gs://carburants-dataflow-temp/temp_dir_bq/,javascriptTextTransformFunctionName=csv_to_json