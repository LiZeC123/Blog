#! /bin/bash

function update() {
  git pull
  docker pull ghcr.io/lizec123/blog:latest
  docker-compose down
  docker-compose up -d
}


if [ "$1"x == "backup"x ]; then
  # 博客由于在Github存在备份, 因此不再手动备份
  :
elif [ "$1"x == "update"x ]; then
  update
else
  echo "无效的参数: $1"
  echo ""
  echo "用法: ./service [参数]"
  echo "参数可以选择以下值:"
  echo "backup    备份数据文件"
  echo "update    更新项目代码并重启"
  echo ""
fi
