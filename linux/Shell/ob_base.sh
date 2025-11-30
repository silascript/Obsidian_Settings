#          ╭──────────────────────────────────────────────────────────╮
#          │                       基础脚本                       │
#          ╰──────────────────────────────────────────────────────────╯

# -------------------------引入脚本区------------------------- #
source ./ob_base_func.sh

# -------------------------函数定义区------------------------ #

# 通过vault的路径打开vault
# 参数 vault的根目录路径
function open_vault_by_path() {

	# vault 根目录路径
	local vault_root=$1

	if [[ $# -lt 1 ]]; then
		echo -e "\e[93m 请输入vault的路径！\n \e[0m"
		return 1
	fi

	local validate_result=$(validate_vault_path $vault_root)
	if [[ $validate_result != "200" ]]; then
		echo $validate_result
		return 1
	fi

	# 去除结尾的/
	vault_root=${vault_root%/}

	# 获取 vault 的名称
	# 实际就是vault 根目录的目录名
	# 所以取出目录路径最后一节即可
	local vault_name=${vault_root##*/}

	# echo $vault_name

	# 通过vault名称打开vault
	open_vault $vault_name

}

# 通过 vault id 打开vault
# 参数 vault id
function open_vault_by_id() {

	# vault id
	local vault_id=$1

	if [[ $# -lt 1 || -z $vault_id ]]; then
		echo -e "\e[93m 请输入vault ID ！\n \e[0m"
		return 1
	fi

	# 打开 vault
	xdg-open "obsidian://open?vault=$vault_id"

}

# 打开 Vault
# 参数：vault 名称
function open_vault() {

	local vault_name=$1

	# 检测参数
	if [[ $# -lt 1 || -z $vault_name ]]; then
		echo -e "\e[96mvault名称不能为空！打开vault失败！\n \e[0m"
		return 1
	fi

	# 打开vault
	xdg-open "obsidian://open?vault=$vault_name"

}

# 创建 Vault
function create_vault() {

	# 要创建 vault 的根目录路径
	local vault_root=$1

	# 检测根目录路径有效性
	local v_root_result=$(validate_dir $vault_root)

	# 检测是否存在该目录
	if [[ $v_root_result == "200" ]]; then
		# 判断是否为空目录
		if [[ "$(ls -A $vault_root)" ]]; then
			echo -e "\e[93m $vault_root \e[96m目录不是空目录，创建失败！ \n \e[0m"
			return 1
		fi
	fi

	echo -e "\e[96m创建 $vault_root \e[96m目录... \n \e[0m"
	# 去除结尾的/
	vautl_root=${vault_root%/}
	# 创建目录
	# mkdir -p $vault_root"/.obsidian"
	mkdir $vault_root

	# 复制 Obsidian 核心配置文件
	# cp_core_config $vault_root

	# 打开目录
	open_vault_by_path $vault_root

}

# ---------------------------------测试区--------------------------------- #

# open_vault $@

# 测试 open_vault_by_path
# open_vault_by_path $@

# 测试 open_vault_by_id
open_vault_by_id $@

# 测试 create_vault
# create_vault $@
