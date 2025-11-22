#          ╭──────────────────────────────────────────────────────────╮
#          │                       Jq 工具测试                        │
#          ╰──────────────────────────────────────────────────────────╯

function get_dl_url() {

	# json文件
	local json_path=$1

	# echo $json_path

	# 从github的releases json文件中获取 main.js manifest.json styles.css的地址
	local dl_file_addr=$(curl $json_path | jq -r '.assets[] | .browser_download_url | select ( contains("main.js") or contains("manifest.json") or contains("styles.css") ) ')

	# echo $dl_file_addr

	# 判断长度
	# 即是否取到文件地址值
	if [[ ${#dl_file_addr[@]} -gt 0 ]]; then

		# 返回
		echo ${dl_file_addr[@]}

	else
		echo -e "\e[93m 取不到文件地址！\n \e[0m"
	fi

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

# 使用jq 读取 插件列表
# function read_pluginlist_by_jq(){

# }

# -----------------------测试--------------------- #
# dl_arr_str=$(get_dl_url $1)
# get_dl_url $1

# echo ${dl_arr_str[@]}
# 转成数组
# arr1=($dl_arr_str)
# echo ${arr1[@]}
# echo ${arr1[1]}

# for addr_temp in ${dl_arr[@]}; do
# 	echo $addr_temp
# done

# addr2=${dl_arr[1]}
# echo $addr2

# json_addr=${dl_arr[1]}
# echo "文件地址："$json_addr
# get_plugins_id $json_addr
