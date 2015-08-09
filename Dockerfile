FROM node:0.12.7-onbuild

MAINTAINER Snorre Magnus Davøen <snorremd@gmail.com>

# Run app at 8888
EXPOSE 8888

# Expose config volume
VOLUME ["/usr/src/app/config"]