from django.urls import path
from pages.views import slowEndpoint, fastEndpoint

urlpatterns = [
    path("slow-endpoint", slowEndpoint, name="slow_endpoint"),
    path("fast-endpoint", fastEndpoint, name="fast_endpoint"),
]
