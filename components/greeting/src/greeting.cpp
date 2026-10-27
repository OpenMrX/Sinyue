#include "greeting/greeting.hpp"

namespace greeting {

std::string hello(const std::string& name) {
    return "hello " + name;
}

}  // namespace greeting
