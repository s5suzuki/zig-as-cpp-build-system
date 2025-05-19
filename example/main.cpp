#include <iostream>

#include "lib.hpp"

int main() {
  int32_t a = 5;
  int32_t b = 10;
  int32_t result = add(a, b);
  std::cout << a << " + " << b << " = " << result << std::endl;
  return 0;
}