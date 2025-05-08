# Stage 1: Builder Stage (to compile and build the application)
FROM registry.access.redhat.com/ubi9/nodejs-18 as builder

USER root

WORKDIR /app
COPY package*.json ./

# Configure npm to use /tmp for its cache and tmp files during build
# This ensures that even if root creates cache files, they are in a transient location
ENV NPM_CONFIG_CACHE=/tmp/.npm-cache
ENV NPM_CONFIG_TMP=/tmp

RUN npm install
COPY . ./
# RUN npm run build # If you have a build step (e.g., for React), otherwise omit

# Stage 2: Production Stage (minimal image)
FROM registry.access.redhat.com/ubi9/ubi-minimal

WORKDIR /app
# Copy only the necessary artifacts from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/index.js ./
COPY --from=builder /app/package*.json ./
# COPY --from=builder /app/dist ./dist # If you have a build step, copy the output

# Install Node.js and npm in the production stage
RUN microdnf install -y --nodocs nodejs && \
    microdnf clean all # Clean up to reduce image size

# Add these ENV variables again for the final stage to ensure npm still uses /tmp
# This handles any npm operations *during runtime* of the container
ENV NPM_CONFIG_CACHE=/tmp/.npm-cache
ENV NPM_CONFIG_TMP=/tmp

RUN chown -R 1001:0 /app

EXPOSE 8080

USER 1001

CMD ["npm", "start"]
