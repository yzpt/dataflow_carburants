const { createReadStream, writeFile } = require('fs');
const csv = require('csv-parser');

function convertCsvToJson(csvFilePath, jsonFilePath) {
  const jsonArray = [];
  let counter = 0;

  createReadStream(csvFilePath)
    .pipe(csv())
    .on('data', (data) => {
      if (counter < 5) {
        jsonArray.push(data);
        counter++;
      } else {
        this.destroy(); // stop reading the CSV file
      }
    })
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