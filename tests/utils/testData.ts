import * as fs from 'fs';
import * as path from 'path';

export function getLoanData() {
  const filePath = path.resolve(__dirname, '../fixtures/loanData.json');
  const rawData = fs.readFileSync(filePath, 'utf-8');
  return JSON.parse(rawData);
}
