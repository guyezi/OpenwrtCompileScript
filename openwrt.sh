#!/bin/bash
#set -x
#set -u

######################### 系统检测 #####################################

# Allow For Raw Print or Source Import In Another Script
if [ -z $1 ]; then
  use_type='PRINT'
elif [ "$1" = 'print' ] || [ "$1" = 'PRINT' ] ; then
  use_type='PRINT'
elif [ "$1" = 'no-print' ] || [ "$1" = 'NO-PRINT' ] ; then
  use_type='SOURCE'
else
  use_type='PRINT'
fi

# Allow For Manual Spesification of Package Manager
if [ -z $2 ]; then
  alt_pkg_manager='NONE'
else
  alt_pkg_manager=$2
fi

# Allow For Manual Spesification of /etc/os-release File
if [ -z $3 ]; then
  release_file="/etc/os-release"
else
  release_file=$3
fi

# Allow For Manual Spesification of Alternate Release File
if [ -z $4 ]; then
  alt_release_file="NONE"
else
  alt_release_file=$2
fi


identify_pkg_manager(){
  # SUSE Based
  if [ -f "/usr/bin/zypper" ]; then
    type=$(file $(readlink -f /usr/bin/zypper) --mime-type | awk -F '[ /]' '{ print $6 }')
    if [ "$type" != "x-shellscript" -a "$type" != "x-perl" ]; then
      pkg_manager="zypper"
    fi
  fi
  
  # Deb Based
  if [ -f "/usr/bin/apt" ]; then
    type=$(file $(readlink -f /usr/bin/apt) --mime-type | awk -F '[ /]' '{ print $6 }')
    if [ "$type" != "x-shellscript" -a "$type" != "x-perl" ]; then
      pkg_manager="apt"
    fi
  fi

  # RHL Based
  if [ -f "/usr/bin/yum" ]; then
    type=$(file $(readlink -f /usr/bin/yum) --mime-type | awk -F '[ /]' '{ print $6 }')
    if [ "$type" != "x-shellscript" -a "$type" != "x-perl" ]; then
      pkg_manager="yum"
    fi
  fi

  # Arch Linux
  if [ -f "/usr/bin/pacman" ]; then
    type=$(file $(readlink -f /usr/bin/pacman) --mime-type | awk -F '[ /]' '{ print $6 }')
    if [ "$type" != "x-shellscript" -a "$type" != "x-perl" ]; then
      pkg_manager="pacman"
    fi
  fi

  # FreeBSD
  if [ -f "/usr/sbin/pkg" ]; then
    type=$(file $(readlink -f /usr/sbin/pkg) --mime-type | awk -F '[ /]' '{ print $6 }')
    if [ "$type" != "x-shellscript" -a "$type" != "x-perl" ]; then
      pkg_manager="pkg"
    fi
  fi

  # Alpine Linux
  if [ -f "/sbin/apk" ]; then
    # Apline Doesn't Come with `file`
    pkg_manager="apk"
  fi

  # Override Package Manager
  if [ "$alt_pkg_manager" != "NONE" ]; then
    pkg_manager="$alt_pkg_manager"
  fi
  
  # Can't Determine
  if [ -z $pkg_manager ]; then
    pkg_manager="UNKNOWN"
  fi
}


identify_deb(){
  kernel=$(uname -r | awk -F '[-]' '{print $1}')
  
  if [ -f "$release_file" ]; then
    distro=$(awk -F '[= ]' '/^NAME=/ { gsub(/"/,"");  print toupper($2) }' $release_file)

    if [ "$distro" = "UBUNTU" ]; then
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '[=. ]' '/^VERSION=/ { gsub(/"/,"");  print $2 }' $release_file)
      minor=$(awk -F '[=. ]' '/^VERSION=/ { gsub(/"/,"");  print $3 }' $release_file)
      patch=$(awk -F '[=. ]' '/^VERSION=/ { gsub(/"/,"");  print $4 }' $release_file)

    elif [ "$distro" = "DEBIAN" ]; then
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
 
      if [ "$alt_release_file" = "NONE" ]; then
        alt_release_file='/etc/debian_version'
      fi

      major=$(head -1 $alt_release_file | awk -F '[=.]' '{ gsub(/"/,""); print $1 }')
      minor=$(head -1 $alt_release_file | awk -F '[=.]' '{ gsub(/"/,""); print $2 }')
      patch='n/a'

    elif [ "$distro" = "KALI" ]; then
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '[=.]' '/^VERSION=/ { gsub(/"/,"");  print $2 }' $release_file)
      minor=$(awk -F '[=.]' '/^VERSION=/ { gsub(/"/,"");  print $3 }' $release_file)
      patch='n/a'

    elif [ "$distro" = "PARROT" ]; then
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '[=.]' '/^VERSION=/ { gsub(/"/,"");  print $2 }' $release_file)
      minor=$(awk -F '[=.]' '/^VERSION=/ { gsub(/"/,"");  print $3 }' $release_file)
      patch='n/a'

    else
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '=' '/^VERSION=/ { gsub(/"/,"");  print $2 }' $release_file)
      minor='UNKNOWN'
      patch='UNKNOWN'
    fi
  
  else
    echo 'System is Based on Debian Linux But NO Release Info Was Found in $release_file!'
    exit 1
  fi
}

identify_rhl(){
  kernel=$(uname -r | awk -F '[-]' '{print $1}')
  
  if [ -f "$release_file" ]; then
    distro=$(awk -F '[= ]' '/^NAME=/ { gsub(/"/,"");  print toupper($2) }' $release_file)

    if [ "$distro" = "FEDORA" ]; then
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '[= ]' '/^VERSION=/ { gsub(/"/,"");  print $2 }' $release_file)
      minor='n/a'
      patch='n/a'

    elif [ "$distro" = "CENTOS" ]; then

      if [ "$alt_release_file" = "NONE" ]; then
        alt_release_file='/etc/centos-release'
      fi

      name=$(cat $alt_release_file)
      major=$(grep -o '[0-9]\+' $alt_release_file | sed -n '1p')
      minor=$(grep -o '[0-9]\+' $alt_release_file | sed -n '2p')
      patch=$(grep -o '[0-9]\+' $alt_release_file | sed -n '3p')

    elif [ "$distro" = "ORACLE" ]; then
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '[=.]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' $release_file)
      minor=$(awk -F '[=.]' '/^VERSION_ID=/ { gsub(/"/,"");  print $3 }' $release_file)
      patch='n/a'

    elif [ "$distro" = "RED" ]; then
      distro='REDHAT'
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '[=.]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' $release_file)
      minor=$(awk -F '[=.]' '/^VERSION_ID=/ { gsub(/"/,"");  print $3 }' $release_file)
      patch='n/a'

    else
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '=' '/^VERSION=/ { gsub(/"/,"");  print $2 }' $release_file)
      minor='UNKNOWN'
      patch='UNKNOWN'
    fi

  else
    echo 'System is Based on RedHat Linux But NO Release Info Was Found in $release_file!'
    exit 1
  fi
}


