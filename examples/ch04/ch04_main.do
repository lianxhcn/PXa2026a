*==============================================================================
* 第 4 讲 线性回归的建模语言：CEF、OLS 与统计推断
* 配套 do 文件（可在 VS Code + Stata All in One 中按 **# 大纲逐节运行）
*
* 数据读取：
*   - mroz / nlsw88 / auto 为 Stata 自带，用 webuse / sysuse 直接载入；
*   - xtcs / B1_production 随本仓库提供，用下方 global D 指到线上路径，
*     或把 $D 改成本地 data/ 目录（本 do 同级）。
* 说明：书稿中的输出均由本文件运行生成、已冻结；图形导出到 fig/ 子目录。
*==============================================================================

clear all
set more off
capture mkdir "fig"

* 仓库数据路径：联网直读；离线时把下一行改成 global D "data"
global D "cd D:\github_lianxh\PXa2026a\examples\ch04\data"  // 本地路径
global D "https://raw.githubusercontent.com/lianxhcn/PXa2026a/main/examples/ch04/data"

*==============================================================================
**# 案例情境：一个系数，三种读法
*==============================================================================

webuse mroz, clear
* 只保留在职女性(wage>0)、剔除个别极端高薪，并把人数过少的教育年限并组
drop if wage==0
drop if wage>17
replace educ = 9  if educ<=9
replace educ = 14 if educ==15
reg wage educ
* wage = -2.74 + 0.52*educ：0.52 该读成"因果/比较/预测"中的哪一种？


*==============================================================================
**# 概念讲解：回归到底在估计什么
*==============================================================================

**## 条件期望函数 (CEF)：按 X 分组求平均
bysort educ: egen wage_m = mean(wage)   // E(wage | educ)
egen tag = tag(educ)
format wage* %3.1f
list educ wage_m if tag==1, clean noobs

* 某一组的 CEF = 条件均值（下面两条等价）
sum wage if educ==12
reg wage if educ==12, noheader

* CEF 散点图（灰点=个体，菱形=各组均值，红线=OLS 拟合）
twoway (scatter wage educ, mcolor(gs10) msize(vsmall) jitter(2)) ///
       (scatter wage_m educ if tag==1, mcolor(navy) msize(medlarge) msymbol(D)) ///
       (lfit wage educ, lcolor(cranberry) lwidth(medthick)), ///
       legend(order(2 "各教育年限的平均工资 E[wage|educ]" 3 "OLS 拟合直线") ///
              rows(2) size(small) pos(11) ring(0)) ///
       xtitle("受教育年限 educ") ytitle("时薪 wage") xlabel(9(1)17)
graph export "fig/g_cef_edu.png", replace width(1200)

**## 回归估计的就是 CEF（个体 = 分组均值加权回归）
bysort educ: egen Nj = count(educ)
eststo clear
eststo m1: reg wage   educ                       // 个体回归
eststo m2: reg wage_m educ if tag==1             // 只用 8 个组均值
eststo m3: reg wage_m educ if tag==1 [aweight=Nj] // 组均值，按组容量加权
esttab m1 m2 m3, nogap mtitle(individual groupmean groupmean_aw) ///
       b(%5.3f) se(%5.3f) scalar(N r2)
* 第 (1)(3) 列斜率相同(0.522)：OLS 拟合的就是那 8 个 CEF 点

**## 线性投影 & 换一个 f(.) 就是换一个模型
gen educ2 = educ^2
eststo clear
eststo s1: reg wage  educ             // (1) 线性
eststo s2: reg wage  educ educ2       // (2) 平方项：允许弯曲
eststo s3: reg lwage educ             // (3) 对数：改变尺度
esttab s1 s2 s3, nogap mtitle(linear quad log) b(%5.3f) se(%5.3f) scalar(N r2)

