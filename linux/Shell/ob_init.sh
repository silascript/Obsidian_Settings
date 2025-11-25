#          ╭──────────────────────────────────────────────────────────╮
#          │                       初始化脚本                       │
#          ╰──────────────────────────────────────────────────────────╯

# -------------------------引入脚本区------------------------- #

source ./ob_base_func.sh
source ./ob_build_plugin_func.sh

# -------------------------函数定义区------------------------ #

# 基础初始化
# 参数：
# 1. vault 路径
# 2. 插件列表文件路径
# vault 应该关闭安全模式，这样才能安装第三方插件
function init_base_notheme() {

	# vault 根路径
	local vault_root=$1
	# 插件列表文件
	# 文件结构： 插件id:版本号
	local plugin_list_file=$2

	# 复制核心配置文件到.obsidian 目录中
	# obsidian核心配置
	# 参数：
	# 1. vault 根目录路径
	# 2. 预配置文件目录路径，可选，省略使用默认值：configs/base
	cp_core_config $vault_root

	# 安装插件

	# 读取插件列表
	# 插件数组：插件id:版本号
	local plugin_arr=$(read_plugin_list $plugin_list_file)

	# 批量安装插件
	install_plugin_batch $vault_path ${plugin_arr[@]}

	# 复制插件配置
	# 参数：
	# 1. vault 根目录路径
	# 2. 插件预配置目录，可选，省略的话，默认值：configs/plugin_config
	cp_plugin_config $vault_root

}

# 批量安装插件
# 参数：
# 1. plugins 根路径：vault 路径/.obsidian/plugins
# 2. 插件列表数组
# 这数组每一元素是包括了插件的id和版本号 id:version
# 所以在安装时需要进一步解析，拆出id和版本号
function install_plugin_batch() {

	# plugin 全路径
	local plugins_root_path=$1
	shift
	# 插件数组
	local plugin_arr=($@)

	# if [ $# -lt 2 ]; then
	# 	echo -e "\e[93m 此函数必须传两个参数！\n \e[0m"
	# 	return 1
	# fi
	# 检测路径有效性
	local validate_result=$(validate_plugin_dir $plugins_root_path)

	if [[ $validate_result != "200" ]]; then
		echo $validate_result
		return 1
	fi

	# 去掉路径结尾/，如果有的话
	plugins_root_path=${plugins_root_path%/}

	if [[ ${#plugin_arr[@]} == 0 ]]; then
		echo -e "\e[93m 数组不能为空！\n \e[0m"
		return 1
	fi

	# echo ${plugin_arr[@]}

	# 插件id数组
	local plugin_id_arr=()

	# 插件id 字符
	local pid_str=""

	# 遍历插件数组
	for plugin_temp in ${plugin_arr[@]}; do
		# echo $plugin_temp
		# 切割出id和版本号
		local plugin_id="${plugin_temp%:*}"
		local plugin_version="${plugin_temp##*:}"

		# 将插件id添加进插件id数组中
		# plugin_id_arr+=($plugin_id)

		# 拼接插件id
		pid_str+='"'$plugin_id'",'

		# 生成该插件的目录，目录名为插件的id
		# 插件根目录即 .obsidian/plugins目录 + 插件id目录
		local plugin_full_path=$plugins_root_path/$plugin_id
		# 判断该目录是否存在
		# 如果不存在将创建目录
		if [[ ! -d $plugin_full_path ]]; then
			mkdir $plugin_full_path
		fi

		echo $plulgin_full_path

		# 构建和安装
		if [[ $plugin_version == 'latest' ]]; then
			build_plugin_by_pid $plugin_full_path $plugin_id
		else
			build_plugin_by_pid $plugin_full_path $plugin_id $plugin_version
		fi

		# echo $plugin_id
		# echo $plugin_version
		# echo "------------"
	done

	# echo ${plugin_id_arr[@]}

	# echo $pid_str
	# 去除最后的逗号
	pid_str=${pid_str%,*}
	# vault 的配置根目录 .obsidian
	local vault_config_path=${plugins_root_path%'plugins'*}
	# echo $vault_config_path
	local plugin_json=$vault_config_path"community-plugins.json"
	# echo $plugin_json
	# echo '['$pid_str']' | jq >$plugin_json

	echo -e "\e[96m 生成 \e[92mcommunity-plugins.json \e[96m文件，用于启用已经构建安装的插件！\n \e[0m"
	echo '['$pid_str']' | jq >$plugin_json
	# echo ${plugin_arr[@]}

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

# -------------------------测试区------------------------ #

# plugins_arr=()
# pfile_path=./plugin_list/pluginlist_base.txt
# pfile_path=./plugin_list/pluginlist_plus.txt
# pfile_path=./plugin_list/pluginlist_style.txt
# plugins_arr=$(read_plugin_list $pfile_path)

# echo ${plugins_arr[@]}

# install_plugin_batch
# install_plugin_batch ~/MyNotes/TestV2/
# install_plugin_batch ~/MyNotes/TestV2/ ${plugins_arr[@]}
# install_plugin_batch ~/MyNotes/TestV/ $plugins_arr
# install_plugin_batch ~/MyNotes/TestV/.obsidian/ $plugins_arr
# install_plugin_batch ~/MyNotes/TestV/.obsidian/plugins ${plugins_arr[@]}
# install_plugin_batch $@

# 测试 cp_plugin_config 函数

# vault_path=~/MyNotes/TestV2/
# vault_path=~/MyNotes/TestV
# vault_path=~/MyNotes/TestV/

# cp_plugin_config $vault_path

# 测试 cp_core_config 函数
# vault_path=~/MyNotes/TestV/

# cp_core_config $vault_path

# 测试 init_base_notheme 函数
vault_path=~/MyNotes/TestV/
pfile_path1=./plugin_list/pluginlist_base.txt
pfile_path2=./plugin_list/pluginlist_plus.txt
# pfile_path3=./plugin_list/pluginlist_style.txt

init_base_notheme $vault_path $pfile_path1 $pfile_path2
