#pragma once

namespace Core {

// 基础模块（foundation）：提供应用元信息，供主程序与 Logger 等其它组件复用。
[[nodiscard]] const char* appName();
[[nodiscard]] const char* version();

}  // namespace Core
