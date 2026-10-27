#include "Logger.hpp"

#include "Core.hpp"

#include <iostream>

namespace Logger {

void info(const char* message) {
    std::cout << "[INFO] " << message
              << "  [" << Core::appName() << " " << Core::version() << "]\n";
}

}  // namespace Logger
