#          ╭──────────────────────────────────────────────────────────╮
#          │                       重置脚本                       │
#          ╰──────────────────────────────────────────────────────────╯

# -------------------------引入脚本区------------------------- #

source ./ob_base_func.sh

# -------------------------函数定义区------------------------ #

# 重置
# 其实就是删掉配置目录
# 参数：
# 1. vault 根目录
# 2. 配置目录名 默认为 .obsidian
function reset_vault() {

	# vault 根路径
	local vault_root_path=$1

	# 配置目录名
	# 默认为 .obsidian
	local config_dir_name=".obsidian"

	# 如果有传入第二个参数，设置配置目录名
	if [[ $# -gt 1 ]]; then
		config_dir_name=$2
	fi

	# 删除配置目录
	echo -e "\e[96m将删除 \e[92m$vault_root_path"/"$config_dir_name \e[96m目录... \n\n \e[0m"
	local del_result=$(delete_obconfigdir $vault_root_path $config_dir_name)
	# delete_obconfigdir $vault_root_path $config_dir_name

	# echo $del_result

	# 检测 .obsidian 目录是否还存在
	if [[ $del_result != "200" ]]; then
		echo $del_result
		echo -e "\e[96m删除 \e[93m$vault_root_path \e[96m的配置目录 \e[93m$config_dir_name \e[96m失败！\n \e[0m"
	else
		echo -e "\e[96m删除 \e[93m$vault_root_path \e[96m的配置目录 \e[93m$config_dir_name \e[96m成功。请自行重新打开\e[95m$vault_root_path\e[96m，才能让Obsidian自动生成默认配置目录\e[93m$config_dir_name！\n \e[0m"
	fi

}

# ---------------------------------测试区--------------------------------- #

# reset_vault $1 $2
# reset_vault $@
