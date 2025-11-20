#          ╭──────────────────────────────────────────────────────────╮
#          │                       初始化脚本                       │
#          ╰──────────────────────────────────────────────────────────╯

# -------------------------引入脚本区------------------------- #

source ./ob_base_func.sh
source ./ob_build_plugin_func.sh

# -------------------------函数定义区------------------------ #

# 基础初始化
# 参数：
# 1. vault路径
# 2. 插件列表文件路径
function init_base() {

	# vault 路径
	local vault_path=$1
	# 插件列表文件
	local plugin_list_file=$2

	# 批量安装插件
	install_plugin_batch $vault_path $plugin_list_file

	# 复制配置文件到.obsidian 目录中

}

# 批量安装插件
# 参数：
# 1. vault 路径
# 2. 插件列表文件路径
function install_plugin_batch() {

	# 插件id数组
	local plugin_id_arr=()
}
