# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Update the packages to ensure vulnerabilities are fixed
RUN apk update && \
    apk upgrade && \
    apk add --no-cache libexpat libxml2 libxslt

# Production stage
FROM nginx:alpine

# Update packages to reduce vulnerabilities in production
RUN apk update && \
    apk upgrade && \
    apk add --no-cache libexpat libxml2 libxslt

# Copy the build files to the Nginx container
COPY --from=build /app/dist /usr/share/nginx/html

# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]