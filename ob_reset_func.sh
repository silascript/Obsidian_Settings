# ----------------------------------------------------------- #
# ------------------------重置函数脚本----------------------- #
# ----------------------------------------------------------- #


# 检测目录是否存在
function validate_dir(){

	dir_path=$1
	
	# 检测路径是否为空
	if [ -z $dir_path ];then
		echo -e "\e[96m Vault路径不能为空！\n \e[0m"
		return 
	fi

	if [ -d $dir_path ];then
		return 0
	else
		return 1
	fi

}


# 检测库的路径
function validate_VaultPath(){

	# 库的路径
	vault_root=$1
	
	# 检测目录
	validate_dir $1

	return $? 
}

# 检测 Vault 中的.obsidian目录存在
function validate_vault_configdir(){

	# vault 路径
	vault_path=$1
	# vault 的配置目录.obsidian
	configdir_name=".obsidian"



	
	# vault 配置目录完整路径
	configdir_path=$vault_path/$configdir_name
	validate_dir $configdir_path
	
	cfdir_result=$?

	if [[ $cfdir_result != 0 ]];then
		echo -e "\e[93m$configdir_path \e[96m不存在！ \n \e[0m"
		return
	fi

	echo -e "\e[92m$configdir_path \e[96m存在！ \n \e[0m"
}

# 重置
function reset(){
	
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


# reset $1

validate_vault_configdir $1

