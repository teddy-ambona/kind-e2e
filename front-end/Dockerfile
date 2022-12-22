FROM node:19

RUN groupadd -r user && useradd -r -g user app

RUN mkdir -v /app && chown -R app /app

# Create app directory
WORKDIR /app

# Install app dependencies
COPY package*.json ./

RUN npm install

# Bundle app source
COPY server.js ./
COPY tracing.js ./
COPY public_html ./public_html

# Using non-root user to reduce vulnerabilities
USER app

# Expose port on which the NodeJS app is listening
EXPOSE 8080

CMD [ "node", "--require", "./tracing.js", "server.js" ]
