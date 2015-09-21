# paraply2

Remake of the old Paraply.

Paraply is a super simple event aggregator which can fetch events from
Facebook, Meetup and Eventbrite and save/display events in a standardised
format.

## Run from source

You need Node.js and Elastic Search installed.

```npm install -g coffee-script forever && npm install```

You should add your own api-keys and settings in a `config/config.coffee`.
You can copy the `config.coffee-dist.coffee` file and use it as an example.
The config example file should be fairly self explanatory.

Note that you need an ElasticSearch server to run Paraply2.

You can now start Paraply2 on your host with:

```forever -c coffee index.coffee```

Paraply 2 should now run on http://localhost:8888

## Run in Docker

Docker is the answer to life, the universe, and everything. So of course we
offer a docker alternative. A docker image of Paraply should be available under
`pilsprog/paraply2`. The image tagged `latest` should be a build of the latest
commit in the master branch. Other builds follow the github releases tags.

To run Paraply2 with Docker install docker, docker-compose. See
[Docker docs](https://docs.docker.com/installation/) for more information.
The docker toolbox is recommended for OS X users.

Then copy the `docker-compose.yml-dist` file to a `docker-compose.yml` file,
and edit the file to set up the docker containers as you want.

The api keys should be supplied without qoutation marks. Example:
```
- FACEBOOK_SECRET_KEY=908af09a8sf098foobarbaz
```

Now you should be able to run `docker-compose up -d`. Run `docker-compose logs`
to see how the containers are behaving.

Note! The paraply2 node application will attempt to connect to ElasticSearch
before ElasticSearch is finished starting up in the ElasticSearch container.
This causes the paraply2 app to report failure to connect to the ElasticSearch
cluster. This is to be expected, and connection retries has been implemented to
handle this.
