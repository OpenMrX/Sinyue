#include <iostream>

#include "Core.hpp"
#include "Logger.hpp"

auto main() -> int {
    std::cout << Core::appName() << " " << Core::version() << std::endl;
    Logger::info("application started");
    return 0;
}
