<p align="center">
  <img src="https://raw.githubusercontent.com/GPuntobit/triad2.0/main/docs/triad-logo.webp" alt="Logo di Triad" width="160">
</p>

# Triad 2.0 — 教程：学习这门语言与项目代码

本教程是一条引导式路径，你沿着它从零开始学习 Triad。它不预设你已经了解这门语言：它只预设你会用其他某种语言编程。如果你已经会写循环、函数和列表，你就具备了所需的一切；其余部分——Triad 的语法、值的行为、可执行子集与完整标准之间的区别—— 都会在这里按最适合学习的顺序讲解。

这条路径会带来三个成果。第一，**编写真正能跑起来的 Triad-Core 程序**，也就是今天就能用参考解释器执行的完整程序。第二，**了解 Triad-Full**，即由标准定义的完整语言，包括当前运行时还无法执行的部分。第三，**读懂项目代码**：参考解释器、机器码实现的 seed、一致性测试套件以及开发工具。本教程不会把概念推给别处去理解：规范（`SPEC.md`、`SPEC-CORE.md`）和 `conformance/` 中的用例是可选的深入材料，而不是前置条件。

## 你会学到什么，以及本书如何组织

本教程是一本分为五部分的书，设计上按顺序阅读，但各部分足够独立，也可以单独查阅。

- **第一部分 —— 入门。** Triad 是什么，如何安装与运行，以及逐行讲解的第一个程序。
- **第二部分 —— 逐步掌握 Triad-Core。** 今天即可运行的子集，逐个构造展开：词法、值、变量、表达式、控制流、函数、闭包、列表、字符串、引导原语、错误，以及不同运行时之间的差异。该部分末尾的引导式练习用来巩固你读过的内容。
- **第三部分 —— Triad-Full（完整标准）。** 声明式类型、多重分派、struct、`for` 与推导式、用事实和规则表达逻辑、宏、契约、预算、追踪以及声明式副作用。这就是规范所定义的语言：你在本书中学习它，但当前运行时还无法执行它。
- **第四部分 —— 项目代码。** 对仓库的一次导览：参考解释器、seed、S1、一致性用例、CLI、基准测试、贡献流程。它帮你理解这门语言是如何实现的，而不只是如何使用。
- **第五部分 —— 参考。** 语法、速查卡、错误信息、术语表、项目状态与常见问题：这些章节以查阅为主，而不是顺序通读。

**“今天即可运行”是什么意思。** Triad 标准定义了两个一致性配置。当一个示例无需修改就能在仓库中已有的某个实现上运行时，它就是*今天即可运行*；当规范描述了它、但当前没有任何运行时能执行它时，它就是*由标准定义*。本教程始终区分这两种情况，并且每个代码块都会声明它所属的配置。

| 配置档 | 定义位置 | 今天即可运行？ |
|---|---|---|
| **Triad-Core** | `SPEC-CORE.md` | **是**：JavaScript 参考解释器 `seed/dev/triad_core.cjs`（37/37 个 Core 用例），以及部分可用的 Windows seed `seed/windows-x86_64/seed.exe`（CI 中验证了 33 个 Core 用例）|
| **Triad-Full** | `SPEC.md` | **否**：struct、dispatch、逻辑、宏、契约、预算、追踪、副作用、解构、`for`、`try`、`Float` 都属于规范；在 Full 一致性测试中只有 `errore` 通过 |

关于背景，有两点需要说明，以免把本书与项目本身混为一谈。标准的版本号是 `0.2.0`，登记在 `VERSION` 中。Triad 不依赖 Julia：那个旧实现已经被移除，你在书中看到的 Triad-Full 输出都是 **golden**，也就是当年由该实现产出、并冻结在 `conformance/cases/` 中的期望结果；当前运行时并未复现它们。相反，每个标注 **Output:** 的示例都是用 `node seed/dev/triad_core.cjs` 验证过的 Triad-Core 程序； Full 示例则标注 **Output (golden Full):**，或者干脆不给输出。

---

## 如何使用本教程

读这本书没有唯一的方式：这取决于你的需要。下面的表格概括了主要的几条阅读路径。不过，如果你还不了解 Triad，就该从第一部分开始：后面的章节都假定你已经掌握了该语言的词法。