identify_suse(){
  kernel=$(uname -r | awk -F '[-]' '{print $1}')
  
  if [ -f "$release_file" ]; then
    distro=$(awk -F '=' '/^NAME=/ { gsub(/"/,"");  print toupper($2) }' $release_file)
    
    if [ "$distro" = "OPENSUSE LEAP" ]; then
      distro="LEAP"
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '[=. ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' $release_file)
      minor=$(awk -F '[=. ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $3 }' $release_file)
      patch='n/a'

    elif [ "$distro" = "OPENSUSE TUMBLEWEED" ]; then
      distro="TUMBLEWEED"
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '[= ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' $release_file | rev | cut -c5- | rev)
      minor=$(awk -F '[= ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' $release_file | cut -c5- | rev | cut -c3- | rev)
      patch=$(awk -F '[= ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' $release_file | cut -c7-)

    elif [ "$distro" = "SLES" ]; then
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '[=.]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' $release_file)
      minor=$(awk -F '[=.]' '/^VERSION_ID=/ { gsub(/"/,"");  print $3 }' $release_file)
      patch='n/a'

    else
      name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
      major=$(awk -F '=' '/^VERSION=/ { gsub(/"/,"");  print $2 }' $release_file)
      minor='UNKNOWN'
      patch='UNKNOWN'
    fi
  
  else
    echo 'System is Based on OpenSUSE But NO Release Info Was Found in $release_file!'
    exit 1
  fi
}


identify_arch(){
  kernel=$(uname -r | awk -F '[-]' '{print $1}')
  
  if [ -f "$release_file" ]; then
    distro=$(awk -F '[= ]' '/^NAME=/ { gsub(/"/,"");  print toupper($2) }' $release_file)
    name=$(awk -F '=' '/^PRETTY_NAME=/ { gsub(/"/,"");  print $2 }' $release_file)
    major=$(awk -F '=' '/^BUILD_ID/ { gsub(/"/,""); print $2 }' $release_file)
    minor=$(awk -F '=' '/^BUILD_ID/ { gsub(/"/,""); print $2 }' $release_file)
    patch=$(awk -F '=' '/^BUILD_ID/ {  gsub(/"/,""); print $2 }' $release_file)
  
  else
    echo 'System is Based on Arch Linux But NO Release Info Was Found in $release_file!'
    exit 1
  fi
}


identify_freebsd(){
  kernel=$(uname -K)
  distro=$(uname | tr [a-z] [A-Z])
  name="$(uname) $(uname -r)"
  major=$(uname -r | awk -F '[.-]' '{ print $1 }')
  minor=$(uname -r | awk -F '[.-]' '{ print $2 }')
  patch='n/a'
}


identify_alpine(){
  kernel=$(uname -r | awk -F '[-]' '{ print $1 }')
  
  if [ -f "$release_file" ]; then
    distro=$(awk -F '[= ]' '/^NAME=/ { gsub(/"/,"");  print toupper($2) }' $release_file)
    name=$(awk -F '=' '/^PRETTY_NAME=/{ gsub(/"/,""); print $2 }' $release_file)
    major=$(awk -F '[=. ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' $release_file)
    minor=$(awk -F '[=. ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $3 }' $release_file)
    patch='n/a'
  
  else
    echo 'System is Based Alpine Linux But NO Release Info Was Found in $release_file!'
    exit 1
  fi
}

win10() {
		export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
		if [[ -e /etc/apt/sources.list.back ]]; then
			clear && echo -e "$green源码已替换$white"
		else
			clear
			echo "-----------------------------------------------------------------"
			echo "+++检测到win10子系统+++"
			echo ""
			echo "  win10子系统已知问题"
			echo "     1.IO很慢，编译很慢，不怕耗时间随意"
			echo "     2.win10对大小写不敏感，你需要百度如何开启win10子系统大小写敏感"
			echo "     3.需要替换子系统的linux源（脚本可以帮你搞定）"
			echo "-----------------------------------------------------------------"
			echo ""
			read -p "是否替换软件源然后进行编译（1.yes，2.no）："  win10_select
				case "$win10_select" in
				1)
					clear
					echo -e "$green开始替换软件源$white" && Time
					sudo cp  /etc/apt/sources.list /etc/apt/sources.list.back
					sudo rm -rf /etc/apt/sources.list
					sudo cp $HOME/$OW/$SF/$OCS/ubuntu18.4_sources.list /etc/apt/sources.list
					sudo apt-get update
					sudo apt-get install git-core build-essential libssl-dev libncurses5-dev unzip
					;;
				2)
					 clear
					 echo "不做任何操作，即将进入主菜单" && Time
					 ;;
				*)
					 clear && echo  "Error请输入正确的数字 [1-2]" && Time
					 description_if
					 ;;
				esac
			
			fi
}

# Use PKG Manager Trigger Identification Process
identify_pkg_manager
if [ "$pkg_manager" = "apt" ]; then
  identify_deb

elif [ "$pkg_manager" = "yum" ]; then
  identify_rhl

elif [ "$pkg_manager" = "zypper" ]; then
  identify_suse

elif [ "$pkg_manager" = "pkg" ]; then
  identify_freebsd

elif [ "$pkg_manager" = "apk" ]; then
  identify_alpine

elif [ "$pkg_manager" = "pacman" ]; then
  identify_arch
else
  echo 'Could NOT Determine The Systems Package Manager!' 
  exit 1
fi
if [ "$use_type" = "PRINT" ]; then 
	#else
	# Import Results as Source
	distro=$distro
	full_name=$name
	pkg_manager=$pkg_manager
	kernel=$kernel
	major=$major
	minor=$minor
	patch=$patch
fi

