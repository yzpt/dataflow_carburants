gcloud config set project $PROJECT_ID

PROJECT_ID=carburants-dataflow
BUCKET_URL_INPUT_FILES=gs://$PROJECT_ID-input-files
BUCKET_URL_TEMP=gs://$PROJECT_ID-temp
DATASET_ID=carburants_dataset
REGION=europe-west9


SUFFIXE=light

cp ./table_schema_bq.json ./table_schema_bq_$SUFFIXE.json
cp ./table_schema_df.json ./table_schema_df_$SUFFIXE.json
cp ./instantane.csv ./instantane_$SUFFIXE.csv
cp ./transform_csv.js ./transform_csv_$SUFFIXE.js



TABLE_ID=carbu_api_test_$SUFFIXE
bq rm -f -t $PROJECT_ID:$DATASET_ID.carbu_api_test_$SUFFIXE
bq mk --table $PROJECT_ID:$DATASET_ID.$TABLE_ID ./table_schema_bq_$SUFFIXE.json

# files transfert
gsutil cp ./table_schema_df_$SUFFIXE.json $BUCKET_URL_INPUT_FILES
gsutil cp ./instantane_$SUFFIXE.csv $BUCKET_URL_INPUT_FILES
gsutil cp ./transform_csv_$SUFFIXE.js $BUCKET_URL_INPUT_FILES

# GCS input file
INPUT_FILE_PATTERN_URL=$BUCKET_URL_INPUT_FILES/instantane_$SUFFIXE.csv
JSON_SCHEMA_FILE=$BUCKET_URL_INPUT_FILES/table_schema_df_$SUFFIXE.json
UDF_PATH=$BUCKET_URL_INPUT_FILES/transform_csv_$SUFFIXE.js

# BQ output table
BQ_OUTPUT_TABLE=$PROJECT_ID:$DATASET_ID.$TABLE_ID

# temporary directories
TEMP_BQ_LOCATION=$BUCKET_URL_TEMP/temp_dir_bq
TEMP_DF_LOCATION=$BUCKET_URL_TEMP/temp_dir_df

datetime_now=$(date '+%m%d_%H%M')

# dataflow job with bigquery storage API support
gcloud dataflow flex-template run job-$SUFFIXE-$datetime_now\
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

