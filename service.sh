#! /bin/sh

function compileService() {
  true
}

function runService() {
    docker build -f docker/hexo/Dockerfile -t hexo .
    docker run --cpus 0.85 -m 200M --memory-swap -1 -v $(pwd):/app hexo
    docker build -f docker/nginx/Dockerfile -t blog .
    docker run -d -p 7080:80 blog  
}

function stopService() {
  runID=$(docker ps | awk '$2=="blog"  {print $1}')

  if [ $runID ]; then
    docker stop $runID
  fi

}

function backup() {
  zip -r Blog.zip . -x "node_modules/*" -x  "public/*" -x ".git/*" 
}

if [ "$1"x == "start"x ]; then
  compileService
  runService
elif [ "$1"x == "compile"x ]; then
  compileService
elif [ "$1"x == "run"x ]; then
  runService
elif [ "$1"x == "stop"x ]; then
  stopService
elif [ "$1"x == "restart"x ]; then
  stopService
  compileService
  runService
elif [ "$1"x == "backup"x ]; then
  backup
else
  echo "无效的参数: $1"
  echo ""
  echo "用法: ./service [参数]"
  echo "参数可以选择以下值:"
  echo "start     编译并启动项目"
  echo "stop      停止项目"
  echo "restart   重启项目"
  echo "compile   只编译项目"
  echo "run       直接运行项目"
  echo "backup    备份数据文件"
  echo ""
fi








