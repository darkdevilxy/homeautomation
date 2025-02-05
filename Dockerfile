FROM public.ecr.aws/docker/library/node:18-alpine
 

WORKDIR /app  
COPY package.json package-lock.json ./  
RUN npm install --only=production  

COPY . .  

CMD ["node", "server.js"]  
EXPOSE 3000  
