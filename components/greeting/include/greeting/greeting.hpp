#pragma once

#include <string>

namespace greeting {

/// Builds the greeting line the application prints.
[[nodiscard]] std::string hello(const std::string& name);

}  // namespace greeting