* 四种设定的拟合线画在同一张散点图上
reg wage educ
predict yhat_lin
reg wage educ c.educ#c.educ
predict yhat_quad
reg lwage educ
predict lyhat
gen yhat_log = exp(lyhat)
gen Dhi = (educ>13)
reg wage c.educ##i.Dhi
predict yhat_dum
sort educ
twoway (scatter wage educ, mcolor(gs11) msize(vsmall) jitter(2)) ///
       (line yhat_lin  educ, lcolor(navy)      lwidth(medthick)) ///
       (line yhat_quad educ, lcolor(cranberry) lwidth(medthick) lpattern(dash)) ///
       (line yhat_log  educ, lcolor(forest_green) lwidth(medthick) lpattern(shortdash)) ///
       (line yhat_dum  educ, lcolor(dkorange)  lwidth(medthick) lpattern(longdash)), ///
       legend(order(2 "线性" 3 "加平方项" 4 "对数(还原)" 5 "分段(虚拟变量)") ///
              rows(1) size(small) pos(6)) ///
       xtitle("受教育年限 educ") ytitle("时薪 wage") xlabel(9(1)17)
graph export "fig/g_four_models.png", replace width(1300)

**## 2.5–2.7 系数含义、比较 vs 影响、多元回归偏效应
* 更明显的偏效应例子：nlsw88 中 tenure(任职年限) 在控制 ttl_exp(总工龄) 后骤降
sysuse nlsw88, clear
eststo clear
eststo n1: reg wage tenure
eststo n2: reg wage tenure ttl_exp
eststo n3: reg wage tenure ttl_exp grade
esttab n1 n2 n3, se star(* 0.10 ** 0.05 *** 0.01) r2 ///
       mtitle("只放 tenure" "+总工龄" "+受教育")
* tenure 0.186*** → 0.041(不显著)：控制总工龄后，"纯任职"效应很小
corr tenure ttl_exp


*==============================================================================
**# 代码实操
*==============================================================================

**## 跑第一个回归：从命令到拟合值
webuse mroz, clear
drop if wage==0 | wage>17
replace educ = 9 if educ<=9
replace educ = 14 if educ==15
reg wage educ
predict wage_hat            // 拟合值
predict e_hat, residual     // 残差
list wage wage_hat e_hat in 1/3, clean

**## 读懂一张回归表（esttab）
eststo clear
eststo t1: reg wage educ
eststo t2: reg wage educ exper
esttab t1 t2, se star(* 0.10 ** 0.05 *** 0.01) r2 mtitle("模型1" "模型2")

**## 换个单位，系数会变吗：变量的尺度
gen wage_cents  = wage*100
gen educ_months = educ*12
eststo clear
eststo a0: reg wage       educ
eststo a1: reg wage_cents educ
eststo a2: reg wage       educ_months
esttab a0 a1 a2, nogap mtitle(wage wage_cents educ_months) ///
       b(%7.4f) se(%7.4f) scalar(r2)

**## 对数与标准化：系数怎么读
* 3.4a 对数-水平：半弹性（%）
reg lwage educ
* 3.4b 对数-对数：弹性（Cobb-Douglas）
use "$D/B1_production.dta", clear
reg lnY lnL lnK
* 3.4c 标准化系数：以标准差为单位比较
webuse mroz, clear
drop if wage==0 | wage>17
reg lwage educ exper, beta

**## 因子变量：把类别放进回归
sysuse auto, clear
label define forlbl 0 "国产车" 1 "进口车"
label values foreign forlbl
reg price i.foreign weight          // 变截距：进口车 vs 国产车
reg price i.foreign##c.weight       // 变截距 + 变斜率
twoway (scatter price weight if foreign==0, mcolor(navy) msymbol(O) msize(small)) ///
       (scatter price weight if foreign==1, mcolor(cranberry) msymbol(T) msize(small)) ///
       (lfit price weight if foreign==0, lcolor(navy)) ///
       (lfit price weight if foreign==1, lcolor(cranberry)), ///
       legend(order(1 "国产车" 2 "进口车") rows(1) pos(6)) ///
       xtitle("车重 weight") ytitle("价格 price")
graph export "fig/g_dummy_shift.png", replace width(1200)

