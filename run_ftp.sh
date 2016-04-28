#!/bin/bash
# author: chengfaying
# description: 
# ftp需要使用的文件夹：/ftp
# 执行命令，导入镜像
#构造的启动命令如下：
#docker load < vsftp_centos7.tar
#user:sobey
#psswd:Sobey_2016
#用户名和密码可以启动Container的时候用-e FTP_USER=myuser -e FTP_PASS=mypass修改（fStartContainer中添加），也可以进入容器后修改
#set -ex

imagefile="vsftp_centos7.tar"
ftpdir="/ftp"
image=$(docker images| gawk '/vsftp_centos7/{print $1}')

#-----------------Function-------------------
function fShowStep ()
{
	#let lColumns=$(tput cols)-8
	lColumns=59
	for ((i=0; i<${lColumns}; i++)); do
		printf '.'
	done
	printf "[ "
	if [[ $1 -eq 0 ]]; then
		printf "\033[1;32m%b\033[0m" " ok "
	else
		printf "\033[1;31m%b\033[0m" "fail\a"
	fi
	printf " ]"
	printf "\r${2}: \n"
}

fCheckAndMkdir ()
{
	if [ ! -d "$ftpdir" ]; then
	  mkdir "$ftpdir"
	fi
	fShowStep $? "Check and make ftp dir"
	chmod 777 "$ftpdir"
	fShowStep $? "chmod $ftpdir"
}

fStartContainer()
{
	echo "starting vsftp_centos7 ."
	docker run -v /ftp:/home/vsftpd  --privileged=true -p 20-21:20-21 -p 21100-21110:21100-21110 --name vsftpd_server -itd vsftp_centos7
	fShowStep $? "start vsftp_centos7"
}
fRmContainer()
{
	id=
	id=$(docker ps -a| gawk '/vsftpd_server/{print $1}')
	if [ -n "$id" ]; then
		docker stop "$id"
		fShowStep $? "stop vsftp_centos7 $id"
		docker rm "$id"
		fShowStep $? "rm vsftp_centos7 $id"
	fi

}
fLoadImage()
{
	if [ -f "$imagefile" ]; then
	  echo "importing $imagefile image ."
	  docker load < "$imagefile"
	  fShowStep $? "import $imagefile image"
	else
	  echo "ftp image $imagefile does not exist"
	fi
}

fMain()
{
	fCheckAndMkdir

	# 判断两个变量是否相等
	if [ "$image" = "vsftp_centos7" ]; then
		fRmContainer
		fLoadImage
	else
		fLoadImage
	fi
	fStartContainer
}

fMain