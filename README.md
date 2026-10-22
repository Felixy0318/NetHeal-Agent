# NetHeal-Agent

NetHeal-Agent 是基于 Co-Sight 的 5G 校园专网故障诊断与自愈**仿真演示项目**。它使用仓库内的合成告警、KPI、拓扑和知识库数据，演示取证、根因定位、审批、生成仿真工单、恢复验证及报告生成的闭环。

项目默认只生成 `dry_run` 命令，不连接或修改真实网元。仓库中的评测结果来自合成数据，不能作为真实网络的性能指标。

## 运行要求

- Python 3.11 或更新版本。
- 首次安装依赖需要访问 Python 软件包源。
- 使用 Co-Sight 的大模型功能时，在本机将 `.env_template` 复制为 `.env` 并填写所需配置。`.env` 不应提交到 Git。

## 启动

Windows：双击根目录的 **`启动项（首次运行需要安装依赖）.bat`**。首次运行会创建 `.venv`、安装依赖并执行测试；也可以在 PowerShell 中运行 `./START_NETHEAL.ps1`。

Linux/macOS：

```sh
sh START_NETHEAL.sh
```

启动后访问：

- NetHeal 运维中心：<http://localhost:7788/cosight/netheal.html>
- Co-Sight 工作台：<http://localhost:7788/cosight/>
- 健康检查：<http://localhost:7788/api/netheal/v1/health>

## 离线验证

在 Windows PowerShell 中完成首次安装后运行：

```powershell
.\.venv\Scripts\python.exe -m unittest discover -s tests -p "test_netheal*.py" -v
.\.venv\Scripts\python.exe -m app.netheal.acceptance_runner
```

场景和设计说明见 [场景包说明](app/netheal/README.md)、[技术方案](docs/netheal/technical_solution.md)与[部署说明](docs/netheal/DEPLOYMENT.md)。

## 当前边界

- 故障数据、修复执行和恢复指标均为本地仿真；真实网管接入仍需实现与验证。
- Docker Compose 默认启用生产鉴权，当前网页尚未接入 Bearer Token 登录；容器部署下的诊断、审批等写操作需要完成前端鉴权适配。
- `.venv/`、`.env`、日志、运行输出和赛事提交证据不属于公开仓库内容。

项目包含 Co-Sight 原有代码；版权与许可条款见 [LICENSE](LICENSE)。
