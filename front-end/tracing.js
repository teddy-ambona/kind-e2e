/* cf:
   https://opentelemetry.io/docs/instrumentation/js/instrumentation/
   https://github.com/open-telemetry/opentelemetry-js/issues/3045
*/
const opentelemetry = require("@opentelemetry/api");
const { Resource } = require("@opentelemetry/resources");
const { SemanticResourceAttributes } = require("@opentelemetry/semantic-conventions");
const { NodeTracerProvider } = require("@opentelemetry/sdk-trace-node");
const { registerInstrumentations } = require("@opentelemetry/instrumentation");
const { ZipkinExporter } = require("@opentelemetry/exporter-zipkin");
const { BatchSpanProcessor } = require("@opentelemetry/sdk-trace-base");
const { HttpInstrumentation } = require('@opentelemetry/instrumentation-http');
const { ExpressInstrumentation } = require('@opentelemetry/instrumentation-express');
const { CompositePropagator } = require('@opentelemetry/core');
const { B3Propagator, B3InjectEncoding } = require("@opentelemetry/propagator-b3");

// Register instrumentation libraries
registerInstrumentations({
  instrumentations: [
    // Express instrumentation expects HTTP layer to be instrumented
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
  ],
});

const resource =
  Resource.default().merge(
    new Resource({
      [SemanticResourceAttributes.SERVICE_NAME]: "node-js-app",
      [SemanticResourceAttributes.SERVICE_VERSION]: "0.1.0",
    })
  );

const provider = new NodeTracerProvider({
  resource: resource,
});

const options = {
  url: process.env.ZIPKIN_URL
}
const exporter = new ZipkinExporter(options);

// BatchSpanProcessor export spans in batches in order to more efficiently use resources.
const processor = new BatchSpanProcessor(exporter);
provider.addSpanProcessor(processor);

// provider.register();
provider.register({
  propagator: new CompositePropagator({
    propagators: [
      new B3Propagator(),
      new B3Propagator({ injectEncoding: B3InjectEncoding.MULTI_HEADER })
    ]
  })
});