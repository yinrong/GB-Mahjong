# apiv2 接口文档

## 简介

`apiv2`接口是GB-Mahjong库的一部分，提供了国标麻将的核心功能，包括听牌计算、胡牌判断和番数计算等。该接口通过`pybind11`绑定到Python中，方便Python用户调用。

## 接口功能

### 1. `calc_ting`

- **功能**: 计算给定手牌的听牌。
- **参数**: `hand` (str) - 表示手牌的字符串。
  - **手牌字符串格式**: 
    - **基本格式**: `立牌、副露|场况与和牌方式|花牌`
      - **立牌**: 表示玩家手中的牌，使用ASCII字符表示。例如，`123m`表示一万、二万、三万。
      - **副露**: 使用中括号`[]`表示，表示吃、碰、杠的牌。供牌者和吃哪张牌使用`,序数`的形式表示。
        - 例如，`[4444p]`表示暗杠四饼，`[1111s,1]`表示明杠上家一条。
      - **场况与和牌方式**: 使用`EE0000`表示，分别表示圈风、门风、是否为自摸、是否为绝张、是否为海底牌、是否为抢杠。
      - **花牌**: 可以直接用数字表示拥有几张，采用"梅兰竹菊春夏秋冬"的顺序。
- **返回值**: `list[int]` - 听牌的牌ID列表。

### 2. `judge_paohu`

- **功能**: 判断给定手牌是否为炮胡，并返回详细信息。
- **参数**: 
  - `hand` (str) - 表示手牌的字符串，格式同上。
  - `hu` (int) - 表示胡的牌ID。
- **返回值**: `tuple[bool, int, list[str]]` - 是否胡牌，总番数，番种详细信息。

### 3. `judge_zimo`

- **功能**: 判断给定手牌是否为自摸，并返回详细信息。
- **参数**: `hand` (str) - 表示手牌的字符串，格式同上。
- **返回值**: `tuple[bool, int, list[str]]` - 是否胡牌，总番数，番种详细信息。

## 使用示例

```python
import apiv2

# 计算听牌
hand = "123m456p789s"
ting_tiles = apiv2.apiv2_calc_ting(hand)
print("听牌: ", ting_tiles)

# 判断炮胡
hand = "123m456p789s"
hu_tile = 5
is_hu, total_fan, fan_details = apiv2.apiv2_judge_paohu(hand, hu_tile)
print("是否胡牌: ", is_hu)
print("总番数: ", total_fan)
print("番种详细: ", fan_details)

# 判断自摸
hand = "123m456p789s"
is_hu, total_fan, fan_details = apiv2.apiv2_judge_zimo(hand)
print("是否自摸: ", is_hu)
print("总番数: ", total_fan)
print("番种详细: ", fan_details)
```

## 依赖

- `pybind11`
- `C++11`或更高版本

## 构建

确保安装了所有依赖后，使用以下命令构建项目：

```bash
make
```

## 测试

使用以下命令运行测试：

```bash
make check
```

## 许可证

[MIT License](LICENSE) 