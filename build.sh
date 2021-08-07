#! /bin/sh

docker build -f docker/hexo/Dockerfile -t hexo .

docker run --cpus 0.85 -m 200M --memory-swap -1 -v $(pwd):/app hexo

docker build -f docker/nginx/Dockerfile -t blog .

docker run -d -p 7080:80 blog  
