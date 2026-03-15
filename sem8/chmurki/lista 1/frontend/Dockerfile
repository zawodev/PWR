FROM node:20-alpine AS build
WORKDIR /app

ARG VITE_API_URL=http://localhost:8000
ENV VITE_API_URL=$VITE_API_URL
ENV NPM_CONFIG_FUND=false
ENV NPM_CONFIG_AUDIT=false

COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY tsconfig.json tsconfig.app.json index.html ./
COPY src ./src

RUN npm run build

FROM nginx:1.27-alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
