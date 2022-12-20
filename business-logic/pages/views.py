# More info on Open Telemetry here:
# https://github.com/open-telemetry/opentelemetry-python/blob/main/docs/examples/django/README.rst
import time

from django.http import HttpResponse
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
    ConsoleSpanExporter,
)

trace.set_tracer_provider(TracerProvider())

trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(ConsoleSpanExporter())
)


def slowEndpoint(request):
    start = time.time()
    end = time.time()
    return HttpResponse(f"I am a slow request that took {end - start} to complete.")


def fastEndpoint(request):
    start = time.time()
    end = time.time()
    return HttpResponse(f"I am a fast request that took {end - start} to complete.")
