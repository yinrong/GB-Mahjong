#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include "fan.h"
#include "handtiles.h"
#include <vector>
#include <string>
#include <tuple>

namespace py = pybind11;

std::vector<int> apiv2_calc_ting(const std::string &hand) {
    try {
        mahjong::Handtiles ht;
        ht.StringToHandtiles(hand);
        mahjong::Fan fan;
        std::vector<mahjong::Tile> ting = fan.CalcTing(ht);
        std::vector<int> ting_tiles;
        for (const auto &t : ting) {
            ting_tiles.push_back(t.GetId());
        }
        return ting_tiles;
    } catch (const std::exception &e) {
        return {};
    }
}

std::tuple<bool, int, std::vector<std::string>> apiv2_judge_paohu(const std::string &hand, int hu) {
    try {
        mahjong::Handtiles ht;
        ht.StringToHandtiles(hand);
        ht.SetTile(mahjong::Tile(hu));
        mahjong::Fan fan;
        bool is_hu = fan.JudgeHu(ht) && !ht.IsZimo();
        if (is_hu) {
            fan.CountFan(ht);
            std::vector<std::string> fan_details;
            for (int i = 1; i < mahjong::FAN_SIZE; i++) {
                if (!fan.fan_table_res[i].empty()) {
                    fan_details.push_back(mahjong::FAN_NAME[i]);
                }
            }
            return std::make_tuple(true, fan.tot_fan_res, fan_details);
        }
        return std::make_tuple(false, 0, std::vector<std::string>());
    } catch (const std::exception &e) {
        return std::make_tuple(false, 0, std::vector<std::string>());
    }
}

std::tuple<bool, int, std::vector<std::string>> apiv2_judge_zimo(const std::string &hand) {
    try {
        mahjong::Handtiles ht;
        ht.StringToHandtiles(hand);
        mahjong::Fan fan;
        bool is_hu = fan.JudgeHu(ht);
        if (is_hu) {
            fan.CountFan(ht);
            std::vector<std::string> fan_details;
            for (int i = 1; i < mahjong::FAN_SIZE; i++) {
                if (!fan.fan_table_res[i].empty()) {
                    fan_details.push_back(mahjong::FAN_NAME[i]);
                }
            }
            return std::make_tuple(true, fan.tot_fan_res, fan_details);
        }
        return std::make_tuple(false, 0, std::vector<std::string>());
    } catch (const std::exception &e) {
        return std::make_tuple(false, 0, std::vector<std::string>());
    }
}

PYBIND11_MODULE(apiv2, m) {
    m.def("calc_ting", &apiv2_calc_ting, "Calculate ting tiles from a hand");
    m.def("judge_paohu", &apiv2_judge_paohu, "Judge if the hand is a paohu and return details");
    m.def("judge_zimo", &apiv2_judge_zimo, "Judge if the hand is a zimo and return details");
} 