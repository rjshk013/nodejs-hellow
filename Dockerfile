# Stage 1: Build the application
FROM node:12 AS build

WORKDIR /usr/src/app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./

RUN npm install

# Copy the application code
COPY . .

# Build the application (if needed)
# RUN npm run build

# Stage 2: Create a smaller production image
FROM node:12-alpine

WORKDIR /usr/src/app

# Copy the app from the previous stage
COPY --from=build /usr/src/app .

EXPOSE 8000

CMD [ "node", "server.js" ]
