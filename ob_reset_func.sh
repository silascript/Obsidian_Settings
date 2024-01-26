# ----------------------------------------------------------- #
# ------------------------重置函数脚本----------------------- #
# ----------------------------------------------------------- #


# -------------------------函数定义区------------------------ #

# 检测目录是否存在
# 返回值为1即不存在，0为存在
function validate_dir(){

	local dir_path=$1
	
	# 检测路径是否为空
	if [ -z $dir_path ];then
		echo -e "\e[96m Vault路径不能为空！\n \e[0m"
		# return 1
		echo 1
	fi
	
	# 目录存在
	if [ ! -d "$dir_path" ];then
		# return 1
		echo 1
	else
		# return 0
		echo 0
	fi

}


# 检测库的路径
# 0 存在
# 1 不存在
function validate_VaultPath(){

	# 库的路径
	local vault_root=$1
	
	# 检测目录
	# validate_dir $vault_root
	local vr=$(validate_dir $vault_root)
	# local vr=$?

	# return $vr 
	echo $vr 
}

# 检测 Vault 中的.obsidian目录存在
function validate_vault_configdir(){

	# vault 路径
	local vault_path=$1
	# vault 的配置目录.obsidian
	local configdir_name=".obsidian"

	# 检测 vault 路径是否是/结尾
	# 如果没有/结尾，就给它加上
	if [[ ${vault_path: -1} != */ ]];then
		vault_path=$vault_path/	
	fi

	# vault 配置目录完整路径
	local configdir_path=$vault_path$configdir_name
	
	# echo $configdir_path

	# return $(validate_dir $configdir_path)
	local v_r=$(validate_dir $configdir_path)
	# echo $(validate_dir $configdir_path)
	# return $v_r
	echo $v_r
	# cfdir_result=$?
	
	# return $cfdir_result

}


# 删除 Vault 的.obsidian 配置目录
# 参数为 Vault 路径
function delete_vault_configdir(){

	# Vault 路径
	local vault_path=$1

	local vconfig_dir=".obsidian"

	validate_VaultPath $vault_path
	local vault_exists=$?

	if [ $vault_exists != 0 ];then
		echo -e "\e[92m $vault_path \e[96m不存在，删除失败！\n \e[0m"
		return	
	fi
	
	# 检测 Vault 下的 .obsidian 目录是否存在
	validate_vault_configdir $vault_path
	local vault_configdir_exists=$?

	# echo -e "\e[93m$exists_result \n \e[0m"
	# echo $exists_result

	if [[ $vault_configdir_exists != 0 ]];then
		echo -e "\e[92m $vault_path \e[96m下不存在 \e[92m.obsidian \e[96m目录，删除失败！\n \e[0m"
		return
	fi

	# 检测 vault 路径是否是/结尾
	# 如果没有/结尾，就给它加上
	if [[ ${vault_path: -1} != */ ]];then
		vault_path=$vault_path/	
	fi
	
	# 删除 .obsidian 目录
	rm -rf $vault_path$vconfig_dir

	if [  $? -eq 0 ];then
		echo -e "\e[93m $vault_configdir \e[96m删除成功！\n \e[0m"
	else
		echo -e "\e[92m $vault_configdir \e[96m删除失败！\n \e[0m"
	fi

}


# 重置
function reset(){
	
	# Vault 路径
	local vault_path=$1
	
	# 检测 Vault 路径
	validate_VaultPath $vault_path
	local vp_result=$?

	# echo -e "\e[96m$vp_result \n \e[0m"
	
	# Vault 不存在
	if [[ $vp_result != 0 ]];then
		echo -e "\e[93m$vault_path \e[96m不存在！ \n \e[0m"
		return
	fi

	# 如果 Vault 存在
	echo -e "\e[92m$vault_path \e[96m存在！ \n \e[0m"

}


# ----------------------------测试区---------------------------- #


# 检测 Vault 路径
# validate_dir $1
# echo $?

# d_path=~/MyNotes/Test_Vault/test01
# d_path=~/MyNotes/Test_Vault/test02
# validate_dir $d_path
# r1=$(validate_dir $d_path)
# echo $r1
# echo $?


# 测试 validate_VaultPath 函数
# v_path=~/MyNotes/Test_Vault/test01
# v_path=~/MyNotes/Test_Vault/test02
# r2=$(validate_VaultPath $v_path)
# echo $r2


# 检测 Vault 下的 .obsidian
# validate_vault_configdir $1
# echo $?

# d_path=~/MyNotes/Test_Vault/test01
# d_path=~/MyNotes/Test_Vault/test02
# d_r=$(validate_vault_configdir $d_path)
# echo $d_r

# 删除
# delete_vault_configdir $1

# reset $1

# d_path=~/MyNotes/Test_Vault/test01
# reset $d_path



