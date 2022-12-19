'use strict';

const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();

// Static Files
app.use(express.static('public_html'));

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public_html/index.html')
});

app.get('/slow_page', (req, res) => {
  res.send('Hello Slow!')
});

app.get('/fast_page', (req, res) => {
  res.send('Hello Fast!')
});

app.listen(PORT, HOST, () => {
  console.log(`Running on http://${HOST}:${PORT}`);
});
