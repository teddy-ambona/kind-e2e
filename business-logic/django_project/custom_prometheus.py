from django_prometheus.middleware import (
    PrometheusAfterMiddleware,
)
from django_prometheus.utils import TimeSince


class PrometheusAfterMiddlewareWithExemplar(PrometheusAfterMiddleware):
    def process_response(self, request, response):
        method = self._method(request)
        name = self._get_view_name(request)
        status = str(response.status_code)
        self.label_metric(
            self.metrics.responses_by_status, request, response, status=status
        ).inc(exemplar={'trace_id': 'abc123'})
        self.label_metric(
            self.metrics.responses_by_status_view_method,
            request,
            response,
            status=status,
            view=name,
            method=method,
        ).inc(exemplar={'trace_id': 'abc123'})
        if hasattr(response, "charset"):
            self.label_metric(
                self.metrics.responses_by_charset,
                request,
                response,
                charset=str(response.charset),
            ).inc()
        if hasattr(response, "streaming") and response.streaming:
            self.label_metric(self.metrics.responses_streaming, request, response).inc()
        if hasattr(response, "content"):
            self.label_metric(
                self.metrics.responses_body_bytes, request, response
            ).observe(len(response.content), {'trace_id': 'abc123'})
        if hasattr(request, "prometheus_after_middleware_event"):
            self.label_metric(
                self.metrics.requests_latency_by_view_method,
                request,
                response,
                view=self._get_view_name(request),
                method=request.method,
            ).observe(TimeSince(request.prometheus_after_middleware_event), {'trace_id': 'abc123'})
        else:
            self.label_metric(
                self.metrics.requests_unknown_latency, request, response
            ).inc(exemplar={'trace_id': 'abc123'})
        return response
