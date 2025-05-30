# Background Jobs Manager for Nextcloud AI

## Summary
Use the docker image defined here to speed up the AI assistant you use
with your self-hosted Nextcloud application. Without this, the AI
assistant will take 3-5 min for every task. Using the docker image
defined here, you'll get responses within seconds, rather than
minutes.

**Note:** This assumes you are running Nextcloud in a docker container using the `fpm-alpine` image of Nextcloud.

## Get It Here:

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-2CA5F2?style=for-the-badge&logo=docker&logoColor=white)](https://hub.docker.com/repository/docker/jogojapan/nextcloud-ai-background-jobs/general)

## Background
Since Nextcloud version 27, there is an AI Assistant app available for
it that provides LLM-based assistance (chat, summaries, translation
etc.) if you configure it with your API key, e.g. for OpenAI or
MistralAI.

The AI assistant integration is provided by [this Nextcloud
app](https://apps.nextcloud.com/apps/assistant) from the Nextcloud app
store, but it has a [well-documented
drawback](https://docs.nextcloud.com/server/latest/admin_manual/ai/overview.html#improve-ai-task-pickup-speed):

Every AI task (such as a question you ask ChatGPT to answer) needs to
be picked up by a background job, and by default, Nextcloud runs
background jobs only every 5 minutes. So, the task will be picked up
after 2.5 minutes on average, which is a delay you'll find
unacceptable.

The link above provides official documentation of how to fix this by
starting an infinite loop of background jobs on the commandline, or by
setting up background jobs through Systemd. Both approaches are
impractical if you are running Nextcloud as docker containers, esp. if
you use the [fpm-alpine](https://hub.docker.com/_/nextcloud/) image
for Nextcloud, which is relatively small (~315MB compressed), but
lacks Systemd and various other useful tool that would make it easier
to run a process that spawns background jobs automatically.

What I am providing here for convenience is a docker image derived
from Nextcloud fpm-alpine that you can add to your docker-compose
configuration. It will inherit the volumes and mappings from your
Nextcloud container and start background AI workers.

## Configuration
We will assume that your docker-compose looks something like this:

``` yaml
services:
  app:
    image: nextcloud:fpm-alpine
    restart: always
    ports:
      - 7077:9000
    volumes:
      - /volume1/nextcloud/shared_with_nginx:/var/www/html
      - /volume1/nextcloud/custom_apps:/var/www/html/custom_apps
      - /volume1/nextcloud/config:/var/www/html/config
      - /volume1/nextcloud/data:/var/www/html/data
    networks:
      - shared-backend
    env_file:
      - stack.env

  cron:
    image: nextcloud:fpm-alpine
    restart: always
    volumes_from:
      - app
    networks:
      - shared-backend
    entrypoint: /cron.sh

networks:
  shared-backend:
    external: true
```

(I am not including configurations for databases, redis etc. Probably
you'll have them defined in a separate docker-compose and running on a
network that you are sharing with your Nextcloud containers. The
`shared-backend` network I included above could be such a network.)

If you add the following to the `services` part of the docker-compose,
you'll get a single AI background worker running. Your AI tasks will
immediately be picked up within seconds rather than minutes:

``` yaml
  ai-workers:
    image: jogojapan/nextcloud-ai-background-jobs:latest
    restart: always
    volumes_from:
      - app
    networks:
      - shared-backend
```

## Config Parameters
### Number of Background Workers
If you'd like more than one background task picker running in parallel, you may configure this through an environment variable. E.g., for 2 parallel task pickers:

``` yaml
  ai-workers:
    image: jogojapan/nextcloud-ai-background-jobs:latest
    restart: always
    volumes_from:
      - app
    environment:
      - WORKER_INSTANCE=2
    networks:
      - shared-backend
```

### Restart Period
By default, the background worker thread will run for 120 seconds and then get retarted. This means if some configuration in the environment (say, the API key, or the system prompt) gets changed, it might take up to 120 seconds until the worker(s) are restarted and have adopted the new settings. If you don't make a lot of changes to the settings, or if you are ok for this to take longer, you may increase the restart period to a higher number using the `RESTART_PERIOD_SEC` environment variable. This will help you reduce CPU load:

``` yaml
  ai-workers:
    image: jogojapan/nextcloud-ai-background-jobs:latest
    restart: always
    volumes_from:
      - app
    environment:
      - RESTART_PERIOD_SEC=500
    networks:
      - shared-backend
```

## Building
If you want to build the docker image yourself, here is how to proceed:

1. Clone the repo from Github:
     ```bash
     git clone git@github.com:jogojapan/nextcloud-ai-background-jobs.git
     ```
1. Build the image (install Docker if you haven't yet):
    ```bash
    cd nextcloud-ai-background-jobs
    docker build -t nextcloud-ai-background-jobs:latest .
    ```
1. Include it in your docker-compose:
    ``` yaml
      ai-workers:
        image: nextcloud-ai-background-jobs:latest
        restart: always
        volumes_from:
          - app
        networks:
          - shared-backend
    ```
