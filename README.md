
# Obsidian 个人初始化设置脚本库

---

## 目录及文件说明

* `linux/Shell`：是使用Shell写的脚本
  * `ob_reset_func.sh`：初始化重置脚本，其实就是把.obsidian目录删掉。想要重新成为Obsidian的vault库，得自行使用Obsidian中打开相应的目录，.obsidian目录会自行重新生成。
  * `ob_init_base.sh`：基础初始化脚本，为指定vault库进行基础配置及根据插件列表进行插件安装，达到快速启用该vault的目的。

* `linux/Lua`：是使用Lua写的脚本

* `config`：文件是Obsidian的相关配置文件
  * `base`：基础配置，用于初始化valut，省动手动配置的麻烦

---

## 相关工具

[Bip901/obsidian-cli](https://github.com/Bip901/obsidian-cli) 是一个Obsidian的CLI工具。

这个工具可以列出、打开和移除Vault的功能：

* `ls`：Lists directories registered as Obsidian vaults.                                                                  
* `open`：Opens the given directory as an Obsidian vault, registering it if necessary.                                      
* `rm`：Unregisters the given vault from Obsidian. This does not remove the actual directory.                             
* `new`：Creates a new Obsidian vault at the given path.
* `template`：Commands to view and edit vault templates.          


