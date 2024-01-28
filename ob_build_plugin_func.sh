# ----------------------------------------------------------- #
# ----------------------构建插件函数脚本--------------------- #
# ----------------------------------------------------------- #


# -------------------------函数定义区------------------------ #


cache_path=.Cache


# 下载插件 release 的json文件
# https://api.github.com/repos/账号/库名/releases/latest
# 账号/库名 由plugin_github_address.txt这个文件读取得到
function dl_plugin_release_json(){

	# 前缀
	local prefix_address="https://api.github.com/repos/"

	# 后缀
	local suffix_address="/releases/latest"

	# 核心地址
	local core_address=$1

	local account=${core_address%%/*}
	local p_name=${core_address##*/}

	# 构建完整下载地址
	local full_address=$prefix_address$core_address$suffix_address

	# 下载保存为json文件
	# 检测下载地址是否能下载
	local httpcode=$(curl -s -o /dev/null -w "%{http_code}\n" $full_address)
	
	# echo $httpcode

	if [[ httpcode -eq 200 ]];then
		# 下载
		wget -O $cache_path/"$p_name.json" $full_address
		return 0
	else
		echo -e "\e[93m $full_address \e[96m此地址不正确，请检查！\n \e[0m"
		return 1
	fi

}



# 构建插件目录
# 一个插件目录中有 main.js manifest.json styles.css
# main.js 和 mainfest.json 这两个文件是必须的，style.css 可选，有的插件是没有的 
function build_plugin(){


	# 

	# 目录名
	local plugin_name=$1





}







# -------------------------测试区------------------------ #

# 检测下载函数
# dl_plugin_release_json "denolehov/obsidian-git"
# dl_plugin_release_json "denolehov/obsidian1-git"




