# 服务器初始化配置系统

一个用于快速配置新服务器的模块化系统，提供完整的开发环境设置和常用工具部署。

机器学习领域的研究者在应用此项目配置好基础的开发环境后，可以按需配置conda环境。配置conda环境的流程不在本项目的范围。

## 目录结构

```bash
init_configuration/
├── setup/                      
│   ├── etc/                  
│   │   ├── bootstrap.sh      # 引导脚本
│   │   ├── update.sh         # 环境部署脚本
│   │   ├── init.sh           # 初始化脚本
│   │   ├── config.sh         # 会话配置脚本
│   │   └── function.sh       # 函数定义脚本
│   │
│   └── README.md             # 设置说明文档
│
└── packages/                   
    ├── bin/                   # 可执行文件
    ├── lib/                   # 程序库
    ├── docs/                  # 文档
    └── resources/             # 资源文件
        ├── conf/         # 配置文件
        ├── fonts/        # 字体文件
        ├── share/        # 共享资源
        └── softwares/    # 软件安装包
```

## 主要功能

### 1. 环境设置 (setup/)

- 自动配置服务器环境
- 设置开发工具链
- 配置系统环境变量
- 部署常用函数和别名

### 2. 应用程序 (packages/)

- 命令行工具（如 cheat 命令）
- Python 工具库
- 开发环境配置
- 常用软件包

## 部署说明

系统会将文件部署到 `~/.local/` 目录下，遵循标准的 Unix 目录结构：

### 部署对应关系

```bash
~/.local/
├── bin/        # <-- packages/bin/
├── etc/        # <-- setup/etc/
├── lib/        # <-- packages/lib/
└── share/      # <-- 可选
```

### 部署过程

1. **初始化阶段** (bootstrap.sh)
   - 创建必要的目录结构
   - 设置正确的权限
   - 调用 update.sh 进行部署

2. **部署阶段** (update.sh)
   - 复制配置脚本到 ~/.local/etc/
   - 复制可执行文件到 ~/.local/bin/
   - 复制程序库到 ~/.local/lib/
   - 复制共享资源到 ~/.local/share/ （可选）

3. **配置阶段**
   - 在 ~/.bashrc 中添加对 ~/.local/etc/init.sh 的引用

## 快速开始

1. 获取引导脚本：

```bash
# 方法一：直接从 GitHub 下载
curl -O https://raw.githubusercontent.com/huangwei0102/init_configuration/main/setup/etc/bootstrap.sh

# 方法二：手动复制
从 GitHub 页面复制 setup/etc/bootstrap.sh 的内容到本地文件
```

2. 设置执行权限并运行引导脚本：

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

3. 重新登录以使配置生效

## 系统要求

- Linux/Unix 操作系统
- Bash 4.0+ 或 Zsh
- Python 3.6+
- Git

## 配置说明

1. **环境设置**
   - 详见 [setup/README.md](setup/README.md)

2. **工具使用**
   - 详见 [packages/README.md](packages/README.md)
