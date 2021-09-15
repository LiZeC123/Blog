function backup() {
  echo "Zip Blog..."
  zip -r Blog.zip . -x "node_modules/*" -x  "public/*" -x ".git/*" > /dev/null
  echo "Done."
}


if [ "$1"x == "backup"x ]; then
  backup
else
  echo "无效的参数: $1"
  echo ""
  echo "用法: ./service [参数]"
  echo "参数可以选择以下值:"
  echo "backup    备份数据文件"
  echo ""
fi
