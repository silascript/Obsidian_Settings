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
function init_base() {

	# vault 路径
	local vault_path=$1
	# 插件列表文件
	local plugin_list_file=$2

	# 批量安装插件
	install_plugin_batch $vault_path $plugin_list_file

	# 复制配置文件到.obsidian 目录中

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

	# 遍历插件数组
	for plugin_temp in ${plugin_arr[@]}; do
		# echo $plugin_temp
		# 切割出id和版本号
		local plugin_id="${plugin_temp%:*}"
		local plugin_version="${plugin_temp##*:}"

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

	# echo ${plugin_arr[@]}

}

# -------------------------测试区------------------------ #

plugins_arr=()
pfile_path=./plugin_list/pluginlist_base.txt
# pfile_path=./plugin_list/pluginlist_style.txt
plugins_arr=$(read_plugin_list $pfile_path)

# echo ${plugins_arr[@]}

# install_plugin_batch
# install_plugin_batch ~/MyNotes/TestV2/
# install_plugin_batch ~/MyNotes/TestV2/ ${plugins_arr[@]}
# install_plugin_batch ~/MyNotes/TestV/ $plugins_arr
# install_plugin_batch ~/MyNotes/TestV/.obsidian/ $plugins_arr
# install_plugin_batch ~/MyNotes/TestV/.obsidian/plugins ${plugins_arr[@]}
install_plugin_batch ~/MyNotes/TestV/.obsidian/plugins ${plugins_arr[@]}
# install_plugin_batch $@
