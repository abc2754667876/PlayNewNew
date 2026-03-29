# PlayNewNew 项目使用指南（Mac + iPhone + Apple Watch）

本指南用于帮助你在 **真实设备**（iPhone + Apple Watch）上运行 `PlayNewNew` 项目。  
内容按从零开始的顺序编写：即使你没有技术背景，也可以按步骤完成。

---

## 一、设备要求

请准备以下设备：

- **Mac 电脑**（强烈推荐 Apple Silicon，即 M 系列芯片，如 M1/M2/M3/M4）
- **iPhone 11 及以上机型**
- **与该 iPhone 已配对的 Apple Watch**

说明：

- Apple Watch 必须先和 iPhone 完成正常配对，才能用于调试和安装 App。
- 首次连接调试时，建议设备电量保持在 50% 以上，避免中途断开。

---

## 二、系统要求

- Apple Watch 系统需为 **watchOS 8.0 及以上**

建议：

- 为保证 Xcode 调试稳定性，建议 iPhone 与 Watch 都更新到较新的正式系统版本。

---

## 三、软件要求

### 1) 在 Mac 上安装 Xcode

1. 打开 Mac 上的 **App Store**。
2. 搜索 `Xcode`。
3. 点击“获取”或“安装”并等待完成（体积较大，请预留足够磁盘空间和下载时间）。

### 2) 确认 Xcode 包含 watchOS SDK

一般随 Xcode 一并安装。如需检查：

1. 打开 Xcode。
2. 菜单栏点击 **Xcode -> Settings... -> Platforms**。
3. 查看是否包含 `watchOS` 平台组件；若未安装，点击安装。

### 3) 打开 iPhone 与 Apple Watch 的“开发者模式”

> 说明：在真机调试时，通常需要开启开发者模式。  
> 若你在设备里暂时看不到该选项，请先将系统更新到较新版本后重试。

#### iPhone 开发者模式开启方法

1. 进入 **设置**。
2. 进入 **隐私与安全性**。
3. 下滑找到 **开发者模式** 并打开。
4. 按提示重启 iPhone。
5. 重启后再次确认并开启开发者模式。

#### Apple Watch 开发者模式开启方法

可在手表上尝试以下路径：

1. 打开 Apple Watch 上的 **设置**。
2. 进入 **隐私与安全性**。
3. 找到并开启 **开发者模式**。
4. 根据提示重启并确认。

如果手表上没有相关开关，可先确认：

- iPhone 和 Watch 已更新到支持开发者模式的系统版本；
- iPhone 已开启开发者模式；
- Watch 与 iPhone 保持连接后重试。

---

## 四、其他要求：Apple 开发者账号

你需要先注册 Apple 开发者账号，并在 Xcode 中登录该账号。

### 1) 注册 Apple 开发者账号（Apple Developer）

1. 准备一个 Apple ID（没有的话先注册 Apple ID）。
2. 打开 [Apple Developer](https://developer.apple.com/) 官网。
3. 点击右上角 **Account** 并登录 Apple ID。
4. 按页面提示完成开发者协议确认与资料填写。
5. 如需发布到 App Store，可按提示加入付费的 Apple Developer Program；  
   仅用于本地真机调试时，通常使用个人免费开发者签名也可进行基础测试。

### 2) 在 Xcode 中登录开发者账号

按以下菜单路径操作：

- **Xcode -> Settings -> Apple Accounts -> Add Apple Account...**

登录后，Xcode 就可以使用该账号进行签名。

---

## 五、克隆项目（下载项目代码）

你可以任选一种方法：

### 方法一：下载 ZIP（适合不熟悉命令行）

1. 打开仓库地址：  
   [https://github.com/abc2754667876/PlayNewNew](https://github.com/abc2754667876/PlayNewNew)
2. 点击页面右上区域的 **Code**。
3. 选择 **Download ZIP**。
4. 下载完成后解压，得到 `PlayNewNew` 文件夹。

### 方法二：使用终端克隆（适合有技术背景）

1. 在 Mac 上打开 **终端**（Terminal）应用。
2. 输入以下命令并按回车：

```bash
git clone https://github.com/abc2754667876/PlayNewNew.git
```

3. 命令执行完成后，会在当前目录生成 `PlayNewNew` 文件夹。

---

## 六、打开项目

1. 打开名为 `PlayNewNew` 的项目文件夹。
2. 双击 `PlayNewNew.xcodeproj`。
3. 等待 Xcode 加载完成（首次打开可能需要几分钟索引工程）。

---

## 七、配置项目签名（非常重要）

1. 在 Xcode 左侧导航栏，点击最顶部蓝色工程项 **PlayNewNew**。
2. 在中间区域选择对应 Target（通常是主 App 与 Watch App 相关 Target，都要检查）。
3. 打开 **Signing & Capabilities** 标签。
4. 在 **Signing** 区域的 **Team** 下拉框中，选择你在第四步登录的开发者账号团队。

建议同时确认：

- **Bundle Identifier** 不与已有项目冲突（必要时改成你自己的唯一标识）。
- 主 App 与 Watch App 的签名团队保持一致。

---

## 八、运行项目到 Apple Watch

1. 确保 **Mac、iPhone、Apple Watch 在同一网络环境**，并保持设备解锁状态。
2. 用数据线将 iPhone 连接到 Mac（首次调试推荐有线连接，更稳定）。
3. 在 Xcode 顶部设备选择栏中，选择你的 **Apple Watch 目标设备**（或其配对 iPhone + Watch 运行目标）。
4. 点击标题栏左上区域的 **▶（Run）** 按钮开始构建和安装。
5. 首次运行时，如设备弹出“信任此开发者”或调试授权提示，请按提示允许。

---

## 常见问题排查（建议收藏）

### 1) 看不到 Apple Watch 运行目标

- 确认 Watch 已与 iPhone 配对成功。
- 确认 iPhone 已被 Mac 信任并可在 Xcode 中识别。
- 重新插拔数据线、重启 Xcode、重启 iPhone/Watch 后重试。

### 2) 签名报错（Signing/Provisioning）

- 回到 `Signing & Capabilities`，确认 `Team` 已正确选择。
- 检查主 App 与 Watch App Target 是否都完成签名配置。
- 确认 Apple ID 已在 Xcode 登录且状态正常。

### 3) 首次构建很慢

- 这是正常现象（依赖解析、索引和首次编译会耗时），请耐心等待。
- 后续再次构建通常会明显加快。

---

## 给不同读者的建议

- **如果你是初学者**：请严格按本 README 的顺序执行，不要跳步骤。
- **如果你是开发者**：建议先完成账号和签名配置，再进行目标设备选择与真机调试，可减少反复排错时间。

祝你顺利在 Apple Watch 真机上跑起 `PlayNewNew`。
