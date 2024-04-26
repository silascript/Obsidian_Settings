#          ╭──────────────────────────────────────────────────────────╮
#          │                       基础函数脚本                       │
#          ╰──────────────────────────────────────────────────────────╯

# -------------------------函数定义区------------------------ #

# 检测目录是否存在
# 返回值：0为存在 其余都是有问题的
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
# 参数：Vault 根路径
function validate_vault_configdir() {

	# vault 根路径
	local vault_path=$1
	# vault 默认配置目录名 .obsidian
	local configdir_name=".obsidian"

	# 如果有第个参数，那就是自定义的配置目录名
	if [[ $# -gt 1 ]]; then
		$configdir_name=$2
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
	local configdir_path=$(build_config_path $vault_path)

	# echo $configdir_path

	# 检测配置目录路径
	local v_r=$(validate_dir $configdir_path)
	# 返回检测结果
	# 如果检测通过返回 200
	echo $v_r

}

# 删除 .obsidian 目录
# 参数为 Vault 根路径
function delete_obconfigdir() {

	local config_dir_p=$1

	local v_r=$(validate_vault_configdir $config_dir_p)

	if [[ $v_r != "200" ]]; then
		echo $v_r
		return 1
	fi

	# 删除目录
	# rm -rf $config_dir_p
	echo $?

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
c_p=$(build_config_path $1 $2)
echo $c_p

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
# d_r=$(delete_obconfigdir $1)
# echo $d_r
