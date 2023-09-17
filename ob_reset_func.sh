# ----------------------------------------------------------- #
# ------------------------重置函数脚本----------------------- #
# ----------------------------------------------------------- #


# -------------------------函数定义区------------------------ #

# 检测目录是否存在
function validate_dir(){

	dir_path=$1
	
	# 检测路径是否为空
	if [ -z $dir_path ];then
		echo -e "\e[96m Vault路径不能为空！\n \e[0m"
		return 1
	fi
	
	# 目录存在
	if [ ! -d "$dir_path" ];then
		return 1
	else
		return 0
	fi

}


# 检测库的路径
function validate_VaultPath(){

	# 库的路径
	vault_root=$1
	
	# 检测目录
	validate_dir $vault_root
	vr=$?

	return $vr 
}

# 检测 Vault 中的.obsidian目录存在
function validate_vault_configdir(){

	# vault 路径
	vault_path=$1
	# vault 的配置目录.obsidian
	configdir_name=".obsidian"

	# 检测 vault 路径是否是/结尾
	# 如果没有/结尾，就给它加上
	if [[ ${vault_path: -1} != */ ]];then
		vault_path=$vault_path/	
	fi

	# vault 配置目录完整路径
	configdir_path=$vault_path$configdir_name
	
	# echo $configdir_path

	return $(validate_dir $configdir_path)
	# cfdir_result=$?
	
	# return $cfdir_result

}


# 删除 Vault 的.obsidian 配置目录
# 参数为 Vault 路径
function delete_vault_configdir(){

	# Vault 路径
	vault_path=$1

	vconfig_dir=".obsidian"

	validate_VaultPath $vault_path
	vault_exists=$?

	if [ $vault_exists != 0 ];then
		echo -e "\e[92m $vault_path \e[96m不存在，删除失败！\n \e[0m"
		return	
	fi
	
	# 检测 Vault 下的 .obsidian 目录是否存在
	validate_vault_configdir $vault_path
	vault_configdir_exists=$?

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
	vault_path=$1
	
	# 检测 Vault 路径
	validate_VaultPath $vault_path
	vp_result=$?

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

# 检测 Vault 下的 .obsidian
# validate_vault_configdir $1
# echo $?


# 删除
# delete_vault_configdir $1

# reset $1




