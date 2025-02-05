FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /public

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of your application
COPY . .

# Expose the port your app will run on
EXPOSE 8080

# Run the application
CMD ["node", "index.js"]
