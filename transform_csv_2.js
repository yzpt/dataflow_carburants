/*
 * Copyright (C) 2023 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

/**
 * Sample UDF function to transform an incoming CSV line into a JSON object with
 * specific schema. Use this to transform lines of CSV files into a structured
 * JSON before writing to destinations like a BigQuery table.
 * Compatible Dataflow templates:
 * - Text Files on Cloud Storage to BigQuery
 * @param {string} line input CSV line string
 * @return {string} outJson output JSON (stringified)
 */
function process(line) {
  const values = line.split(',');

  // Create new obj and set each field according to destination's schema
  const obj = {
    id: values[0],
    record_timestamp: values[1],
    latitude: values[2],
    longitude: values[3],
    cp: values[4],
    pop: values[5],
    adresse: values[6],
    ville: values[7],
    horaires: values[8],
    services: values[9],
    gazole_maj: values[10],
    gazole_prix: values[11],
    sp95_maj: values[12],
    sp95_prix: values[13],
    e85_maj: values[14],
    e85_prix: values[15],
    gplc_maj: values[16],
    gplc_prix: values[17],
    e10_maj: values[18],
    e10_prix: values[19],
    sp98_maj: values[20],
    sp98_prix: values[21]
  };

  return JSON.stringify(obj);
}