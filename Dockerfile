### Ingenspark Main WebApplication Docker
FROM node:16.14 as dev-build
# Set the working directory
WORKDIR /usr/local/ingenspark/
# Add the source code to app
COPY . /usr/local/ingenspark

# Install all the dependencies
RUN npm install -g @angular/cli
RUN npm install

# Generate the build of the application
RUN ng build --base-href https://ingendev01.ingenspark.com/ --configuration

# Stage 2: Serve app with nginx server

# Use official nginx image as the base image
FROM nginx:latest
RUN apt-get update
RUN apt-get install -y vim
RUN apt-get install -y nano
# Create SSL Directory and copy certificates to ssl directory
RUN mkdir -p /etc/nginx/ssl
COPY ./ingenspark_cert.crt /etc/nginx/ssl
COPY ./ingenspark_wc_private.key /etc/nginx/ssl
RUN chown -R root:root /etc/nginx/ssl
RUN chmod -R 600 /etc/nginx/ssl
# Copy the build output to replace the default nginx contents.
COPY --from=dev-build /usr/local/ingenspark/dist/ /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY ./ingendev.conf /etc/nginx/conf.d/
EXPOSE 80
EXPOSE 443
EXPOSE 4200