######################### 系统检测 #####################################

######################### 系统检测 #####################################

calculating_time_start() {
startTime=`date +%Y%m%d-%H:%M:%S`
startTime_s=`date +%s`
}

calculating_time_end() {
endTime=`date +%Y%m%d-%H:%M:%S`
endTime_s=`date +%s`
sumTime=$[ $endTime_s - $startTime_s ]
echo ""
echo -e "$yellow开始时间:$green $startTime ---> $yellow结束时间:$green $endTime" "$yellow耗时:$green $sumTime 秒$white"
}
######################### 系统检测 #####################################

#############################  安装编译环境  #############################
sysinstall() {
	Distro=$distro
	Full_name=$name
	Pkg_manager=$pkg_manager
	Kernel=$kernel
	Major=$major
	Minor=$minor
	Patch=$patch
check_win10_system=$(cat /proc/version |grep -o Microsoft@Microsoft.com)
check_win10_system01=$(cat /proc/version |grep -o microsoft-standard)
if [[ "$check_win10_system" == "Microsoft@Microsoft.com" ]]; then
		win10
elif [[ "$check_win10_system01" == "microsoft-standard" ]]; then
		win10
elif [[ "$Distro" = 'Ubuntu' ]]; then
		sudo apt-get install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync bison g++ gcc help2man htop ncurses-term ocaml-nox sharutils yui-compressor make cmake build-essential libncurses-dev unzip python
elif [[ "$Distro" = 'Centos' ]]; then
		sudo yum update && yum install binutils bzip2 gcc gcc-c++ gawk gettext flex ncurses-devel zlib-devel zlib-static make patch unzip perl-ExtUtils-MakeMaker glibc glibc-devel glibc-static ncurses-libs sed sdcc intltool sharutils bison wget git-core openssl-devel xz nano
elif [[ "$Pkg_manager" = 'pacman' ]]; then
		pacman -S --needed asciidoc bash bc binutils bzip2 fastjar flex git gcc util-linux gawk intltool zlib make cdrkit ncurses openssl patch perl-extutils-makemaker rsync unzip wget gettext libxslt boost libusb bin86 sharutils b43-fwcutter findutils time
elif [[ "$Pkg_manager" = 'dnf' ]]; then
		dnf update && dnf -y install @c-development @development-tools @development-libs zlib-static wget python2 binutils bzip2 gcc gcc-c++ gawk gettext git-core flex ncurses-devel ncurses-compat-libs zlib-devel zlib-static make patch unzip perl-ExtUtils-MakeMaker perl-Thread-Queue glibc glibc-devel glibc-static quilt sed sdcc intltool sharutils bison wget openssl-devel
elif [[ "$Pkg_manager" = 'zypper' ]]; then
		zypper install -y asciidoc bash bc patterns-openSUSE-devel_basis zlib-devel-static binutils bzip2 fastjar flex git-core gcc-c++ gcc util-linux gawk intltool zlib-devel mercurial make genisoimage ncurses-devel libopenssl-devel patch perl-ExtUtils-MakeMaker python-devel rsync sdcc unzip wget gettext-tools libxslt-tools zlib-devel
elif [[ "$Pkg_manager" = 'apk' ]]; then
		apk add asciidoc bash bc binutils bzip2 cdrkit coreutils diffutils findutils flex g++ gawk gcc gettext git grep intltool libxslt linux-headers make ncurses-dev patch perl python2-dev tar unzip  util-linux wget zlib-dev
elif [[ "$Pkg_manager" == "pkg" ]]; then
		sudo port -y install coreutils e2fsprogs ossp-uuid asciidoc binutils bzip2 fastjar flex getopt gtk2 intltool jikes hs-zlib openssl p5-extutils-makemaker python26 subversion rsync ruby sdcc unzip gettext libxslt bison gawk autoconf wget gmake ncurses findutils gnutar mpfr libmpc gcc49
else
	echo '未支持本系统!'  && clear
fi
}
###########################  安装编译环境end  ############################

