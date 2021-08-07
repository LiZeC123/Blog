import io
import os
import sys
import json
import random

# 处理编码问题
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

configPath = "../_config/currentSlideName.json"

def readDictFromFile(filename):
    with open(filename,"r",encoding="utf8") as f:
        return json.loads(f.read())

def writeDictToFile(filename, data):
    with open(filename,"w",encoding="utf8") as f:
        f.write(json.dumps(data))

def find_first():
    for idx in range(1, 100):
        if not os.path.exists(f"current_{idx}.md"):
            return f"current_{idx}.md"

def makeNewSlide(filename:str):
    if os.path.exists(configPath):
        info = readDictFromFile(configPath)
    else:
        info = {}
    
    newName = find_first()
    os.system(f"mv ../_posts/{filename}.md {newName}")
    info[newName] = filename

    writeDictToFile(configPath,info)
        


def publishSlide(idx:str):
    if os.path.exists(configPath):
        info = readDictFromFile(configPath)
    else:
        raise EOFError("No File Need to be published")
    
    name = f"current_{idx}.md"
    if name in info:
        real_name = info[name]
        os.system(f"mv {name} {real_name}.md") 
        del info[name]
        writeDictToFile(configPath,info)
        print("文章发布后请同步更新索引文件")
    else:
        raise ValueError("指定的索引无效")

def show_list():
    if os.path.exists(configPath):
        info = readDictFromFile(configPath)
    else:
        info = {}
    
    for key,value in info.items():
        print(f"{key} --> {value}")

def print_help():
    print("SlideHelper 需要指定至少一个参数, 参数列表如下:")
    print("new        : 创建一个新Slide")
    print("pub <id>   : 从草稿发布Slide")
    print("show       : 显示Slide草稿列表")

if __name__ == "__main__":
    if len(sys.argv) >= 2:
        if sys.argv[1] == "new":
            makeNewSlide(sys.argv[2])
        elif sys.argv[1] == "pub":
            publishSlide(sys.argv[2])
        elif sys.argv[1] == "show":
            show_list()
    else:
        print_help()