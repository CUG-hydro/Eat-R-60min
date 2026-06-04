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

