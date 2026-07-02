---
title: "计算机组成原理"
author: "CloudyGirl"
date: \today
---

# 第一章

这是正文。这个模板适合课程笔记、408 学习笔记、实验报告和项目文档。

## 常用 Markdown

支持 **粗体**、*斜体*、~~删除线~~、`行内代码`。

> 这是引用块。适合放定义、结论、注意事项。

### 列表

- 无序列表
- 支持中文
- 支持代码和公式

1. 第一步
2. 第二步
3. 第三步

## 代码

### C++

```cpp
#include <iostream>

int main() {
    std::cout << "Hello, Pandoc + XeLaTeX\\n";
    return 0;
}
```

### Rust

```rust
fn main() {
    println!("Hello, Pandoc + XeLaTeX");
}
```

## 数学公式

行内公式：$E = mc^2$。

公式块：

$$
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
$$

## 表格

| CPU | 主频 |
| --- | --- |
| i5 | 4.5GHz |
| R7 | 5GHz |

## 图片

把图片放到 `assets/` 下，然后这样引用：

```markdown
![示例图片](assets/image1.png)
```

如果图片不存在，先不要取消下面这一行的注释。

<!-- ![示例图片](assets/image1.png) -->
