# Alpine, Nginx, PHP development environment

> Compatible with Laravel application development

## Included Software
- Apline Linux
- PHP 7.1
- Nginx
- Composer

Running a container
-------------------

**1.** Download the public Docker image from Dockerhub:

		docker pull lkmadushan/nginx-php-alpine

**2.** Run the Docker image as a new Docker container:

		docker run -d \
		-p 80:80 \
		-v .:/var/www/html \
		lkmadushan/nginx-php-alpine

Replace '.' with the path to the Laravel application's root directory in
the host. This directory is a shared volume and so can be used to access the
application files in either the host or the container.