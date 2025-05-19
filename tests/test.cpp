#include "gtest/gtest.h"
#include "lib.hpp"

TEST(Lib, AddInt32) { EXPECT_EQ(add(1, 2), 3); }
TEST(Lib, AddVector3d) { EXPECT_EQ(add(Eigen::Vector3d(0, 1, 2), Eigen::Vector3d(3, 4, 5)), Eigen::Vector3d(3, 5, 7)); }
