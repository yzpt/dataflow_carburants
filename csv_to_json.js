const { createReadStream, writeFile } = require('fs');

// npm install csv-parser
const csv = require('csv-parser');

function convertCsvToJson(csvFilePath, jsonFilePath) {
  const jsonArray = [];

  createReadStream(csvFilePath)
    .pipe(csv())
    .on('data', (data) => jsonArray.push(data))
    .on('end', () => {
      writeFile(jsonFilePath, JSON.stringify(jsonArray, null, 2), (error) => {
        if (error) {
          console.error('Error writing JSON file:', error);
        } else {
          console.log('CSV file converted to JSON successfully!');
        }
      });
    });
}

// Usage example:
convertCsvToJson('instantane.csv', 'data.json');
