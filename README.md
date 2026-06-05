# 1 scoop

```powershell
# or shorter
iwr -useb get.scoop.sh | iex
Note: if you get an error you might need to change the execution policy (i.e. enable Powershell) with

Set-ExecutionPolicy RemoteSigned -scope CurrentUser
```

## 2 R语言环境

```bash
# scoop install git R arf
# scoop update git R arf
scoop install git 
scoop install R 
scoop install arf
```

## R语言 VSCode 快捷键
- `ctrl+shift+l` : load_all
- `ctrl+r`       : run 1 line
- `ctrl+enter`   : run 1 chunk
- `ctrl+shift+i` : insert chunk
- `f12`          : go to definition
