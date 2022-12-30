FROM python:3.11-alpine

RUN apk add --no-cache  \
  plantuml~=1 \
  graphviz~=7.0 \
  freetype=~2.12 ttf-dejavu~=2.37

ENV LD_LIBRARY_PATH /usr/lib
COPY requirements.txt /tmp
RUN pip install --no-cache-dir -r /tmp/requirements.txt
ENV PLANTUML_BIN=/usr/bin/plantuml
EXPOSE 8000 35729

