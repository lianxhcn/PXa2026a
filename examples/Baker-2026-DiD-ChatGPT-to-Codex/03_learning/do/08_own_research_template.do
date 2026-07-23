/* 可迁移 DID 模板：先替换宏，再核对数据和研究设计。 */
version 19
clear all
set more off
local y        "outcome"
local id       "unit_id"
local t        "year"
local g        "first_treat_year"
local x        "x1 x2 x3"
local w        "weight"
local cluster  "cluster_id"

* 1. 载入自己的数据后，先做唯一性、缺失值和 cohort 检查。
* use "your_panel_data.dta", clear
* isid `id' `t'
* tab `g'
* by `id' (`t'): assert (`t' >= `g') >= (`t'[_n-1] >= `g') if `g' > 0 & _n > 1

* 2. 单一处理时点或标准 2x2：可以估计交互项并检查其目标 ATT。
* reg `y' i.treated##i.post, vce(cluster `cluster')

* 3. 分期处理：明确 not-yet-treated 或 never-treated 对照组。
* csdid `y' `x' [iw=`w'], ///
*     ivar(`id') time(`t') gvar(`g') method(dripw) notyet
* estat event

* 4. 处理前系数与 HonestDiD 需要和实际 e(b) 的列名逐项核对。
display "模板只提供工作流，不能自动保证识别成立。"