| 你想…… | 请阅读 |
|---|---|
| 编写今天就能运行的 Triad 程序 | [第一部分](#parte-1) → [第二部分](#parte-2)（第 4–17 章，含练习）|
| 了解标准定义的完整语言 | [第三部分](#parte-3)（第 18–32 章）|
| 为 JS 解释器、seed、S1、CLI 或一致性测试贡献代码 | [第四部分](#parte-4)（第 33–43 章）|
| 查阅语法、速查卡、错误信息、术语表 | [第五部分](#parte-5)（第 44–49 章）|

一些约定能让示例更容易读懂。命令分别按 Linux/macOS（`sh`）给出，当两者不同时也给出 Windows（`cmd`/PowerShell）的写法。`triad` 代码块包含 Core 代码，通常可用 JS 解释器运行；专门针对 Windows seed 的片段会在正文中说明。`triad-full` 代码块展示的是由 Full 标准定义、当前运行时还无法执行的代码。**JS 解释器**指 `seed/dev/triad_core.cjs`，即在 Linux/macOS 上以及一致性 runner 中使用的 Triad-Core 参考解释器； **seed** 指 `seed/windows-x86_64/seed.exe`，即机器码实现的 Triad-Core 解释器（S0）。两者行为不同的地方，[第 15 章](#cap-15) 会告诉你。源码写在 `.triad`（规范扩展名）或 `.td`（历史别名）文件中。

## 目录

**[第一部分 —— 入门](#parte-1)**
1. [Triad 是什么](#cap-1)
2. [安装与运行](#cap-2)
3. [第一个程序](#cap-3)

**[第二部分 —— 逐步掌握 Triad-Core（今天即可运行）](#parte-2)**

4. [词法](#cap-4)
5. [值、类型与打印](#cap-5)
6. [变量与赋值](#cap-6)
7. [运算符与表达式](#cap-7)
8. [控制流](#cap-8)
9. [函数](#cap-9)
10. [Lambda、闭包与作用域](#cap-10)
11. [列表](#cap-11)
12. [字符串、符号与转换](#cap-12)
13. [引导原语](#cap-13)
14. [运行时错误](#cap-14)
15. [JS 解释器与 Windows seed：差异](#cap-15)
16. [Triad-Core 惯用写法](#cap-16)
17. [引导式练习](#cap-17)

**[第三部分 —— Triad-Full（完整标准）](#parte-3)**

18. [Full 的词法与类型](#cap-18)
19. [类型化函数与多重分派](#cap-19)
20. [Struct](#cap-20)
21. [Full 控制流：`for`、range、推导式、`try`](#cap-21)
22. [逻辑：事实、规则、`solve`](#cap-22)
23. [解构](#cap-23)
24. [错误即数据](#cap-24)
25. [契约](#cap-25)
26. [预算](#cap-26)
27. [追踪](#cap-27)
28. [声明式副作用](#cap-28)
29. [代码即数据、统一树与宏](#cap-29)
30. [Full 内置函数](#cap-30)
31. [命令行与 REPL（SPEC §14）](#cap-31)
32. [带 golden 输出的 Full 示例](#cap-32)

**[第四部分 —— 项目代码](#parte-4)**

33. [仓库地图](#cap-33)
34. [JS 参考解释器（`seed/dev/triad_core.cjs`）](#cap-34)
35. [Windows S0 seed 及其生成器](#cap-35)
36. [Linux seed（E0）](#cap-36)
37. [自举：`selfhost/` 中的 S1](#cap-37)
38. [一致性测试：读取、编写与验证用例](#cap-38)
39. [开发 CLI `triad-cli`](#cap-39)
40. [AI 基准测试（`ai/`）](#cap-40)
41. [编辑器、启动器与站点](#cap-41)
42. [持续集成](#cap-42)
43. [贡献流程](#cap-43)

**[第五部分 —— 参考](#parte-5)**

44. [Triad-Core 语法（EBNF）](#cap-44)
45. [Core 与 Full 速查卡](#cap-45)
46. [调试与常见问题](#cap-46)
47. [术语表](#cap-47)
48. [状态、已知限制与历史修复](#cap-48)
49. [FAQ](#cap-49)

---

<a id="parte-1"></a>

# 第一部分 —— 入门

<a id="cap-1"></a>

## 1. Triad 是什么

Triad 是一门自成一体的编程语言，它把三种范式——命令式、逻辑式和元编程式——统一在单一的块语法之中。其基本理念是：这些范式不该被拆散到各自独立的语言里。一个 Triad 程序可以像命令式语言那样定义函数和循环，像 Prolog 那样声明事实与规则，也可以像 Lisp 那样把代码当作可构造、可变换的值来对待；而这三件事在同一个文件中并存，既不分层，也不需要接口。

它明确承认的影响来源有三个，对于每一种，本书都会逐一说明 Triad 借鉴了什么：

| 影响来源 | 在 Triad 中借鉴的思想 |
|---|---|
| Julia | `function … end`、`struct`、带 `::` 的类型、多重分派、把运算符当作函数、`if`/`for`/`while`/`let` |
| Prolog | `fact`、`rule`、带 occurs-check 的合一、回溯、带逻辑变量 `?x` 的 `solve` |
| Lisp | 代码即数据（`Node`）、带 `$` 的 `:( … )`/`quote`、宏 |

除此之外，还有作为语言本身（而非某个库）的一部分而存在的东西：**错误即数据**（`Err`）、**契约**（`requires`/`ensures`）、**预算**（`with budget`）、**追踪**（`with trace`）以及**声明式副作用**（`!io`、`!state`）。

“语言的一部分”和“库”之间的区别不是嘴上说说的，值得立刻弄清楚。一个作为值的错误可以被返回、检查，并像任何其他数据一样组合，而不必中断程序；写在函数签名里的契约对实现可见，实现可以对其进行检查；声明式副作用则让运行时能够验证一个纯函数不会打印输出。这些都是一种语言只有“认识”它们才能提供的功能，正因如此，Triad 把它们写进标准，而不是留给程序员之间的约定。

语法骨架来自 Julia：`function … end` 块、带 `::` 的类型、struct 和多重分派。逻辑引擎来自 Prolog：事实、规则、带 occurs-check 的合一、回溯以及带逻辑变量的 `solve`。来自 Lisp 的是“代码是一棵统一的树”这一想法，因此代码和其他值一样，也是值；而宏机制正是建立在这个想法之上。把三种模型放在一起，才是真正新的部分：不存在“周一的语言”和“周二的语言”，只存在一个程序、一套关于表达式和块的语义。

### 1.1 两个配置档：Core 与 Full

标准定义了两个一致性配置（SPEC §16.1）：

- **Triad-Core**（[`SPEC-CORE.md`](SPEC-CORE.md)）：整数、Bool、字符串、符号、`nothing`、列表、函数、lambda 与闭包、`if`/`elseif`/`else`、`while`、`let`、`begin`、三元表达式、`return`/`break`/`continue`，以及若干引导原语。它足够小，可以用手写的机器码实现；又足够有表达力，可以用它写出整个 Triad 的解释器。
- **Triad-Full**（[`SPEC.md`](SPEC.md)）：整门语言。

这种划分源于一个现实约束，而不是图方便。Triad 的第一个解释器必须在 Triad 编译器存在之前就存在，因此必须用手写的机器码实现：语言越小，这项工作越现实。同时，这个子集又必须足够让你在第二阶段写出完整的解释器。Triad-Core 正是两种需求之间的平衡点，因此它由一份独立规范定义。

每个 Triad-Core 程序（引导原语除外）同时也是有效的 Triad-Full 程序，并且行为必须一致。反过来则不成立：使用了 `struct`、`for` 或 `float` 的程序属于 Full，Core 运行时不会执行它。这就是你会在整本书中反复遇到的区分：第二部分讲的是今天就能运行的配置档，第三部分补上其余部分。

### 1.2 引导链

Triad 不想依赖任何宿主语言，但每门语言总得从某个起点开始。引导链分阶段解决这个问题：先用手写的机器码解释器，再用它去运行一个用 Triad 写的解释器，如此递进，直到出现一个能编译自身的编译器。计划见 [`BOOTSTRAP.md`](BOOTSTRAP.md)：

```
S0  seed: interprete Triad-Core in codice macchina x86-64 (dump esadecimale nel repo)
S1  interprete di tutto Triad scritto in Triad-Core      (selfhost/, in corso)
S2  compilatore nativo scritto in Triad                  (non iniziato)
S3  compilatore self-hosted: S2 compilato da S2          (non iniziato)
S4  Triad completo: REPL, CLI, tooling, parità Linux     (non iniziato)
```

S0 seed 并不是以可执行文件的形式发布，而是以十六进制转储（dump）的形式：这是给文本仓库中的二进制文件做版本管理最简单的办法，它可以用操作系统的解码工具还原出来（见[第 2 章](#cap-2)）。S1–S4 这些阶段是项目的方向，而不是阅读本书所必需的东西：要跟着本教程走，有 S0 seed 或 JS 解释器就够了。

Node.js 下的工具（`seed/dev/*.js`、`conformance/run.mjs`、`cli/`）属于**开发工具**：它们有助于生成和验证，但不属于 S0→S4 这条链。书中的第四部分会逐一介绍它们，说明它们做什么，以及为什么它们在引导链之外。

---

<a id="cap-2"></a>

## 2. 安装与运行

这里的“安装”Triad 并不是指安装某个软件包，而是指准备好仓库以及两个运行时之一。目前既没有可以装进系统的编译器，也没有这门语言的包管理器。因此本章回答两个具体问题：怎样运行一个文件，以及从哪个运行时入手更合适。

对初学者而言，推荐的选择是 **JS 解释器**：它通过 Node.js 启动，不需要解码二进制文件，一致性用例也是用它验证的。当你想在没有宿主运行时的环境中看到语言被执行时，Windows seed 就很有意思了；它的限制列在[第 15 章](#cap-15)。阅读本书只用 JS 解释器就够了，等到某章需要时再切换到 seed。

### 2.1 环境要求

- **Node.js ≥ 18**（CI 使用 Node 20），用于 JS 解释器、一致性 runner 和 CLI。
- 在 Windows 上，使用 seed 不需要其他任何东西：`seed.exe` 由 `seed.hex` 用 `certutil` 解码得到。
- 用 Git 克隆仓库：`git clone https://github.com/GPuntobit/triad2.0.git`。

依赖之所以这么少是有意为之：Triad 不希望运行程序时依赖其他语言，而开发工具链唯一的依赖就是 Node.js。有了 Node.js，你就具备了运行第二部分全部示例所需的一切。

### 2.2 运行一个文件

Triad 程序是一个文本文件，由运行时读取、解析并执行。下表展示了在两个平台上如何启动它，以及如何把脚本从 stdin 传给它：

| 平台 | 命令 |
|---|---|
| Linux / macOS | `node seed/dev/triad_core.cjs file.triad arg1 arg2` |
| Windows（seed）| `seed\windows-x86_64\seed.exe file.triad` 或 `bin\triad.cmd file.triad` |
| 任意平台（stdin，JS 解释器）| `echo 'println(7 * 6)' \| node seed/dev/triad_core.cjs -` |

现成可运行、今天就能跑的示例：所有 `conformance/core/cases/*/program.td`，也就是本书在每章末尾引用为规范参考的那些用例。

```sh
node seed/dev/triad_core.cjs conformance/core/cases/ricorsione/program.td   # 120, 55
```

```cmd
bin\triad.cmd conformance\core\cases\ricorsione\program.td
```

注释 `# 120, 55` 不属于命令本身：它标示的是期望输出，也就是你应当看到的内容。用 `-` 代替文件名，是告诉 JS 解释器从标准输入读取程序。同一个文件可以由两个运行时执行，但结果未必相同：差异正是[第 15 章](#cap-15)的主题。

### 2.3 还原 seed

seed 的源码就是那份十六进制转储；可执行文件要用系统上的解码器得到。只有当你想试用 seed 时才需要这一步：JS 解释器不需要这个过程。

```powershell
Remove-Item seed\windows-x86_64\seed.exe -ErrorAction SilentlyContinue
certutil -decodehex seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe
```

```sh
# Linux: seed ELF allo stadio E0 (stampa solo "Triad seed Linux OK")
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed && chmod +x seed/linux-x86_64/seed
```

Windows 命令会先删除已有的旧可执行文件（如果存在），再从转储重新生成它；在 Linux 上，产物是一个极简的 ELF，即 E0 阶段，它目前只会打印一条启动消息，还不是真正的解释器。这不是安装错误，而是 [`STATUS.md`](STATUS.md) 中描述的移植现状。

### 2.4 启动器 `bin/triad` 与 `bin/triad.cmd`

有了启动器，你就不必每次都记着用哪个二进制文件、它放在哪个目录。它不是必需的，但很方便：当 `bin/` 在 `PATH` 中时，只需 `triad file.triad`，就像使用安装在系统里的语言一样。运行时查找遵循一个精确顺序，从最好的运行时排到当前可用的那个：

1. `bin/triad-native`（独立可执行文件，**尚未产出**：将随 S2–S3 一起到来）；
2. `seed/<piattaforma>/seed`（在 Windows 上是 `seed\windows-x86_64\seed.exe`）。

在 Linux 上，启动器会找到 E0 阶段的 ELF seed，它**还不会解释程序**：要在 Linux 上执行代码，请直接使用 JS 解释器。`triad --build` 是旧 Julia 实现留下的残留：它会打印一条消息，说明为什么不再支持构建，并以退出码 2 结束。当没有任何运行时可用时，启动器不会悄无声息地失败：它会打印还原 seed 的操作说明。

### 2.5 退出码

退出码是语言契约的一部分，而不是图方便的细节：一致性测试套件也会比较退出码，因此一个输出正确、但退出码不对的程序不算通过。

| 退出码 | 含义 |
|---|---|
| `0` | 成功 |
| `1` | 解析错误或运行时错误（消息输出到 stderr）、文件不可读 |
| `2` | 用法无效（例如没有指定文件）|

SPEC §14 中的选项（`-e`、`-E`、`-l`、`-i`、`--tree`、`--help`、REPL）**尚未实现**： JS 解释器会把它们当作文件名，而只记录了 `seed.exe FILE` 用法的 Windows seed 根本不认识它们。因此，当示例不工作时，第一个要问的问题是你拿到了三个退出码中的哪一个： `2` 表示命令有问题，`1` 表示程序有问题。

### 2.6 开发 CLI 简介

CLI 是可选的：它把原本要在仓库里手动完成的各种操作汇总到一个命令中。下面几行是最常用的用法，每一行都带有说明其作用的注释。

```sh
bin/triad-cli status                 # ambiente e seed trovato (Windows: bin\triad-cli.cmd)
bin/triad-cli test conformance       # conformance Core
bin/triad-cli ai verify -v           # verifica le soluzioni di ai/tasks/
bin/triad-cli seed generate windows  # rigenera seed.hex e stampa lo SHA-256
node conformance/run.mjs             # runner di conformance diretto (Core)
```

启动器 `bin/triad-cli*` 会在首次启动时于 `cli/` 中执行 `npm install`。另一种做法是使用随 [beta 版发布](https://github.com/GPuntobit/triad2.0/releases)附带的独立可执行文件 `triad-cli.exe` / `triad-cli`。细节见[第 39 章](#cap-39)。要跟随第二部分并不需要 CLI：示例可以直接用 `node` 运行。

---

<a id="cap-3"></a>

## 3. 第一个程序

Triad 程序不需要任何仪式：没有配置文件，没有需要声明的 import，也没有必须调用的 `main` 函数。第一个程序就是一个文本文件，其中的指令按应当执行的顺序排列。

创建 `ciao.triad`：

```triad
#!/usr/bin/env triad
# il mio primo programma Triad
nome = "Triad"
println("ciao, " * nome)
println(6 * 7)
```

Output:

```text
ciao, Triad
42
```

运行它：

```sh
node seed/dev/triad_core.cjs ciao.triad          # Linux/macOS
```

```cmd
seed\windows-x86_64\seed.exe ciao.triad          # Windows
```

注意以下几点：

- 第一行 `#!`（shebang）会被忽略：它以 `#` 开头，因此被当作注释；
- `println` 打印它的参数时**不加分隔符**，并在末尾补一个换行；
- 字符串之间的 `*` 表示**拼接**（不是 `+`）；
- 没有 `main` 函数：顶层语句按顺序执行。

你可以逐行追踪执行过程。`nome = "Triad"` 这一行先算出字符串，再把该值绑定到名字 `nome`。在下一行，运行时读取 `nome`，用 `*` 把两个字符串值拼接起来，并把结果传给 `println`。在最后一行，`6 * 7` 在调用之前就被求值：传到 `println` 的是整数值 `42`，而不是计算过程的文本。每条语句只执行一次，且按出现顺序执行；被调用的函数自然会在程序进入下一条语句之前先执行完自己的函数体。

`#!` 这一行并不是解释器所必需的指令：在这些示例中，它只是一种约定写法，方便操作系统直接启动可执行文件。Triad 运行时把它当作注释，因此会忽略它。如果某个示例不工作，请分别检查：文件是否以 `.triad` 或 `.td` 扩展名保存、命令是否指向正确的运行时，以及源码是否只用了所声明配置档所支持的构造。

### 3.1 命令行参数

文件名之后的参数放在 `ARGS` 中，它是一个字符串列表（不含程序名）。用 JS 解释器的例子：

```sh
printf 'println(ARGS)\nprintln(length(ARGS))\n' > args.triad
node seed/dev/triad_core.cjs args.triad uno due      # [uno, due]  poi  2
```

> Windows seed 只记录了 `seed.exe FILE` 这一种用法：`ARGS` 不在
> `seed/windows-x86_64/README.md` 所列的功能之中。带参数的程序请使用 JS 解释器。

### 3.2 推荐的工作流程

1. 只用 Triad-Core（第二部分）编写程序；
2. 用 JS 解释器运行它（`node seed/dev/triad_core.cjs`）；
3. 如果它还要在 Windows seed 上运行，请查阅[第 15 章](#cap-15)的表格；
4. 如果这是需要固化的语言行为，就把它变成一个一致性用例（见[第 38 章](#cap-38)）。

同样的循环也适用于第 17 章的练习：先写出程序，再把输出与期望输出做对比，最后如果确有需要，才去看解答。

---
<a id="parte-2"></a>

# 第二部分 —— 逐步掌握 Triad-Core（今天即可运行）

本部分的每一章都只使用 Triad-Core。带有 **Output:** 的示例都已用 JS 解释器实际执行过；每章末尾给出的那一个一致性用例，就是需要你阅读并运行的规范参考。

各章的结构始终相同，因此你总是知道该去哪里找：先讲这个构造本身以及它所解决的问题，然后是语法与规则，接着是一个完整示例及其输出，最后是示例所依据的一致性用例。当某条规则暗藏陷阱时，正文会明确指出。

<a id="cap-4"></a>

## 4. 词法

词法是编写程序时用到的基本构件集合：一个名字是什么、数字或字符串该怎么写、运行时把什么当作两条语句之间的分隔符。它不是一份需要死记硬背的清单：它的作用是让你明白为什么某段文本会被这样解读而不是那样解读，进而明白为什么一个看起来正确的程序却会产生 `parse error`。

下表汇集了 Triad-Core 的各类元素，给出允许的写法以及各自的示例：

| 元素 | 写法 | 示例 |
|---|---|---|
| 标识符 | 字母或 `_`，之后是字母/数字/`_`；允许结尾带一个 `!` | `x`, `somma_2`, `push!` |
| 整数 | 十进制数字，`_` 作为分隔符；正负号是一元运算符 | `42`, `1_000_000`, `-5` |
| 布尔值 | `true`, `false` | |
| nothing | `nothing` | |
| 字符串 | `"..."`，转义序列有 `\n \t \" \\`；**不支持插值** | `"ciao\n"` |
| 符号 | `:` 后跟一个名称或一个运算符 | `:alice`, `:+` |
| 注释 | `#` 直到行尾；`#= ... =#` 可跨多行 | |
| 分隔符 | 换行或 `;` | `println(1); println(2)` |

Core 的运算符：`+ - * % ^ == != < <= > >= && || ! = += -= *= -> ?:`。

Core 使用的保留字：`function end if elseif else while let begin return break continue true false nothing`。

不属于 Core 的有：`Float` 字面量（`1.5`）、逻辑变量 `?x`、宏 `@nome`、插值 `$x`，以及运算符 `/`。

`->` 运算符用于构造 lambda，而 `?` 与 `:` 组成条件表达式：它们是词法层面的 token，但其含义属于[第 7 章](#cap-7)和[第 10 章](#cap-10)的讨论范围。保留字不能用作变量名：解析器会把它们识别为构造，像 `let = 3` 这样的赋值会产生语法错误。保留字列表之所以这么短，是因为 Core 是一门小语言：凡是这里没有列出的东西都属于 Triad-Full，在一个 Core 程序里使用它们就不属于“今天即可运行的代码”。

另一处需要牢记的区分是空格与分隔符。空格和制表符分隔 token，但不分隔语句；分号和换行则分隔语句。因此 `println(1); println(2)` 把两条语句放在同一行，而一个空行不会产生任何语句。简而言之，分号与换行的作用相同：它是分隔符，而不是块结束标记。

```triad
#= commento
   su più righe =#
x = 1_000   # commento di riga
println(x); println("tab:\t|", " virgolette: \"", " backslash: \\")
println(:alice, " ", :+)
```

Output:

```text
1000
tab:	| virgolette: " backslash: \
alice +
```

> **注意。** 在 Core 中，`"x = $x"` 会原样打印出 `x = $x`：插值只存在于 Triad-Full。在 Core 中要拼接，应写成：`"x = " * string(x)`。
>
> 在 JS 解释器中，`#= … =#` 注释**不可嵌套**：注释会在遇到第一个 `=#` 时结束。不要指望嵌套；如果要注释的代码里已经含有 `#= … =#` 块，请改用行注释。

这两条警告同源：在 Core 中，词法被刻意做到了最小，那些在别的语言里“只是一个小细节”的东西在这里可能根本不存在。不要用其他语言的习惯去解读 Core 程序的文本：如果某个转义或符号没有出现在表里，运行时就不会识别它。

参考：`conformance/core/cases/aritmetica`、`simboli_base`、`stringhe_base`。

---

<a id="cap-5"></a>

## 5. 值、类型与打印

Triad 是一门动态类型语言：每个值都有精确的类型，但变量没有。同一个变量可以先装整数再装字符串，类型是在运算发生时检查的，而不是在声明时检查。由此带来一个实际结论：要弄清一个值里面装的是什么，得用 `typeof` 向运行时询问；而要写出健壮的代码，你得考虑可能传进来的类型，而不只是你打算传进去的那些。

下表列出了 Core 程序可能遇到的类型：

| 类型 | 取值 | `typeof(v)` |
|---|---|---|
| `Int` | 64 位带符号整数，算术按二进制补码回绕 | `Int` |
| `Bool` | `true`, `false` | `Bool` |
| `String` | 不可变的 UTF-8 字节序列 | `String` |
| `Symbol` | `:nome`；名称相同则相等 | `Symbol` |
| `List` | 异构的**可变**列表，索引从 1 开始 | `List` |
| `Function` | 具名函数、lambda 或闭包 | `Function` |
| `Nothing` | `nothing` | `Nothing` |

`typeof` 返回的是**以符号形式表示的类型名**。

用符号而不是字符串并不是吹毛求疵：`typeof(1)` 的结果是 `:Int`，不是 `"Int"`。拿结果和字符串比较行不通，正确的比较方式是 `typeof(v) == :Int`。一般来说，在 Triad 里类型是用符号来命名的；字符串是给要打印消息的人用的，不是给要写判断的程序员用的。

类型不是装饰：一次运算能接受什么，取决于类型。`Int` 是 64 位的，因为它必须装进一个机器字，而机器字正是 seed 使用的单位；`String` 不可变，因为语言没有提供就地修改它的方式；`Symbol` 是为名称和内部标识符设计的；`List` 可变，因为它是这门语言干活时的基本数据结构；`Nothing` 表示“没有有用的值”，而不是错误。

### 5.1 `print`/`println` 的打印规则

- 各参数直接拼接，不加分隔符；`println` 会追加 `\n`；
- `Int` 以十进制打印，`Bool` 打印为 `true`/`false`，`String` 原样打印，`Nothing` 打印为 `nothing`；
- 直接传入的 `Symbol` 打印时**不带** `:`；放在列表里则**带** `:`；
- `List` 打印为 `[a, b]`；列表中的字符串打印时不带引号。

```triad
xs = [1, :a, "s", true, nothing, [2, 3]]
println(xs)
println(:alice)
println(typeof(1), " ", typeof("s"), " ", typeof(:a), " ", typeof(xs))
println(typeof(nothing), " ", typeof(true), " ", typeof(x -> x))
print("senza ", "a capo")
println()
```

Output:

```text
[1, :a, s, true, nothing, [2, 3]]
alice
Int String Symbol List
Nothing Bool Function
senza a capo
```

### 5.2 相等性

`==` 和 `!=` 对数字、字符串和符号是**按值**比较，对列表是**逐元素**比较（嵌套的列表也一样），对函数则是**按身份**比较。

```triad
println([1, [2, [3]]] == [1, [2, [3]]])
println("ab" == "a" * "b", " ", :a == :a, " ", 1 == 2)
```

Output:

```text
true
true true false
```

打印出来的值并不总是一种可以直接当源码复用的表示。例如，直接传给 `println` 的符号显示时不带冒号（`alice`），而在列表里则显示为 `:alice`；列表中的字符串显示时也不带引号。所以，要验证一个值的类型，正确的做法是用 `typeof`，而 `println` 的显示形式主要是给人看的。类似地，`==` 对数字、字符串、符号和列表比较内容，对函数比较身份：两段文本相同的函数，并不因此就是同一个函数对象。

UTF-8 表示是按字节计量的，不一定等于可见的字母数。一个带重音的字母可能占多个字节；因此对字符串调用 `length`，得到的不一定是一个人眼感知到的字符数。Core 中没有针对字符的索引操作：引导原语明确工作在字节上，只应用于读取和分析源码这类任务。

参考：`conformance/core/cases/valori`、`nothing_base`、`confronti`。

---

<a id="cap-6"></a>

## 6. 变量与赋值

在 Triad 里，变量就是绑定到一个值上的名字。你既不用声明它，也不用公布它的类型：第一次赋值创建这个绑定，之后的赋值更新它。这让代码变得简短，但也把注意力转移到两个在有声明的语言里本该自动回答的问题上：此刻某个名字里装着什么值？那个名字在哪个环境里是可见的？

基本规则如下：

- `nome = espr` 用于绑定或更新一个名字；赋值是一个表达式，其值就是被赋的值。
- `+=`、`-=`、`*=` 用于更新一个已存在的变量（左侧只求值一次）。
- 使用一个从未赋值过的名字是运行时错误（`undefined variable`）。
- 没有声明，也没有类型：变量是动态的。

赋值是表达式而不是语句——这是最不显然的一条规则。它意味着 `x = 42` 不只是“做点什么”：它会产生值 `42`，而这个值可以在赋值出现的地方被使用。实践上，它在赋值出现在某个会返回值的块中时有用；但这也正是本书其余部分不再严格区分“语句”和“表达式”的原因。复合赋值（`+=`、`-=`、`*=`）是“读一次再写一次同一变量”的语法糖，并保证左侧只求值一次：如果左侧包含一个下标，这个下标不会被计算两遍。

一个在赋值之前就被使用的名字，既不是 `nothing` 也不是零：它是一个会中断程序的错误。这是有意为之，因为隐含的“空值”会掩盖逻辑错误；[第 14 章](#cap-14)会说明如何识别这种情况，以及终端上会看到什么。

```triad
x = 42
y = x + 8
x = x + 1
z = (x + y) * 2
println(x, " ", y, " ", z)
n = 10
n += 5
n -= 3
n *= 2
println(n)
```

Output:

```text
43 50 186
24
```

关于**可见性**的规则（函数内部、`let` 内、lambda 内）见[第 10 章](#cap-10)。

跟踪程序执行的一种实用方法，是维护一张当前绑定的小表：

| 已完成的语句 | `x` | `y` | `z` |
|---|---:|---:|---:|
| `x = 42` | 42 | — | — |
| `y = x + 8` | 42 | 50 | — |
| `x = x + 1` | 43 | 50 | — |
| `z = (x + y) * 2` | 43 | 50 | 186 |

这张表说明了为什么赋值不是响应式公式：`y` 保留的是它那一行被执行时算出的结果，即使之后 `x` 变了也不变。相反，列表是可变的，而且可以被多个名字引用；修改它的某个元素影响的是那个共享对象，而不只是某一处名字与值的关联。第 11 章会说明如何在代码中辨认这一差别。

参考：`conformance/core/cases/variabili`。

---

<a id="cap-7"></a>

## 7. 运算符与表达式

表达式是把值组合起来以产生新值的方式。Triad 并不严格区分表达式与语句：几乎一切都是表达式，连控制结构也有值。要毫无歧义地读懂一个表达式，需要两方面的信息：每个运算符“绑定得有多紧”，以及同一层级的运算符按什么方向结合。

### 7.1 优先级（从低到高）

| 层级 | 运算符 | 结合性 |
|---|---|---|
| 1 | `=` `+=` `-=` `*=` | 右结合 |
| 2 | `c ? a : b` | 右结合 |
| 3 | `\|\|` | 左结合，短路 |
| 4 | `&&` | 左结合，短路 |
| 5 | `==` `!=` `<` `<=` `>` `>=` | 左结合 |
| 6 | `+` `-` | 左结合 |
| 7 | `*` `%` | 左结合 |
| 8 | `^` | **右结合** |
| 9 | 一元 `-` `!` | 前缀 |
| 10 | `f(args)` `xs[i]` | 后缀 |

这张表要当作排名来读：层级 1 绑定得最松，层级 10 绑定得最紧。在 `2 + 3 * 4` 里同时出现了层级 6（`+`）和层级 7（`*`）；层级高者胜出，因此先算 `3 * 4`。当两个运算符处于同一层级时，由结合性决定：`-` 是左结合，所以 `8 - 3 - 2` 是 `(8 - 3) - 2`，而不是 `8 - (3 - 2)`。最重要的例外是 `^`，它是右结合的：`2 ^ 3 ^ 2` 表示 `2 ^ (3 ^ 2)`，结果是 512，而不是 64。

这张表描述的是 Triad-Core。Triad-Full 增加了其他运算符和其他层级——区间 `a:b`、`in`/`isa`/`is`、类型断言 `e::T`、lambda `x -> e`——这些都在规范（SPEC §2）中有描述。只写 Core 的人可以凭这张表推理；转向 Full 的人则必须查阅完整的那张表。

### 7.2 整数算术

- `+ - * ^` 作用于 `Int`，**按 64 位回绕**；
- `%` 是**带被除数符号的余数**（就像 Julia 的 `rem`）：`-7 % 3 == -1`；
- `^` 的指数为负是错误；`%` 的除数为零是错误；
- Core 中**不存在 `/`**（除法属于 Triad-Full）。

```triad
println(2 + 3 * 4, " ", (2 + 3) * 4, " ", 2 ^ 3 ^ 2)
println(7 % 3, " ", -7 % 3, " ", 10 % 4)
println(9223372036854775807 + 1)
```

Output:

```text
14 20 512
1 -1 2
-9223372036854775808
```

结果 `-9223372036854775808` 就是回绕的可见一面：最大值加一不会产生错误，而是产生最小值。Triad-Core 既没有“大整数”类型，也没有溢出检查，因为它必须保持用少量机器指令就能实现；如果某个计算必须留在合法域内，那道检查就得由程序自己来写。

负余数遵循同样的逻辑：`-7 % 3` 等于 `-1`，因为符号由被除数而不是除数决定。这就是 Julia 中 `rem` 的行为；用 `%` 计算循环位置时要记住这一点：遇到负值需要显式修正。

### 7.3 逻辑与条件

- 条件（`if`、`while`、三元表达式、`&&`、`||`、`!`）**只接受 `Bool`**：不存在“真值性”（`if 1` 是错误）。
- `&&` 和 `||` 会短路。
- 比较不能串联：`1 < 2 < 3` 是错误（这是在拿 `Bool` 和 `Int` 比较）；请写成 `1 < 2 && 2 < 3`。

```triad
println(!false, " ", true && false, " ", false || true)
println(1 < 2 && 2 < 3)
x = 3
println(x > 2 ? "grande" : "piccolo")
```

Output:

```text
true false true
true
grande
```

**短路**是看得见的：对于 `a && b`，若 `a` 为 `false`，`b` 不会被求值；对于 `a || b`，若 `a` 为 `true`，`b` 不会被求值。它不只是一个优化：它还能避免不必要的计算产生错误。因此，像 `i <= length(xs) && xs[i] > 0` 这样的检查可以在访问列表之前先验证边界，前提是 `i` 是一个合法整数。不过，两个被求值的操作数仍然都必须是布尔值。

只接受 `Bool` 这一选择避免了一整类歧义：在许多语言里，`0`、`""` 和 `nothing` 依约定是“假”的，而每位程序员带来的约定各不相同。Triad 里没有需要记住的约定：条件非真即假，任何其他类型都是错误。正因如此 `1 < 2 < 3` 行不通：比较是左结合的，解析器读到的是 `(1 < 2) < 3`，也就是拿 `Bool` 和 `Int` 作比较。

相关的一个陷阱涉及 `=` 与 `==`：`if x = 0` 并不把 `x` 和零比较，而是把零赋给 `x`，并让 `0` 成为条件的值；运行时拒绝这个值，因为它不是 `Bool`。比较要用 `==`，而且值得养成总是写它的习惯。

优先级表描述的是分组方式：`a + b * c` 等价于 `a + (b * c)`。当两个运算符层级相同时，就要看结合性。有疑问时，请加括号：括号会让你想要的分组结构变得明确，也便于区分“分组错误”和“操作数的值错了”。

参考：`conformance/core/cases/aritmetica`、`operatori`、`interi`、`confronti`。

---

<a id="cap-8"></a>

## 8. 控制流

控制流决定执行哪些语句、执行多少次。Triad 有一个让心智模型更简单的约束：**一切都是表达式**，连 `if`、`while`、`let` 和 `begin` 都有值（就是最后一条被执行语句的值；若一条都没执行，则为 `nothing`）。因此并不存在两个彼此分离的世界——“不值什么的语句”和“值点什么的表达式”——而只有一套机制，块就是包含其他表达式的表达式。

### 8.1 `if` / `elseif` / `else`

```triad
function classifica(x)
    if x < 0
        "negativo"
    elseif x == 0
        "zero"
    else
        "positivo"
    end
end
println(classifica(-3), " ", classifica(0), " ", classifica(7))
v = if 2 > 1 :si else :no end
println(v)
```

Output:

```text
negativo zero positivo
si
```

`if` 一次只求值一个条件，从第一个到最后一个，并且只执行第一个值为 `true` 的条件所对应的分支；如果没有任何条件为真且存在 `else`，就执行 `else`，否则什么都不执行，其值为 `nothing`。`elseif` 并不是“一个包含另一个 `if` 的 `else`”的语法糖：它是同一条链上的一个分支，这样就避免了每一层都要多写一个 `end`。示例的最后一行表明 `if` 可以放在赋值的右边：它的值就是所选分支的值，这里是符号 `:si`。

两个反复出现的陷阱：忘记写 `end`（它负责闭合 `if`、`while`、`function` 和 `let`），以及用 `else if` 代替 `elseif`：在 Core 中 `elseif` 是同一条链上的单个分支，而 `else if` 会嵌套出第二个 `if`，需要多一个 `end`。第 7 章的 `? :` 是同一结构的紧凑写法，当两个分支都是极短的表达式时很方便。

### 8.2 `while`、`break`、`continue`

```triad
i = 0
somma_dispari = 0
while i < 10
    i += 1
    if i % 2 == 0
        continue
    end
    somma_dispari += i
end
println(somma_dispari)
while true
    break
end
println(:fine)
```

Output:

```text
25
fine
```

`while` 是 Triad-Core 唯一的循环：没有 `for`，遍历列表要像[第 11 章](#cap-11)那样用计数器和上限来写。这一选择与引导过程是一致的：只有一种循环结构更容易用机器码实现，而 `for` 可以在之后的 S1 阶段加入，不会改变 `while` 的语义。

`while` 的经典陷阱是循环体内语句的顺序：如果 `continue` 跳过了计数器的更新，循环就不会终止。示例中计数器在每次 `continue` 之前就自增了，这不是巧合：退出条件必须能沿循环体的所有路径到达。`break` 和 `continue` 总是作用于最内层的 `while`，因此在嵌套循环中要仔细阅读。

### 8.3 `let` 与 `begin`

`let` 引入一个新的作用域，其中含有局部绑定；`begin … end` 把若干语句归拢在一起，但不创建新的绑定。

```triad
x = 1
let x = 10
    let x = 20
        println(x)
    end
    println(x)
end
println(x)
r = begin
    a = 2
    a * 21
end
println(r)
```

Output:

```text
20
10
1
42
```

`begin … end` 块把若干语句归拢在一起，并取最后一条的值：它让你在只需要一个值的地方使用多条语句，比如放在赋值右边。`let` 则是打开一个新的环境，在里面绑定的名字可以遮蔽外层的名字而不改动它们：这正是 Triad-Core 用来隔离一段计算的机制。示例展示了 `x` 的三个绑定（`20`、`10`、`1`），随后是 `begin` 的值（`42`），它和其他任何值一样进入赋值表达式。

两个构造之间的差别，就是“归拢”与“隔离”之间的差别：只想把语句放在一起时用 `begin`，当某个局部名字必须保持局部时用 `let`。

参考：`conformance/core/cases/controllo`、`if_else`、`if_elseif`、`if_nested`、`if_no_else`、`while_loop`、`let_annidato`、`begin_block`。

---

<a id="cap-9"></a>

## 9. 函数

函数是一段你为其命名、带参数并返回一个值的程序代码。它是用来构建其余一切的积木：在 Triad-Core 中既没有 struct 也没有方法，因此函数也是为某个操作命名并加以复用的唯一方式。

### 9.1 定义函数的三种方式

```triad
# forma breve: il corpo è un'espressione
quadrato(x) = x * x

# forma blocco: il valore è quello dell'ultima espressione
function calcola(n)
    m = n + 1
    m * 2
end

# funzione anonima assegnata a un nome
moltiplica = function (a, b)
    a * b
end

println(quadrato(4), " ", calcola(3), " ", moltiplica(6, 7))
```

Output:

```text
16 8 42
```

调用 `calcola(3)` 时，`n` 接收 `3`；函数体先算出 `m = 4`，再求值 `m * 2` 并返回 `8`，因为它是最后一个表达式。绑定 `m` 属于这一次调用，不会自动变成全局变量。使用简短形式时，`=` 右边的表达式直接就是函数体。匿名函数可以被赋给一个名字、作为参数传入，或由另一个函数返回：名字只是一个有用的引用，而不是函数值必须具备的属性。

### 9.2 `return`、递归与元数

- `return e` 会立即退出函数；单独写 `return` 则返回 `nothing`。
- 有名字的函数在其自身函数体内可见：直接递归是可行的。
- 实参个数必须与形参一致（否则会报 `arity mismatch`）。

```triad
function taglia(n)
    if n > 100
        return :grande
    end
    :piccola
end
fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)
fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)
mcd(a, b) = b == 0 ? a : mcd(b, a % b)
println(taglia(500), " ", taglia(5))
println(fattoriale(10), " ", fib(15), " ", mcd(48, 18))
```

Output:

```text
grande piccola
3628800 610 6
```

理解递归的方法是顺着调用链往下看，每一次调用都带着自己的参数。以 `fattoriale(4)` 为例，调用把 `n` 依次减到 3、2、1；到达基础情形时返回 1，随后挂起的调用依次恢复，并把结果分别乘以 2、3、4。因此基础情形是一个终止条件，而不仅仅是一个额外的示例。如果参数始终不趋近基础情形，函数就会继续调用自己；在 Core 运行时中，执行预算并不是语言构造，因此避免无限递归是程序自身的责任。

没有 `return` 时，函数的值就是最后执行的表达式，即使函数体是在某个 `if` 内部结束的也是如此。只有当定义语句被执行时，函数才是绑定到名字上的值：因此在它的定义行之前调用它会得到 `undefined variable`，而不是提前解析。不存在默认参数，也不存在可变参数：元数必须与形参完全一致。

### 9.3 副作用标注 `!io`

在 Triad-Full 中，会打印输出的函数必须声明 `!io`（[第 28 章](#cap-28)）。Core 接受该标注并将其忽略：写上它，代码就已经为 Full 做好了准备。

```triad
function mostra() !io
    println("hello from block")
    20 + 22
end
println(mostra())
```

Output:

```text
hello from block
42
```

该标注在 Triad-Full 中属于函数签名的一部分：在那里，一个没有 `!io` 却要打印输出的函数会违反副作用检查，调用方将得到 `Err(:effect)`（[第 28 章](#cap-28)）。在 Core 中不存在这种检查，因此该标注会被接受并忽略：程序照常运行，但你并没有得到任何额外的保证。不过从一开始就写上它依然有用，因为代码在迁移到 Full 之后依然有效，也因为它记录了编写者的意图。

参考：`conformance/core/cases/funzioni`、`funzioni_semplici`、`funzioni_blocco`、`funzioni_io`、`ricorsione`、`gcd`、`formula`。

---

<a id="cap-10"></a>

## 10. Lambda、闭包与作用域

lambda 是不需要名字的函数：你在需要的地方直接写，它本身就是那个函数值。每当你想把某种行为传给另一个函数时——「对每个元素施加这个变换」、「对每个值调用这个检查」——它都很有用，这样就无需为只用一次的代码起名字。闭包是记住自己诞生环境的 lambda；正是这一机制，使得不借助全局变量也能构造出参数化的函数。

### 10.1 Lambda

```triad
doppio = x -> x * 2
somma = (a, b) -> a + b
applica = f -> f(3)
println(doppio(5), " ", somma(1, 2), " ", applica(x -> x * x))
```

Output:

```text
10 3 9
```

函数体包含多条语句的 lambda 要用 `begin … end` 或 `function (…) … end` 来写。无参数的 lambda（`() -> …`）**不**受支持：请使用 `function () … end`。

### 10.2 闭包

lambda 会捕获它被创建时所处的环境。根据 SPEC-CORE §5，被捕获的变量是 **共享的**：对它们的修改是可见的。

```triad
function add(n)
    x -> x + n
end
f = add(10)
g = add(100)
println(f(5), " ", g(5))

function contatore()
    v = 0
    x -> begin
        v += x
        v
    end
end
acc = contatore()
acc(5)
println(acc(10))
```

Output:

```text
15 105
15
```

> Windows seed 按**值**捕获，并且只覆盖 frame 中的最后一个绑定：像
> `contatore` 这样的累加器在 seed 上可能无法工作（[第 15 章](#cap-15)）。

普通函数与闭包之间的差别，在于那个仍然可访问的外部上下文。`add(10)` 已经结束，但返回的 lambda 仍然保留着绑定 `n = 10`；对 `add` 的另一次调用则会创建一个不同的环境。而在计数器中，闭包并不只是读取 `v`：它还会更新那个共享的绑定。JS 解释器遵循 Core 的约定，这种修改对后续调用是可见的。Windows seed 的捕获能力更受限，因此依赖这一行为的程序应当用参考解释器来验证，而不能仅因为 seed 接受了语法就断定它的行为正确。

### 10.3 作用域规则

1. `function`、lambda、`let` 和 `while` 都会引入新的环境；一个名字在它所绑定的环境以及其内部环境中可见（词法作用域）。
2. **在有名字的函数内部**，赋值会绑定到本地 frame：函数**不会修改全局变量**。
3. **在 lambda 内部**，给外部已经绑定的名字赋值会更新那个绑定（上面的累加器正是这样工作的）。
4. **在顶层**，循环会更新全局变量。
5. `let x = …` 会创建一个新的 `x`；在 `let` 内部给 `x` 赋值不会影响外层的 `x`。

```triad
x = 1
function f()
    x = 2
    x
end
println(f(), " ", x)
c = 0
function incrementa()
    c += 1
end
incrementa()
println(c)
```

Output:

```text
2 1
0
```

微妙之处在于，规则 2 和规则 3 看起来自相矛盾：有名字的函数不修改全局变量，lambda 却会。这个差别并非随意为之，而是取决于环境是如何被捕获的。lambda 随身携带对创建时那个环境的引用，因此赋值会找到外部的绑定并更新它。有名字的函数则被设计为可以单独调用，不对全局作用域里的名字产生隐藏影响：赋值会创建本地绑定，而全局变量仍保持原样。示例用 `x`（仍为 `1`）和 `c`（即使在 `incrementa()` 之后仍为 `0`）说明了这一点。

如果你需要把某个结果传出去，有两条与这个模型一致的路：可以用 `return` 返回该值，或者把状态放进列表里——列表是可变的，因此即使是有名字的函数也能共享它（[第 11 章](#cap-11)）。

参考：`conformance/core/cases/lambda`、`closure`、`chiusure`、`chiusure_local`、`chiusura_in_if`、`let_chiusura`、`scope`。

---

<a id="cap-11"></a>

## 11. 列表

列表是一串有序的值，可以按位置访问。在 Triad-Core 中它是主力数据结构：既没有 struct 也没有字典，因此列表、列表的列表和带标签列表就是表示记录、环境和树的方式。理解列表的行为——它是可变的，而且索引从 1 开始—— 正是打开 Core 中所有非平凡编程之门的钥匙。

基础操作不多，但读它们时值得想一想它们对列表这个对象本身做了什么，而不仅仅是它们返回了什么值：

- 字面量：`[1, 2, 3]`、`[]`，可以异构，也可以嵌套。
- 索引**从 1 开始**：`xs[1]` 是第一个元素；越界是错误。
- 按索引赋值：`xs[i] = v`，也可以 `xs[i] += v`。
- `length(xs)` 是元素个数；`push!(xs, v)` 在末尾追加元素，**就地修改**该列表并返回它。
- 列表是引用：两个名字可能指向同一个列表。

```triad
xs = [1, 2, 3]
println(xs[1], " ", length(xs))
push!(xs, 4)
xs[1] += 100
println(xs)
alias = xs
push!(alias, 5)
println(xs)
tot = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
```

Output:

```text
1 3
[101, 2, 3, 4]
[101, 2, 3, 4, 5]
115
```

Core 没有 `map`、`filter`、`reduce`、`sum`、`sort`：它们要用 Core 自己写出来（参见 [第 16 章](#cap-16)）。

> 在 Windows seed 上：只支持整数列表，支持 `push!`，但**不**支持 `xs[i]` 和 `length(xs)`；
> 取而代之的是非标准的辅助函数 `get(xs, i)`，其索引**从 0 开始**（[第 15 章](#cap-15)）。

参考：`conformance/core/cases/liste`、`liste_base`、`liste_push`。

记住别名的模型：执行 `alias = xs` 之后，两个名字标识的并不是两份拷贝，而是同一个列表。修改 `xs[1]` 或通过 `alias` 追加元素，改变的是双方共同观察到的那个对象。如果你需要的是一个独立的值，就要显式地构建一个新列表并用循环拷贝元素。这种行为与整数变量不同：赋值 `y = x` 拷贝的是数值，此后对 `x` 的重新赋值不会更新 `y`。

在使用索引的算法中，`i = 1` 与 `i <= length(xs)` 这一对恰好表达了 Core 中位置的全部取值范围。在读取 `xs[i]` 之前，先确认 `i` 落在该范围内；越界的下标是错误，而不是一个 `nothing` 元素。一致性测试用例 `liste` 验证的正是这些标准操作，而 seed 的辅助函数 `get` 使用 0 起始的索引，不能与 `xs[i]` 混淆。

---

<a id="cap-12"></a>

## 12. 字符串、符号与转换

字符串与符号看上去像是近亲——两者都承载文本——但角色不同。字符串是一种被构造、被拼接、被打印的数据；符号则是语言视为原子值的名字，适合用作标签、键、记录的 tag 以及类型名。二者之间、以及文本与数字之间的转换，是程序读取输入、构造消息或比较以文本形式到达的值时所需的桥梁。

下表汇总了 Core 中可用的操作：

| 操作 | 含义 |
|---|---|
| `a * b` | 字符串拼接 |
| `length(s)` | UTF-8 的**字节**数（`length("é") == 2`）|
| `string(x)` | 任意值的文本表示（`string(:a) == "a"`，`string([1, 2]) == "[1, 2]"`）|
| `Int(s)` | 从字符串转整数（`Int("42") == 42`）；从 Bool 转换：`0`/`1` |
| `Symbol(s)` | 从字符串转符号（`Symbol("ciao") == :ciao`）|
| `typeof(x)` | 以符号表示的类型 |

```triad
nome = "Triad"
saluto = "ciao " * nome
println(saluto, " (", length(saluto), " byte)")
println("risposta: " * string(40 + 2))
println(Int("41") + 1, " ", Symbol("bob"), " ", string(true))
println(:ok == Symbol("ok"))
```

Output:

```text
ciao Triad (10 byte)
risposta: 42
42 bob true
true
```

要访问字符串中的单个字节，需要用到下一章介绍的引导原语。

有三件事值得留意。第一，字符串是**不可变**的：`saluto = "ciao " * nome` 不会修改 `"ciao "`，而是构建出一个新的字符串。这与语言的其余部分保持一致——只有列表是可变的——也让把字符串传给函数变得安全：接收方无法改动它。第二，拼接用的是 `*` 而不是 `+`：`+` 仍然是数值加法，这样选择就避免了在 `a + b` 这类表达式中还得猜测操作数类型的问题。第三，`length` 数的是**字节**，而不是人眼看到的字符：一个带重音的字母可能占两个字节，因此在 Core 中「字符串的长度」指的是「UTF-8 字节大小」，而针对单个字符的操作要用 [第 13 章](#cap-13) 的原语在字节层面完成。

`string(x)` 是一种为阅读而设计的表示，并不意味着结果可以被当作源码重新读入：`string(:a)` 产生 `"a"`（不带冒号），而一个列表的打印结果未必是有效的 Triad 代码。用于生成消息完全够用；但要重建一个值，就需要显式的转换。转换本身也不是校验：`Int("42")` 预设了文本格式正确，而 `Int` 作用在非数字文本上会做什么**并未被规定**；程序应当事先检查，而不是指望得到一个有用的结果。

最后一个陷阱与符号有关。`println(:ok)` 会打印出 `ok`，但这个值仍然是一个符号：`:ok == "ok"` 的结果是 `false`，正确的比较对象是 `:ok` 本身或 `Symbol("ok")`。一个值打印出来的样子并不是这个值。

参考：`conformance/core/cases/stringhe`、`stringhe_concat`、`stringhe_multi`、`simboli_base`。

---

<a id="cap-13"></a>

## 13. 引导原语

它们供 S1 用来读取和分析 Triad 源码。**不**属于 Triad-Full（SPEC-CORE §8）：只在引导代码中使用它们。

「bootstrap」这个名字解释了它们为何存在。要用 Triad 写一个 Triad 解释器，就需要读取文件、查看该文件的单个字节、并从中截取片段的能力：这些是语言用普通类型无法提供的操作，因为字符串是不可变的，也无法按下标访问。这些原语在尽可能低的层面——字节层面——补上了这一缺口，并且留在常规语言之外，因为一套完整的字符串库将随 S1 一同到来，并用 Triad 编写。

下表列出这五个原语及其语义：

| 原语 | 语义 |
|---|---|
| `readfile(path)` | 文件内容，以 `String` 返回；若不可读则报错 |
| `strlen(s)` | 字节数 |
| `strbyte(s, i)` | 位置 `i` 处的字节（`Int` 0–255），位置从 1 开始 |
| `strsub(s, a, b)` | 从第 `a` 个字节到第 `b` 个字节（含两端）的子串，位置从 1 开始 |
| `exit(n)` | 以退出码 `n` 终止进程 |

所有位置都是 **1 起始**的，与列表下标相同，而且 `strsub` 包含两端： `strsub(s, 1, 3)` 返回前三个字节。`strbyte` 返回的是 0 到 255 之间的整数，而不是字符：程序得自己知道关心的是哪些编码。越界的下标是运行时错误，而不是一个值为零的字节；因此分析源码的代码在读取之前总会先检查边界。

示例：统计一个字符串中的数字个数，并分离出第一个单词。

```triad
s = "abc 123 xyz"
cifre = 0
i = 1
while i <= strlen(s)
    b = strbyte(s, i)
    if b >= 48 && b <= 57
        cifre += 1
    end
    i += 1
end
println(cifre)
fine = 1
while fine <= strlen(s) && strbyte(s, fine) != 32
    fine += 1
end
println(strsub(s, 1, fine - 1))
```

Output:

```text
3
abc
```

第一个循环通过把字节与 ASCII 编码 `48`–`57` 比较来统计数字：`strbyte` 不会告诉你「这是一个数字字符」，它只会说「这是数字 48」，程序必须知道 48 就是数字 `0`。第二个循环查找第一个空格（编码 `32`），然后用 `strsub` 提取到它之前为止的字节；注意，如果字符串以空格开头，`fine - 1` 可能是 `0`，而这正是真正的 tokenizer 必须显式处理的情形。

程序可以用 `readfile(ARGS[1])` 读取自身或另一个源码：这正是一个自举解释器的第一步（[第 37 章](#cap-37)）。不过还是值得重申这条界线：使用了 `readfile`、`strlen`、`strbyte`、`strsub` 或 `exit` 的程序**不**是有效的 Triad-Full 程序。这是「Core 是 Full 的子集」这条规则少数几个例外之一，也正是这些原语被放在单独一章、而不是混在字符串的常规操作之中的原因。

---
<a id="cap-14"></a>

## 14. 运行时错误

运行时错误是指程序再也无法继续前进的节点：一个不存在的名字、一个错误的类型、一个越界的索引。在 Triad-Full 中，错误是值，可以被处理；而在 Triad-Core 中不行，这个差异很重要：在这里，错误会**以退出码 1 终止进程**，并在 stderr 上打印一条诊断信息。此前已经打印到 stdout 的内容会保留下来。

由于没有办法捕获错误，Core 程序的策略不是「处理它」而是「不引发它」：在访问之前检查边界，在使用之前转换值，在函数开头验证假设。运行时消息的作用是让你弄清程序在哪里、为什么停了下来。

```triad
println("prima")
println(non_esiste)
println("dopo")
```

```text
stdout:  prima
stderr:  error: undefined variable non_esiste
exit:    1
```

JS 解释器的消息（stderr）及典型原因：

| 消息 | 原因 |
|---|---|
| `parse error: unexpected token …` / `parse error: expected …` | 非 Core 语法（例如 `1.5`、`/`、`() -> …`、缺少 `end`）|
| `error: undefined variable NOME` | 从未赋值的名字，或在定义之前就被调用的函数 |
| `error: not a function` | 调用了一个并非函数的值（`x = 5; x(1)`）|
| `error: arity mismatch` | 实参个数与形参不一致 |
| `error: index out of range` | `xs[i]` 中 `i < 1` 或 `i > length(xs)` |
| `error: + type error`（`- * % < …` 等同理）| 操作数类型错误（`1 + "a"`）|
| `error: if cond` / `while cond` / `ternary cond` / `&& expects bool` | 条件不是 `Bool` |
| `error: div by zero` / `negative exponent` | `x % 0`、`2 ^ -1` |
| `error: unknown function NOME` | 以不受支持的方式使用了保留的内置函数 |
| `cannot read file: …` | 文件不存在或不可读 |
| `usage: triad FILE [ARG...]`（exit 2）| 没有传入文件 |

Windows seed 不打印详细消息：它以退出码 `1`（语法、未定义的变量或函数、参数个数、读取问题）或 `2`（没有参数）退出。

要诊断一个错误，要把**层次**与**程序中的位置**分开来看。`parse error` 表明文本没有被识别为 Core 语法：先检查配置档、括号和 `end`，再检查非 Core 的运算符。`undefined variable` 或类型错误则是在求值阶段出现的：要检查定义的顺序、名字产生时所处的环境，以及实参的实际类型。如果程序打印了第一行之后才失败，此前的那段输出不会被撤销；请复现最小用例，并把 stdout、stderr 和退出码分开比较。

不要自动地把某个运行时产生的错误文本复制到测试里。Core 测试套件比较的是 stdout 和退出码，而不是 stderr：真正重要的契约是标准所声明的行为类别。诊断细节在不同运行时之间可能变化，而针对返回值或输出的测试必须保持可重复。

### 14.1 在 Core 中把错误当作值

为了在不终止进程的前提下传播错误（Full 程序将由 S1 来做到这一点），需要采用一种基于列表的约定：`[:Err, kind, msg]`。

```triad
err(kind, msg) = [:Err, kind, msg]
is_err(v) = typeof(v) == :List && length(v) == 3 && v[1] == :Err
function div_intera(a, b)
    if b == 0
        return err(:domain, "divisione per zero")
    end
    q = 0
    while a >= b
        a -= b
        q += 1
    end
    q
end
r = div_intera(7, 0)
if is_err(r)
    println("errore ", r[2], ": ", r[3])
end
println(div_intera(17, 5))
```

Output:

```text
errore domain: divisione per zero
3
```

`[:Err, kind, msg]` 这个约定并不是语言中的类型：它是函数之间的一个协议，用 Core 提供的手段（列表和符号）写成。检测到错误的一方用 `err` 构造它；接收到错误的一方必须先检查标签再读取各字段，`is_err` 的存在正是为此。优点在于错误像任何其他值一样传递：可以被返回、保存、比较、打印。局限则在于没有任何机制强制函数遵守该协议：如果某个函数返回的是一个普通列表，标签检查就会失败，程序会带着错误的值继续运行。

当 S1 运行 Triad-Full 时，语言将拥有真正的 `Err` 值（[第 24 章](#cap-24)），这个约定就会变得多余；在此之前，它是让「错误即数据」与一个尚不支持这一点的运行时共存的方式。

注意：`&&` 会短路，因此 `v[1]` 只在 `v` 是一个 3 元素列表时才会被求值。

---

<a id="cap-15"></a>

## 15. JS 解释器与 Windows seed：差异

Triad-Core 有两套实现，而它们并不是同一回事。JS 解释器是开发工具：只要有 Node.js 就能运行，容易修改，并且是用于验证一致性用例的参考实现。Windows seed 是自举的第一步：一个用机器码编写、不依赖宿主运行时的解释器，因为是手写的，限制更多。如果一个程序也必须能在 seed 上运行（就像 S1 的代码那样），了解两者各自能做什么就至关重要。

契约是 `conformance/core/`：两个运行时必须产生相同的 golden 输出。目前 JS 解释器通过全部用例，Windows seed 通过 CI 中 `seed-windows` 作业所列的 33 个用例。在这些用例之外，两个运行时存在差异：

| 功能 | JS 解释器（`seed/dev/triad_core.cjs`）| Windows seed（`seed.exe`）|
|---|---|---|
| 整数、Bool、运算符、比较、三元 | ✅ | ✅ |
| `if`/`elseif`/`else`、`while`、`let`、`begin` | ✅ | ✅ |
| 简写形式与块形式的函数、递归 | ✅ | ✅（最多 4 个参数）|
| `return`、`break`、`continue` | ✅ | 未列在 `seed/windows-x86_64/README.md` 中 |
| lambda | ✅ 多个参数 | ✅ **仅一个参数** |
| 闭包 | 共享（变更可见，SPEC-CORE §5）| **按值**，且只有栈帧中最后一个绑定 |
| 字符串、`*`、`length(s)` | ✅ | ✅ |
| `string(x)` | ✅ 所有类型 | 仅 `Int` 和 `String` |
| 符号、`nothing` | ✅ | ✅ |
| 列表 | 可异构，`xs[i]`、`xs[i] = v`、`length`、`push!` | 仅整数；支持构造、打印和 `push!`（最多 64 个元素）|
| `get(xs, i)` | 不存在 | **非标准**辅助函数，索引 **从 0 开始** |
| `-=`、`*=`、`Int`、`Symbol`、`typeof` | ✅ | 未列在 seed 的 README 中 |
| `ARGS`、引导原语 | ✅ | 未列在 seed 的 README 中 |
| 打印一个函数 | `#lambda(x)` | `fun` |
| `triad -`（stdin）| ✅ | 否 |
| 错误消息 | 输出到 stderr | 仅退出码 |

这张表应当作为一张可移植性地图来读：左列是一个正确的 Core 程序可以依赖的行为，右列说明 seed 今天能做到什么。「未列在 README 中」并不自动意味着「不能工作」，但它意味着在亲自试过之前你不能依赖该行为。最危险的差异是语义层面的，而不是语法层面的：seed 可能接受同一个 lambda，却以不同的方式捕获它，因此能跑通的程序不一定会给出相同的结果。

实用原则：**编写遵循 SPEC-CORE 的代码，并用 JS 解释器验证**；如果它必须在 seed 上运行（就像 `selfhost/` 那样），就把自己限制在右列，并在 Windows 上验证。

---

<a id="cap-16"></a>

## 16. Triad-Core 的惯用模式

前面的章节讲解了各个单独的构造；本章把它们组合成若干反复出现的模式。它们并不是编写 Triad-Core 的唯一方式，但确实是这个语言在仓库中被实际使用的方式，包括 `selfhost/` 中 S1 的代码。认出这些模式有助于阅读别人的代码，也能在你脑中还没有现成结构时帮助选择一种结构。

### 16.1 用 Core 编写高阶函数

Core 没有 `map`/`filter`/`reduce`：用 `while` 和 lambda 写一次就够了。

```triad
function mappa(f, xs)
    out = []
    i = 1
    while i <= length(xs)
        push!(out, f(xs[i]))
        i += 1
    end
    out
end
function filtra(p, xs)
    out = []
    i = 1
    while i <= length(xs)
        if p(xs[i])
            push!(out, xs[i])
        end
        i += 1
    end
    out
end
function riduci(f, acc, xs)
    i = 1
    while i <= length(xs)
        acc = f(acc, xs[i])
        i += 1
    end
    acc
end
xs = [1, 2, 3, 4, 5, 6]
println(mappa(x -> x * x, xs))
println(filtra(x -> x % 2 == 0, xs))
println(riduci((a, b) -> a + b, 0, xs))
```

Output:

```text
[1, 4, 9, 16, 25, 36]
[2, 4, 6]
21
```

这三种模式说明高阶函数并不需要任何语法层面的支持：一个接收另一个函数的函数本来就是可以写的，而 `while` 足以遍历列表。`mappa` 构造出一个新列表，`filtra` 逐个元素做判断，`riduci` 维护一个累加器。当你的程序需要在没有 Triad-Full 那些便利设施的情况下转换数据时，它们也是出发点。

### 16.2 用带标签的列表表示记录

Core 没有 `struct`：记录就是一个列表，其第一个位置上放着一个符号作为标签。

```triad
punto(x, y) = [:Punto, x, y]
px(p) = p[2]
py(p) = p[3]
somma_punti(a, b) = punto(px(a) + px(b), py(a) + py(b))
p = somma_punti(punto(1, 2), punto(10, 20))
println(p, " ", p[1] == :Punto)
```

Output:

```text
[:Punto, 11, 22] true
```

标签不是装饰：它是判别式，让程序能在运行时识别记录的类型，并写出像 `px` 和 `py` 这样假定特定形状的函数。在 Full 中，同样的角色将由 `struct` 承担（[第 20 章](#cap-20)），并且还带字段检查的优点；在 Core 中，带标签的列表给出相同的结构但没有这种检查，于是遵守约定就成为程序员的责任。

### 16.3 用关联列表表示环境

这是 `selfhost/` 中的解释器所使用的结构：一个扁平列表 `[nome1, valore1, nome2, valore2, …]`（在 Core 中你也可以使用嵌套的键值对）。

```triad
function env_get(env, nome)
    i = 1
    while i < length(env)
        if env[i] == nome
            return env[i + 1]
        end
        i += 2
    end
    nothing
end
function env_set(env, nome, valore)
    i = 1
    while i < length(env)
        if env[i] == nome
            env[i + 1] = valore
            return env
        end
        i += 2
    end
    push!(env, nome)
    push!(env, valore)
end
env = []
env_set(env, :x, 10)
env_set(env, :y, 20)
env_set(env, :x, 11)
println(env, " ", env_get(env, :x), " ", env_get(env, :z))
```

Output:

```text
[:x, 11, :y, 20] 11 nothing
```

扁平列表交替存放名字和值：`env_get` 每次前进两个位置，`env_set` 在找到名字时更新它，否则追加到末尾。`while i < length(env)`（而不是 `<=`）是刻意为之：最后一个有用的位置是 `length(env) - 1`，因为 `env[i + 1]` 必须仍在列表之内。正是这种结构让用 Core 编写的解释器成为可能：环境和其他东西一样都是数据，而不是语言中隐藏的机制。

### 16.4 共享的可变状态

由于具名函数不能给全局变量重新赋值，共享状态只能放在一个（可变的）列表里，或者放在闭包里。

```triad
stato = [0]
function tick()
    stato[1] += 1
end
tick()
tick()
println(stato[1])
```

Output:

```text
2
```

这个列表充当共享单元：具名函数不能给 `stato` 重新赋值，但可以修改 `stato` 所指向的对象，而该变更在外部依然可见。这是在 Core 中不用闭包就获得可变状态最简单的方式；当状态必须保持私有时，闭包（[第 10 章](#cap-10)）是另一种选择。

### 16.5 构造字符串

```triad
function ripeti(s, n)
    out = ""
    while n > 0
        out = out * s
        n -= 1
    end
    out
end
function unisci(xs, sep)
    out = ""
    i = 1
    while i <= length(xs)
        if i > 1
            out = out * sep
        end
        out = out * string(xs[i])
        i += 1
    end
    out
end
println(ripeti("ab", 3))
println(unisci([1, 2, 3], ", "))
```

Output:

```text
ababab
1, 2, 3
```

用连续拼接来构造字符串是可行的，但代价不小：每次 `*` 都会创建一个新字符串，因此循环会构造出与迭代次数一样多的中间字符串。在 Core 中没有更好的替代方案——没有可用的暂存结构——对于练习性质的程序这没问题；而在真正的解释器中，更适合把各个片段累积到一个列表里，最后一次性拼接起来。

### 16.6 风格

下面这些规则并非出于美观考虑：它们源于同一个代码可能需要迁移到 Triad-Full，以及仓库是用意大利语写成的这一事实。

- 函数要小，名字要清楚（用意大利语，与仓库其余部分保持一致）。
- 每处递归都要写明基本情况；深度较大时优先使用 `while`。
- 循环要使用显式计数器（`i = 1 … while i <= length(xs)`）。
- 不要把 `fact`、`rule`、`solve`、`struct` 以及 Full 的其他关键字用作名字：代码在 Triad-Full 中也必须保持有效。
- 在会打印的函数上写 `!io`：Core 会忽略它，Full 则要求它。

这些是约定，而不是语言规则：运行时不会检查它们。但遵守这些约定的程序在 Core 和 Full 中都保持有效，而正是这一特性让项目代码能够在自举的后续阶段被复用。

---

<a id="cap-17"></a>

## 17. 引导式练习

这些练习让你把第 4–16 章的内容付诸实践；如果连起来读，它们还勾勒出一条路径：从计算与递归开始，过渡到列表和字符串，最后用一个小型 tokenizer 和一个表达式求值器收尾——也就是一个解释器最先要写的两个部件。每个练习都有一份经过验证的解答，藏在一个折叠框里：只有在你亲自尝试过之后再去打开它，因为重点不是阅读解答，而是自己写出一个能产生相同输出的版本。

要检查你的解答，把它保存到一个文件里，并用 `node seed/dev/triad_core.cjs` 运行；然后把输出与解答中展示的输出作对比。如果输出一致但代码不同，也没问题：这些练习描述的是一种行为，而不是唯一可能的写法。

### 练习 1 —— 幂与求和

不使用 `^`，编写递归的 `potenza(b, e)`，以及使用 `while` 的 `somma_fino(n)`（即 `1 + … + n` 的和）。打印 `potenza(3, 13)`、`potenza(2, 10)` 和 `somma_fino(100)`。

<details>
<summary>解答</summary>

```triad
potenza(b, e) = e == 0 ? 1 : b * potenza(b, e - 1)
function somma_fino(n)
    s = 0
    i = 1
    while i <= n
        s += i
        i += 1
    end
    s
end
println(potenza(3, 13), " ", potenza(2, 10), " ", somma_fino(100))
```

Output:

```text
1594323 1024 5050
```

</details>

### 练习 2 —— 素数

打印小于 30 的素数列表。

<details>
<summary>解答</summary>

```triad
function primo(n)
    if n < 2
        return false
    end
    d = 2
    while d * d <= n
        if n % d == 0
            return false
        end
        d += 1
    end
    true
end
primi = []
n = 2
while n < 30
    if primo(n)
        push!(primi, n)
    end
    n += 1
end
println(primi)
```

Output:

```text
[2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
```

</details>

### 练习 3 —— 反转列表

编写 `inverti(xs)`，返回一个元素顺序相反的新列表。

<details>
<summary>解答</summary>

```triad
function inverti(xs)
    out = []
    i = length(xs)
    while i >= 1
        push!(out, xs[i])
        i -= 1
    end
    out
end
println(inverti([1, :due, "tre"]))
```

Output:

```text
[tre, :due, 1]
```

</details>

### 练习 4 —— 插入排序

就地排序 `[5, 2, 9, 1, 7]`。

<details>
<summary>解答</summary>

```triad
function ordina!(xs)
    i = 2
    while i <= length(xs)
        k = xs[i]
        j = i - 1
        while j >= 1 && xs[j] > k
            xs[j + 1] = xs[j]
            j -= 1
        end
        xs[j + 1] = k
        i += 1
    end
    xs
end
println(ordina!([5, 2, 9, 1, 7]))
```

Output:

```text
[1, 2, 5, 7, 9]
```

按照惯例，名字末尾的 `!` 表示该函数会修改自己的参数。

</details>

### 练习 5 —— 单词计数器

使用 `strbyte` 统计 `"il  linguaggio Triad "` 中的单词数（单词由空格分隔）。

<details>
<summary>解答</summary>

```triad
function conta_parole(s)
    n = 0
    dentro = false
    i = 1
    while i <= strlen(s)
        spazio = strbyte(s, i) == 32
        if !spazio && !dentro
            n += 1
        end
        dentro = !spazio
        i += 1
    end
    n
end
println(conta_parole("il  linguaggio Triad "))
```

Output:

```text
3
```

</details>

### 练习 6 —— 一个迷你 tokenizer

把 `"12+x*3"` 转换成一个 token 列表 `[tipo, testo]`，token 类型为 `:num`、`:id`、`:op`。这是一个解释器的第一步（参见 `selfhost/tokenizer.td`）。

<details>
<summary>解答</summary>

```triad
cifra(b) = b >= 48 && b <= 57
lettera(b) = (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || b == 95
function tokenizza(s)
    toks = []
    i = 1
    while i <= strlen(s)
        b = strbyte(s, i)
        if cifra(b)
            j = i
            while j <= strlen(s) && cifra(strbyte(s, j))
                j += 1
            end
            push!(toks, [:num, strsub(s, i, j - 1)])
            i = j
        elseif lettera(b)
            j = i
            while j <= strlen(s) && (lettera(strbyte(s, j)) || cifra(strbyte(s, j)))
                j += 1
            end
            push!(toks, [:id, strsub(s, i, j - 1)])
            i = j
        else
            push!(toks, [:op, strsub(s, i, i)])
            i += 1
        end
    end
    toks
end
println(tokenizza("12+x*3"))
```

Output:

```text
[[:num, 12], [:op, +], [:id, x], [:op, *], [:num, 3]]
```

</details>

### 练习 7 —— 对表达式求值

使用练习 6 中的 token，编写一个带优先级的 `+` 和 `*` 递归下降求值器，其中变量取自一个关联列表。提示：把当前位置保存在列表 `pos = [1]` 中，这样函数就能更新它。

<details>
<summary>解答</summary>

```triad
cifra(b) = b >= 48 && b <= 57
lettera(b) = (b >= 97 && b <= 122) || b == 95
function tokenizza(s)
    toks = []
    i = 1
    while i <= strlen(s)
        b = strbyte(s, i)
        if cifra(b)
            j = i
            while j <= strlen(s) && cifra(strbyte(s, j))
                j += 1
            end
            push!(toks, [:num, strsub(s, i, j - 1)])
            i = j
        elseif lettera(b)
            j = i
            while j <= strlen(s) && lettera(strbyte(s, j))
                j += 1
            end
            push!(toks, [:id, strsub(s, i, j - 1)])
            i = j
        else
            push!(toks, [:op, strsub(s, i, i)])
            i += 1
        end
    end
    toks
end
function cerca(env, nome)
    i = 1
    while i < length(env)
        if env[i] == nome
            return env[i + 1]
        end
        i += 2
    end
    0
end
function primario(toks, pos, env)
    t = toks[pos[1]]
    pos[1] += 1
    if t[1] == :num
        Int(t[2])
    else
        cerca(env, t[2])
    end
end
function prodotto(toks, pos, env)
    v = primario(toks, pos, env)
    while pos[1] <= length(toks) && toks[pos[1]][2] == "*"
        pos[1] += 1
        v = v * primario(toks, pos, env)
    end
    v
end
function somma(toks, pos, env)
    v = prodotto(toks, pos, env)
    while pos[1] <= length(toks) && toks[pos[1]][2] == "+"
        pos[1] += 1
        v = v + prodotto(toks, pos, env)
    end
    v
end
valuta(s, env) = somma(tokenizza(s), [1], env)
println(valuta("12+x*3", ["x", 10]))
println(valuta("2*3+4*5", []))
```

Output:

```text
42
26
```

</details>

---
<a id="parte-3"></a>

# 第三部分 —— Triad-Full（完整标准）

本部分介绍由 [`SPEC.md`](SPEC.md) 定义的语言。**当前的运行时尚不能执行**它：它的用途是了解标准、编写为 S1 做准备的代码，以及理解 `conformance/cases/` 中的 golden。每一章都会指出它源自 SPEC 的哪一节。标记为 **Output (golden Full):** 的输出来自已冻结的 golden。

<a id="cap-18"></a>

## 18. Full 的词法与类型 (SPEC §1, §4)

Full 在 Core 的词法基础上扩展了以下内容：

| 元素 | 形式 | 示例 |
|---|---|---|
| 标识符 | 与 Core 相同，也允许非 ASCII 字母；若后面不跟 `=`，则可以以 `!` 结尾 | `età`, `push!` |
| 逻辑变量 | `?` **紧贴**名称 | `?x`, `?who` |
| 匿名变量 | `?_`（每次出现都是一个新变量）| `parent(?x, ?_)` |
| `Float` | `3.14`, `1e-9` | |
| 插值 | `"x = $x"`, `"$(a + b)"`；额外的转义 `\$` | |
| 嵌套注释 | `#= a #= b =# c =#` | |
| 宏 | `@nome(...)` | `@unless(c, e)` |

**关键字：** `function struct macro end if elseif else for in while let begin return break continue fact rule solve quote try catch with requires ensures true false nothing isa is`。`solve` 之后的上下文关键字：`limit depth steps trace`。

**冒号 `:` 的规则**
- `1:n`, `xs[2:end]`：`:` 紧贴某个值且不带空格 → range；
- `f(:a)`, `x = :a`：`:` 前面没有值、后面跟着名称 → 符号；
- `:( … )` → 引用的代码；
- `c ? a : b`：`:` 两侧都有空格 → 三元表达式。

**`?` 的规则：** `?x` 紧贴 = 逻辑变量；`? ` 后带空格 = 三元表达式。

换行会结束一条语句，但在 `( )`、`[ ]` 和 `:( )` 内部除外；紧跟在二元运算符之后或 `rule` 的逗号之后时，换行同样不结束语句。

**Full 类型**（除 Core 的类型之外）：

| 类型 | 值 |
|---|---|
| `Int`, `Float`（`Number` 的子类型）| `42`, `3.5` |
| `Expr` | 引用的代码（`Node`）|
| `Term`, `Cons` | 逻辑项与列表模式 |
| `Solution` | `{who = :dave}` |
| `Err` | 错误即数据 |
| `Type` | `typeof(3) == Int` |
| 用户自定义 struct | `Point(3.0, 4.0)` |
| `Any` | 一切类型的超类型，用于函数签名 |

**类型化变量：**

```triad-full
x::Int = 5
x = 6          # bene
x = 5.5        # Err(:type): il nome mantiene il tipo dichiarato
y::Float = 1.0
y = 2          # 2.0: conversione Int → Float
```

该约束随声明而产生，并存在于创建该名称时所处的那个作用域中。

---

<a id="cap-19"></a>

## 19. 类型化函数与多重分派 (SPEC §5)

```triad-full
sq(x) = x * x
area(n::Number) = :number
area(n::Int) = :int

function dist(a::Point, b::Point)::Float
    requires a.x != b.x || a.y != b.y
    sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

function +(a::Point, b::Point)      # gli operatori sono funzioni ridefinibili
    Point(a.x + b.x, a.y + b.y)
end
```

规则：
- 在所有适用的方法中，**最具体**的那个胜出（`area(1) == :int`，`area(1.5) == :number`）；
- 没有适用的方法 → `Err(:method)`（对数值运算符则会回退到内置实现）；
- 有多个同样具体的方法 → `Err(:ambiguous)`；
- 返回类型 `::R` 在函数出口处检查（包含 Int→Float 的转换）；
- 函数和运算符都是值：`reduce(+, xs)`、`map(sq, xs)`；
- 类型化 lambda：`function (x::Int) x end` → `f(2.0)` 的结果是 `Err(:type)`。

要预测将调用哪个实现，请先检查参数个数，再检查每个参数的类型。对于方法 `area(n::Number)` 和 `area(n::Int)`，整数 `1` 与两者都兼容，但 `Int` 比 `Number` 更具体；`Float` 类型的 `1.5` 只与基于 `Number` 的方法兼容。在带多个参数的方法中，比较是按元组进行的：一个函数签名可能在第一个参数上更具体，却在第二个参数上更宽泛。如果没有任何一个签名支配其他签名，系统不会去猜测意图：结果是错误 `:ambiguous`，这要求你提供一个更具体的签名，或者重新审视已有的签名。

返回类型的检查发生在函数体之后。因此 `::Float` 不会预先转换参数，也不保证每一个中间运算都合法；它要求最终产生的值可转换，或与所声明的类型兼容。于是，参数注解与返回注解是该方法契约中彼此独立的两部分。

---

<a id="cap-20"></a>

## 20. Struct (SPEC §4)

```triad-full
struct Point
    x::Float
    y::Float
end

p = Point(3, 4)      # costruttore posizionale, Int → Float
p.x                  # 3.0
typeof(p) == Point   # true
p isa Point          # true
```

- 不可变；字段带类型。
- 字段不存在 → `Err(:field)`；类型不符 → `Err(:type)`。
- 在 Core 中，同样的概念用带标签列表表示（[§16.2](#cap-16)）。

struct 提供一个**具名**记录：类型名称把 `Point` 与另一个记录区分开来，而字段名（`x`、`y`）则让你不必记住数字位置。构造时会对照字段的类型检查取值；访问 `p.x` 则按名称解析字段。在标准中结构体是不可变的，因此字段描述的是所创建实例的状态，不会因为后续的赋值而更新。Core 的带标签列表更灵活，但把这些保证转移给了构造、读取和修改该记录的代码。

---

<a id="cap-21"></a>

## 21. Full 控制流：`for`、range、推导式、`try` (SPEC §2)

```triad-full
s = 0
for i in 1:10
    s += i
end                                  # s == 55

xs = [1, 2, 3]
xs[end]                              # 3
xs[2:end]                            # [2, 3]
[x^2 for x in 1:4 if x > 2]          # [9, 16]
x = 3; x > 2 ? :big : :small         # :big

e = try div(1, 0) end                # l'errore diventa il valore
r = try div(1, 0) catch err; 0 end   # con catch: err è l'Err, il valore è quello del ramo
```

其他预期取值（来自旧版 Julia 实现中的测试）：

```triad-full
x = 2; y = x * 21; y                           # 42
7 / 2                                          # 3.5
"ab" * "cd"                                    # "abcd"
let a = 1, b = a + 1; a + b; end               # 3
if 1 > 2; :a; elseif 2 > 1; :b; else; :c; end  # :b
sq(x) = x * x; map(sq, [1, 2, 3])              # [1, 4, 9]
reduce(+, [1, 2, 3, 4])                        # 10
filter(x -> x % 2 == 0, 1:6)                   # [2, 4, 6]
function fact_(n::Int)::Int
    if n <= 1; return 1; end
    n * fact_(n - 1)
end; fact_(10)                                 # 3628800
```

顶层的 `requires c` 是一条断言；`ensures c` 只允许出现在 `function` 内部。

在循环中，range `1:10` 表示从 1 到 10 的闭区间整数值：你不必手写一个列表字面量。`for` 把每一个后继值绑定到 `i`，为这次绑定执行循环体，并一直持续到可迭代对象结束。推导式把同样的模式与结果构造结合起来：它对每个元素求值过滤器，只把对应的表达式加入输出。因此读取顺序是“迭代器、过滤器、表达式”，而不是同时求值。

`try` 则划定了错误可以被转化为结果的边界。没有 `catch` 时，该表达式直接返回 `Err`；有 `catch err` 时，局部名称 `err` 标识该错误，而最终值是恢复块中的值。这样就可以处理某种情况，而不会把错误与同类型的成功值混为一谈。

---

<a id="cap-22"></a>

## 22. 逻辑：事实、规则、`solve` (SPEC §6)

```triad-full
fact parent(:alice, :bob)
fact parent(:alice, :carol)
fact parent(:bob, :dave)

rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)
rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
```

`solve` 返回一个 **`Solution` 列表**（它是一个值，不会打印任何内容）：

```triad-full
sols = solve grandparent(:alice, ?who) limit 5
[s.who for s in sols]                       # [:dave]
[s.d for s in solve ancestor(:alice, ?d)]
```

- 选项：`limit n`、`depth d`、`steps s`（默认 1 000 000）、`trace`。
- 作为函数使用的谓词是一个 `Bool`：`grandparent(:alice, :dave)` → `true`；可以在 `if` 中使用。
- 目标：`p(t…)`、`g1 && g2`、`(g1, g2)`、`g1 || g2`、`!g`/`not(g)`、`a = b`（合一）、`?y is espr`、比较、返回 `Bool` 的 Triad 函数、`true`/`false`。
- occurs-check 处于启用状态：`solve ?x = f(?x)` 没有解（不会陷入循环）。
- 模式中可使用 Prolog 风格的列表：`[?h | ?t]`。
- `vars(s)` 返回一个 `Solution` 中绑定的名称；通过 `s.nome` 或 `s[:nome]` 访问。

要读懂一条规则，请把**头部**与**主体**分开来看。在 `grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)` 中，头部描述该规则能够证明哪些值；主体则要求依次完成两次证明。引擎先为第一个目标查找一个 `parent`，把找到的绑定保存给 `?y`，然后在第二个目标中使用这个绑定。如果第二个目标失败，就退回上一次选择，尝试下一个兼容的事实：这就是回溯。如果两者都成功，`?z` 就会出现在解中。

不同子句中同名的变量不会意外共享状态：每次使用该规则时它们都会被重命名。occurs-check 阻止不可能的递归绑定，例如 `?x = f(?x)`。`depth` 限制会剪掉过深的分支；`steps` 限制总工作量；`limit` 限制收集到多少个解。这是三种不同的控制，而且在限制之内得到一个空列表，并不等同于一次被 `Err(:budget)` 打断的搜索。

示例：

```triad-full
# percorso con costo
fact edge(:a, :b, 2)
fact edge(:b, :c, 3)
rule path(?x, ?y, ?c) :- edge(?x, ?y, ?c)
rule path(?x, ?y, ?c) :- edge(?x, ?z, ?c1), path(?z, ?y, ?c2), ?c is ?c1 + ?c2
(solve path(:a, :c, ?costo))[1].costo      # 5

# append alla Prolog
rule app([], ?l, ?l)
rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
(solve app([1, 2], [3], ?r))[1].r          # [1, 2, 3]
length(solve app(?a, ?b, [1, 2, 3]))       # 4

# negazione per fallimento
fact parent(:tom, :bob)
persone = [:tom, :bob]
foglie = filter(p -> !parent(p, ?_), persone)   # [:bob]
```

---

<a id="cap-23"></a>

## 23. 解构 (SPEC §2)

列表模式具有**精确元数**；模式周围的括号是必需的。

```triad-full
(a, b) = [1, 2]                 # a == 1, b == 2
e = try (a, b) = [1] end        # e.kind == :bounds
e = try (a, b) = [1, 2, 3] end  # e.kind == :bounds

xs = []
for (k, v) in [[1, 2], [3, 4]]
    push!(xs, k + v)
end                             # xs == [3, 7]
```

- `for` 中出现非列表元素或元数不同的元素 → `Err(:bounds)` 或 `Err(:type)`。
- `function f((a, b))` 定义的是**两个参数** `a` 和 `b`（参数被展平）： `f(10, 20) == 30`。若要解构单个列表参数，请在函数体中使用 `(a, b) = pair`。
- 递归的嵌套模式目前尚不支持。

---

<a id="cap-24"></a>

## 24. 错误即数据 (SPEC §8)

错误是一个 `Err(kind, msg, data)` 值；除非在顶层未被处理，否则它不会变成宿主异常（此时进程以退出码 1 结束，且失败语句的 stdout 为空：这正是一致性测试中 `errore` 的情形）。

```triad-full
e = try div(1, 0) end     # Err(:domain, ...)
e.kind                    # :domain
e.msg                     # messaggio
iserr(e)                  # true
7.0 / 0                   # Inf: la divisione Float non è un errore
throw(err(:mio, "ops", 42))
error("boom")             # Err(:error, ...)

describe(e::Err) = string("errore ", e.kind, ": ", e.msg)
describe(x::Any) = string("valore ", x)
for r in [try div(10, d) end for d in [2, 0, 5]]
    println(describe(r))
end
```

标准 kind：`:syntax`、`:undef`、`:type`、`:method`、`:ambiguous`、`:field`、`:bounds`、`:domain`、`:instantiation`、`:contract`、`:budget`、`:effect`、`:host`。

`Err(:syntax)` 会在 `data` 中带上位置信息（`e.data.line`、`e.data.col`）。

错误处理把失败的操作与程序决定如何应对它的位置分离开来。`try` 不会自动修复状态：它把结果转换成一个 `Err` 值，或者把该值传给 `catch` 块。于是调用方可以选择显示一条消息、尝试另一种方案，或者通过返回该错误来传播它。如果没有任何 `try` 拦截到它，运行时就会把它上报到上一层，进程以非零退出码终止。这样处理是显式的，但错误不会仅仅因为被表示成一个值就变成成功。

---

<a id="cap-25"></a>

## 25. 契约 (SPEC §9)

```triad-full
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end

safe_div(6, 3)            # 2.0
e = try safe_div(1, 0) end
e.kind                    # :contract
e.data.clause             # :requires
e.data.fn                 # :safe_div
```

- `requires c` 在它出现的位置被检查（函数体的开头，或在顶层作为断言）。
- `ensures c` 在退出时检查，此时 `result` 绑定到返回值，检查发生在返回类型检查之后。
- 违反 → `Err(:contract, …)`，其中带有 `data.clause`、`data.fn`、`data.cond`、`data.result`。
- 契约是**纯粹的**：契约内部出现副作用 → `Err(:effect)`。
- 在 `function` 之外使用 `ensures` → `Err(:syntax)`。

把 `requires` 看作操作的入口条件，把 `ensures` 看作出口条件。前置条件规定了调用者必须保证什么；后置条件规定了函数在正常结束时承诺什么。契约子句不能取代类型检查：一个函数可能收到类型正确的参数，却仍然违反某条定义域前置条件；也可能返回一个类型正确、却违反后置条件的值。由于契约是纯粹的，它们的求值不能打印任何东西，也不能修改知识库：检查本身不得改变它正在验证的程序。

---

<a id="cap-26"></a>

## 26. 预算 (SPEC §10)

```triad-full
r = with budget(steps = 10_000)
    while true end
end
r.kind                    # :budget — il ciclo infinito diventa un valore
```

- 一步 = 一次调用、一次循环迭代、一步求解。
- 预算可以嵌套：以最内层为准；只有当前 `with` 的预算会变成值，外层预算则继续向外传递。
- `solve … steps N` 是单次查询的预算。
- 无限递归不会导致栈溢出：它最终以 `Err(:budget)` 结束（显式栈）。

预算衡量的是标准所定义的工作单位，而不是 CPU 秒数，也不是已分配的内存。因此它是执行模型步数上一个可复现的限制，而不是操作系统的通用超时。用它来给可能极其漫长的计算设定上限，尤其是逻辑求解，或可能不会终止的循环。`Err(:budget)` 这个结果与函数体的有效结果并不相同，可以用 `try` 处理，也可以通过检查 `with` 返回的值来处理。

---

<a id="cap-27"></a>

## 27. 追踪 (SPEC §11)

追踪是一个**值**，而不是输出。

```triad-full
fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)
t = with trace
    fib(3)
end
t.result      # 2
t.trace       # [Event(port=:call, fn=:fib, args=[3], depth=0), …]

t = solve path(:a, :c) trace
t.trace       # porte Byrd: :call, :exit, :redo, :fail, :depth
```

事件是记录，带有 `port`、`goal`/`fn`、`depth`（函数还有 `value`/`args`）：它们像任何值一样可以被过滤。

追踪记录的是计算的历史，而不只是它的结果。在函数追踪中，`call` 表示进入，`exit` 表示退出；在逻辑查询中还会出现 `redo` 和 `fail`，因为搜索可能尝试多个备选方案。`result` 的值始终与事件并列可用：你可以把最终结果与所走的路径作比较。追踪不是自动打印出来的日志；由程序决定要过滤、计数或展示哪些事件。

---

<a id="cap-28"></a>

## 28. 声明式副作用 (SPEC §12)

函数默认是纯粹的。副作用有两种：`io`（`println`、`print`）和 `state`（在函数内部使用 `fact`/`rule`）。

```triad-full
function saluta(nome::String) !io
    println("ciao, ", nome)
end

function impara(x) !state
    fact visto($x)
end
```

- 动态检查：一个纯粹函数调用了 `!io` 函数或 `println` → `Err(:effect)`。
- 顶层允许所有副作用；lambda 继承所在上下文的副作用。
- 宏和契约是纯粹的；读取知识库（`solve`、谓词）也是纯粹的。
- 修改列表或局部变量不算副作用。

副作用声明是对执行权限的动态校验，而不只是描述性的注解。当函数尝试执行带副作用的操作时，运行时会检查调用链：`!io` 函数只有在调用上下文允许时才能打印。顶层是最宽松的上下文；从那里调用一个纯粹函数，并不会因此就获得打印的许可。在签名中列出 `!io` 是向调用者说明要求，也让运行时能够在该副作用违反声明的地方当场拒绝它。

---

<a id="cap-29"></a>

## 29. 代码即数据、统一树与宏 (SPEC §3, §7)

### 29.1 统一树

解析器只产生一种节点类型 `Node(head, args)`：kernel 执行的正是这棵树，`:( … )` 返回的也是这棵树，`--tree` 打印出来的同样是这棵树（以 S-表达式形式）。

| 语法 | 节点 |
|---|---|
| `f(a, b)`, `a + b` | `(call f a b)`, `(call + a b)` |
| `a && b`, `a \|\| b` | `(and a b)`, `(or a b)` |
| `x = e` | `(assign x e)` |
| `:alice` | `(sym alice)` |
| `a.x`, `xs[i]` | `(dot a x)`, `(index xs i)` |
| `[a, b]`, `[h \| t]` | `(list a b)`, `(cons (list h) t)` |
| `[e for x in xs if c]` | `(comprehension e x xs c)` |
| `x -> e` | `(lambda (tuple x) e)` |
| `x::T` | `(typed x T)` |
| `"a $x"` | `(string "a " x)` |
| `if c a else b end`, `c ? a : b` | `(if c (block a) (block b))` |
| `while`, `for`, `let`, `begin` | `(while c body)`, `(for x iter body)`, `(let (tuple …) body)`, `(block …)` |
| `function f(a::T)::R !io … end` | `(function f (tuple (typed a T)) R (tuple io) body)` |
| `struct P; x::Float; end` | `(struct P (tuple (typed x Float)))` |
| `macro m(a) … end`, `@m(e)` | `(macro m (tuple a) body)`, `(macrocall m e)` |
| `:(e)`, `quote … end`, `$e` | `(quasi e)`, `(quasi (block …))`, `(unquote e)` |
| `fact t`, `rule h :- g1, g2` | `(fact t)`, `(rule h g1 g2)` |
| `solve g limit 5 trace` | `(solve g (tuple (assign limit 5) (assign trace true)))` |
| `try b catch e h end` | `(try b e h)` |
| `with budget(steps = N), trace … end` | `(with (tuple (call budget (assign steps N)) trace) body)` |

把表格中的一行读作**可见语法**与**内部表示**之间的映射。例如 `a + b` 并不需要为加法准备一种专门的节点类型：它就是对名字 `+` 的调用，带两个参数。相反，`&&` 变成了一个专用节点，因为求值器必须能够避免对第二个操作数求值。所以，树的形式并不是装饰：它编码了运行时为遵守语义所必须做出的决策。

这个模型在读错误信息时同样有用：如果 `sexpr` 显示的树与预期的分组不一致，问题出在解析阶段；如果树是正确的但结果不对，问题更可能出在求值阶段。程序的形式与程序的值之间的区分，正是元编程的基础。

### 29.2 Quote、unquote 与 eval

```triad-full
c = :(a.x + f(b, 2))
c.head        # :call
sexpr(c)      # "(call + (dot a x) (call f b 2))"

n = 7
quadrato = :($n * $n)
eval(quadrato)                  # 49
parse("if x > 0; :pos; else; :neg; end")   # albero
unparse(parse_program("1:n"))   # "1:n"
Expr(:call, :f, 1)              # costruisce un Node
```

### 29.3 宏

宏接收代码并返回代码；展开是纯粹的，而且是**非卫生式**的：请用 `gensym()` 生成新的名字。

```triad-full
macro unless(c, body)
    :(if !$c; $body; end)
end

macro swap(a, b)
    tmp = gensym(:tmp)
    quote
        $tmp = $a
        $a = $b
        $b = $tmp
    end
end

macro time_it(label, e)
    :(begin
        r = $e
        println($label, " -> ", r)
        r
    end)
end

@swap(x, y)
@unless(x < y, println("x non è minore di y"))
@time_it("somma", reduce(+, 1:100))     # stampa "somma -> 5050"
```

要评估一个宏，就把源参数与它构造出的代码作比较。在 `@unless(c, body)` 中，`c` 和 `body` 是以节点的形式传入的；宏把它们插入一个条件被取反的 `if` 中。这样，函数体只有在原条件为假时才会执行，就如同程序员手写了那段代码一样。如果宏改用普通函数，参数会在调用之前就被求值，你将无法控制 `body` 是否被求值。这项能力很强大，但也让执行过程更难阅读：显式展开以及生成的临时名字，是避免意外的关键工具。

### 29.4 生成代码的代码

```triad-full
function poly(coeffs)
    acc = :(0)
    i = 0
    for c in coeffs
        acc = :($acc + $c * x ^ $i)
        i += 1
    end
    acc
end
p = poly([1, 2, 3])
x = 2
eval(p)        # 17
```

---

<a id="cap-30"></a>

## 30. Full 内置函数 (SPEC §13)

| 作用域 | 函数 |
|---|---|
| 算术与比较 | `+ - * / ^ % == != < <= > >= !`、`abs sqrt floor ceil round exp log sin cos div mod min max`；`*` 连接字符串 |
| 列表 | `length isempty first last rest reverse sort sum push! pop! append! vcat collect`、`a:b`、`x in xs` |
| 高阶 | `map filter reduce any all count` |
| 字符串与输出 | `string repr println print` |
| 类型 | `typeof`、`isa`、`Int Float String Symbol` |
| 错误 | `err iserr throw error` |
| 代码 | `eval parse unparse sexpr Expr gensym` |
| 逻辑 | `vars(sol)` |

其中 Core 只提供 `+ - * % ^`、比较、`&& || !`、`length`、`push!`、索引、字符串上的 `*`、`Int`、`string`、`Symbol`、`print`、`println`、`typeof`（SPEC-CORE §7）。

---

<a id="cap-31"></a>

## 31. 命令行与 REPL (SPEC §14)

`triad` 的规范接口（目前运行时只实现了 `triad FILE [ARG...]`，以及在 JS 解释器中的 `triad -`）：

```
triad                            # REPL
triad FILE [ARG...]              # esegue FILE; ARGS == [ARG...]
triad -l FILE                    # carica FILE e apre il REPL
triad -i FILE                    # esegue FILE e poi apre il REPL
triad -e CODE                    # esegue CODE
triad -E CODE                    # esegue CODE e stampa il valore
triad --tree FILE                # stampa l'albero uniforme come S-expression
triad -q                         # REPL senza banner
triad -h, --help
triad -v, --version
triad -                          # legge lo script da stdin
```

- 扩展名 `.triad`/`.td` 可以省略；shebang `#!` 会被忽略。
- 退出码：`0` 表示成功，`1` 表示未处理的错误（打印到 stderr），`2` 表示用法无效。

**REPL**（Prolog 风格）：

```
triad> 1 + 2
3
triad> ?- ancestor(:tom, ?d)
?d = :bob ;
?d = :liz.
triad> parent(:jim, ?x)
false.
```

- 未闭合的块会一直等待，直到 `end`。
- `?- goal`（或针对知识库中某个谓词的 goal）会执行一次查询；每得到一个解之后，`;`/`n`/空格 = 下一个解，`a` = 全部解，回车/`.` = 停止。
- 命令：`:load FILE…`（`:l`）、`:reload`（`:r`、`make`）、`:listing [nome|nome/arità]`（`:ls`）、`:tree CODICE`、`:reset`、`:help`（`:h`）、`:quit`（`:q`、`halt`、Ctrl-D）。

---

<a id="cap-32"></a>

## 32. 带 golden 输出的 Full 示例

这些文件位于 `examples/`（待 S1 就绪后即可运行）；输出则是 `conformance/cases/` 中冻结下来的 golden。

| 文件 | 覆盖内容 | golden 用例 |
|---|---|---|
| `examples/assaggio.td` | struct、多重分派、逻辑、宏、契约 | `assaggio` |
| `examples/famiglia.td` | 事实/规则、递归、Prolog 列表、否定 | `famiglia` |
| `examples/garanzie.td` | 错误、契约、预算、追踪、副作用 | `garanzie_core` |
| `examples/macro.td` | quote、eval、宏、gensym | `macro` |
| `examples/tour.td` | 所有范式 | `tour` |
| `examples/hello_shebang.td` | shebang、`ARGS`、副作用 | `hello_shebang` |
| `examples/benvenuto.triad` | 规范扩展名、`Float`、`solve` | — |

### 32.1 `assaggio.td`

```triad-full
struct Point
    x::Float
    y::Float
end

function dist(a::Point, b::Point)::Float
    requires a.x != b.x || a.y != b.y
    sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

fact parent(:alice, :bob)
fact parent(:bob, :dave)
rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

result = solve grandparent(:alice, ?who) limit 5
println("nipoti: ", result)     # [{who = :dave}]
println("primo: ", result[1].who) # :dave
```

Output (golden Full)（完整文件）：

```text
nipoti di alice: [{who = :dave}]
primo: dave
quanti: 1
dist(p, q) = 5.0
dist(p, p) -> Err(:contract, "requires violata in dist: a.x != b.x || a.y != b.y", Info(fn = :dist, clause = :requires, cond = :(a.x != b.x || a.y != b.y)))
tipo: contract
almeno un nipote
alice è nonna di dave? true
```

### 32.2 `famiglia.td`

Output (golden Full):

```text
discendenti di tom: [:bob, :liz, :ann, :pat, :jim]
fratelli di ann: [:pat]
madri: ["pat -> jim"]
senza figli: [:liz, :ann, :jim]
over 50: [:tom, :bob]
modi di spezzare [1, 2, 3]:
  [] ++ [1, 2, 3]
  [1] ++ [2, 3]
  [1, 2] ++ [3]
  [1, 2, 3] ++ []
figli di bob: [:ann, :pat]
```

### 32.3 `garanzie.td`

Output (golden Full, 追踪已简化):

```text
2.5
violazione: contract — requires violata in safe_div: b != 0
clausola: requires, funzione: safe_div
valore 5
errore domain: divisione intera per zero
valore 2
valore 42
errore input: età non valida
catturato mio con dati [1, 2, 3]
ciclo infinito -> budget
solve infinito -> budget
fib(3) = 2 in 10 eventi
chiamate: [[3], [2], [1], [0], [1]]
  call path(:a, :c) @0
  call edge(:a, :c) @1
  fail edge(:a, :c) @1
  …
ciao, Triad
effetto non dichiarato -> println richiede !io ma rumorosa non lo dichiara
imparato: [:gatto]
```

### 32.4 `macro.td`

Output (golden Full):

```text
codice:  :(a.x + f(b, 2))
head:    call
args:    [:+, :(a.x), :(f(b, 2))]
sexpr:   (call + (dot a x) (call f b 2))
:(7 * 7) = 49
parse:   (if (call > x 0) (block (sym pos)) (block (sym neg)))
unparse: if x > 0; :pos; else; :neg; end
dopo @swap: x = 2, y = 1
x non è minore di y
somma -> 5050
polinomio: :(0 + 1 * x ^ 0 + 2 * x ^ 1 + 3 * x ^ 2)
p(2) = 17
```

### 32.5 契约与预算并用

```triad-full
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end
e = try safe_div(1, 0) end
e.kind          # :contract
r = with budget(steps = 1000)
    while true end
end
r.kind          # :budget
```

---
<a id="parte-4"></a>

# 第四部分 —— 项目代码

本部分说明这个仓库是如何构建的，以及其中每一类代码是如何编写（或修改）的。

<a id="cap-33"></a>

## 33. 仓库地图

| 路径 | 语言 | 内容 |
|---|---|---|
| `SPEC.md`、`SPEC-CORE.md`、`VERSION`、`CHANGELOG.md` | Markdown | 标准（Full 与 Core）、版本、历史 |
| `BOOTSTRAP.md`、`STATUS.md`、`TASK.md`、`plan.md` | Markdown | S0→S4 计划、状态、backlog 与任务 |
| `conformance/` | Triad + Node | golden 用例（Full 为 `cases/`，Core 为 `core/cases/`）与 runner `run.mjs` |
| `seed/windows-x86_64/` | 机器码 | `seed.hex`（源）、`seed.exe`（解码后）、含布局说明的 README |
| `seed/linux-x86_64/` | 机器码 | ELF E0 seed（`seed.hex`、`seed`）|
| `seed/dev/` | Node.js | seed 生成器（`gen_seed.js`、`gen_seed_linux.js`）与参考解释器 `triad_core.cjs` |
| `selfhost/` | Triad-Core | S1：用 Triad-Core 编写的 Triad 解释器（进行中）|
| `examples/` | Triad-Full | 标准的示例程序 |
| `cli/` | Node.js (ESM) | `triad-cli`：开发用 CLI（commander、execa、chalk）|
| `bin/` | sh / cmd | 启动器 `triad`、`triad.cmd`、`triad-cli`、`triad-cli.cmd` |
| `ai/` | Triad + Node | 面向 LLM 的代码生成基准测试、prompt、带 golden 的任务 |
| `editors/` | JSON / Vim script | VS Code 语法（TextMate）、Vim 语法、Linguist 条目 |
| `docs/` | HTML/CSS/JS | GitHub Pages 站点及仓库发布的材料 |
| `obsidian-triad/` | Markdown | 带有文件索引和项目图的 Obsidian 库 |
| `.github/workflows/` | YAML | CI（`ci.yml`）与站点发布（`pages.yml`、`static.yml`）|
| `test_*.td`、`min_*.td`（根目录）| Triad-Core | seed 开发期间使用的小型探针（例如 CI 中的 `test_get.td`）|

通用约定：
- 文档、注释和消息均使用**意大利语**；
- 所有地方都使用 **LF** 换行，唯独 `*.cmd` 使用 CRLF，这由 `.gitattributes` 规定；
- `.gitignore` 排除 `*.out`，但 `!conformance/**/expected.out` 例外。

---

<a id="cap-34"></a>

## 34. JS 参考解释器（`seed/dev/triad_core.cjs`）

这是一个用单个 CommonJS 文件实现的完整 Triad-Core 解释器（约 1000 行，没有任何依赖）。它是在 Linux/macOS 上验证 Core 一致性的工具，也是通过阅读代码来理解 Core 语义最快的方式。

### 34.1 架构

```
sorgente ──tokenize()──▶ token ──Parser──▶ AST {kind: …} ──evalStmt/evalExpr──▶ effetti su stdout
```

1. **值**（位于文件开头）：由 `I`（Int，基于 `BigInt` 并用 `wrap()` 包装为 64 位）、`B`、`S`、`Y`（Symbol）、`L`（List）、`F`（函数：`params`、`body`、`env`、`isLambda`）构建的 `{t, v}` 对象，以及常量 `NOTHING`。内置函数的表示形式是 `{t:'builtin', name}`。
2. **`tokenize(src)`**：产出 token `SEP`（换行或 `;`）、`NUM`、`STR`、`SYM`、`IDENT`、`OP`、`LPAREN`/`RPAREN`、`LBRACKET`/`RBRACKET`、`COMMA`、`QMARK`、`COLON`、`EOF`。注释和空白在这里被丢弃。
3. **`class Parser`**：遵循 [§7.1](#cap-7) 优先级的递归下降解析：`parseProgram → parseStmt → parseExpr → parseAssign → parseTernary → … → parsePostfix → parsePrimary`，另外还有用于解析直到 `end`/`else`/`elseif` 之前代码块的 `parseBlock(terminators)`。产出的节点：`program`、`funcdef`、`return`、`break`、`continue`、`exprstmt`、`num`、`str`、`sym`、`bool`、`nothing`、`var`、`list`、`lambda`、`assign`、`indexassign`、`binary`、`unary`、`ternary`、`call`、`index`、`if`、`while`、`let`、`begin`。
4. **环境**：`makeFrame(parent, owner, isLambda)` 创建一个带绑定 `Map` 的 frame；`lookup` 沿链向上查找。`writeVar` 实现 [§10.3](#cap-10) 的作用域规则：更新同一“所有者”（函数）的绑定，或者在 lambda 内部更新一个外层绑定；否则创建局部绑定。
5. **求值**：`evalStmt`、`evalExpr` → `evalExprBinary` → `evalExprRest` → `evalExprBlocks`。`return`、`break`、`continue` 是 JS 异常（`ReturnSignal`、`BreakSignal`、`ContinueSignal`），由调用处或 `while` 捕获。
6. **内置函数**：集合 `BUILTIN_NAMES` + `callBuiltin(name, args, env)`；打印用 `printValue`（不带 `:` 的符号只在顶层输出），转换用 `stringOf`。
7. **`main()`**：读取文件（带 `-` 时读取 stdin），绑定 `ARGS` 并执行；解析错误 → `parse error: …`，运行时错误 → `error: …`，两者都以 exit 1 结束；没有文件 → exit 2。

这个流程把各项职责分开，便于一次只诊断一个问题。如果 `tokenize` 产出的 token 有误，问题出在 parser 之前；如果 parser 生成了错误的形态，AST 树就与语法规则不符；如果树是对的但结果不对，缺陷就在环境、求值或某个内置函数里。一个小的一致性用例可以固定观察到的行为，同时修正出问题的那一层。当语法或语义发生改动时，测试、解释器和规范必须保持一致：给 parser 加一个分支却没有对应的求值逻辑，会产生一种能被识别却无法执行的形态。

### 34.2 示例：添加一个内置函数

假设你想试验一个内置函数 `abs`（Core 中没有：需要先在标准中提出，见 [§43](#cap-43)）。需要做两处修改：

```js
// 1. registrare il nome
const BUILTIN_NAMES = new Set(['print','println','length','push!','Int','string','Symbol',
  'typeof','readfile','strlen','strbyte','strsub','exit','abs']);

// 2. implementarlo in callBuiltin, prima del throw finale
  if (name === 'abs') {
    if (args.length !== 1 || args[0].t !== 'int') throw new Error('abs');
    return I(args[0].v < 0n ? -args[0].v : args[0].v);
  }
```

然后：在 `conformance/core/cases/` 中添加一个用例（[§38](#cap-38)），并运行 `node conformance/run.mjs`。记住 `Int` 就是 `BigInt`（`0n`、`1n`），结果必须用这些辅助函数构建（`I`、`B`、`S`、`Y`、`L`、`NOTHING`）。

### 34.3 示例：添加语法

1. 如果需要新的 token，扩展 `tokenize`（例如在 `twoOps` 中加一个运算符）；
2. 在 `Parser` 中添加相应的优先级层级，产出新的 `kind`；
3. 在 `evalExpr*` 中处理该 `kind`；
4. 更新 `SPEC-CORE.md`（语法 §4 与语义 §5），并添加一个 Core 用例。

规则：JS 解释器必须**忠实于 SPEC-CORE**；不要添加 seed 和 S1 本不应具备的扩展。

---

<a id="cap-35"></a>

## 35. Windows S0 seed 及其生成器

### 35.1 它是什么

`seed/windows-x86_64/seed.exe` 是一个 **25.088 字节**的 PE32+ x86-64 可执行文件，只导入 `KERNEL32.dll`（`GetStdHandle`、`GetCommandLineA`、`CreateFileA`、`ReadFile`、`WriteFile`、`CloseHandle`、`ExitProcess`、`VirtualAlloc`）。它既不使用 libc，也不使用运行时。**源文件**是 dump `seed.hex`（SHA-256 由 CI 校验：`3A75A21E2F47D8DC4C88D4BC2580A85D5349BCDF7550E5FFA16E2C0AC7CA8C11`）。

seed **不构建 AST**：它直接解释源文本，用一个游标（`rsi`）逐字节前进；函数体和 lambda 体是指向源码的指针，每次调用时都会重新执行。

### 35.2 内部约定

| 寄存器 | 作用 |
|---|---|
| `r14` | `VirtualAlloc` 内存基址（源码在 `+0`，环境在 `+0x10000`，函数在 `+0x20000`，堆在 `+0x30000`）|
| `r15` | 变量环境（每项 24 字节：名称指针、长度、值）|
| `rbx` | 变量计数器 |
| `r13` | 函数表（每项 128 字节）|
| `r12` | stdout 句柄 |
| `rsi` | 源码中的游标 |

2 位标记值：`Int = n << 2`、`false = 1`、`true = 5`、闭包 `= ptr | 2`、堆对象（字符串为 `[tipo][len][byte…]`）标记为 3。完整布局（PE 头、IAT、标签 `parse_program`、`st_if`、`parse_primary`、`env_find`……的映射）见 [`seed/windows-x86_64/README.md`](seed/windows-x86_64/README.md)。

### 35.3 生成器 `seed/dev/gen_seed.js`

手写几千字节是不现实的：生成器是一个用 JavaScript 写的 **assembler-lite**，负责输出字节并解析标签。文件分为以下几部分：

| 部分 | 内容 |
|---|---|
| `emitter` | `B(...)` 输出字节，`B32(v)` 输出一个 dword，`L(nome)` 定义一个标签，`reloc`/`je`/`jne`/`jmp`/`callL` 输出带相对补丁的跳转，`callIat(i)` 调用第 `i` 个导入 |
| 指令辅助函数 | 以指令名命名的函数（`incRsi`、`cmpByteRsiImm('(')`、`testRax`、`leaRdxR14(d)`……），输出对应的 x86-64 字节 |
| `PE/data layout` | 常量 `IAT = 0x4000`、`SEC_RAW`、`HEADERS` |
| `main` | 序言、读取命令行、打开/读取文件 |
| `parser` | 解释器的核心：语句、表达式、函数、lambda |
| `ambiente` | `env_find`、`env_store`、`env_assign` |
| `exit labels` | `fail`、`read_fail`、`open_fail`、`usage` |
| `PE builder` | 写入 DOS/PE/COFF 头、`.text` 段、导入表以及十六进制 dump |

风格示例（取自 `main`）：跳过命令行中的程序名。

```js
cmpByteRsiImm(0x22); jne('skip_plain');   // il path inizia con " ?
L('q_loop');
incRsi();
cmpByteRsiImm(0); je('no_arg');           // fine stringa: nessun argomento → exit 2
cmpByteRsiImm(0x22); jne('q_loop');
```

### 35.4 修改 seed 的流程

1. 修改 `seed/dev/gen_seed.js`（加一个标签、dispatcher 中加一个分支……）；
2. 重新生成 dump：`node seed/dev/gen_seed.js seed/windows-x86_64/seed.hex`（或者用 `bin/triad-cli seed generate windows`，它还会打印 SHA-256）；
3. 在 Windows 上解码：`certutil -decodehex -f seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe`；
4. 在 seed 上运行 Core 用例以及探针 `test_get.td`；
5. **同时**更新：`.github/workflows/ci.yml` 中的哈希（job `seed-windows`、step `Hash check`）、`seed/windows-x86_64/README.md`、`seed/dev/README.md`、`STATUS.md`；如果有新的 Core 用例在 seed 上通过，就把它加入该 job 的 `$cases` 数组。

已知陷阱（来自 `STATUS.md`）：代码不断增长，可能与数据重叠（导入名现在从 RVA `0x5000` 开始）；寄存器在初始化之前就被使用（bug `pbs_int`）；内置函数调用中栈上参数顺序有误（`get`）。Defender 可能把该 PE 报为误报（CI 中已加入排除项）。

---

<a id="cap-36"></a>

## 36. Linux seed（E0）

`seed/linux-x86_64/seed` 是一个 **173 字节**的静态 ELF64，由 `seed/dev/gen_seed_linux.js` 生成：入口 `0x400078`，只有一个 R|X 的 `PT_LOAD`，直接使用 `write`/`exit` 系统调用。它会打印 `Triad seed Linux OK` 并以 0 退出。这是里程碑 M7 的第一步；E1/E2/E3（读文件、解释器）还要完成，做法是复用 Windows seed 的逻辑，但换成不同的 `os_*` 层。

```sh
node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex   # verifica magic, entry, round-trip
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed && chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed                                     # Triad seed Linux OK
```

---

<a id="cap-37"></a>

## 37. 自举：`selfhost/` 中的 S1

S1 是用 Triad-Core 编写、由 seed 执行的完整 Triad 解释器。目前它还处于若干独立原型的阶段，每个原型在文件末尾都带一个小测试：

| 文件 | 验证内容 |
|---|---|
| `main.td` | 以扁平列表 `[chiave, valore]` 表示内联环境；CI 冒烟测试（期望 `Value: 10`）|
| `value.td` | 用整数模拟 2 位标记值（`make_int`、`make_bool`、`as_int`）|
| `tokenizer.td` | 对编码为列表 `[lunghezza, byte…]` 的源文本执行 `next_token(chars, pos)`；token 为 `[tipo, valore, pos]` |
| `parser.td` | 从 ASCII 码识别关键字 `if`/`end` |
| `eval.td`、`program.td` | 对数字 token、标识符、赋值和 `println` 求值 |
| `env.td`、`heap.td`、`ast.td`、`interpreter.td` | 环境、bump 分配器和 AST 的桩代码 |

### 37.1 今天如何编写 S1 代码

S1 代码必须能在 **Windows seed** 上运行，因此要遵守 [第 15 章](#cap-15) 右栏的限制：

- 使用 `get(xs, i)` 并让索引**从 0 开始**，而不是 `xs[i]`（这不符合标准：等 seed 支持之后要换成 Core 的索引方式）；
- 列表只能是整数：源字符串表示为 ASCII 码的列表，长度放在第 0 个位置；
- `push!` 返回新的列表：要写成 `env = push!(env, v)`；
- token 类型的常量（`0` EOF、`1` NUMBER、`2` IDENTIFIER……）在文件开头的注释中说明；
- 函数最多 4 个参数，lambda 只接受 1 个参数，不支持多绑定捕获。

```triad
# stile S1: ambiente piatto e lookup con get (0-based)
env = []
env = push!(env, 1)      # chiave
env = push!(env, 10)     # valore
if get(env, 0) == 1
  println("Value: " * string(get(env, 1)))
end
```

在 Linux 上这些文件**无法**用 JS 解释器运行（它没有 `get`）：需要在 Windows 上用 `seed\windows-x86_64\seed.exe selfhost\main.td` 试跑。

### 37.2 S1 的方向

S1.3–S1.15 各任务写在 [`TASK.md`](TASK.md) 中：标记值、内联 tokenizer 与 parser、表达式求值、`let`、完整程序、函数与调用、闭包，最后让一致性测试在 seed+S1 之上跑起来。[第 17 章](#cap-17) 的练习 6 和 7 是这些步骤的标准 Core 版本。

---

<a id="cap-38"></a>

## 38. 一致性测试：读取、编写与验证用例

### 38.1 格式

```
conformance/core/cases/<nome>/      (oppure conformance/cases/<nome>/ per Full)
  program.td        programma Triad eseguito come script
  args.txt          opzionale: un argomento per riga (ARGS)
  expected.out      stdout atteso, byte per byte, fine riga LF
  expected.golden   copia di expected.out (fallback del runner)
  expected.code     exit code atteso
```

一个用例通过的条件是 stdout 与退出码都一致；stderr 不参与比对。没有 stdin，也没有交互式输入。

### 38.2 runner `conformance/run.mjs`

```sh
node conformance/run.mjs                              # Core (default conformance/core/cases)
node conformance/run.mjs --cases conformance/cases    # Full (oggi passa solo errore)
node conformance/run.mjs --skip liste,valori          # salta casi (default: liste)
node conformance/run.mjs --update                     # RIGENERA i golden dal runtime corrente
```

所选运行时按以下顺序确定：变量 `TRIAD_SEED`；在 Linux/macOS 上是 JS 解释器；在 Windows 上是 `bin/triad-native.exe`，其次是 `seed/windows-x86_64/seed.exe`。例如用显式路径试用 seed： `TRIAD_SEED=/percorso/seed node conformance/run.mjs`。

在 Linux/macOS 上，运行器使用 JS 解释器并校验全部 37 个用例。在 Windows 上使用 seed，并且默认跳过 `liste` 用例，因为 seed 没有实现标准的 `xs[i]` 下标访问：因此运行器会打印 36 个用例。要用 JS 解释器测试那个被排除的用例：

```sh
node seed/dev/triad_core.cjs conformance/core/cases/liste/program.td
```

消息：
- `PASS  nome` / `FAIL  nome  (exit X, atteso Y, stdout N byte, attesi M)`；
- `golden mancante`：该 checkout 里没有 `expected.out`（通常执行一次 `git pull` 即可）。

golden 是一份版本化的期望值，而不是语义的规范性来源。`program.td` 文件定义输入，`args.txt` 定义参数，`expected.out` 定义逐字节的输出，`expected.code` 定义退出码。运行器把这些结果与所选运行时进行比对；这样同一个用例就可以由多个解释器执行，从而让分歧显现出来。如果对运行时的行为有疑问，先把该用例与 SPEC-CORE 比对，只有当规范确认了新的期望值之后，才去修正 golden。`--update` 选项会把当前行为复制进期望结果：不加审阅就使用它，等于把一个 bug 变成了正确性的主张。

### 38.3 新增一个 Core 用例

1. 选一个意大利语的描述性名称（`liste_annidate`、`stringhe_vuote`……）；
2. 编写 `program.td`，**只**使用 SPEC-CORE §2–§7（不要用引导原语：它们也必须能在 Full 上运行）；
3. 手工编写 `expected.out`（结尾带 LF）和 `expected.code`（`0`），依据规范来推理——**不要**用 `--update` 盲目生成，否则等于把运行时的 bug 固定下来；
4. 把 `expected.out` 复制为 `expected.golden`；
5. `node conformance/run.mjs` 必须打印 `PASS  <nome>`；
6. 如果该用例在 Windows seed 上也能通过，就把它加到 `.github/workflows/ci.yml` 中 `seed-windows` job 的 `$cases` 里。

```sh
mkdir conformance/core/cases/somma_lista
cat > conformance/core/cases/somma_lista/program.td <<'TD'
xs = [3, 4, 5]
tot = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
TD
printf '12\n' > conformance/core/cases/somma_lista/expected.out
cp conformance/core/cases/somma_lista/expected.out conformance/core/cases/somma_lista/expected.golden
printf '0' > conformance/core/cases/somma_lista/expected.code
node conformance/run.mjs | grep somma_lista          # PASS  somma_lista
```

Full 的 golden（`conformance/cases/`）是**冻结的**：在存在 Full 实现之前不要重新生成。

---

<a id="cap-39"></a>

## 39. 开发 CLI `triad-cli`

### 39.1 用法

| 命令 | 作用 |
|---|---|
| `triad-cli status` | Node 版本、平台、找到的 seed、项目根目录 |
| `triad-cli test conformance [-c DIR] [-u]` | 执行 `conformance/run.mjs`（默认 Core，`--skip liste`）|
| `triad-cli test run` | Core conformance 的别名（旧的 Julia 测试已经不存在）|
| `triad-cli ai verify [-t DIR] [-v]` | 在原生 seed 上执行 `ai/tasks/` 里的 `solution.triad` 并与 golden 比对 |
| `triad-cli seed generate windows\|linux [-o FILE]` | 运行 seed 生成器并打印 dump 的 SHA-256 |
| `triad-cli build standalone` | 不可用：只打印一条消息 |

启动方式：`node cli/triad-cli.mjs …`（先执行 `cd cli && npm install`）、启动器 `bin/triad-cli` / `bin\triad-cli.cmd`（首次启动时安装依赖，若 `npm install` 失败则停止），或者使用 release 中的 standalone 可执行文件。

### 39.2 代码结构

```
cli/
  triad-cli.mjs            definizione dei comandi con commander
  lib/utils.mjs            findProjectRoot, findSeed, runSeed, runNode, projectPath, …
  lib/commands/test.mjs    handleTestRun, handleTestConformance
  lib/commands/ai.mjs      handleAIVerify
  lib/commands/seed.mjs    handleSeedGenerate (windows/linux)
  lib/commands/build.mjs   handleBuildStandalone
  build-exe.mjs            build dell'eseguibile Node SEA (esbuild + postject)
```

- `findProjectRoot()` 查找项目根目录（一个同时包含 `conformance/run.mjs` 和 `seed/` 的文件夹），依次从 `TRIAD_HOME`、模块所在目录、可执行文件所在目录和当前目录开始查找。
- 每个 handler 返回 `true`/`false`；`triad-cli.mjs` 把它转换成退出码 0/1。

### 39.3 新增一个命令

1. 创建 `cli/lib/commands/<nome>.mjs`，其中有一个返回布尔的 `handle<Nome>(options)` 函数，并使用 `utils.mjs` 里的 `projectPath`、`runNode`、`runSeed`；
2. 在 `triad-cli.mjs` 中注册它：

```js
import { handleLint } from './lib/commands/lint.mjs';

program
  .command('lint')
  .description('Controlla i file .triad')
  .option('-v, --verbose', 'Verbose output')
  .action(async (options) => {
    const success = await handleLint(options);
    process.exit(success ? 0 : 1);
  });
```

3. 在 `status` 中加上这一行，并在 [`cli/README.md`](cli/README.md) 中写好文档。

### 39.4 standalone 可执行文件

```sh
cd cli && npm install
npm run build:exe                         # dist/triad-cli per la piattaforma corrente
node build-exe.mjs path/to/win/node.exe   # dist/triad-cli.exe per Windows, anche da Linux
```

传入的 Node 二进制文件决定目标平台；它的版本必须与执行构建的 Node 相同。

---

<a id="cap-40"></a>

## 40. AI 基准测试（`ai/`）

衡量一个 LLM 编写 Triad-Core 的水平。

- `ai/SYSTEM_PROMPT.md`：包含允许子集的系统提示词（比较保守：禁止列表、`string()`、`elseif`、`return`，因为 seed 当时并未全部支持）；
- `ai/tasks/NN_nome/`：`task.md`（任务要求）、`expected.out`、`solution.triad`（参考解答）；
- 校验：`node cli/triad-cli.mjs ai verify`（或 `--tasks ai/tasks/01_somma`）：`PASS`/`FAIL`，缺少解答时为 `SKIP`；
- `ai/jev_audit.mjs`、`ai/jev_prompt.md`：单独的审计（见 `PROMPT_JEV.md`）。

新增一个 task：创建 `ai/tasks/06_nome/`，其中包含 `task.md`（精确描述期望输出）、`expected.out`，以及一份能够通过的参考 `solution.triad`。模型生成的代码只在隔离环境中执行。

---

<a id="cap-41"></a>

## 41. 编辑器、启动器与站点

- **VS Code**（`editors/vscode/`）：`package.json` 声明 `triad` 语言（扩展名 `.triad`、`.td`）；`syntaxes/triad.tmLanguage.json` 是 TextMate 语法（`source.triad`），包含 `keywords` 规则、带插值的字符串、数字、`:-`、shebang；`language-configuration.json` 负责注释和括号。打包方式：`cd editors/vscode && npx @vscode/vsce package`。
- **Vim/Neovim**（`editors/vim/`）：`ftdetect/triad.vim` 和 `syntax/triad.vim`。
- **Linguist**（`editors/linguist/`）：`languages.yml` 条目已准备好，可直接给 GitHub Linguist 提 PR。
- 如果你给标准新增了关键字，请在**所有**语法中同步更新。
- **启动器**（`bin/`）：`triad`（POSIX，解析符号链接并计算 `TRIAD_HOME`）和 `triad.cmd`（Windows，CRLF 文件）；见 [§2.4](#cap-2)。
- **站点**（`docs/`）：发布在 GitHub Pages 上的静态 HTML；`docs/assets/js/app.js` 用 `marked` 加载仓库中的 Markdown（例如 `docs/pages/tutorial.html` 加载这个文件）。目录的锚点使用显式的 `<a id="…">`，以便在那里也能生效。

---

<a id="cap-42"></a>

## 42. 持续集成

`.github/workflows/ci.yml`，在每次 push 和 pull request 时运行：

| job | 校验什么 |
|---|---|
| `conformance-core`（Ubuntu、Node 20）| 用 JS 解释器执行 `node conformance/run.mjs --cases conformance/core/cases --skip liste` |
| `seed-windows` | 解码 `seed.hex`，在 PE 上运行 33 个 Core 用例并比对 stdout，探针 `test_get.td`（期望 `20`），冒烟测试 `selfhost/main.td`（期望 `Value: 10`），`seed.hex` 的哈希 |
| `seed-linux` | 解码 ELF E0，运行它并校验其哈希 |

`pages.yml` 和 `static.yml` 在每次推送到 `main` 时把 `docs/` 发布到 GitHub Pages。

Full 配置**不在 CI 中**，因为它还没有实现：不要把它展示为绿色。

---

<a id="cap-43"></a>

## 43. 贡献流程

按改动类型划分的检查清单：

| 改动 | 要做的事 |
|---|---|
| 语言行为 | 更新 `SPEC.md`/`SPEC-CORE.md`、`CHANGELOG.md`，如果改动具有规范意义还要更新 `VERSION`；新增或更新 conformance 用例 |
| JS 解释器 | 保持忠于 SPEC-CORE；`node conformance/run.mjs` 通过 |
| Windows seed | 重新生成 `seed.hex`，更新 CI 和 README 中的哈希，在 Windows 上测试 |
| S1（`selfhost/`）| 运行在 `seed.exe` 上；如果 `main.td` 的输出发生变化，就更新 CI 中的冒烟测试 |
| CLI | handler 返回布尔值；`cli/README.md`；必要时重新构建可执行文件 |
| 编辑器 | VS Code 与 Vim 的语法与 SPEC §1 的关键字保持一致 |
| 文档 | `README.md`、`STATUS.md` 以及仓库中的说明文字要描述真正能运行的东西 |

总则：不要宣称未经验证的功能可用；golden 要依据规范推理来写；新的开发工具不得进入 S0→S4 这条链路。

---

<a id="parte-5"></a>

# 第五部分 —— 参考

<a id="cap-44"></a>

## 44. Triad-Core 语法（EBNF）

来自 [`SPEC-CORE.md`](SPEC-CORE.md) §4：

```ebnf
program  = { sep } { stmt sep { sep } } ;
stmt     = funcdef | "return" [ expr ] | "break" | "continue" | expr ;
funcdef  = "function" NAME "(" [ NAME { "," NAME } ] ")" block "end"
         | NAME "(" [ NAME { "," NAME } ] ")" "=" expr ;
expr     = assegnamento ;
assegnamento = NAME ( "=" | "+=" | "-=" | "*=" ) expr | ternario ;
ternario = or_expr [ "?" expr ":" expr ] ;
or_expr  = and_expr { "||" and_expr } ;
and_expr = cmp_expr { "&&" cmp_expr } ;
cmp_expr = sum_expr { ( "==" | "!=" | "<" | "<=" | ">" | ">=" ) sum_expr } ;
sum_expr = mul_expr { ( "+" | "-" ) mul_expr } ;
mul_expr = pow_expr { ( "*" | "%" ) pow_expr } ;
pow_expr = unary { "^" unary } ;                    (* destra *)
unary    = ( "-" | "!" ) unary | postfix ;
postfix  = primary { "(" args ")" | "[" expr "]" } ;
primary  = INT | STRING | SYMBOL | "true" | "false" | "nothing" | NAME
         | "(" expr ")"
         | "[" [ expr { "," expr } ] "]"
         | "(" NAME { "," NAME } ")" "->" expr
         | "if" expr block { "elseif" expr block } [ "else" block ] "end"
         | "while" expr block "end"
         | "let" [ NAME "=" expr { "," NAME "=" expr } ] block "end"
         | "begin" block "end"
         | "function" "(" [ NAME { "," NAME } ] ")" block "end" ;
block    = { stmt sep { sep } } ;                   (* fino a end/else/elseif *)
```

Full 语法（Pratt，12 个层级）见 [`SPEC.md`](SPEC.md) §2。

---

<a id="cap-45"></a>

## 45. Core 与 Full 速查卡

**Triad-Core**（今天即可运行）：

```
assegnamento:  x = e    x += e    x -= e    x *= e    xs[i] = e
funzione:      f(a, b) = e
               function f(a, b) ... end        (anche !io, ignorato)
anonima:       x -> e    (a, b) -> e    function (a) ... end
condizione:    if c ... elseif c ... else ... end    c ? a : b
ciclo:         while c ... end    break    continue
blocchi:       let a = 1, b = 2 ... end    begin ... end
uscita:        return e
liste:         [1, 2]    xs[i] (da 1)    length(xs)    push!(xs, v)
stringhe:      "a" * "b"    length(s)    string(x)
conversioni:   Int("42")    Symbol("s")    typeof(x)
I/O:           print(...)    println(...)    ARGS
bootstrap:     readfile(p)  strlen(s)  strbyte(s, i)  strsub(s, a, b)  exit(n)
```

**Triad-Full**（规范）：

```
struttura:   struct Nome; x::T; y::T; end
funzione:    function f(a::T)::R !eff ... end
fatto:       fact p(:a, :b)
regola:      rule p(?x, ?y) :- q(?x), r(?y)
query:       solve p(?x) limit N depth D steps S trace
destruttura: (a, b) = [1, 2]        for (k, v) in [[1,2],[3,4]] ... end
ciclo for:   for v in it ... end    1:n    xs[2:end]    [e for x in xs if c]
try/catch:   try b catch e h end / try b end
contratto:   requires c / ensures c
budget:      with budget(steps = N) ... end
traccia:     with trace ... end / solve p trace
effetto:     function f() !io ... end
macro:       macro m(a) ... end / @m(e)
quote:       :(espr) / quote ... end / $espr
eval:        eval(codice)
```

---

<a id="cap-46"></a>

## 46. 调试与常见问题

**Core（当前）：**

| 现象 | 可能原因 | 解决方案 |
|---|---|---|
| `parse error: expected RPAREN` | `1.5`、`/`、`() -> …` 或其他 Full 语法 | 请保持在 Core 子集内（[§4](#cap-4)）|
| `"x = $x"` 被原样打印 | 字符串插值只有 Full 支持 | `"x = " * string(x)` |
| `error: if cond` | 条件不是 `Bool` | 请使用比较（`x != 0`）|
| `a < b < c` 上出现 `error: < type error` | 比较被串联 | `a < b && b < c` |
| 某个函数没有更新全局变量 | 具名函数在本地赋值 | 请返回该值或改用列表（[§16.4](#cap-16)）|
| `error: undefined variable f` | 函数在定义之前就被调用 | 请把它定义在更靠前的位置 |
| `FAIL … (golden mancante …)` | 检出时缺少 `expected.out` | 执行 `git pull`；检查 `.gitignore` |
| seed 以退出码 1 结束且没有任何消息 | 该功能 seed 不支持 | 请改用 JS 解释器试试；见 [§15](#cap-15) |
| Windows seed 被拦截 | 杀毒软件误报 | 请把 `seed\windows-x86_64` 加入排除项 |

**Full（规范）：**

| 现象 | 可能原因 | 解决方案 |
|---|---|---|
| `Err(:syntax)`“期望语句结束”| 缺少 `end` 或分隔符 | 补上 `end` 或 `;` |
| `Err(:undef)` | 名称未定义 | 请定义它，或用 `:nome` 表示符号 |
| `Err(:method)` / `Err(:ambiguous)` | 没有匹配的方法 / 同样具体的方法不止一个 | 请增加重载或重新设计函数签名 |
| 解构中出现 `Err(:bounds)` | 元素个数与模式不一致 | 请使用长度精确匹配的列表 |
| `Err(:effect)` | 纯函数中调用了 `!io`/`!state` | 请在调用方声明该副作用 |
| `solve` 中出现 `Err(:budget)` | 步数过多 | 请增大 `steps`，或使用 `limit`/`depth` |

Full 规划中的工具：`triad --tree file`、`sexpr(codice)`、`parse`/`unparse`、`with trace … end`、`solve … trace`、`try … end`（配合 `.kind`/`.msg`/`.data`）。

---

<a id="cap-47"></a>

## 47. 术语表

- **S0 / seed**：以机器码实现的 Triad-Core 解释器（`seed/`）。
- **S1**：用 Triad-Core 编写的完整 Triad 解释器（`selfhost/`）。
- **S2 / S3 / S4**：原生编译器、自举、完整运行时（见 `BOOTSTRAP.md`）。
- **E0 / E1 / …**：seed 的 Linux 移植阶段（里程碑 M7）。
- **Triad-Core / Triad-Full**：两个一致性配置。
- **JS 解释器**：`seed/dev/triad_core.cjs`，用于开发和 CI 的 Core 参考实现。
- **Golden**：已提交的期望输出（`expected.out`、`expected.code`）。
- **引导原语**：`readfile`、`strlen`、`strbyte`、`strsub`、`exit`（仅 Core）。
- **带标签列表**：形如 `[:Tag, campo1, …]` 的 Core 记录。
- **Node**：Triad Full 中唯一的树类型（`head`、`args`）：代码与数据合一。
- **Solution**：`solve` 返回的 `{nome = valore, …}`；可用 `s.nome` 或 `s[:nome]` 访问。
- **Err**：错误即数据（`kind`、`msg`、`data`）。
- **Traced**：`with trace` / `solve … trace` 返回的 `(result, trace)`。
- **Occurs-check**：合一时会拒绝 `?x = f(?x)`。
- **Multiple dispatch**：在适用的方法中挑选最具体的那一个。
- **声明式副作用**：签名中的 `!io`、`!state`；动态检查。
- **契约**：`requires`（前置条件）/ `ensures`（后置条件，带 `result`）。
- **预算**：`with budget(steps = N)`；耗尽时返回 `Err(:budget)`。
- **解构**：`(a, b) = lista`、`for (k, v) in lista_di_liste`。

---

<a id="cap-48"></a>

## 48. 状态、已知限制与历史修复

**状态**（详见 [`STATUS.md`](STATUS.md)）：

- Core：JS 解释器上 37/37 个用例通过；CI 中 Windows seed 上 33 个用例通过。
- Full：12 个 golden 用例已冻结，仅 `errore` 通过。
- S1：`selfhost/` 中的原型，CI 中跑冒烟测试；尚未达到一致性。
- S2–S4：尚未开始。Linux seed：E0。
- CLI `triad`：目前只能执行文件（REPL 和 SPEC §14 的选项待实现）。

**标准的限制**（SPEC §15）：标准未涵盖具名参数（`budget(steps = …)` 除外）、可变 struct、用户自定义的抽象类型与参数化类型、无括号的宏、多层嵌套的 quote、Prolog 的 cut；副作用检查是动态的。

**历史修复**：应用于旧版 Julia 实现；下表“之后”一列给出的行为，是 SPEC.md 对每种实现都要求的行为：

| # | 修复 | 之后 |
|---|---|---|
| 1 | range 的往返转换 | `unparse(1:n)` 产出 `"1:n"`（不含空格）|
| 2 | `:destructure`/`:dfor` 的 `unparse` | 它们有各自的分支，并能往返转换 |
| 3 | `xs[end] = v` | `end` 在写入时同样绑定：`xs[end] = 7` 可用 |
| 4 | 未知转义字符 | 只支持 `\n \t \" \\ \$`；其他 → 带行号和列号的 `Err(:syntax)` |
| 5 | 嵌套的 `#=` 注释 | 会计算嵌套深度；`#=` 未闭合 → `incomplete` 错误 |
| 6 | 带类型参数的 lambda | `function (x::Int) x end` 会检查类型：`f(2.0)` → `Err(:type)` |

---

<a id="cap-49"></a>

## 49. FAQ

**需要 Julia 吗？** 不需要。Julia 实现已被移除；Triad 运行在机器码的 seed（Windows）上，或开发用的 JS 解释器上。

**为什么我的 `struct` 或 `fact` 示例跑不起来？** 它们属于 Triad-Full：当前运行时只执行 Triad-Core。请看教程开头的配置对照表。

**`.td` 还是 `.triad`？** `.triad` 是规范形式；`.td` 也被接受作为别名（它同时是 LLVM TableGen 的扩展名，因此从外部识别的角度建议使用 `.triad`）。

**如何验证一个程序是“纯粹的”Core？** 用 JS 解释器运行它；如果它也要对 Full 有效，请检查没有使用引导原语；对于规范性用例，请把它加入 Core 一致性测试套件。

**为什么 `selfhost/*.td` 用 JS 解释器会失败？** 它们使用了 `get(xs, i)`，这是 Windows seed 的非标准辅助函数；需要用 `seed.exe` 运行。

**我在哪里提出对语言的修改？** 在标准（`SPEC.md`/`SPEC-CORE.md`）中提出，同时在 `CHANGELOG.md` 中登记条目并附上一致性用例；随后再落到各个实现中。

---

标记为 **Output:** 的 Core 示例，可用 `node seed/dev/triad_core.cjs` 运行来验证。