########################### 系统检测 ####################################
#判断代码
description_if(){
   	cd
	clear
	echo "开始检测系统"
	#添加hosts(解决golang下载慢的问题)
	#if [[ $(grep -o "34.64.4.113 proxy.golang.org" /etc/hosts | wc -l) == "1" ]]; then
		#echo "之前设置的hosts失效，需要删除，请输入密码，放心不会炸的"
		#sudo sed -i 's\34.64.4.113 proxy.golang.org\ \g' /etc/hosts
	#else
		#clear
		#echo "添加hosts(解决golang下载慢的问题)"
		#sudo cp  /etc/hosts /etc/hosts_back
		#sudo sed -i '3a\34.64.4.113 proxy.golang.org' /etc/hosts
	#fi
	
	if [[ ! -d "$HOME/$OW/$SF/$OCS" ]]; then
		echo "开始创建主文件夹"
		#mkdir -p $HOME/$OW/$SF/dl
		ln -s $HOME/$user/dl $HOME/$OW/$SF/dl
		mkdir -p $HOME/$OW/$SF/My_config
		mkdir -p $HOME/$OW/$SF/tmp
	fi

  	#清理一下之前的编译文件
   	rm -rf $HOME/$OW/$SF/tmp/*

	#判断是否云编译
	workspace_home=`echo "$HOME" | grep gitpod | wc -l`
	if [[ "$workspace_home" == "1" ]]; then
		echo "$yellow请注意云编译已经放弃维护很久了，不保证你能编译成功,太耗时耗力，你如果不信邪你可以回车继续$white"
		read a
        	echo "开始添加云编译系统变量"
		Cloud_env=`gp env | grep -o "shfile" | wc -l `
       		if [[ "$Cloud_env" == "0" ]]; then
           		eval $(gp env -e openwrt=$THEIA_WORKSPACE_ROOT/Openwrt/Script_File/OpenwrtCompileScript/openwrt.sh)
			eval $(gp env -e shfile=$THEIA_WORKSPACE_ROOT/Openwrt/Script_File/OpenwrtCompileScript)
           		echo -e  "系统变量添加完成，老样子启动  bash \$openwrt"
			Time
		fi
		HOME=`echo "$THEIA_WORKSPACE_ROOT"`
   	 else
		#添加系统变量
		openwrt_shfile_path=$(cat /etc/profile | grep -o shfile | wc -l)
		openwrt_script_path=$(cat /etc/profile | grep -o openwrt.sh | wc -l)
		if [[ "$openwrt_shfile_path" == "0" ]]; then
			echo "export shfile=$HOME/Openwrt/Script_File/OpenwrtCompileScript" | sudo tee -a /etc/profile
			echo -e "$green添加openwrt脚本变量成功,以后无论在那个目录输入 cd \$shfile 都可以进到脚本目录$white"
			#clear
		elif [[ "$openwrt_script_path" == "0" ]]; then
			echo "export openwrt=$HOME/Openwrt/Script_File/OpenwrtCompileScript/openwrt.sh" | sudo tee -a /etc/profile
			#clear
			echo "-----------------------------------------------------------------------"
			echo ""
			echo -e "$green添加openwrt变量成功,重启系统以后无论在那个目录输入 bash \$openwrt 都可以运行脚本$white"
			echo ""
			echo ""
			echo -e "                    $green回车重启你的操作系统!!!$white"
			echo "-----------------------------------------------------------------------"
			read a
			Time
			rm -rf `pwd`/$OCS
			reboot	
		else
			echo "系统变量已经添加"
		fi

	fi

	if [[ -e $HOME/$OW/$SF/$OCS ]]; then
		echo "存在"
	else 
		cd $HOME/$OW/$SF/
        #git clone https://github.com/openwrtcompileshell/OpenwrtCompileScript.git
		git clone https://github.com/guyezi/OpenwrtCompileScript.git
		cd 
		rm -rf `pwd`/$OCS
		cd $HOME/$OW/$SF/$OCS
		bash openwrt.sh
	fi
}

win10() {
		export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
		if [[ -e /etc/apt/sources.list.back ]]; then
			clear && echo -e "$green源码已替换$white"
		else
			clear
			echo "-----------------------------------------------------------------"
			echo "+++检测到win10子系统+++"
			echo ""
			echo "  win10子系统已知问题"
			echo "     1.IO很慢，编译很慢，不怕耗时间随意"
			echo "     2.win10对大小写不敏感，你需要百度如何开启win10子系统大小写敏感"
			echo "     3.需要替换子系统的linux源（脚本可以帮你搞定）"
			echo "-----------------------------------------------------------------"
			echo ""
			read -p "是否替换软件源然后进行编译（1.yes，2.no）："  win10_select
				case "$win10_select" in
				1)
					clear
					echo -e "$green开始替换软件源$white" && Time
					sudo cp  /etc/apt/sources.list /etc/apt/sources.list.back
					sudo rm -rf /etc/apt/sources.list
					sudo cp $HOME/$OW/$SF/$OCS/ubuntu18.4_sources.list /etc/apt/sources.list
					sudo apt-get update
					sudo apt-get install git-core build-essential libssl-dev libncurses5-dev unzip
					;;
				2)
					 clear
					 echo "不做任何操作，即将进入主菜单" && Time
					 ;;
				*)
					 clear && echo  "Error请输入正确的数字 [1-2]" && Time
					 description_if
					 ;;
				esac
			
			fi
}
##################################### 系统检测 ###########################################
##################################  网络检测 #############################################
interface_test() {
	clear
	CheckUrl_google=$(curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null   www.google.com)

	if [[ "$CheckUrl_google" -eq "200" ]]; then
		Check_google=`echo -e "$green网络正常$white"`
	else
		Check_google=`echo -e "$red网络较差$white"`
	fi

	CheckUrl_gfwip=$(curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null   www.google.com.hk)
	gfwip=$(curl -s --socks5 127.0.0.1:1088 https://ip8.com/ip)
	hostip=$(curl -s https://ip8.com/ip)
	if [[ "$CheckUrl_gfwip" -eq "200"  ]]; then
		Check_gfwip=`echo -e "$green$gfwip"`
	else
		Check_gfwip=`echo -e "$red$hostip$white"`
	fi

	CheckUrl_baidu=$(curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null  www.baidu.com)
	if [[ "$CheckUrl_baidu" -eq "200" ]]; then
		Check_baidu=`echo -e "$green百度正常$white"`
	else
		Check_baidu=`echo -e "$red百度无法打开，请修复这个错误$white"`
	fi

	Root_detection=`id -u`	# 学渣代码改良版
	if [[ "$Root_detection" -eq "0" ]]; then
		Root_run=`echo -e "$red请勿以root运行,请修复这个错误$white"`
	else
		Root_run=`echo -e "$green非root运行$white"`
	fi

	
	clear
	echo "稍等一下，正在取回远端脚本源码，用于比较现在脚本源码，速度看你网络"
	cd && cd $HOME/$OW/$SF/$OCS
	git fetch
	if [[ $? -eq 0 ]]; then
		echo ""
	else
		echo -e "$red>> 取回分支没有成功，重新执行代码$white" && Time
		self_test
	fi
	clear
	git_branch=$(git branch -v | grep -o 落后 )
	if [[ "$git_branch" == "落后" ]]; then
		Script_status=`echo -e "$red建议更新$white"`
	else
		Script_status=`echo -e "$green最新$white"`		
	fi	

	echo "	      	    -------------------------------------------"
	echo "	      	  	【  Script Self-Test Program  】"
	echo ""
	echo " 			检测是否root运行:  $Root_run  "
	echo ""
	echo "		  	检测与DL网络情况： $Check_google "
	echo "  "
	echo "		  	检测梯子是否正常： $Check_gfwip "
	echo "  "
	echo "		  	检测百度是否正常： $Check_baidu "
	echo "  "
	echo "		  	检测脚本是否最新： $Script_status "
	echo "  "
	echo "	      	    -------------------------------------------"
	echo ""
	echo -e "$green  脚本问题反馈：https://github.com/guyezi/OpenwrtCompileScript/issues或者加群反馈(群在github有)$white"
	echo ""
	echo "  请自行决定是否修复红字的错误，以保证编译顺利，你也可以直接回车进入菜单，但有可能会出现编译失败！！！如果都是绿色正常可以忽略此段话"
	read a
}
##################################  网络检测 ##############################################


###########################    预设变量参数   ############################
version="21.3"
SF="Script_File"
OW="Openwrt"
BY="guyezi"
OCS="OpenwrtCompileScript"
cpu_cores=`cat /proc/cpuinfo | grep processor | wc -l`	

##颜色
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"
blue="\033[34m"
magenta="\033[35m"
cyan="\033[36m"
############################ 预设变量参数 ###########################

############################ 下载变量值 ############################
URL=http://guyezi.com/
O_Sou_URL=https://git.openwrt.org/openwrt/openwrt.git
O_SDK_URL=https://mirrors.cloud.tencent.com/lede/releases
PanBox_Sdk_URL=http://downloads.pangubox.com:6380/pandorabox
C_git_URL=https://github.com/coolsnowwolf/lede.git
L_git_URL=https://github.com/Lienol/openwrt.git
I_down_URL=https://mirrors.cloud.tencent.com/lede/releases
########################## 下载变量值end ###########################

########################## SDK && imagebuilder下载地址变量值 ###############################
OIB_Down_URL=$('$O_SDK_URL'/'$O_REV'/targets/'$O_Platform'/'$O_Model'/'$O_IB_FILES'.tar.gz)
OSDK_Down_URL=$('$O_SDK_URL'/'$O_REV'/targets/'$O_Platform'/'$O_Model'/'$O_SDK'-'$O_REV'-"$O_SDK_FILES".tar.xz)
########################## SDK && imagebuilder下载地址变量值 ###############################

########################## 解压文件变量值 #####################################
O_IB_FILES=$('$O_IB'-'$O_REV'-'$O_Platform'-'$O_Model'-x86-64.Linux-x86_64)
O_IB="openwrt-imagebuilder"
O_SDK_FILES=$('$O_SDK'-'$O_REV'-'$O_Platform'-'$O_Model'_O_SDK_GCC)
O_SDK="openwrt-sdk"
O_S18_FILES=$('$O_SDK'-'$O_R18'-'$O_Platform'-'$O_Model'_'$O_SDK_18_GCC')
O_S18S_FILES=$('$O_SDK'-'$O_R18S'-'$O_Platform'-'$O_Model'_'$O_SDK_18_GCC')
O_S19_FILES=$('$O_SDK'-'$O_R19'-'$O_Platform'-'$O_Model'_'$O_SDK_19_GCC')
O_S19S_FILES=$('$O_SDK'-'$O_R19S'-'$O_Platform'-'$O_Model'_'$O_SDK_19_GCC')
O_S21_FILES=$('$O_SDK'-'$O_R21'-'$O_Platform'-'$O_Model'_'$O_SDK_21_GCC')
O_S21S_FILES=$('$O_SDK'-'$O_R21S'-'$O_Platform'-'$O_Model'_'$O_SDK_21_GCC')
O_SDK_18_GCC="gcc-7.3.0_musl.Linux-x86_64"
O_SDK_19_GCC="gcc-7.5.0_musl.Linux-x86_64"
O_SDK_21_GCC="gcc-8.4.0_musl.Linux-x86_64"
##############################################################################
########################## OPENWRT版本变量值 ##############################
O_R18="18.06.9"
O_R18S="18.06-SNAPSHOT"
O_R19="19.07.7"
O_R19S="19.07-SNAPSHOT"
O_R21="21.02"
O_R21S="21.02-SNAPSHOT"
########################## OPENWRT版本变量值end ###########################

########################## o_platform机型变量值 ##############################
ADM5120="adm5120"
ADM8668="adm8668"
APM821XX="apm821xx"
AR7="ar7"
AR71XX="ar71xx"
ARC770="arc770"
ARCHS38="archs38"
ARMVIRT="armvirt"
AT9="at91"
ATH25="ath25"
AU1000="au1000"
BCM53XX="bcm53xx"
BRCM2708="brcm2708"
BRCM47XX="brcm47xx"
BRCM63XX="brcm63xx"
CNS3XXX="cns3xxx"
GEMINI="gemini"
IMX6="imx6"
IPQ40XX="ipq40xx"
IPQ806XX="ipq806x"
IXP4XX="ixp4xx"
KIRKWOOD="kirkwood"
LANTIQ="lantiq"
LAYERSCAPE="layerscape"
MALTA="malta"
MCS814X="mcs814x"
MEDIATEK="mediatek"
MPC85XX="mpc85xx"
MVEBU="mvebu"
MXS="mxs"
OCTEON="octeon"
OCTEONTX="octeontx"
OMAP="omap"
OXNAS="oxnas"
PISTACHIO="pistachio"
RAMIPS="ramips"
RB532="rb532"
SUNXI="sunxi"
X86="x86"
XBURST="xburst"
ZYNQ="zynq"
########################## 机型变量值end ###########################

########################## o_model型号变量值 ##############################

## armvirt x86
32=32

## armvirt x86
64=64

## ar7 
AC49X="ac49x"

## layerscape
ARM832="armv8_32b" 
ARM864="armv8_64b"

## lantiq
ASE="ase"

## au1000
AU1500="au1500"
AU1550="au1550"

## brcm2708
BCM2708="bcm2708" 
BCM2709="bcm2709"
BCM2710="bcm2710"

## malta
BE="be"

## mvebu sunxi
CORTEXA53="cortexa53"

## mvebu
CORTEXA72="cortexa72"

## mvebu
CORTEXA9="cortexa9"

## sunxi
CORTEXA8="cortexa8"

## sunxi
CORTEXA7="cortexa7"

## lantiq
FALCON="falcon"

## adm8668 ar7 ar71xx arc770 archs38 ath25 bcm53xx brcm47xx brcm63xx cns3xxx 
## gemini imx6 ipq40xx ipq806x ixp4xx kirkwood mcs814x mpc85xx mxs octeon 
## octeontx omap oxnas pistachio rb532 x86 zynq
GENERIC="generic"

## x86
GEODE="geode"

## ixp4xx
HARDDISK="harddisk"

## at91 brcm47xx x86
LEGACY="legacy"

## ar71xx
MIKROTIK="mikrotik"

## brcm47xx
MIPS74K="mips74k"

## ramips
MT7620="mt7620"

## ramips
MT7621="mt7621"

## mediatek
MT7622="mt7622"

## mediatek
MT7623="mt7623"

## ramips
MT76X8="mt76x8"

## apm821xx ar71xx
NAND="nand"

## oxnas
OX820="ox820"

## mpc85xx
P1020="p1020"

## xburst
QI1B60="qi_lb60"

## adm5120
ROUTERBE="router_be"
ROUTERLE="router_le"

## ramips
RT288X="rt288x"

## ramips
RT305X="rt305x"

## ramips
RT3883="rt3883"

## apm821xx
SATA="sata"

## at91
SAMA5D2="sama5d2" 
SAMA5D3="sama5d3" 
SAMA5D4="sama5d4"

## brcm63xx
SMP="smp"

## ar71xx 
TINY="tiny"

## lantiq
XRX200="xrx200"
XWAY="xway"
XWAYLEGACY="xway_legacy"
########################## 型号变量值end ###########################

##########################  Adm5120 SDK 下载   ############################
O_Down_Adm5120_SDK() {
	if []; then
	elif []; then
	fi
}
##########################  Adm5120 SDK 下载   ############################

########################## OPENWRT 源码版本检测 ############################
source_if() {
		#检测源码属于那个版本
		source_git_branch=$(git branch | sed 's/* //g')
		if [[ `git remote -v | grep -o '$O_Sou_URL' | wc -l` == "2" ]]; then
			echo "openwrt" > $HOME/$OW/$SF/tmp/source_type
			if [[ $source_git_branch == "lede-17.01" ]]; then
				echo "lede-17.01" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "openwrt-18.06" ]]; then
				echo "openwrt-18.06" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "openwrt-19.07" ]]; then
				echo "openwrt-19.07" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "master" ]]; then
				echo "master" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "openwrt-19.07" ]]; then
				echo "openwrt-19.07.7" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "openwrt-19.07" ]]; then
				echo "openwrt-21.02" > $HOME/$OW/$SF/tmp/source_branch
			fi
		elif [[ `git remote -v | grep -o '$C_git_URL' | wc -l` == "2" ]]; then
			echo "lean" > $HOME/$OW/$SF/tmp/source_type
			echo "lede-17.01" > $HOME/$OW/$SF/tmp/source_branch

		elif [[ `git remote -v | grep -o '$C_git_URL' | wc -l` == "2" ]]; then
			echo "lean" > $HOME/$OW/$SF/tmp/source_type
			if [[ $source_git_branch == "master" ]]; then
				echo "master" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "lede-17.01" ]]; then
				echo "lede-17.01" > $HOME/$OW/$SF/tmp/source_branch
			fi

		elif [[ `git remote -v | grep -o https://github.com/Lienol/openwrt.git | wc -l` == "2" ]]; then
			echo "lienol" > $HOME/$OW/$SF/tmp/source_type
			if [[ $source_git_branch == "master" ]]; then
				echo "master" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "19.07" ]]; then
				echo "19.07" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "21.02" ]]; then
				echo "21.02" > $HOME/$OW/$SF/tmp/source_branch
			fi

		else
			echo -e  "检查到你的源码是：$red未知源码$white"
			echo -e  "是否继续运行脚本！！！运行请回车，不运行请终止脚本"
			echo "unknown" > $HOME/$OW/$SF/tmp/source_type
			read a
		fi 
}

############################# OPENWRT 源码版本检测 ###################################

source_Soft_link() {
		#1
		#if [[ -e $HOME/$OW/$SF/description ]]; then
		#	echo ""
		#else
		#	description >> $HOME/$OW/$SF/description
		#fi
		#2
		if [[ -e $HOME/$OW/$file/lede/dl ]]; then
			echo ""
		else
			ln -s  $HOME/$user/dl $HOME/$OW/$SF/dl
			ln -s  $HOME/$OW/$SF/dl $HOME/$OW/$file/lede/dl
		fi

		#3
		if [[ -e $HOME/$OW/$file/lede/My_config ]]; then
			echo ""
		else
			ln -s  $HOME/$OW/$SF/My_config $HOME/$OW/$file/lede/My_config
		fi

		#4
		if [[ -e $HOME/$OW/$file/lede/openwrt.sh ]]; then
			echo ""
		else
			ln -s  $HOME/$OW/$SF/$OCS/openwrt.sh $HOME/$OW/$file/lede/openwrt.sh
		fi
}

source_openwrt() {
		clear
		source_type=`cat "$HOME/$OW/$SF/tmp/source_type"`
		if [[ `echo "$source_type" | grep openwrt | wc -l` == "1" ]]; then
			rm -rf package/lean 
			source_openwrt_Setting
		elif [[ `echo "$source_type" | grep lean | wc -l` == "1" ]]; then
			echo ""
		fi			
}

############################# 定义源码目录 ###################################
create_file() {
	clear
	echo ""
	echo "----------------------------------------"
	echo "		   开始创建文件夹"
	echo "----------------------------------------"
	echo ""
	read -p "请输入你要创建的文件夹名:" file

	if [[ -e $HOME/$OW/$file ]]; then
		clear && echo "文件夹已存在，请重新输入文件夹名" && Time
		create_file

	 else
		echo "开始创建文件夹"
			mkdir $HOME/$OW/$file
			cd $HOME/$OW/$file  && clear
			echo "$file" > $HOME/$OW/$SF/tmp/you_file
			main_num
	 fi
}
############################# 定义源码目录 ###################################

############################  更新Feeds代码 #########################################
update_feeds() {
	clear
	echo "---------------------------"
	echo "      更新Feeds代码"
	echo "---------------------------"
	./scripts/feeds update -a
	if [[ $? -eq 0 ]]; then
		echo ""
	else
		clear	
		echo "Feeds没有更新成功，重新执行代码" && Time
		update_feeds
	fi
}
############################  更新Feeds代码 ########################################

############################  安装Feeds代码 #########################################
install_feeds() {
	clear
	echo "---------------------------"
	echo "       安装Feeds代码"
	echo "---------------------------"
	./scripts/feeds install -a
	if [[ $? -eq 0 ]]; then
		echo ""
	else
		clear	
		echo "Feeds没有安装成功，重新执行代码" && Time
		update_feeds
	fi
}
############################  安装Feeds代码 ########################################

############################  测试编译环境 #########################################
make_defconfig() {
	clear
	echo "---------------------------"
	echo ""
	echo ""
	echo "       测试编译环境"
	echo ""
	echo ""
	echo "--------------------------"
		make defconfig
}
############################  测试编译环境 #########################################


source_make_clean() {
	clear
	echo "--------------------------------------------------------"
	echo -e "$green++是否执行make clean清理固件++$white"
	echo ""
	echo "  1.执行make clean"
	echo ""
	echo "  2.不执行make clean"
	echo ""
	echo -e "$yellow  温馨提醒make clean会清理掉之前编译的固件，为了编译成功 $white"
	echo -e "$yellow率建议执行make clean，虽然编译时间会比较久$white"
	echo "--------------------------------------------------------"
	read  -p "请输入你的参数(回车默认：make clean)：" mk_c
	if [[ -z "$mk_c" ]];then
		clear && echo -e "$green开始执行make clean $white"
		make clean
	else
		case "$mk_c" in
		1)
		clear && echo -e "$green开始执行make clean $white"
		make clean
		;;
		2)
		clear && echo -e "$green不执行make clean $white"
		;;
		*)
		clear && echo  "Error请输入正确的数字 [1-2]" && Time
		 clear && source_make_clean
		;;
	esac
	fi

}

#显示编译文件夹
ls_file() {
	LF=`ls $HOME/$OW | grep -v $0  | grep -v Script_File`
	echo -e "$green$LF$white"
	echo ""
}
ls_file_luci(){
	clear && cd
	echo "***你的openwrt文件夹有以下几个***"
	ls_file
	read -p "请输入你的文件夹（记得区分大小写）：" file
	if [[ -e $HOME/$OW/$SF/tmp ]]; then
		echo "$file" > $HOME/$OW/$SF/tmp/you_file
	else
		mkdir -p $HOME/$OW/$SF/tmp	
	fi
}

#显示config文件夹
ls_my_config() {
	LF=`ls My_config`
	echo -e "$green$LF$white"
	echo ""
}

#倒数专用
Time() {
	seconds_left=3
	echo ""
	echo "   ${seconds_left}秒以后执行代码"
	echo "   如果不需要执行代码以Ctrl+C 终止即可"
	echo ""
	while [[ ${seconds_left} -gt 0 ]]; do
		echo -n ${seconds_left}
		sleep 1
		seconds_left=$(($seconds_left - 1))
		echo -ne "\r     \r"
	done
}

#选项9.更新update_script
update_script() {
	clear
	cd $HOME/$OW/$SF/$OCS
	if [[ "$action1" == "" ]]; then
		git fetch --all
		git reset --hard origin/master
		if [[ $? -eq 0 ]]; then
			echo -e "$green>> 脚本源码更新成功回车进入编译菜单$white"
			read a
			bash $openwrt
		else
			echo -e "$red>> 脚本源码更新失败，重新执行代码$white"
			update_script
		fi
	else
		git fetch --all
		git reset --hard origin/master
		if [[ $? -eq 0 ]]; then
			echo -e "$green>> 脚本源码更新成功$white"
		else
			echo -e "$red>> 脚本源码更新失败，重新执行代码$white"
			update_script
		fi
	fi
}

#主菜单
main_num(){
	clear
printf "#######################################################################
#        Openwrt Compile Script for CentOS/RedHat 6+ Debian 7+        #
#      and Ubuntu 12+ Upgrade Software versions for version "$version"       #
#       For more information please visit https://guyezi.com          #
#######################################################################"
echo "---------------------------------"
echo "|************ 主菜单 ************|"
echo "---------------------------------"
echo ""
echo -e "  $green  1$white. 搭建编译环境（需管理权限）"
echo ""
echo -e "  $green  2$white. 以源码编译固件"
echo ""
echo -e "  $green  3$white. 以ImageBuilder编译固件"
echo ""
echo -e "  $green  4$white. 以SDK编译插件"
echo ""
echo -e "  $green  5$white. 合并性编译固件"
echo ""
echo -e "  $green  6$white. 自定义下载插件"
echo ""
echo -e "  $green  7$white. 更新脚本"
#echo ""
#echo -e "  $green  U$white. 上一页"
#echo ""
#echo -e "  $green  D$white. 下一页"
echo ""
echo -e "  $green  E$white. 退出"
#echo ""
#echo -e "  $green  0$white. 主菜单"
echo ""
echo -e "$yellow PS:傻瓜式定制OpenWRT系统,以减少报错,按需要选择项目$blue"
read -p "输入选择：" main_num_1
	case $main_num_1 in
		1)
		  echo "环境搭建"
		  sysinstall
		  create_file
		  main_num
        ;;
        2)
          echo "以源码编译固件"
          source_download_openwrt
        ;;
        3)
        echo "以ImageBuilder编译固件"
        ;;
        4)
		echo "以SDK编译插件"
		;;
		5)
		echo "合并性编译固件"
		;;
		6)
		echo "自定义下载插件"
		;;
		7)
		echo "更新脚本"
		update_script
		;;
#		8)
#		echo "更新脚本"
#		;;
#		9)
#		echo "更新脚本"
#		;;
#		10)
#		echo "更新脚本"
#		;;
#		U)
#		echo "更新脚本"
#		;;
#		D)
#		echo "更新脚本"
#		;;
		E)
		echo "退出"
		exit
		#;;
		#0)
		#echo "主菜单"
		#main_num
		;;
		*)
	clear && echo  "请输入正确的数字 [1-4,0]" && Time
	main_num
	;;
esac
}

#搭建系统编译环境
#Install_SYS_Pat(){
#	System_info
#}
###main_num

########################### 

###### 准备下载源码 ############
source_download_openwrt() {
	clear
	printf "#######################################################################
#        Openwrt Compile Script for CentOS/RedHat 6+ Debian 7+        #
#      and Ubuntu 12+ Upgrade Software versions for version "$version"       #
#       For more information please visit https://guyezi.com          #
#######################################################################"
		clear
		echo ""
  		echo "	准备下载openwrt代码"
		echo ""
		echo -e "  $green  1$white. Lean_lede-17.01_source"
		echo ""
		echo -e "  $green  2$white. Lean_master_source"
		echo ""
		echo -e "  $green  3$white. Lienol(dev-19.07)_source"
		echo ""
		echo -e "  $green  4$white. openwrt17.1(stable version)_source"
		echo ""
		echo -e "  $green  5$white. openwrt18.6(stable version)_source"
		echo ""
		echo -e "  $green  6$white. openwrt19.7(stable version)_source"
		echo ""
		echo -e "  $green  7$white. openwrt19.7.7(stable version)_source"
		echo ""
		echo -e "  $green  U$white. 上一层"
		echo ""
		echo -e "  $green  D$white. 下一页"
		echo ""
		echo -e "  $green  E$white. 退出"
		echo ""
		echo -e "  $green  0$white. 主菜单"
		echo ""
		echo ""
		echo "  ----------------------------------------"
		read  -p "请输入你要下载的源代码:" Download_source_openwrt
			case "$Download_source_openwrt" in
				1)
				git clone -b lede-17.01 https://git.openwrt.org/openwrt/openwrt.git lede
				Opt_source_num_Setting
				;;
				2)
				git clone https://e.coding.net/guyezi/openwrt/lede.git lede
				Opt_source_num_Setting
				;;
				3)
				git clone https://e.coding.net/guyezi/mypackages/Lienol-openwrt.git lede
				Opt_source_num_Setting
				;;
				4)
				git clone -b lede-17.01 '$O_Sou_URL' lede
				Opt_source_num_Setting
				;;
				5)
				git clone -b openwrt-18.06 '$O_Sou_URL' lede
				Opt_source_num_Setting
				;;
				6)
				git clone -b openwrt-19.07 '$O_Sou_URL' lede
				Opt_source_num_Setting
				;;
				7)
				git clone -b openwrt-19.7.7 '$O_Sou_URL' lede
				Opt_source_num_Setting
				;;
				U)
				main_num
				;;
				D)
				source_download_openwrt1
				;;
				E)
				exit
				;;
				0)
				main_num
				;;
				*)
				clear && echo  "请输入正确的数字（1-6，0）" && Time
				source_download_openwrt
				 ;;
			esac
		}

source_download_openwrt1() {
	clear
	printf "#######################################################################
#        Openwrt Compile Script for CentOS/RedHat 6+ Debian 7+        #
#      and Ubuntu 12+ Upgrade Software versions for version "$version"       #
#       For more information please visit https://guyezi.com          #
#######################################################################"
		clear
		echo ""
  		echo "	准备下载openwrt代码"
		echo ""
		echo -e "  $green  1$white. openwrt21.02(stable version)_source"
		echo ""
		echo -e "  $green  2$white. openwrt21.02(master version)_source"
		echo ""
		echo -e "  $green  3$white. openwrt(Trunk)_source"
		echo ""
		echo -e "  $green  U$white. 上一页"
		echo ""
		#echo -e "  $green  9$white. 下一页"
		#echo ""
		echo -e "  $green  E$white. 退出"
		echo ""
		echo -e "  $green  0$white. 主菜单"
		echo ""
		echo ""
		echo "  ----------------------------------------"
		read  -p "请输入你要下载的源代码:" Download_source_openwrt_1
			case "$Download_source_openwrt_1" in
				1)
				git clone -b openwrt-21.02 '$O_Sou_URL' lede
				Opt_source_num_Setting
				;;
				2)
				git clone -b openwrt-21.02 '$O_Sou_URL' lede
				Opt_source_num_Setting
				;;				
				8)
				git clone -b openwrt-19.07.7 '$O_Sou_URL' lede
				Opt_source_num_Setting
				;;
				9)
				git clone -b openwrt-21.02 '$O_Sou_URL' lede
				Opt_source_num_Setting
				;;
				U)
				source_download_openwrt
				;;
			#	D)
			#	Opt_source_num_Setting
			#	;;
				E)
				echo "退出"
				exit
				;;
				0)
				main_num
				;;
				*)
				clear && echo  "请输入正确的数字（1-6，0）" && Time
				source_download_openwrt1
				 ;;
			esac
		}

#定义优化项目
Opt_source_num_Setting(){
	clear
printf "#######################################################################
#        Openwrt Compile Script for CentOS/RedHat 6+ Debian 7+        #
#      and Ubuntu 12+ Upgrade Software versions for version "$version"       #
#       For more information please visit https://guyezi.com          #
#######################################################################"
echo "---------------------------------"
echo "|********** 自定义优化 **********|"
echo "---------------------------------"
echo ""
echo -e "  $green  1$white. 添加upx的编译($yellow PS:添加upx是为了减少插件的体积$blue）"
echo ""
echo -e "  $green  2$white. 修改默认网关地址"
echo ""
echo -e "  $green  3$white. 添加默认访问密码"
echo ""
echo -e "  $green  4$white. 开启DHCP自动ip分配"
echo ""
echo -e "  $green  5$white. 修改"
echo ""
echo -e "  $green  6$white. 自定义下载插件"
echo ""
echo -e "  $green  7$white. 更新脚本"
echo ""
echo -e "  $green  U$white. 上一页"
echo ""
echo -e "  $green  D$white. 下一页"
echo ""
echo -e "  $green  E$white. 退出"
echo ""
echo -e "  $green  0$white. 主菜单"
echo ""
echo -e "$yellow PS:傻瓜式定制OpenWRT系统,以减少报错,按需要选择项目$blue"
read -p "输入选择：" Opt_source_num
	case $Opt_source_num in
		1)		  
		  if [[ $(grep -o "upx" tools/Makefile | wc -l)  == "1" ]]; then
			echo "正在添加"
		else
			#sed -i '28 a\tools-y += ucl upx' tools/Makefile
			sed -i 's/zlib zstd/zlib zstd ucl upx/' $HOME/$OW/$file/lede/tools/Makefile 
			sed -i '40 a\$(curdir)/upx/compile := $(curdir)/ucl/compile' $HOME/$OW/$file/lede/tools/Makefile 
			git clone https://github.com/guyezi/openwrt-upx.git  $HOME/$OW/$file/lede/tools/upx
			git clone https://github.com/guyezi/openwrt-ucl.git  $HOME/$OW/$file/lede/tools/ucl
		 fi
		 echo "已添加 UPX 完成" && clear
		 Opt_source_num_Setting
        ;;
        2)
          echo "修改默认网关地址" 
        ;;
        3)
        echo "添加默认访问密码"
        ;;
        4)
		echo "开启DHCP自动ip分配"
		;;
		5)
		echo "修改"
		;;
		6)
		echo "修改"
		;;
		7)
		echo "修改"
		update_script
		;;
		U)
		echo "上一页"
		clean
		source_download_openwrt
		;;
		D)
		echo "下一页"
		clean
		Opt_source_num_Setting1
		;;
		E)
		echo "退出"
		exit
		;;
		0)
		#echo "主菜单"
		main_num
		;;
		*)
	clear && echo  "请输入正确的数字 [1-7,U,D,E,0]" && Time
	Opt_source_num_Setting
	;;
esac
}
