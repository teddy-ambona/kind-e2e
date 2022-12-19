# Fetch a compatible version with 3.10.* including the latest patch release
FROM python:3.10

RUN groupadd -r user && useradd -r -g user app

RUN pip install pip -U && pip install pip-tools

RUN mkdir -v /app && chown -R app /app

WORKDIR /app

# Set environment variables
# Python won’t try to write .pyc files on the import of source modules
ENV PYTHONDONTWRITEBYTECODE 1
# Ensuer that the stdout and stderr streams are sent straight to terminal
ENV PYTHONUNBUFFERED 1

# Install requirements.txt in new instruction to benefit from the layer caching system.
COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY django_project ./django_project
COPY pages ./pages/
COPY manage.py ./manage.py

# Using non-root user to reduce vulnerabilities
USER app

# Expose port on which the Django app is listening
EXPOSE 8000

ENTRYPOINT ["python3"]
CMD ["manage.py", "runserver", "0.0.0.0:8000", "--noreload"]