**## 交叉项：让边际效应随另一个变量变
use "$D/xtcs.dta", clear
xtset code year
global zz "tang fr ndts L.tobin i.year"
reg tl npr size $zz, robust noheader       // 不含交叉项：npr 系数为负
reg tl npr size c.npr#c.size $zz, robust noheader // 含交叉项：npr 系数翻正(size=0 处，无意义)
* 边际效应 dtl/dnpr = 1.729 - 0.100*size
qui reg tl npr size c.npr#c.size $zz, robust
keep if e(sample)
margins, dydx(npr) at(size=(19(1)24))
marginsplot, yline(0, lpattern(dash) lcolor(red)) recast(line) recastci(rarea) ///
    xtitle("公司规模 size") ytitle("npr 对 tl 的边际效应")
graph export "fig/g_margins_npr.png", replace width(1200)

* 中心化（可选）：让一阶项系数在 z 均值处、便于解释；不改变交叉项与推断
use "$D/xtcs.dta", clear
xtset code year
center npr size, prefix(c_)    // 需 -center- 命令：ssc install center
reg tl c_npr size c.c_npr#c.size tang fr ndts, robust

**## 平方项：允许先升后降
sysuse nlsw88, clear
gen ttl_exp2 = ttl_exp^2
reg wage ttl_exp ttl_exp2 hours age tenure married south i.race
di "拐点 TP = " %3.1f -_b[ttl_exp]/(2*_b[ttl_exp2])   // 27.2 年
global tp: di %3.1f -_b[ttl_exp]/(2*_b[ttl_exp2])
keep if e(sample)
local b0 = _b[_cons]
local b1 = _b[ttl_exp]
local b2 = _b[ttl_exp2]
sum ttl_exp
local mn: di %3.1f r(min)
local mx: di %3.1f r(max)
twoway (function y = `b2'*x^2 + `b1'*x + `b0', range(`mn' `mx') lcolor(navy) lwidth(medthick)), ///
       xline($tp, lpattern(dash) lcolor(cranberry)) ///
       xtitle("工作经验 ttl_exp") ytitle("时薪 wage（其他变量取均值处）") ///
       xlabel(`mn' 5(5)25 $tp) note("拐点 TP = $tp 年")
graph export "fig/g_square_ushape.png", replace width(1200)
* 注意：拐点 27 落在数据右端，多数样本在上升段，别把外推讲成规律

**## 3.7b 断点回归初步：用 binscatter 看断点处的跳跃
* 需 -binscatter- 命令：ssc install binscatter
sysuse nlsw88, clear
gen lnwage = ln(wage)
capture binscatter lnwage hours, rd(40) line(qfit) ///
    xtitle("周工作时长 hours") ytitle("ln(wage)")
capture graph export "fig/g_rdd_hours.png", replace width(1200)
gen D40        = (hours>40)
gen hours_c    = (hours-40)/10
gen hours_c_sq = hours_c^2
eststo clear
eststo r1: reg lnwage D40 hours_c              // 线性设定
eststo r2: reg lnwage D40 hours_c hours_c_sq   // 允许两侧弯曲
esttab r1 r2, nogap b(%6.4f) t(%5.2f) mtitle(linear quad)
* D40 = hours=40 处的跳跃：线性 0.061(n.s.) vs 加平方项 0.163***

**## 稳健标准误与聚类标准误
sysuse nlsw88, clear
global x "age ttl_exp union collgrad"
qui reg wage $x i.industry i.occupation
keep if e(sample)
eststo clear
eststo c1: reg wage $x                            // 同方差
eststo c2: reg wage $x, robust                    // 异方差稳健
eststo c3: reg wage $x, vce(cluster industry)     // 一维聚类
* 二维聚类需 -reghdfe-：ssc install reghdfe
eststo c4: reghdfe wage $x, noabsorb cluster(industry occupation)

* 结果对比
esttab c1 c2 c3 c4, mtitle(OLS Robust Clus1 Clus2) s(N r2) ///
       b(%5.3f) se(%5.4f) star(* 0.1 ** 0.05 *** 0.01) nogap keep($x)
* 系数完全相同，只有 SE 变；industry 仅 12 个聚类——聚类数偏少要当心


*==============================================================================
**# 结果解释与因果护栏（写作，无代码）
*==============================================================================
* 统计显著 ≠ 经济显著：用变量实际单位说清"这个数在现实里多大"
* 因果护栏：把"导致/提升/影响"改成"相关/更高/在控制…之后"
* 结论只对本样本与总体成立（外推边界，见第 3 讲）

* end of file
