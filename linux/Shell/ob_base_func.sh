#          ╭──────────────────────────────────────────────────────────╮
#          │                       基础函数脚本                       │
#          ╰──────────────────────────────────────────────────────────╯

# -------------------------函数定义区------------------------ #

# 检测目录是否存在
# 返回值：200为存在 1是有问题的
function validate_dir() {

	local dir_path=$1

	# 检测路径是否为空
	if [ -z $dir_path ]; then
		echo -e "\e[93m 路径不能为空！\n \e[0m"
		return 1
	fi

	# 目录存在
	if [ ! -d "$dir_path" ]; then
		echo -e "\e[93m $dir_path \e[96m目录路径不存在！\n \e[0m"
		return 1
	else
		# return 0
		echo "200"
	fi

}

# 检测库的路径
# 200 存在 其余不存在
function validate_vault_path() {

	# 库的路径
	local vault_root=$1

	# 检测目录
	# validate_dir $vault_root
	local vr=$(validate_dir $vault_root)
	# 如果 Vault 路径检测不通过
	if [[ $vr != "200" ]]; then
		echo $vr
		return 1
	fi

	# 检测通过返回 200
	echo $vr
}

# 构建 Vault 的配置目录路径
# 参数：
# 1. Vault 根路径
# 2. 配置目录名
function build_config_path() {

	# Vault 根路径
	local vault_rpath=$1

	# 检测 vault 路径是否是/结尾
	# 如果没有/结尾，就给它加上
	if [[ ${vault_rpath: -1} != */ ]]; then
		vault_rpath=$vault_rpath/
	fi

	# echo $vault_rpath

	# vault 默认配置目录名 .obsidian
	local configdir_default_name=".obsidian"

	# 如果有第个参数，那就是自定义的配置目录名
	if [[ $# -gt 1 ]]; then
		configdir_default_name=$2
	fi

	# echo $configdir_default_name

	# vault 配置目录完整路径
	local config_full_path=$vault_rpath$configdir_default_name

	# 返回构建好的配置目录路径
	echo $config_full_path
}

# 检测 Vault 中的 配置目录存在
# 默认检测 .obsidian 目录
# 参数：
# 1. Vault 根路径
# 2. 配置目录名，可选，如果没有，就是默认的 .obsidian
# 返回值：200是通过检测 如果返回1是没通过检测
function validate_vault_configdir() {

	# vault 根路径
	local vault_path=$1
	# vault 默认配置目录名 .obsidian
	local configdir_name=".obsidian"

	# 如果有第2个参数，那就是自定义的配置目录名
	if [[ $# -gt 1 ]]; then
		configdir_name=$2
	fi
	# 检测 Vault 路径
	local vp_r=$(validate_dir $vault_path)

	# 如果 Vault 路径检测不通过
	if [[ $vp_r != "200" ]]; then
		echo $vp_r
		return 1
	fi

	# 构建 配置目录完整路径
	# 构建配置目录函数至少要传一个参数，即 Vault 根路径
	# 如果没有第二个参数，即没有配置目录名 就使用默认配置目录名 .obsidian
	local configdir_path=$(build_config_path $vault_path $configdir_name)

	# echo $configdir_path

	# 检测配置目录路径
	local v_r=$(validate_dir $configdir_path)
	# 返回检测结果
	# 如果检测通过返回 200
	echo $v_r

}

# 删除配置目录
# 参数为 Vault 根路径
function delete_obconfigdir() {

	local vault_rootpath=$1

	# local v_r=$(validate_vault_configdir $config_dir_p)
	# 检测 Vault 根路径是否存在
	local v_result=$(validate_vault_path $vault_rootpath)

	if [[ $v_result != "200" ]]; then
		echo $v_result
		return 1
	fi

	# 构建 Vault 配置目录路径
	# 默认目录名为 .obsidian
	local conf_dir_name=".obsidian"

	# 如果有第2个参数，那就是自定义的配置目录名
	if [[ $# -gt 1 ]]; then
		conf_dir_name=$2
	fi

	# echo $conf_dir_name

	# 检测配置目录路径
	# 如果通过检测就构建完整的配置目录路径，然后删除配置目录
	# 第1个参数为 Vault 路径；第2个参数为配置目录的目录名
	local v_conf_r=$(validate_vault_configdir $vault_rootpath $conf_dir_name)
	# echo $v_conf_r
	if [[ $v_conf_r != "200" ]]; then
		echo $v_conf_r
		return 1
	else
		# 构建配置目录的完整路径
		local config_fpath=$(build_config_path $vault_rootpath $conf_dir_name)

		# 删除目录
		# echo -e "\e[92m \e[37m$config_fpath \e[92m目录！\n \e[0m"
		echo -e "\e[96m将删除 \e[92m$config_fpath \e[96m目录... \n \e[0m"
		rm -r $config_fpath
		# 再检测配置目录是否还存在
		local deled_v_r=$(validate_vault_configdir $vault_rootpath $conf_dir_name)

		if [[ $deled_v_r != "200" ]]; then
			# echo -e "\e[92m$config_fpath \e[96m目录删除成功！\n \e[0m"
			echo "200"
			return
		else
			# echo -e "\e[93m$deled_v_r \n \e[0m"
			echo -e "\e[93m$config_fpath \e[96m目录删除失败！\n \e[0m"
			return 1
		fi
	fi

}

# 检测插件存储的目录
# Obsidian 的插件是放在某个vault的.obsidian/plugins目录
# 需要检测有两个：.obsidian目录及plugins子目录
# 参数：目录路径 /xxx/xxx/.../.obsidian/plugins
# 返回值：200是通过检测 如果返回1是没通过检测
function validate_plugin_dir() {

	local plugins_dir_path=$1

	# 目录是否存在
	local path_validate_result=$(validate_dir $plugins_dir_path)

	# 目录是否存在
	if [[ $path_validate_result != "200" ]]; then
		echo $path_validate_result
		return 1
	# else
	# 	echo "200"
	fi

	# 倒数第二节路径名
	# 应该是 .obsidian
	local secondtolast_dir=$(echo $plugins_dir_path | awk -F '/' '{print $(NF-1)}')
	# echo $secondtolast_dir

	if [[ $secondtolast_dir != ".obsidian" ]]; then
		echo -e "\e[93m $plugins_dir_path \e[96m倒数第二节的目录名不是\e[93m .obsidian\n \e[0m"
		return 1
	fi

	# 最后一节路径名
	# 应该是 plugins
	local last_dir=$(echo $plugins_dir_path | awk -F '/' '{print $NF}')
	# echo $last_dir
	if [[ $last_dir != "plugins" ]]; then
		echo -e "\e[93m $plugins_dir_path \e[96m最后一节的目录名不是\e[93m plugins\n \e[0m"
		return 1
	fi

	# 通过检测
	echo "200"

}

# -------------------------测试区------------------------ #

# 检测 Vault 路径
# r_1=$(validate_dir $1)
# echo $r_1
# echo $?

# 测试构建配置目录函数
# 构建配置目录函数有两参数：1. Vault 根路径 2. 配置目录名
# 如果第二个参数即配置目录名省略，将使用默认配置目录名 .obsidian
# c_p=$(build_config_path $1)
# c_p=$(build_config_path $1 $2)
# echo $c_p

# 检测 Vault 下的 .obsidian
# validate_vault_configdir $1
# v_r=$(validate_vault_configdir $1)
# echo $v_r

# d_path=~/MyNotes/Test_Vault/test01
# d_path=~/MyNotes/Test_Vault/test02
# d_r=$(validate_vault_configdir $d_path)
# d_r=$(validate_vault_configdir $1)
# echo $d_r

# 删除配置目录.obsidian
# delete_obconfigdir $1
# delete_obconfigdir $1 $2

# 检测插件目录路径
# pdir_path=~/MyNotes/TestV/.obsidian
# pdir_path=~/MyNotes/WritingNotes/.obsidian/themes
# pdir_path=~/MyNotes/WritingNotes/.obsidian/plugins
# echo $pdir_path
# validate_plugin_dir $pdir_path
