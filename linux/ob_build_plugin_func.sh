#          ╭──────────────────────────────────────────────────────────╮
#          │					构建插件函数脚本                      │
#          ╰──────────────────────────────────────────────────────────╯

# -------------------------函数定义区------------------------ #

# 缓存目录
cache_path=.Cache

# 下载插件 release 的json文件
# https://api.github.com/repos/账号/库名/releases/latest
# 账号/库名 由plugin_github_address.txt这个文件读取得到
function download_plugin_release_json() {

	# 前缀
	local prefix_address="https://api.github.com/repos/"

	# 后缀
	local suffix_address="/releases/latest"

	# 核心地址
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
# main.js 和 mainfest.json 这两个文件是必须的，style.css 可选，有的插件是没有的
# 构建前必须已经下载了相应的 release json 文件，插件那三个文件的下载地址都在这个json中
# 参数：release json 文件
function release_json_parser() {

	# 同时也是json文件的文件名
	local plugin_json=$1

	# 检测 json 文件是否存在
	# if [[ ! -f "$plugin_json" ]]; then
	# 	echo -e "\e[93m $plugin_json \e[96m不存在！\n \e[0m"
	# 	return
	# fi

	# echo $plugin_json
	# 从json文件获取文件下载地址，并将其存放至数据数组中
	# main.js manifest.json styles.css 下载地址
	local dl_file_addr=$(curl $json_path | jq -r '.assets[] | .browser_download_url | select ( contains("main.js") or contains("manifest.json") or contains("styles.css") ) ')

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

# 构建插件
# 参数：github 库限定名（账号/库名）
function build_plugin() {

	# github库限定名
	# 账号/库名
	local account_repository=$1

	#
	# local p_name=${account_repository##*/}

	# 前缀
	local prefix_address="https://api.github.com/repos/"

	# 后缀
	local suffix_address="/releases/latest"

	# 解析 release json文件
	local dl_addr_str=$(release_json_parser $prefix_address$account_repository$suffix_address)

	# 下载插件必备文件

}

# -------------------------测试区------------------------ #

# 检测下载 release的json文件函数
# download_plugin_release_json "denolehov/obsidian-git"
# download_plugin_release_json "denolehov/obsidian1-git"

# 检测 download_file_core 函数 download_file_core

# 检测下载插件必备文件函数
# download_plugin_files obsidian1-git
# download_plugin_files obsidian-git

# 检测插件构建函数
# build_plugin denolehov/obsidian-git
