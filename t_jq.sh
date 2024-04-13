#          ╭──────────────────────────────────────────────────────────╮
#          │                       Jq 工具测试                        │
#          ╰──────────────────────────────────────────────────────────╯

function get_dl_url() {

	# json文件
	local json_path=$1

	# jq -r '.assets[] | .browser_download_url | select ( contains("main.js") or contains("manifest.json") or contains("styles.css") )' $json_path

	# echo $json_path

	# 从github的releases json文件中获取 main.js manifest.json styles.css的地址
	# local dl_file_addr=$(curl $json_path | jq -r '.assets[] | .browser_download_url | select ( contains("main.js") or contains("manifest.json") or contains("styles.css") ) ')
	# 取值并输出成数组
	local dl_file_addr_arr=$(curl $json_path | jq -r '.assets[] | .browser_download_url | select ( contains("main.js") or contains("manifest.json") or contains("styles.css") ) ')
	# 将获取到的字符串构建成一个列表
	# local dl_file_addr_list=($(curl $json_path | jq -r '.assets[] | .browser_download_url | select ( contains("main.js") or contains("manifest.json") or contains("styles.css") )'))

	# echo $dl_file_addr

	# 判断字符串长度是丰大于0
	# if [[ -n $dl_file_addr ]]; then

	# 判断列表长度是否大于0
	# 即检测是否取到文件地址
	# if [[ ${#dl_file_addr_list[@]} -gt 0 ]]; then

	# 判断数组长度
	if [[ ${#dl_file_addr_arr[@]} -gt 0 ]]; then

		# 返回数组
		echo $dl_file_addr_arr

		# 返回列表
		# echo ${dl_file_addr_list[@]}

		# 将字符串按空格分割成数组
		# local addr_arr=($dl_file_addr)

		# for addr_temp in ${addr_arr[@]}; do
		# 	echo $addr_temp
		# done
		# 返回数组
		# echo ${addr_arr[@]}
	else
		echo -e "\e[92m 取不到文件地址！\n \e[0m"
	fi

	# 使用 jq 获取各文件下载地址并输出到临时文件中
	# jq -r '.assets[] | .browser_download_url' $json_path > temp.txt

	# 过滤掉 main.js manifest.json styles.css 三个文件之外所有文件
	# for line in `cat temp.txt`
	# do
	# local f_name=${line##*/}
	#
	# if [[ $f_name == "main.js" ]] || [[ $f_name == "manifest.json" ]] || [[ $f_name == "styles.css" ]];then
	# echo $line
	# fi
	# done

}

# 从manifest.json文件中获取id值
# 这个id值是这个插件的插件目录名
function get_plugins_id() {
	# manifest.json 文件
	local json_file=$1

	if [[ ! -e $json_file ]]; then
		echo -e "\e[93m $json_file \e[92m文件不存在！\n \e[0m"
	fi

}

# -----------------------测试--------------------- #
dl_arr=$(get_dl_url $1)
# echo ${dl_arr[@]}

for addr_temp in ${dl_arr[@]}; do
	echo $addr_temp
done
