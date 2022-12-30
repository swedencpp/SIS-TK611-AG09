# About this docs

This site uses mkdoc, material theme with some nice extensions.

For fluid documentation writing, there is a docker container in the repo.
This can be used to start a local server with the documentation and having live preview when editing content.

## Running the development environment

In the root folder is a docker file. Use this to run the page in developer mode.

First, build the container

```bash
docker build -t tk611-ag09-doc -f Dockerfile .
```

Run it and mount the folder into the containers working directory.
Two ports, the listening and one for the live reload feature, need to be provided.

And then we can run the mkdocs developer server.

The whole command looks like this:

```bash
docker run --rm -it \
    -v $(pwd):/home/ag09 -w /home/ag09 \
    -p 127.0.0.1:8000:8000 -p 127.0.0.1:35729:35729 \
    tk611-ag09-doc mkdocs serve -a 0.0.0.0:8000
```

Open a browser at [http://localhost:8000/SIS-TK611-AG09/](http://localhost:8000/SIS-TK611-AG09/)

Now you can start editing documents. Whenever the content changes, the page will be rebuilt and the website refreshed.

Happy documentation writing!
