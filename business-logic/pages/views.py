# More info on Open Telemetry here:
# https://github.com/open-telemetry/opentelemetry-python/blob/main/docs/examples/django/README.rst
import time
import os

from django.http import HttpResponse
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

from opentelemetry.propagate import set_global_textmap
from opentelemetry.propagators.b3 import B3MultiFormat
from opentelemetry.exporter.zipkin.json import ZipkinExporter

set_global_textmap(B3MultiFormat())

tracer = trace.get_tracer_provider().get_tracer(__name__)
zipkin_exporter = ZipkinExporter(
    endpoint=os.environ['ZIPKIN_URL'],
)

trace_provider = TracerProvider(resource=Resource.create({"service.name": "django-app"}))

# BatchSpanProcessor export spans in batches in order to more efficiently use resources.
span_processor = BatchSpanProcessor(zipkin_exporter)
trace_provider.add_span_processor(span_processor)

trace.set_tracer_provider(trace_provider)


def slowEndpoint(request):
    start = time.time()

    # Add a new span for the data transformation
    with tracer.start_as_current_span("data_transformation"):
        # Calling a very slow function
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
