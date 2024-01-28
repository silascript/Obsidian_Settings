


function get_dl_url(){

	# json文件
	local json_path=$1

	# 使用 jq 获取各文件下载地址并输出到临时文件中
	jq -r '.assets[] | .browser_download_url' $json_path > temp.txt

	# 过滤掉 main.js manifest.json styles.css 三个文件之外所有文件
	for line in `cat temp.txt`
	do
		local f_name=${line##*/}

		if [[ $f_name == "main.js" ]] || [[ $f_name == "manifest.json" ]] || [[ $f_name == "styles.css" ]];then
			echo $line
		fi
	done
	

}


# -------------------------------------------- #

get_dl_url $1


