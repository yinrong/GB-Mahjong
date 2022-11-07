#include <pybind11/pybind11.h>
#include "console.h"
#include "fan.h"
#include "handtiles.h"
#include "print.h"
#include <iostream>
#include <vector>
#include <sstream>
#include <stdio.h>
#include <execinfo.h>
#include <csignal>
using namespace std;
#include <boost/stacktrace.hpp>
#include "tile.h"




int add(int i, int j) {
  return i + j;
}

void handler(int sig) {
  std::cout << boost::stacktrace::stacktrace();
}

void enableDebug () {
  g_debug = 1;
  signal(SIGSEGV, handler);   // install our handler
}


string calc (string hand, int hu);
PYBIND11_MODULE(mj, m) {
  m.doc() = "mj extension";
  m.def("add", &add, "example add");
  m.def("calc", &calc, "mj calc");
  m.def("enableDebug", &enableDebug, "enable debug");
}

//int main() {
//  cout << calc("[456s,1][456s,1][456s,3]45s55m |EE0000|fah", 15) << endl;
//  return 0;
//}

