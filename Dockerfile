# syntax=docker/dockerfile:1

# ================================
# Stage 1: Build Angular application
# ================================
FROM node:24-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with cache mount (persists between builds)
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# Copy source code and build
COPY . .
RUN npm run build -- --configuration=production

# ================================
# Stage 2: Serve with Nginx
# ================================
FROM nginx:alpine

ARG APP_NAME=olympic-games-starter

COPY nginx/nginx.conf /etc/nginx/nginx.conf
RUN rm -f /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/${APP_NAME}/browser/ /app/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
