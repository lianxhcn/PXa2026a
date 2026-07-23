
# Baker-2026-DiD-Guide 复现指南

>连玉君，`2026.7.23`

[toc]

## 任务说明

本说明旨在指导读者如何复现 Baker et al. (2026) 的 Difference-in-Differences 设计方法，包括阅读论文、理解核心方法、以及在 Stata 中实现相关代码的步骤。

我介绍了两种方案：一种是直接让 Codex 工作，另一种是先与 ChatGPT 交流再让 Codex 工作。你如果使用其他的 Agent 工作的模式也跟这个相似，只需要把我后文中的 Codex 换成你的 Agent 的名称就可以了。

## 事前准备工作 

我把该文的基本信息发给了 [ChatGPT](https://chatgpt.com/share/6a60eba2-a438-83e8-9462-c6098f55b50a)，让它帮我收集完整的引文信息。提示词如下：

```raw
Baker, Callaway, Cunningham, Goodman-Bacon & Sant'Anna (2026). 
Difference-in-Differences Designs: A Practitioner's Guide 

帮我提供完整的引文信息，还有 github 链接等。`
```

它返回的信息如下：

>Baker, A., Callaway, B., Cunningham, S., Goodman-Bacon, A., & Sant'Anna, P. H. C. (2026). Difference-in-differences designs: A practitioner's guide. *Journal of Economic Literature, 64*(2), 498--557. [Link](https://doi.org/10.1257/jel.20251650?utm_source=chatgpt.com), [AEA](https://www.aeaweb.org/articles?id=10.1257%2Fjel.20251650&utm_source=chatgpt.com), [PDF](https://psantanna.com/files/DiD_JEL.pdf?utm_source=chatgpt.com), Google, [GitHub](https://github.com/pedrohcgs/JEL-DiD?utm_source=chatgpt.com), [Replication](https://doi.org/10.3886/E239070V1), [Appendix](https://www.aeaweb.org/articles/materials/25430), [arXiv](https://arxiv.org/abs/2503.13323?utm_source=chatgpt.com).

接下来，我在本地手动完成了如下工作 (其实这些工作也可以交给 Codex来完成)：

1. 在本地建立项目文件夹：如 `{mypath}` = `D:\github_lianxh\PXa2026a\examples\Baker-2026-DiD-Guide--by-Lian`
2. 访问 <https://github.com/pedrohcgs/JEL-DiD>，依次点击 **Code** (绿色按钮) 再选择 **Download ZIP** 下载代码。
3. 解压下载的 ZIP 文件，将其中的内容放入 `{mpath}` 中。
4. 下载 PDF 原文：点击 [PDF](https://psantanna.com/files/DiD_JEL.pdf?utm_source=chatgpt.com)，另存到 `{mpath}` 中，命名为 `Baker-2026-DiD-Guide.pdf`。


## 做计划

我粗略地浏览了一下 PDF 原文，发现有 60 页作者介绍了很多模型，以及在实证分析里边的一些常见的疑难杂症，比如说平行趋势检验呀，外溢效果等等。同时，在正式发表的 PDF 论文中，作者也提到了他们有一个仓库，里边也同时提供 Stata、R 和 Python 的复现代码。

所以接下来我们有两种工作方式：

- 一种是直接打开 Codex，让 Codex 根据我们的需要开始规划任务。
- 另一种方式是我们先跟 ChatGPT 聊一下，把这个基本情况跟他介绍一下，让他帮我们做一个规划。然后我们再把 ChatGPT 给出的规划文档，连同刚才放在我们这个项目的根目录下面，让 Codex 去读这个任务，随后再开始工作。

## 模式 1：Codex 直接工作

1. 打开 Codex，点击左侧 **项目** 菜单右侧的 `+` 按钮，打开 `{mypath}` 文件夹，进入项目。
2. 写入如下提示词 (你可以酌情修改)：

--- 

这是我最近看到的一篇论文，我想先读懂这篇文章，然后再根据作者提供的 GitHub 仓库中的资料进行一些代码复现。
- **我的背景**：我只会执行 Stata 代码；我只了解最经典的 2×2 DID 的原理；会用 `reghdfe` 命令。
- **我的目的**：作为初学者，我很想了解清楚这篇文章里面介绍的一些主要的，尤其是在多数的论文中使用的方法的原理和 Stata 的实现方法。最终我希望能把这些方法应用到我自己的论文中去。
- **Output**：你在整个输出的过程中，不要改动作者的GitHub仓库中的任何文件。
  - **注意**：你工作的时候，要保持 `{mypath}` 为只读状态。你需要在与 `{mypath}` 平行的目录下新建文件夹 `Baker-2026-DiD-Codex-sole` 进行所有的写操作。所有的工作都在这个文件夹下完成，输入结果也存储在这个文件夹下。
  - 你帮我撰写中文精要的时候新开一个文件夹：`.\notes`。然后帮我撰写一个10页左右的中文讲义风格的中文精，要不需要把论文里边的好多技术细节都讲出来，只需要把论文里涉及到的一些核心方法的模型设定思路说清楚，尤其是它的适用条件和适用场景。如果你觉得10页的篇幅不够，可以酌情扩充，但是最长不要超过20页。
  - 复现作者的 GitHub 中提到的例子的时候，先新建一个文件夹: `dofile-replication`。 
    - 帮我编写一个单一的 dofile 文件；酌情添加一些关键的注释，但是注释文字不要太长。每行代码连加注释不要超过80列，必要的时候可以采用换行。
    - 在这个文件夹下，按照项目的要求可以新建一些子文件夹，分别用来存储数据和输出结果等内容
    - 上述基本设定工作完成以后，你就可以跑代码。
    
以上只是我的一些初步想法。你可以根据我的需求帮我做一个相对完整的规划。     

---

## 模式 2：先与 ChatGPT 交流再让 Codex 工作

如果采用chatgpt帮你规划的这种方式，由于chatgpt不能够一次性接触很多的文件，所以你最好是把仓库的地址还有你本地的文件目录数都发给chatgpt。他本身是有能力去读取给他远程仓库里面的内容的。

### Step1：与 ChatGPT 交流的内容准备

我读到了这篇论文以及作者提供的 GitHub 仓库中的复现代码，准备在本地进行学习和复现。你帮我做个规划，我让我的本地 Codex 根据这个规划去完成后续的任务。

注意：你在规划的过程中，不要提供很多细节的过程信息以及你思考的过程，只需要把关键的信息列出来就行，最终只需要给我一套可以让我转给codex去执行的文档就行。

>Baker, A., Callaway, B., Cunningham, S., Goodman-Bacon, A., & Sant'Anna, P. H. C. (2026). Difference-in-differences designs: A practitioner's guide. *Journal of Economic Literature, 64*(2), 498--557. [Link](https://doi.org/10.1257/jel.20251650?utm_source=chatgpt.com), [PDF](https://psantanna.com/files/DiD_JEL.pdf?utm_source=chatgpt.com), [GitHub](https://github.com/pedrohcgs/JEL-DiD?utm_source=chatgpt.com).

- **我的背景**：我只会执行 Stata 代码；我只了解最经典的 2×2 DID 的原理；会用 `reghdfe` 命令。
- **我的目的**：作为初学者，我很想了解清楚这篇文章里面介绍的一些主要的，尤其是在多数的论文中使用的方法的原理和 Stata 的实现方法。最终我希望能把这些方法应用到我自己的论文中去。
- **我的需求**：我希望 ChatGPT 能帮我做一个详细的学习和复现计划，包括阅读论文的顺序、复现代码的步骤以及可能遇到的问题和解决方法。然后我交给我的本地codex去完成相关的实操任务。整个复现过程中，我希望原作者的GitHub仓库保持干净整洁，不被污染，我自己的这些撰写的中文精要和复现代码要另外设定一些文件夹来存放。
  - 帮我撰写一个10页左右的中文讲义风格的中文精，要不需要把论文里边的好多技术细节都讲出来，只需要把论文里涉及到的一些核心方法的模型设定思路说清楚，尤其是它的适用条件和适用场景。如果你觉得10页的篇幅不够，可以酌情扩充，但是最长不要超过20页。

- 本地项目文件夹路径：`{mypath}` = `D:\github_lianxh\PXa2026a\examples\Baker-2026-DiD-Guide--by-Lian`
- GitHub 仓库地址：<https://github.com/pedrohcgs/JEL-DiD>
- PDF 原文路径：`{mypath}\Baker-2026-DiD-Guide.pdf`
  - URL：<https://psantanna.com/files/DiD_JEL.pdf?utm_source=chatgpt.com>
- **注意**：Codex 工作的时候，要保持 `{mypath}` 为只读状态。你需要在与 `{mypath}` 平行的目录下新建文件夹 `Baker-2026-DiD-ChatGPT-to-Codex` 进行所有的写操作。所有的工作都在这个文件夹下完成，输入结果也存储在这个文件夹下。

**Filetree**: 

```text
. dirtree
Baker-2026-DiD-Guide--by-Lian \
|-- baker-2026-did-guide.pdf
|-- readme.md
+-- jel-did-main \
    |-- did_jel.rproj
    |-- index.html
    |-- license
    |-- readme.md
    |-- readme.pdf
    |-- renv.lock
    |-- data \
    |   |-- county_mortality_data.csv
    |   |-- bls \
    |   |   |-- laucnty09.xlsx
    |   |   |-- laucnty10.xlsx
    |   |   |-- laucnty11.xlsx
    |   |   |-- laucnty12.xlsx
    |   |   |-- laucnty13.xlsx
    |   |   |-- laucnty14.xlsx
    |   |   |-- laucnty15.xlsx
    |   |   |-- laucnty16.xlsx
    |   |   |-- laucnty17.xlsx
    |   |   |-- laucnty18.xlsx
    |   |   +-- laucnty19.xlsx
    |   |-- cdc \
    |   |   |-- female_pop.csv
    |   |   |-- hispanic_pop.csv
    |   |   |-- mortality.csv
    |   |   |-- total_pop.csv
    |   |   +-- white_pop.csv
    |   +-- kff \
    |       +-- expansion_status.csv
    |-- figures \
    |   |-- figure1_r.pdf
    |   |-- figure1_stata.pdf
    |   |-- figure2_r.pdf
    |   |-- figure2_stata.pdf
    |   |-- figure3_r.pdf
    |   |-- figure3_stata.pdf
    |   |-- figure4_r.pdf
    |   |-- figure4_stata.pdf
    |   |-- figure5_r.pdf
    |   |-- figure5_stata.pdf
    |   |-- figure6_r.pdf
    |   |-- figure6_stata.pdf
    |   |-- figure7_r.pdf
    |   |-- figure7_stata.pdf
    |   |-- figure8_r.pdf
    |   |-- figure8_stata.pdf
    |   |-- figure9_r.pdf
    |   +-- figure9_stata.pdf
    |-- markdown \
    |   +-- r_stata \
    |       |-- code_appendix.html
    |       +-- code_appendix.qmd
    |-- renv \
    |   |-- activate.r
    |   +-- settings.json
    |-- scripts \
    |   |-- r \
    |   |   |-- 00_master_did_jel.r
    |   |   |-- 0_make_data.r
    |   |   |-- 1_adoption_table.r
    |   |   |-- 2_2x2.r
    |   |   |-- 3_2xt.r
    |   |   |-- 4_gxt.r
    |   |   +-- 5_honestdid.r
    |   +-- stata \
    |       |-- 00_stata_master_did_jel.do
    |       |-- 0_stata_make_data.do
    |       |-- 1_stata_adoption_table.do
    |       |-- 2_stata_2x2.do
    |       |-- 3_stata_2xt.do
    |       |-- 4_stata_gxt.do
    |       +-- 5_stata_honestdid.do
    +-- tables \
        |-- table1_r.tex
        |-- table1_stata.tex
        |-- table2_r.tex
        |-- table2_stata.tex
        |-- table3_r.tex
        |-- table3_stata.tex
        |-- table4_r.tex
        |-- table4_stata.tex
        |-- table5_r.tex
        |-- table5_stata.tex
        |-- table6_r.tex
        |-- table6_stata.tex
        |-- table7_r.tex
        +-- table7_stata.tex
```

### Step2：开始本地工作

1. 在本地与 `{mypath}` 平行的目录下新建文件夹 `Baker-2026-DiD-ChatGPT-to-Codex`
2. 将 ChatGPT 输出的工作计划文档 (如 `work_plan.md`) 放在 `Baker-2026-DiD-ChatGPT-to-Codex` 文件夹中。
3. 在 Codex 中打开 `Baker-2026-DiD-ChatGPT-to-Codex` 文件夹。让它读取 `work_plan.md` 文件，完成相关工作。


----


### 补充说明：如何获得项目文件夹的结构

你可以在 Stata 中执行如下代码获得项目文件夹的结构：

```stata
cd "D:\github_lianxh\PXa2026a\examples\Baker-2026-DiD-Guide--by-Lian"

ssc install dirtree
dirtree
```

当然你也可以用本地的agent让他直接帮你生成这个项目文件夹的结构。提示词：

```text
请帮我生成如下文件夹的项目文件夹的结构，txt 格式:

D:\github_lianxh\PXa2026a\examples\Baker-2026-DiD-Guide--by-Lian
```