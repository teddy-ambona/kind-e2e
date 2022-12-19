import time

from django.http import HttpResponse


def slowEndpoint(request):
    start = time.time()
    end = time.time()
    return HttpResponse(f"I am a slow request that took {end - start} to complete.")


def fastEndpoint(request):
    start = time.time()
    end = time.time()
    return HttpResponse(f"I am a fast request that took {end - start} to complete.")
