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
gcloud dataflow flex-template run api-carbu-data-$SUFFIXE\
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

