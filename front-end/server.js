'use strict';

const express = require('express');
const axios = require('axios');
const opentelemetry = require("@opentelemetry/api");
const { B3Propagator } = require("@opentelemetry/propagator-b3");
const { context, propagation, trace, ROOT_CONTEXT } = require("@opentelemetry/api");
const { AsyncHooksContextManager } = require("@opentelemetry/context-async-hooks");

// Set global propagator
propagation.setGlobalPropagator(new B3Propagator());

// Set global context manager
const contextManager = new AsyncHooksContextManager();
contextManager.enable();
context.setGlobalContextManager(contextManager);

// Constants
const PORT = process.env.PORT;
const HOST = process.env.HOST;
const BL_HOST = process.env.BL_HOST;

// App
const app = express();

// Static Files
app.use(express.static('public_html'));

const tracer = opentelemetry.trace.getTracer(
  'front-end-tracer'
);

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public_html/index.html')
});

app.get('/slow-page', (req, res) => {
  // Extract context from the incoming request headers
  context.with(propagation.extract(ROOT_CONTEXT, req.headers), () => {

    // Create a custom span. A span must be closed.
    tracer.startActiveSpan('slow-page-custom-span', span => {

      // This is where we manually inject the context in the HTTP headers
      const headers = {};
      propagation.inject(context.active(), headers);

      // Call business-logic api
      axios.get(`${BL_HOST}/slow-endpoint`, {headers}).then(resp => {
        // Be sure to end the custom span!
        span.end();
        console.log(resp.data);
        res.send(`Response from Django: ${resp.data}`)
      })
    });
  });
});

app.get('/fast-page', (req, res) => {
  // Extract context from the incoming request headers
  context.with(propagation.extract(ROOT_CONTEXT, req.headers), () => {

    // This is where we manually inject the context in the HTTP headers
    const headers = {};
    propagation.inject(context.active(), headers);

    // Call business-logic api
    axios.get(`${BL_HOST}/fast-endpoint`, {headers}).then(resp => {
      console.log(resp.data);
    })
    res.send('Hello Fast!')
  });
});

app.listen(PORT, HOST, () => {
  console.log(`Running on http://${HOST}:${PORT}`);
});
