#          ╭──────────────────────────────────────────────────────────╮
#          │                       基础函数脚本                       │
#          ╰──────────────────────────────────────────────────────────╯

# -------------------------函数定义区------------------------ #

# 检测目录是否存在
# 返回值：200为存在 1是有问题的
function validate_dir() {

	local dir_path=$1

	# echo $dir_path

	# 检测路径是否为空
	if [ -z "$dir_path" ]; then
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

# 通过 vault 路径获取vault id
# 参数：vault 目录路径
# 返回 vault id
function get_vaultid_by_path() {

	local vault_root=$1

	local ob_json=$HOME/.config/obsidian/obsidian.json

	# echo $vault_root

	# 检测路径有效性
	local validate_result=$(validate_vault_path $vault_root)

	if [[ $validate_result != "200" ]]; then
		echo $validate_result
		return 1
	fi

	# 去除结尾的/
	vault_root=${vault_root%/}

	# echo $vault_root

	# 获取 vault id
	local vault_id=$(cat $ob_json | jq -r --arg v_path "$vault_root" '.vaults | map_values(select(.path==$v_path)) | keys[0]')

	echo $vault_id

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

# 删除vault
# ~/.config/obsidian/obsidian.json文件中记录了Obsidian所有的vault
# 想要目录脱离Obsidian管理，即从vault管理列表中删除，就得对obsidian.json这个文件进行操作
# 参数：vault 根目录
function delete_vault() {

	# vault 根目录
	local vault_root=$1

	# 去除结尾/
	vault_root=${vault_root%/}

	local json_path="$HOME/.config/obsidian/obsidian.json"

	# echo $vault_root

	# 检测目录是否真存在
	local validate_vault_result=$(validate_vault_path $vault_root)

	if [[ $validate_vault_result != "200" ]]; then
		echo $validate_vault_result
		return 1
	fi

	# echo $json_path

	# cat "$json_path" | jq -r '.vaults'
	# cat $json_path | jq --arg path_arg $vault_root '.vaults | map_values(select(.path==$path_arg))'
	local vault_key=$(cat $json_path | jq --arg path_arg $vault_root -r '.vaults | map_values(select(.path==$path_arg))|keys')
	vault_key=$(echo $vault_key | jq -r '.[]')
	echo $vault_key

	# cat $json_path | jq --arg v_key "$vault_key" '.| del($v_key)'

}

# 删除配置目录
# 参数为 Vault 根路径
function delete_obconfigdir() {

	# vault 根目录路径
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

	# 去除目录路径结尾/
	vault_rootpath=${vault_rootpath%/}
	conf_dir_name=${conf_dir_name%/}

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
		# echo -e "\e[96m将删除 \e[92m$config_fpath \e[96m目录... \n \e[0m"

		rm -r $config_fpath
		# 再检测配置目录是否还存在
		# local deled_v_r=$(validate_vault_configdir $vault_rootpath $conf_dir_name)

		# if [[ $deled_v_r != "200" ]]; then
		if [[ ! -d $config_fpath ]]; then
			# echo -e "\e[92m$config_fpath \e[96m目录删除成功！\n \e[0m"
			echo "200"
			return 0
		else
			# echo -e "\e[93m$deled_v_r \n \e[0m"
			echo -e "\e[93m$config_fpath \e[96m目录删除失败！\n \e[0m"
			return 1
		fi
	fi

}

# 复制核心配置文件
#
# app.json 主配置
# appearance.json 外观配置
# core-plugins-migration.json core-plugins.json 核心插件配置
# hotkeys.json 快捷键配置
# 存储位置：vault根目录/.obsidian/ 目录下
# Shell 脚本预配置目录： configs/base/ 目录下
# 此函数是将 configs/base/ 目录下预配置文件到制 指定vault的配置目录.obsidian目录下
# 参数：
# 1. vault 根目录路径
# 2. 预配置文件目录路径 默认为 configs/base
function cp_core_config() {

	# vault 根目录
	local vault_root=$1

	# 预配置文件目录
	# 默认是在configs/base 目录下
	local ob_config_dir=$2

	# 如果没传预配置文件目录，则设置默认的目录
	# configs/base
	if [[ $# -lt 2 ]]; then
		ob_config_dir=configs/base
	fi

	# 检测 vault 根目录有效性
	local validate_vault_result=$(validate_vault_path $vault_root)

	if [[ $validate_vault_result != "200" ]]; then
		echo $validate_vault_result
		return 1
	fi

	# 检测预配置目录有效性
	if [[ ! -d $ob_config_dir ]]; then
		echo -e "\e[93m $ob_config_dir 目录不存在！\n \e[0m"
		return 1
	fi

	# 去除目录路径结尾/
	vault_root=${vault_root%/}
	ob_config_dir=${ob_config_dir%/}

	# 复制预配置目录中所有的json配置文件到 vault/.obsidian中
	local source_file=$ob_config_dir'/*json'
	# echo $source_file
	echo -e "\e[96m 开始复制配置... \n \e[0m"
	cp -v $source_file $vault_root"/.obsidian"
}

# 复制插件配置文件
# 就是将 预配置好的 data.json 这个文件复制到指定的插件目录中
# 参数：
# 1. vault 根目录
# 2. 插件预配置目录 默认为：configs/plugin_config
function cp_plugin_config() {

	# vault 根目录
	local vault_root=$1

	# 插件配置目录
	local plugin_config_dir=$2

	# 没有传第二参数
	# 即没传插件预配置文件目录
	# 则设置默认目录 configs/plugin_config
	if [[ $# -lt 2 ]]; then
		plugin_config_dir=configs/plugin_config
	fi

	# 检测vault根目录路径有效性
	local validate_result=$(validate_vault_path $vault_root)

	# 检测 vault 根目录是否存在
	if [[ $validate_result != "200" ]]; then
		echo $validate_result
		return 1
	fi

	# 检测预配置目录有效性
	if [[ ! -d $plugin_config_dir ]]; then
		echo -e "\e[93m $plugin_config_dir 目录不存在！\n \e[0m"
		return 1
	fi
	# 确保目录路径不以/结尾
	vault_root=${vault_root%/}
	plugin_config_dir=${plugin_config_dir%/}
	# echo $vault_root

	# community-plugins.json 路径
	# vault根目录/.obsidian/community-plugins.json
	local plugin_json_path=$vault_root"/.obsidian/community-plugins.json"

	if [[ ! -f $plugin_json_path ]]; then
		echo -e "\e[93m $plugin_json_path \e[96m文件不存在！\n \e[0m"
		return 1
	fi

	# echo $plugin_json_path

	# 读取 community-plugins.json 文件
	# 获取已启用的插件id 返回的是一个数组
	local using_plguin_id_arr=$(read_using_plugin_json $plugin_json_path)

	# echo ${using_plguin_id_arr[@]}

	# 遍历 已启用插件id数组
	for pid_temp in ${using_plguin_id_arr[@]}; do

		# 拼接出 插件配置目录路径
		# 默认是在 plugin_config/插件id/
		local pid_config_dir=$plugin_config_dir"/"$pid_temp

		# 插件目录
		# vault根目录/.obsidian/plugins/插件id/
		local plugin_dir=$vault_root"/.obsidian/plugins/"$pid_temp

		# echo $pid_config_dir

		if [[ -d $pid_config_dir ]]; then
			# data.json文件
			local data_file=$pid_config_dir"/data.json"

			if [[ -f $data_file ]]; then
				# 复制 该插件的data.json文件到 .obsidian/plugins/插件id/ 目录下
				# echo $data_file
				# echo $plugin_dir
				cp -v $data_file $plugin_dir
			else
				echo -e "\e[93m $data_file \e[96m配置文件不存在，复制该插件配置失败！\n \e[0m"
			fi

		fi

	done

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

# 读取插件列表
# 插件列表中存储的是插件的id值
# 参数：插件id列表文件路径
# 返回值：插件id 数组
function read_plugin_list() {

	# 插件数组
	local plugin_arr=()

	if [[ $# -eq 0 ]]; then
		echo -e "\e[93m 至少提供一个插件文件！\n \e[0m"
		return 1
	fi

	# 可能有多个插件列表
	for plugin_list_file in "$@"; do

		# 检测路径是否为空
		if [ -z $plugin_list_file ]; then
			echo -e "\e[93m 文件路径不能为空！\n \e[0m"
			return 1
		fi

		# 读取
		if [ -f "$plugin_list_file" ]; then
			# 过滤掉空行及使用#注释的行
			for line in $(cat $plugin_list_file | grep -v ^$ | grep -v ^\#); do
				# 把每行插件id存储进数组中
				plugin_arr+=($line)
			done
		fi

	done

	# 返回插件数组
	echo ${plugin_arr[@]}
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

# 测试读取插件列表函数
# read_plugin_list ./plugin_list/pluginlist_base.txt
# read_plugin_list ./plugin_list/pluginlist_base.txt ./plugin_list/pluginlist_plus.txt
# read_plugin_list ./plugin_list/pluginlist_base.txt ./plugin_list/pluginlist_plus.txt ./plugin_list/pluginlist_style.txt
# read_plugin_list $@

# 测试 delete_vault 函数
# delete_vault $@

# 测试 cp_plugin_config 函数

# vault_path=~/MyNotes/TestV2/
# vault_path=~/MyNotes/TestV
# vault_path=~/MyNotes/TestV/

# cp_plugin_config $vault_path

# 测试 cp_core_config 函数
# vault_path=~/MyNotes/TestV/

# cp_core_config $vault_path

# 测试 get_vaultid_by_path
# get_vaultid_by_path $@
