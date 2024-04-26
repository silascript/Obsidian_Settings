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

# 检测 Vault 中的.obsidian目录存在
# 参数：Vault 根路径
function validate_vault_configdir() {

	# vault 根路径
	local vault_path=$1
	# vault 的配置目录.obsidian
	local configdir_name=".obsidian"

	# 检测 Vault 路径
	local vp_r=$(validate_dir $vault_path)

	# 如果 Vault 路径检测不通过
	if [[ $vp_r != "200" ]]; then
		echo $vp_r
		return 1
	fi

	# 检测 vault 路径是否是/结尾
	# 如果没有/结尾，就给它加上
	if [[ ${vault_path: -1} != */ ]]; then
		vault_path=$vault_path/
	fi

	# vault 配置目录完整路径
	local configdir_path=$vault_path$configdir_name

	# echo $configdir_path

	# return $(validate_dir $configdir_path)
	local v_r=$(validate_dir $configdir_path)
	# 返回检测结果
	# 如果检测通过返回 200
	echo $v_r

}

# -------------------------测试区------------------------ #

# 检测 Vault 路径
# r_1=$(validate_dir $1)
# echo $r_1
# echo $?

# d_path=~/MyNotes/Test_Vault/test01
# d_path=~/MyNotes/Test_Vault/test02
# validate_dir $d_path
# r1=$(validate_dir $d_path)
r1=$(validate_vault_configdir $1)
echo $r1
# echo $?

# 测试 validate_vault_path 函数
# v_path=~/MyNotes/Test_Vault/test01
# v_path=~/MyNotes/Test_Vault/test02
# r2=$(validate_vault_path $v_path)
# echo $r2

# 检测 Vault 下的 .obsidian
# validate_vault_configdir $1
# echo $?

# d_path=~/MyNotes/Test_Vault/test01
# d_path=~/MyNotes/Test_Vault/test02
# d_r=$(validate_vault_configdir $d_path)
# echo $d_r
