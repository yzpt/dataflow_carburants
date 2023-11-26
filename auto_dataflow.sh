PROJECT_ID=carburants-dataflow
gcloud config set project $PROJECT_ID
BUCKET_URL_INPUT_FILES=gs://$PROJECT_ID-input-files
BUCKET_URL_TEMP=gs://$PROJECT_ID-temp
DATASET_ID=carburants_dataset
REGION=europe-west9

TABLE_ID=dataflow_test

# files transfert
gsutil cp ./table_schema_test.json $BUCKET_URL_INPUT_FILES
gsutil cp ./instantane_test.csv $BUCKET_URL_INPUT_FILES
gsutil cp ./transform_csv_test.js $BUCKET_URL_INPUT_FILES

# GCS input file
INPUT_FILE_PATTERN_URL=$BUCKET_URL_INPUT_FILES/instantane_test.csv
JSON_SCHEMA_FILE=$BUCKET_URL_INPUT_FILES/table_schema_test.json
UDF_PATH=$BUCKET_URL_INPUT_FILES/transform_csv_test.js

# BQ output table
BQ_OUTPUT_TABLE=$PROJECT_ID:$DATASET_ID.$TABLE_ID

# temporary directories
TEMP_BQ_LOCATION=$BUCKET_URL_TEMP/temp_dir_bq
TEMP_DF_LOCATION=$BUCKET_URL_TEMP/temp_dir_df

# Get current datetime
current_datetime=$(date +"%Y-%m-%d_%Hh%M")

gcloud dataflow jobs run job_$(date +"%Y-%m-%d_%Hh%M") \
    --gcs-location gs://dataflow-templates-europe-west9/latest/GCS_Text_to_BigQuery \
    --region $REGION \
    --staging-location $TEMP_DF_LOCATION \
    --additional-experiments {} \
    --parameters inputFilePattern=$INPUT_FILE_PATTERN_URL,JSONPath=gs://$JSON_SCHEMA_FILE,outputTable=$BQ_OUTPUT_TABLE,bigQueryLoadingTemporaryDirectory=$TEMP_BQ_LOCATION,javascriptTextTransformGcsPath=$UDF_PATH,javascriptTextTransformFunctionName=process

gcloud dataflow jobs run job_$(date +"%Y-%m-%d_%Hh%M") \
    --gcs-location gs://dataflow-templates-europe-west9/latest/GCS_Text_to_BigQuery \
    --region $REGION \
    --staging-location $TEMP_DF_LOCATION \
    --additional-experiments {} \
    --parameters inputFilePattern=$INPUT_FILE_PATTERN_URL,JSONPath=gs://$JSON_SCHEMA_FILE,outputTable=$BQ_OUTPUT_TABLE,bigQueryLoadingTemporaryDirectory=$TEMP_BQ_LOCATION,javascriptTextTransformGcsPath=$UDF_PATH,javascriptTextTransformFunctionName=process

    echo $TEMP_DF_LOCATION