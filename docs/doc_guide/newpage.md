# Adding a new page

You can add a page either directly on github, or checkout the repo and do it locally.
Working local gives you the chance to preview changes before they are published.

Adding a new page needs two steps.

- Add the new page on the location you want tho have it
- Edit the `docs/PAGE_MAP.md` file so it becomes visible in the menu structure

The `PAGE_MAP.md` should be self explaining.

## Containerized workflow

For fluid documentation writing there is a docker container in the repo.
This can be used to start a local server with the documentation and having live preview when editing content.

### Build the container

In the root folder is a docker file. Use this to run the page in developer mode.

First, build the container

```bash
docker build -t tk611-ag09-doc -f Dockerfile .
```

### Run the container

Run the container and mount the folder into the containers working directory.
Two ports, for listening and the live reload feature, need to be bound.

Then we can run the mkdocs developer server.

The whole command looks like this:

```bash
docker run --rm -it \
    -v $(pwd):/home/ag09 -w /home/ag09 \
    -p 127.0.0.1:8000:8000 -p 127.0.0.1:35729:35729 \
    tk611-ag09-doc mkdocs serve -a 0.0.0.0:8000
```

## Local workflow

It's also possible to easily work without using docker, even if the docker way is the prefered one.

Tow work without docker you need a python3 environment.
I recommend using [python3 venv](https://docs.python.org/3/library/venv.html) to create one, but details are up to you.

For running the documentation you need to install the required pips, and a [PlantUML](https://plantuml.com) installation.

The required pips can be installed with `pip install -r requirements.txt`.

For the [PlantUML](https://plantuml.com) installation, please visit the [PlantUML](https://plantuml.com) documentation.

For starting the local development server run `mkdocs serve`.

## Live preview and edit

Open a browser at [http://localhost:8000/SIS-TK611-AG09/](http://localhost:8000/SIS-TK611-AG09/)

Now you can start editing documents. Whenever the content changes, the page will be rebuilt and the website in the browser refreshes automatically.

**Happy documentation writing!**
