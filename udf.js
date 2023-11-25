const { createReadStream } = require('fs');
const csv = require('csv-parser');
const { promisify } = require('util');
const pipeline = promisify(require('stream').pipeline);
const { Writable } = require('stream');

async function convertCsvToJsonString(csvFilePath) {
  const jsonArray = [];

  await pipeline(
    createReadStream(csvFilePath),
    csv(),
    new Writable({
      objectMode: true,
      write(data, _, done) {
        jsonArray.push(data);
        done();
      }
    })
  );

  return JSON.stringify(jsonArray, null, 2);
}

// Usage example:
// convertCsvToJsonString('instantane.csv')
//   .then(jsonString => console.log(jsonString))
//   .catch(console.error);