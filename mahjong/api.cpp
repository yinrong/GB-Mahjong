#include "fan.h"
#include "console.h"
#include "handtiles.h"
#include <vector>
#include <sstream>
#include <execinfo.h>
#include <stdlib.h>
using namespace std;
#include "tile.h"

string calc (string hand, int hu) {
try {
  // 构造手牌
  mahjong::Handtiles ht;
  ht.StringToHandtiles(hand);
  if (ht.fulu.size() * 3 + ht.lipai.size() != 14) {
      return "";
  }

  mahjong::Fan fan;

  // 计算听牌
  // std::vector<mahjong::Tile> ting = fan.CalcTing(ht);
  // for (auto t : ting) {
  //   mahjong::StdPrintTile(t);
  // }

  // 判断是否铳和
  // cerr<<hand<<" "<<hu<<"\n";
  ht.SetTile(mahjong::Tile(hu));

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
} catch (exception &e) {
  cout << e.what() << endl;
  return "";
}
}



int quick_calc  (const std::vector<int> &tiles) {
try {
  // 构造手牌
  mahjong::Handtiles ht;
  ht.unsafeSetTilesFast(tiles);
  mahjong::Fan fan;
  fan.CountFan(ht);
  return fan.tot_fan_res;
} catch (exception &e) {
  return -1;
}
}

tuple<int, vector<string>> quick_calc_detail (const std::vector<int> &tiles) {
try {
  tuple<int, vector<string>> ret(0, vector<string>());

  // 构造手牌
  mahjong::Handtiles ht;
  ht.unsafeSetTilesFast(tiles);
  mahjong::Fan fan;
  fan.CountFan(ht);
  std::get<0>(ret) = fan.tot_fan_res;

  for (int i = 1; i < mahjong::FAN_QUANDAIYAO; i++) {
    if (fan.fan_table_res[i].size() == 0) { continue; }
    std::get<1>(ret).push_back(mahjong::FAN_NAME[i]);
  }
  if (std::get<1>(ret).size() == 0) {
    if (fan.tot_fan_res >= 8) {
        std::get<1>(ret).push_back("small");
    } else {
      for (int i = mahjong::FAN_QUANDAIYAO; i < mahjong::FAN_SIZE; i++) {
        if (fan.fan_table_res[i].size() == 0) { continue; }
        std::get<1>(ret).push_back("under");
        break;
      }
    }
  }
  return ret;
} catch (exception &e) {
  return tuple<int, vector<string>>(-1, vector<string>());
}
}