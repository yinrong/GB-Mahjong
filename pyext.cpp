#include <pybind11/pybind11.h>
#include "console.h"
#include "fan.h"
#include "handtiles.h"
#include "print.h"
#include <iostream>
#include <vector>
#include <sstream>
using namespace std;


string calc (string hand, int hu) {
  // 构造手牌
  mahjong::Handtiles ht;
  ht.StringToHandtiles(hand);

  mahjong::Fan fan;

  // 计算听牌
  // std::vector<mahjong::Tile> ting = fan.CalcTing(ht);
  // for (auto t : ting) {
  //   mahjong::StdPrintTile(t);
  // }

  // 判断是否铳和
  ht.SetTile(hu);

  std::ostringstream ret("", std::ios_base::ate);
  ret << "牌：" << ht.HandtilesToString() << endl;
  ret << "是否和牌：" << fan.JudgeHu(ht) << endl;

  // 摸牌并算番
  // ht.DiscardTile(); // 出牌
  // ht.DrawTile(mahjong::Tile(TILE_6s)); // 摸牌
  fan.CountFan(ht); // 计番
  ret << "总番数：" << fan.tot_fan_res << endl;
  for (int i = 1; i < mahjong::FAN_SIZE; i++) { // 输出所有的番
    for (size_t j = 0; j < fan.fan_table_res[i].size(); j++) {
      ret << mahjong::FAN_NAME[i] << " " << mahjong::FAN_SCORE[i] << "番";
      std::string pack_string;
      for (auto pid : fan.fan_table_res[i][j]) { // 获取该番种具体的组合方式
        pack_string += " " + mahjong::PackToEmojiString(fan.fan_packs_res[pid]);
      }
      ret << pack_string;
      ret << endl;
    }
  }

  return ret.str();
}

int add(int i, int j) {
  return i + j;
}

PYBIND11_MODULE(mj, m) {
  m.doc() = "mj extension";
  m.def("add", &add, "example add");
  m.def("calc", &calc, "mj calc");
}

//int main() {
//  cout << calc("[456s,1][456s,1][456s,3]45s55m |EE0000|fah", 15) << endl;
//  return 0;
//}

