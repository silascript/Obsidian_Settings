# ----------------------------------------------------------- #
# ------------------------重置函数脚本----------------------- #
# ----------------------------------------------------------- #


# -------------------------引入脚本区------------------------- #

source ./ob_base_func.sh

# -------------------------函数定义区------------------------ #


# 删除 Vault 的.obsidian 配置目录
# 参数为 Vault 路径
function delete_vault_configdir(){

	# Vault 路径
	local vault_path=$1

	local vconfig_dir=".obsidian"
	
	# 检测 vault 路径是否存在
	local vault_exists=$(validate_vault_path $vault_path)
	# 不存在
	if [ $vault_exists != 0 ];then
		echo -e "\e[92m $vault_path \e[96m不存在，删除失败！\n \e[0m"
		return	
	fi
	
	# 检测 Vault 下的 .obsidian 目录是否存在
	local vault_configdir_exists=$(validate_vault_configdir $vault_path)

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

	local vault_configdir_full_path=$vault_path$vconfig_dir

	# 删除 .obsidian 目录
	rm -rf $vault_configdir_full_path

	if [  $? -eq 0 ];then
		echo -e "\e[93m $vault_configdir_full_path \e[96m删除成功！\n \e[0m"
	else
		echo -e "\e[92m $vault_configdir_full_path \e[96m删除失败！\n \e[0m"
	fi

}


# 重置
function reset(){
	
	# Vault 路径
	local vault_path=$1
	
	# 检测 Vault 路径
	local vp_result=$(validate_vault_path $vault_path)

	# echo -e "\e[96m$vp_result \n \e[0m"
	
	# Vault 不存在
	if [[ $vp_result != 0 ]];then
		echo -e "\e[93m$vault_path \e[96m不存在！ \n \e[0m"
		return
	fi
	# 如果 Vault 存在
	# echo -e "\e[92m$vault_path \e[96m存在！ \n \e[0m"

	# 检测 vault 目录下是否存在 .obsidian 配置目录
	local v_cd_r=$(validate_vault_configdir $vault_path)

	if [[ $v_cd_r != 0 ]];then
		echo -e "\e[93m $vault_path \e[96m不存在\e[93m.obsidian \e[96m配置目录！\e[0m"
		return
	fi

	# 删除 .obsidian 目录
	delete_vault_configdir $vault_path
}


# ----------------------------测试区---------------------------- #

# 删除
# delete_vault_configdir $1

# reset $1

d_path=~/MyNotes/Test_Vault/test01
# d_path=~/MyNotes/Test_Vault/test02
reset $d_path



