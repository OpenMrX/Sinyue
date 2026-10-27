# 星月

---
<p align="center">
  <img src="./Assets/Moc.jpg" alt="Moc 预览图" width="500">
</p>

## 构建

工具链：Clang + Ninja + sccache，依赖由 CPM 拉取并缓存在 `.cpmcache/`，
构建系统基于 [abcmake](https://github.com/an-dr/abcmake) 的组件约定。

```bash
# 首次：检查工具链 + 预热 CPM 缓存
./scripts/bootstrap.ps1

# 编译（debug / release）
./scripts/build.ps1 -Config debug -Run
./scripts/build.ps1 -Config release

# 清理
./scripts/clean.ps1
```

也可以直接使用 CMake Presets：

```bash
cmake --preset clang-debug
cmake --build --preset clang-debug
```

在 VS Code 中打开本目录即可：`.vscode/` 已配置好预设、构建任务与调试启动项。

## 目录结构

```
CMakeLists.txt              主组件（add_main_component，SOURCE_DIR=src/App）
CMakePresets.json           clang-debug / clang-release 预设
cmake/                      CPM.cmake、CPMCache.cmake、Sccache.cmake
src/
  App/                      应用入口 AppMain.cpp
  Components/               库组件（每个目录一份 add_component，PascalCase）
    Core/                   基础模块：Core::appName() / Core::version()
    Logger/                 日志组件（占位）：Logger::info()，依赖 Core::Core
scripts/                    引导、构建、清理、缓存统计脚本
.cpmcache/                  CPM 依赖缓存（不提交）
```
