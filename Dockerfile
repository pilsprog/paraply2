FROM node:4.0.0-onbuild

MAINTAINER Snorre Magnus Davøen <snorremd@gmail.com>

RUN chmod +x /usr/src/app/entrypoint.sh

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]

# Re-enable default command
CMD [ "npm", "start" ]

# Run app at 8888
EXPOSE 8888
