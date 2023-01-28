# More info on Open Telemetry here:
# https://github.com/open-telemetry/opentelemetry-python/blob/main/docs/examples/django/README.rst
import time
import os
import logging

from django.http import HttpResponse
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.propagate import set_global_textmap
from opentelemetry.propagators.b3 import B3MultiFormat
from opentelemetry.exporter.zipkin.json import ZipkinExporter
from opentelemetry.instrumentation.logging import LoggingInstrumentor

set_global_textmap(B3MultiFormat())

tracer = trace.get_tracer_provider().get_tracer(__name__)
zipkin_exporter = ZipkinExporter(
    endpoint=os.environ['ZIPKIN_URL'],
)

trace_provider = TracerProvider(resource=Resource.create({"service.name": "business-logic"}))

# BatchSpanProcessor export spans in batches in order to more efficiently use resources.
span_processor = BatchSpanProcessor(zipkin_exporter)
trace_provider.add_span_processor(span_processor)

trace.set_tracer_provider(trace_provider)

# Override logger format which with trace id and span id
# The integration uses the following logging format by default:
# %(asctime)s %(levelname)s [%(name)s] [%(filename)s:%(lineno)d] [trace_id=%(otelTraceID)s span_id=%(otelSpanID)s resource.service.name=%(otelServiceName)s] - %(message)s
# cf https://opentelemetry-python-contrib.readthedocs.io/en/latest/instrumentation/logging/logging.html
LoggingInstrumentor().instrument(set_logging_format=True)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def slowEndpoint(request):
    start = time.time()

    # Add a new span for the data transformation
    with tracer.start_as_current_span("data_transformation"):
        # Calling a very slow function
        logger.info("Calling the slow function 'data_transformation'")
        data_transformation(None)
    end = time.time()
    return HttpResponse(f"I am a slow request that took {end - start} to complete.")


def fastEndpoint(request):
    return HttpResponse("I am a fast request")


def data_transformation(df):
    """
    This is a mock function that is slow to complete.

    Parameters
    ----------
    df: pd.DataFrame

    Returns
    -------
    pd.DataFrame
    """
    time.sleep(3)
    return df
