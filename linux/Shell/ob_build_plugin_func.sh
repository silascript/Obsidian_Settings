#          ╭──────────────────────────────────────────────────────────╮
#          │					构建插件函数脚本                      │
#          ╰──────────────────────────────────────────────────────────╯

# -------------------------函数定义区------------------------ #

# 缓存目录
cache_path=.Cache

# 通过插件id获取插件，从community-plugins.json 文件获取插件仓库 地址
# 参数：該插件的id
# 返回值 仓库地址值形式：账号/仓库名
function get_plugin_repo_addr_by_pid_from_plistfile() {

	# 根据 id 取出相应的插件对象
	# cat community-plugins.json | jq '.[]| select(.id=="better-word-count")'
	# 进一步取出repo属性值，这个就是插件仓库地址：账号/仓库名
	# cat community-plugins.json | jq -r '.[]| select(.id=="better-word-count") | .repo'

	# 插件 id
	local plugin_id=$1

	# echo $plugin_id

	# community-plugin.json默认地址
	local plist_file_default_addr="https://raw.githubusercontent.com/obsidianmd/obsidian-releases/refs/heads/master/community-plugins.json"

	# echo $plist_file_default_addr

	# community-plugins.json 文件地址
	# 使用默认地址初始化
	local plist_file_addr=$plist_file_default_addr

	# echo $plist_file_addr

	# 如果传入的 插件列表文件地址就使用此文件
	if [[ -e $2 ]]; then
		plist_file_addr=$2
	fi
	# curl https://raw.githubusercontent.com/obsidianmd/obsidian-releases/refs/heads/master/community-plugins.json | jq -r '.[]| select(.id=="better-word-count") | .repo'

	local plugin_repo_addr=$(curl $plist_file_addr | jq --arg pluginid $plugin_id -r '.[]| select(.id==$pluginid) | .repo')

	# 返回插件仓库地址
	echo $plugin_repo_addr

}

# 下载插件 release 的json文件
# https://api.github.com/repos/账号/库名/releases/latest
# 账号/库名 由plugin_github_address.txt这个文件读取得到
function download_plugin_release_json() {

	# 前缀
	local prefix_address="https://api.github.com/repos/"

	# 后缀
	local suffix_address="/releases/latest"

	# 核心地址
	# 账号/库名
	local core_address=$1

	# 把前后的"/"去掉
	local account=${core_address%%/*}
	local p_name=${core_address##*/}

	# 构建完整下载地址
	local full_address=$prefix_address$core_address$suffix_address

	# 下载保存为json文件
	# 检测下载地址是否能下载
	local httpcode=$(curl -s -o /dev/null -w "%{http_code}\n" $full_address)

	# echo $httpcode

	if [[ httpcode -eq 200 ]]; then

		# 判断目录是否存在
		if [[ ! -d $cache_path ]]; then
			# 创建缓存目录
			mkdir $cache_path
		fi

		# 下载
		wget -O $cache_path/"$p_name.json" $full_address
		return 0
	else
		echo -e "\e[93m $full_address \e[96m此地址不正确，请检查！\n \e[0m"
		return 1
	fi

}

# 下载文件
# 参数：下载地址 下载目标目录
function download_file_core() {

	# 下载地址
	local dl_addr=$1
	# 目录路径
	local dl_dir_path=$2
	# 存放文件名
	# local dl_file_name=$3

	# 判断下载的目录路径是否以 / 结尾
	# 结尾没有 / 就加上 /
	if [[ ! "$dl_dir_path" =~ /$ ]]; then
		# 没有就加上 /
		dl_dir_path="$dl_dir_path/"
	fi

	# 下载
	echo -e "\e[96m开始下载 \e[92m$dl_file_name \e[96m至 \e[92m$dl_dir_path \e[96m目录中... \e[0m"
	wget -P $dl_dir_path $dl_addr

}

# 使用加速网站下载
# 在原地址前直接添加 https://github.moeyy.xyz/
# 参数：原下载地址 下载目标目录
function download_file_proxy() {

	# 加速地址
	local proxy_path="https://github.moeyy.xyz/"

	# 原下载地址
	local s_dl_addr=$1
	# 目录路径
	local dl_dir_path=$2
	# 保存文件名
	# local dl_file_name=$3

	# 参数：下载地址 下载目标目录
	download_file_core $proxy_path$s_dl_addr $dl_dir_path
}

