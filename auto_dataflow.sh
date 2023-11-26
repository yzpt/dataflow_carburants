PROJECT_ID=carburants-dataflow
gcloud config set project $PROJECT_ID
BUCKET_URL_INPUT_FILES=gs://$PROJECT_ID-input-files
BUCKET_URL_TEMP=gs://$PROJECT_ID-temp
DATASET_ID=carburants_dataset
REGION=europe-west9

TABLE_ID=carbu_api_test_light
bq mk --table $PROJECT_ID:$DATASET_ID.$TABLE_ID ./table_schema_bq_light.json




# files transfert
gsutil cp ./table_schema_df_light.json $BUCKET_URL_INPUT_FILES
gsutil cp ./instantane_light.csv $BUCKET_URL_INPUT_FILES
gsutil cp ./transform_csv_light.js $BUCKET_URL_INPUT_FILES

# GCS input file
INPUT_FILE_PATTERN_URL=$BUCKET_URL_INPUT_FILES/instantane_light.csv
JSON_SCHEMA_FILE=$BUCKET_URL_INPUT_FILES/table_schema_df_light.json
UDF_PATH=$BUCKET_URL_INPUT_FILES/transform_csv_light.js

# BQ output table
BQ_OUTPUT_TABLE=$PROJECT_ID:$DATASET_ID.$TABLE_ID

# temporary directories
TEMP_BQ_LOCATION=$BUCKET_URL_TEMP/temp_dir_bq
TEMP_DF_LOCATION=$BUCKET_URL_TEMP/temp_dir_df

# Get current datetime
current_datetime=$(date +"%Y-%m-%d_%Hh%M")

# dataflow job with bigquery storage API support
gcloud dataflow flex-template run api-carbu-data\
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

