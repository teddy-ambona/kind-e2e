'use strict';

const express = require('express');
const axios = require('axios')

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';
const BL_HOST = 'http://business-logic:8080';

// App
const app = express();

// Static Files
app.use(express.static('public_html'));

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public_html/index.html')
});

app.get('/slow-page', (req, res) => {
  axios.get(BL_HOST.concat('/slow-endpoint')).then(resp => {

    console.log(resp.data);
    res.send('Response from Django:'.concat(resp.data))
  })
});

app.get('/fast-page', (req, res) => {
  axios.get(BL_HOST.concat('/fast-endpoint')).then(resp => {

    console.log(resp.data);
  })
  res.send('Hello Fast!')
});

app.listen(PORT, HOST, () => {
  console.log(`Running on http://${HOST}:${PORT}`);
});