# release json 文件解析器
# 一个插件目录中有 main.js manifest.json
# main.js 和 manifest.json 这两个文件是必须的，style.css 可选，有的插件是没有的
# 构建前必须已经下载了相应的 release json 文件，插件那三个文件的下载地址都在这个json中
# 参数：release json 文件
# 返回值：该插件所需文件下载地址数组。至少包括 main.js及manifest.json
function release_json_parser() {

	# plugin release的json文件
	local plugin_json=$1

	# echo $plugin_json

	# 检测 json 文件是否存在
	# if [[ ! -f "$plugin_json" ]]; then
	# 	echo -e "\e[93m $plugin_json \e[96m不存在！\n \e[0m"
	# 	return
	# fi

	# echo $plugin_json
	# 从json文件获取文件下载地址，并将其存放至数据数组中
	# main.js manifest.json styles.css 下载地址
	local dl_file_addr=$(curl $plugin_json | jq -r '.assets[] | .browser_download_url | select ( contains("main.js") or contains("manifest.json") or contains("styles.css") ) ')

	# 返回数组
	# 实际返回的是带空格的字符串
	echo ${dl_file_addr[@]}

	# 判断数组长度
	# 即是否取到文件地址值
	# if [[ ${#dl_file_addr[@]} -gt 0 ]]; then
	# 	# 返回数组
	# 	# 实际返回的是带空格的字符串
	# 	echo ${dl_file_addr[@]}
	# else
	# 	echo -e "\e[93m 取不到文件地址！\n \e[0m"
	# fi

}

# 从manifest.json文件中获取id值
# 这个id值是这个插件的插件目录名
function get_plugins_id() {
	# manifest.json 文件
	local json_file=$1

	if [[ ! -e $json_file ]]; then
		echo -e "\e[93m $json_file \e[92m文件不存在！\n \e[0m"
	else
		# 取文件名
		local fileName=${json_file##*\/}
		if [[ $fileName != "manifest.json" ]]; then
			echo -e "\e[93m $json_file \e[92m不是 manifest.json 文件！\n e[0m"
		else
			# 获取 id
			local idvalue=$(curl $json_file | jq -r '.id')
			echo $idvalue
		fi

	fi

}

# 构建安装插件
# 参数：
# 1. 插件保存的目录完全路径（必要）
# 笔记根目录/.obsidian/plugins/插件id/
# 2. 插件id 作为此插件目录名（必要）
# 3. tag名（可选，如果不提供，将使用latest版）
function build_plugin_by_pid() {

	# 插件将要保存的目录路径
	# 此路径应该在调用此函数的上层函数检测过路径有效性
	# 这里是默认目录路径是有效的
	local plugin_save_path=$1

	# 插件id
	local plugin_id=$2

	# 根据id查询該插件的github的库限定名
	# 账号/库名
	local account_repo=$(get_plugin_repo_addr_by_pid_from_plistfile $plugin_id)
	# echo $account_repo

	# tag名称
	local tagname=$3

	# local p_name=${account_repository##*/}

	# 前缀
	local prefix_address="https://api.github.com/repos/"
	# 后缀
	# 默认是最新版
	local suffix_address="/releases/latest"
	# 如果传了第三个参数
	# 使用指定版本
	if [[ -n $tagname ]]; then
		suffix_address="/releases/tags/$tagname"
	fi

	# echo $suffix_address

	# release地址
	local release_addr=$prefix_address$account_repo$suffix_address

	# echo $release_addr
	# 解析 release json文件
	# 得到插件各文件下载地址数组
	local dl_addr_arr=$(release_json_parser $release_addr)

	# echo $dl_addr_str

	# 


	# 下载插件必备文件
	for addr_temp in ${dl_addr_arr[@]}; do
		# echo -e "$addr_temp \n"
		# echo $addr_temp
		# curl --output-dir $plugin_save_path -O $addr_temp
		# 提取出文件名
		local file_name=${addr_temp##*/}
		# echo $file_name
		# 下载文件
		wget --no-check-certificate -c -O $plugin_save_path/$file_name $addr_temp
		# wget --no-check-certificate -O $plugin_save_path/$file_name $addr_temp
	done

}

# -------------------------测试区------------------------ #

# 检测下载 release的json文件函数
# download_plugin_release_json "denolehov/obsidian-git"
# download_plugin_release_json "denolehov/obsidian1-git"

# 检测 download_file_core 函数 download_file_core

# 检测下载插件必备文件函数
# download_plugin_files obsidian1-git
# download_plugin_files obsidian-git

# 通过插件id从插件列表文件中获取插件的仓库地址
# test_pid="better-word-count"
# plugin_repo=$(get_plugin_repo_addr_by_pid_from_plistfile $test_pid)
# echo $plugin_repo

# 检测插件构建函数
# save_path=~/MyNotes/TestV/.obsidian/plugins/better-word-count
# test_pid="better-word-count"
# build_plugin_by_pid $save_path $test_pid
# build_plugin_by_pid $save_path $test_pid 0.10.0
