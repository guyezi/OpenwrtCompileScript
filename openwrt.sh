#!/bin/bash
#=======================================#
#                   #
#                   #
#                   #
#                   #
#                   #
#=======================================#

### 变量预设
url=http://www.guyezi.com
O_Sou_URL='https://git.openwrt.org/openwrt/openwrt.git'

version="21.3"
SF="Script_File"
OW="Openwrt"
by="guyezi"
OCS="OpenwrtCompileScript"
cpu_cores=$(cat /proc/cpuinfo | grep processor | wc -l)
user='$whoami'

#openwrt
O_R17="17.01.7"
O_R17S="17.01.7-SNAPSHOT"
O_R18="18.06.9"
O_R18S="18.06-SNAPSHOT"
O_R19="19.07.7"
O_R19S="19.07-SNAPSHOT"
O_R21="21.02"
O_R21S="21.02-SNAPSHOT"

#颜色调整参考wen55333
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"

calculating_time_start() {
  startTime=$(date +%Y%m%d-%H:%M:%S)
  startTime_s=$(date +%s)
}

calculating_time_end() {
  endTime=$(date +%Y%m%d-%H:%M:%S)
  endTime_s=$(date +%s)
  sumTime=$(($endTime_s - $startTime_s))
  echo ""
  echo -e "$yellow开始时间:$green $startTime ---> $yellow结束时间:$green $endTime" "$yellow耗时:$green $sumTime 秒$white"
}

prompt() {
  echo -e "$green  脚本问题反馈：https://github.com/openwrtcompileshell/OpenwrtCompileScript/issues或者加群反馈(群在github有)$white"
  echo -e " $yellow温馨提示，最近的编译依赖有变动，如果你最近一直编译失败，建议使用脚本5.其他选项 --- 1.只搭建编译环境功能 $white"
}

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
  read -p "请输入你的参数(回车默认：make clean)：" mk_c
  if [[ -z "$mk_c" ]]; then
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
      clear && echo "Error请输入正确的数字 [1-2]" && Time
      clear && source_make_clean
      ;;
    esac
  fi

}

#显示编译文件夹
ls_file() {
  LF=$(ls $HOME/$OW | grep -v $0 | grep -v Script_File)
  echo -e "$green$LF$white"
  echo ""
}
ls_file_luci() {
  clear && cd
  echo "***你的openwrt文件夹有以下几个***"
  ls_file
  read -p "请输入你的文件夹（记得区分大小写）：" file
  if [[ -e $HOME/$OW/$SF/tmp ]]; then
    echo "$file" >$HOME/$OW/$SF/tmp/you_file
  else
    mkdir -p $HOME/$OW/$SF/tmp
  fi
}

#显示config文件夹
ls_my_config() {
  LF=$(ls My_config)
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
    echo -ne "\r"
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
    echo "Feeds没有更新或安装成功，重新执行代码" && Time
    update_feeds
  fi
}

install_feeds() {
  clear
  echo "---------------------------"
  echo "      安装Feeds代码"
  echo "---------------------------"
  ./scripts/feeds install -a
  if [[ $? -eq 0 ]]; then
    echo ""
  else
    clear
    echo "Feeds没有更新或安装成功，重新执行代码" && Time
    install_feeds
  fi
}

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

#选项5.其他选项
other() {
  clear
  echo "        -------------------------------------"
  echo "              【 5.其他选项 】"
  echo ""
  echo "      1 只搭建编译环境，不进行编译"
  echo ""
  echo "      2 单独Download DL库 "
  echo ""
  echo "      3 更新lean软件库 "
  echo ""
  echo "      4 下载额外的插件 "
  echo ""
  echo "      0. 回到上一级菜单"
  echo ""
  echo ""
  echo "    PS:请先搭建好梯子再进行编译，不然很慢！"
  echo "           By:孤爺仔"
  echo "        --------------------------------------"
  read -p "请输入数字:" other_num
  case "$other_num" in
  1)
    clear
    echo "5.1 只搭建编译环境，不进行编译 " && Time
    update_system
    echo "环境搭建完成，请自行创建文件夹和git"
    ;;
  2)
    ls_file_luci
    dl_other
    ;;
  3)
    update_lean_package
    ;;
  4)
    download_package
    ;;
  0)
    main_interface
    ;;
  *)
    clear && echo "请输入正确的数字 [1-4,0]" && Time
    other
    ;;
  esac
}

dl_other() {
  dl_download
  if [[ $? -eq 0 ]]; then
    echo ""
    echo -e ">>$green dl已经单独下载完成$white"
  else
    clear
    echo -e "$red dl没有下载成功,重新执行下载代码 $white" && Time
    dl_other
  fi

}

update_lean_package() {
  ls_file_luci
  source_make_clean
  rm -rf package/lean
  source_openwrt_Setting
  echo "插件下载完成"
  Time
  display_git_log_luci
  update_feeds
  source_config
}

download_package() {
  ls_file_luci
  if [[ -e package/Extra-plugin ]]; then
    echo ""
  else
    mkdir $HOME/$OW/$file/lede/package/Extra-plugin
  fi
  download_package_luci

}

download_package2() {
  cd $HOME/$OW/$file/lede
  rm -rf ./tmp
  display_git_log_luci
  update_feeds
  source_config
}

download_package_luci() {
  cd $HOME/$OW/$file/lede/package/Extra-plugin
  clear
  echo "        -------------------------------------"
  echo "              【 5.4额外的插件 】"
  echo ""
  echo "      1. luci-theme-argon"
  echo ""
  echo "      2. luci-app-oaf （测试中）"
  echo ""
  echo "      3. luci-app-bypass"
  echo ""
  echo "      4. luci-app-fileassistant"
  echo ""
  echo "      5. luci-app-filebrowser"
  echo ""
  echo "      6. luci-app-jd-dailybonus"
  echo ""
  echo "      7. luci-app-ssr-plus"
  echo ""
  echo "      8. luci-app-bypass"
  echo ""
  echo "      9. luci-app-bypass"
  echo ""
  echo "      10. luci-app-bypass"
  echo ""
  echo "      11. luci-app-bypass"
  echo ""
  echo "      12. luci-app-bypass"
  echo ""
  echo "      13. luci-app-bypass"
  echo ""
  echo "      14. luci-app-bypass"
  echo ""
  echo "      15. luci-app-bypass"
  echo ""
  echo "      16. luci-app-bypass"
  echo ""
  echo "      99. 自定义下载插件 "
  echo ""
  echo "      0. 回到上一级菜单"
  echo ""
  echo "    PS:如果你有什么好玩的插件，可以提交给我"
  echo "        --------------------------------------"
  read -p "请输入数字:" download_num
  case "$download_num" in
  1)
    git clone https://github.com/jerrykuku/luci-theme-argon.git
    ;;
  2)
    git clone https://github.com/destan19/OpenAppFilter.git
    ;;
  3)
    git clone http://192.168.1.13:3000/guyezi/luci-app-bypass.git
    ;;
  4)
    git clone http://192.168.1.13:3000/guyezi/luci-app-fileassistant.git
    ;;
  5)
    git clone -b v2.12.1 http://192.168.1.13:3000/guyezi/openwrt-filebrowser-go.git $HOME/$OW/$file/lede/package/Extra-plugin/filebrowser
    git clone http://192.168.1.13:3000/guyezi/luci-app-filebrowser-go.git $HOME/$OW/$file/lede/package/Extra-plugin/luci-app-filebrowser-go
    ;;
  6)
    git clone http://192.168.1.13:3000/guyezi/luci-app-jd-dailybonus.git
    ;;
  7)
    git clone http://192.168.1.13:3000/guyezi/helloworld.git $HOME/$OW/$file/lede/package/Extra-plugin/ssr
    rm -rf $HOME/$OW/$file/lede/package/Extra-plugin/ssr/xray-core
    #;;
    #8)
    #git clone http://192.168.1.13:3000/guyezi/luci-app-bypass.git
    #;;
    #9)
    #git clone http://192.168.1.13:3000/guyezi/luci-app-bypass.git
    #;;
    #10)
    #git clone http://192.168.1.13:3000/guyezi/luci-app-bypass.git
    #;;
    #11)
    #git clone http://192.168.1.13:3000/guyezi/luci-app-bypass.git
    #;;
    #12)
    #git clone http://192.168.1.13:3000/guyezi/luci-app-bypass.git
    #;;
    #13)
    #git clone http://192.168.1.13:3000/guyezi/luci-app-bypass.git
    #;;
    #14)
    #git clone http://192.168.1.13:3000/guyezi/luci-app-bypass.git
    #;;
    #15)
    #git clone http://192.168.1.13:3000/guyezi/luci-app-bypass.git
    #;;
    #16)
    #git clone http://192.168.1.13:3000/guyezi/luci-app-bypass.git
    ;;
  99)
    download_package_customize
    ;;
  0)
    other
    ;;
  *)
    clear && echo "请输入正确的数字 [1-2,99,0]" && Time
    download_package_luci
    ;;
  esac
  if [[ $? -eq 0 ]]; then
    download_package_customize_Decide
  else
    clear
    echo -e "没有下载成功或者插件已经存在，请检查$red package/Extra-plugin $white里面是否已经存在" && Time
    download_package_customize
  fi
}

download_package_customize() {
  cd $HOME/$OW/$file/lede/package/Extra-plugin
  clear
  echo "--------------------------------------------------------------------------------"
  echo "自定义下载插件"
  echo ""
  echo -e " $green例子：git clone https://github.com/destan19/OpenAppFilter.git   (此插件用于过滤应用)$white"
  echo "--------------------------------------------------------------------------------"
  echo ""
  read -p "请输入你要下载的插件地址：" download_url
  $download_url
  if [[ $? -eq 0 ]]; then
    cd $HOME/$OW/$file/lede
  else
    clear
    echo -e "没有下载成功或者插件已经存在，请检查$red package/Extra-plugin $white里面是否已经存在" && Time
    download_package_customize
  fi
  download_package_customize_Decide

}

download_package_customize_Decide() {
  echo "----------------------------------------"
  echo -e "$green是否需要继续下载插件$white"
  echo " 1.继续下载插件"
  echo " 2.不需要了"
  echo "----------------------------------------"
  read -p "请输入你的决定：" Decide
  case "$Decide" in
  1)
    cd $HOME/$OW/$file/lede/package/Extra-plugin
    download_package_luci
    ;;
  2)
    download_package2
    ;;
  *)
    clear && echo -e"$red Error请输入正确的数字 [1-2]$white" && Time
    clear && download_package_customize_Decide
    ;;
  esac
}

##安装编译环境
function install() {
  DW=$(cat '/proc/version' | grep -o 'Darwin')
  CT=$(cat '/proc/version' | grep -o "centos")
  UB=$(cat '/proc/version' | grep -o "ubuntu")
  WIN1=$(cat '/proc/version' | grep -o "Microsoft@Microsoft.com")
  WIN2=$(cat '/proc/version' | grep -o "microsoft-standard")
  DWOS='Darwin'
  CTOS="centos"
  UBOS="ubuntu"
  OS1="Microsoft@Microsoft.com"
  OS2="microsoft-standard"
  OS=($cat '/proc/version')

  if [[ $WIN1 =~ $OS1 ]]; then
    echo "Win10" && win10
  elif [[ $WIN2 =~ $OS2 ]]; then
    echo "Win10" && win10
  elif [[ $DW =~ $DWOS ]]; then
    echo -e "MAC OS X" && sudo port -y install coreutils e2fsprogs \
    ossp-uuid asciidoc binutils bzip2 fastjar flex getopt gtk2 \
    intltool jikes hs-zlib openssl p5-extutils-makemaker \
    python26 subversion rsync ruby sdcc unzip gettext \
    libxslt bison gawk autoconf wget gmake ncurses \
    findutils gnutar mpfr libmpc gcc49
    echo "搭建环境完成" && clear && description_if
  elif [[ $CT =~ $CTOS ]]; then
    echo -e "CentOS" && sudo yum update &&
      echo "搭建环境完成" && clear && description_if
  elif [[ $UB =~ $UBOS ]]; then
    echo "Ubuntu" && ubuntu
    echo "搭建环境完成" && description_if
  else
    echo $OS && clear && description_if
  fi
}

#判断代码
description_if() {
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
  workspace_home=$(echo "$HOME" | grep gitpod | wc -l)
  if [[ "$workspace_home" == "1" ]]; then
    echo "$yellow请注意云编译已经放弃维护很久了，不保证你能编译成功,太耗时耗力，你如果不信邪你可以回车继续$white"
    read a
    echo "开始添加云编译系统变量"
    Cloud_env=$(gp env | grep -o "shfile" | wc -l)
    if [[ "$Cloud_env" == "0" ]]; then
      eval $(gp env -e openwrt=$THEIA_WORKSPACE_ROOT/Openwrt/Script_File/OpenwrtCompileScript/openwrt.sh)
      eval $(gp env -e shfile=$THEIA_WORKSPACE_ROOT/Openwrt/Script_File/OpenwrtCompileScript)
      echo -e "系统变量添加完成，老样子启动  bash \$openwrt"
      Time
    fi
    HOME=$(echo "$THEIA_WORKSPACE_ROOT")
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
      rm -rf $(pwd)/$OCS
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
    rm -rf $(pwd)/$OCS
    cd $HOME/$OW/$SF/$OCS
    bash openwrt.sh
  fi

  clear
  if [[ -e $HOME/$OW/$SF/description ]]; then
    self_test
    menu
  else
    clear
    self_test
    menu
  fi
}

ubuntu() {
  if [[ -e /etc/apt/sources.list.back ]]; then
    clear && echo -e "$green源码已替换$white"
  else
    clear
    echo "-----------------------------------------------------------------"
    echo -e "+++检测到$green Ubuntu 系统$white+++"
    echo ""
    echo -e "  $green Ubuntu 系统已知问题"
    echo "     1.IO很慢，编译很慢，不怕耗时间随意"
    echo "     2.win10对大小写不敏感，你需要百度如何开启win10子系统大小写敏感"
    echo "     3.需要替换子系统的linux源（脚本可以帮你搞定）"
    echo "-----------------------------------------------------------------"
    echo ""
    read -p "是否替换软件源然后进行编译（1.yes，2.no）：" Ubuntu_select
    case "$Ubuntu_select" in
    1)
      clear
      echo -e "$green开始替换软件源$white" && Time
      #sudo cp  /etc/apt/sources.list /etc/apt/sources.list.back
      #sudo rm -rf /etc/apt/sources.list
      #sudo cp $HOME/$OW/$SF/$OCS/ubuntu18.4_sources.list /etc/apt/sources.list
      sudo apt-get update
      sudo apt-get install build-essential asciidoc binutils bzip2 \
      gawk gettext git libncurses5-dev libz-dev patch python3 \
      python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 \
      subversion flex uglifyjs git-core gcc-multilib p7zip \
      p7zip-full msmtp libssl-dev texinfo libglib2.0-dev \
      xmlto qemu-utils upx libelf-dev autoconf automake \
      libtool autopoint device-tree-compiler g++-multilib \
      antlr3 gperf wget curl swig rsync bison g++ gcc \
      help2man htop ncurses-term ocaml-nox sharutils \
      yui-compressor make cmake libncurses-dev unzip \
      python tree nano
      ;;
    2)
      clear
      echo "不做任何操作，即将进入主菜单" && Time
      ;;
    *)
      clear && echo "Error请输入正确的数字 [1-2]" && Time
      description_if
      ;;
    esac

  fi
}

centos() {
  if [[ -e /etc/yum.repos.dsources.list.back ]]; then
    clear && echo -e "$green源码已替换$white"
  else
    clear
    echo "-----------------------------------------------------------------"
    echo -e "+++检测到$green Centos 系统$white+++"
    echo ""
    echo -e "  $green Centos 系统已知问题"
    #echo "     1.IO很慢，编译很慢，不怕耗时间随意"
    #echo "     2.对大小写不敏感，你需要百度如何开启win10子系统大小写敏感"
    #echo "     3.需要替换子系统的linux源（脚本可以帮你搞定）"
    echo "-----------------------------------------------------------------"
    echo ""
    read -p "是否替换软件源然后进行编译（1.yes，2.no）：" Centos_select
    case "$Centos_select" in
    1)
      clear
      echo -e "$green开始替换软件源$white" && Time
      #sudo cp  /etc/apt/sources.list /etc/apt/sources.list.back
      #sudo rm -rf /etc/apt/sources.list
      #sudo cp $HOME/$OW/$SF/$OCS/ubuntu18.4_sources.list /etc/apt/sources.list
      yum update
      yum install -y gcc gcc-c++ kernel-devel python-mini \
      pciutils ncurses-devel asciidoc autoconf binutils bison \
      bzip2 flex gawk gettext git patch quilt subversion unzip \
      openssl-devel perl-XML-Parser zlib-devel libxslt xmlto \
      uglify-js xz nanotree nano tree
      yum -y install binutils bzip2 git \
      gcc gcc-c++ gawk gettext openssl-devel \
      flex ncurses ncurses-devel zlib-devel \
      zlib-static make patch unzip \
      perl-ExtUtils-MakeMaker glibc \
      glibc-devel glibc-static ncurses-libs \
      sed sdcc intltool sharutils bison wget \
      git-core openssl-devel xz nanotree nano tree
      ;;
    2)
      clear
      echo "不做任何操作，即将进入主菜单" && Time
      ;;
    *)
      clear && echo "Error请输入正确的数字 [1-2]" && Time
      description_if
      ;;
    esac

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
    read -p "是否替换软件源然后进行编译（1.yes，2.no）：" win10_select
    case "$win10_select" in
    1)
      clear
      echo -e "$green开始替换软件源$white" && Time
      sudo cp /etc/apt/sources.list /etc/apt/sources.list.back
      sudo rm -rf /etc/apt/sources.list
      sudo cp $HOME/$OW/$SF/$OCS/ubuntu18.4_sources.list /etc/apt/sources.list
      sudo apt-get update
      sudo apt-get install build-essential asciidoc binutils bzip2 \
      gawk gettext git libncurses5-dev libz-dev patch python3 \
      python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 \
      subversion flex uglifyjs git-core gcc-multilib p7zip \
      p7zip-full msmtp libssl-dev texinfo libglib2.0-dev \
      xmlto qemu-utils upx libelf-dev autoconf automake \
      libtool autopoint device-tree-compiler g++-multilib \
      antlr3 gperf wget curl swig rsync bison g++ gcc \
      help2man htop ncurses-term ocaml-nox sharutils \
      yui-compressor make cmake libncurses-dev unzip \
      python
      ;;
    2)
      clear
      echo "不做任何操作，即将进入主菜单" && Time
      ;;
    *)
      clear && echo "Error请输入正确的数字 [1-2]" && Time
      description_if
      ;;
    esac

  fi
}

create_file() {
  clear
  echo ""
  echo "----------------------------------------"
  echo "       开始创建文件夹"
  echo "----------------------------------------"
  echo ""
  read -p "请输入你要创建的文件夹名:" file

  if [[ -e $HOME/$OW/$file ]]; then
    clear && echo "文件夹已存在，请重新输入文件夹名" && Time
    cd $HOME/$OW/$file && clear
    echo "$file" >$HOME/$OW/$SF/tmp/you_file
  else
    echo "开始创建文件夹"
    mkdir $HOME/$OW/$file
    cd $HOME/$OW/$file && clear
    echo "$file" >$HOME/$OW/$SF/tmp/you_file
  fi
}

self_test() {
  clear
  CheckUrl_google=$(curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null www.google.com)

  if [[ "$CheckUrl_google" -eq "200" ]]; then
    Check_google=$(echo -e "$green网络正常$white")
  else
    Check_google=$(echo -e "$red网络较差$white")
  fi

  CheckUrl_gfwip=$(curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null www.google.com.hk)
  gfwip=$(curl -s --socks5 127.0.0.1:1088 https://ip8.com/ip)
  hostip=$(curl -s https://ip8.com/ip)
  if [[ "$CheckUrl_gfwip" -eq "200" ]]; then
    Check_gfwip=$(echo -e "$green$gfwip")
  else
    Check_gfwip=$(echo -e "$red$hostip$white")
  fi

  CheckUrl_baidu=$(curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null www.baidu.com)
  if [[ "$CheckUrl_baidu" -eq "200" ]]; then
    Check_baidu=$(echo -e "$green百度正常$white")
  else
    Check_baidu=$(echo -e "$red百度无法打开，请修复这个错误$white")
  fi

  Root_detection=$(id -u) # 学渣代码改良版
  if [[ "$Root_detection" -eq "0" ]]; then
    Root_run=$(echo -e "$red请勿以root运行,请修复这个错误$white")
  else
    Root_run=$(echo -e "$green非root运行$white")
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
  git_branch=$(git branch -v | grep -o 落后)
  if [[ "$git_branch" == "落后" ]]; then
    Script_status=$(echo -e "$red建议更新$white")
  else
    Script_status=$(echo -e "$green最新$white")
  fi

  echo "          -------------------------------------------"
  echo "              【  Script Self-Test Program  】"
  echo ""
  echo "      检测是否root运行:  $Root_run  "
  echo ""
  echo "        检测与DL网络情况： $Check_google "
  echo "  "
  echo "        检测梯子是否正常： $Check_gfwip "
  echo "  "
  echo "        检测百度是否正常： $Check_baidu "
  echo "  "
  echo "        检测脚本是否最新： $Script_status "
  echo "  "
  echo "          -------------------------------------------"
  echo ""
  echo -e "$green  脚本问题反馈：https://github.com/openwrtcompileshell/OpenwrtCompileScript/issues或者加群反馈(群在github有)$white"
  echo ""
  echo "  请自行决定是否修复红字的错误，以保证编译顺利，你也可以直接回车进入菜单，但有可能会出现编译失败！！！如果都是绿色正常可以忽略此段话"
  read a
}

to_file() {
  if [[ -e $HOME/$OW/$file ]]; then
    cd $HOME/$OW/$file/lede/
  fi
}

Upx_source_setting() {
  Upx_compile='$(curdir)/upx/compile := $(curdir)/ucl/compile'
  if [[ $(grep -o "upx" tools/Makefile | wc -l) == "1" ]]; then
    echo "正在添加upx"
  else
    #sed -i '28 a\tools-y += ucl upx' tools/Makefile
    sed -i 's#zlib zstd#zlib zstd ucl upx#g' $HOME/$OW/$file/lede/tools/Makefile
    #sed -i '40i\\$Upx_compile' $HOME/$OW/$file/lede/tools/Makefile
    echo $Upx_compile | sed -i "40i\\$Upx_compile" $HOME/$OW/$file/lede/tools/Makefile
    cd $HOME/$OW/$file/lede
    cat tools/Makefile | grep -n $Upx_compile
    git clone https://github.com/guyezi/openwrt-upx.git $HOME/$OW/$file/lede/tools/upx
    git clone https://github.com/guyezi/openwrt-ucl.git $HOME/$OW/$file/lede/tools/ucl
  fi
  echo "添加 UPX 完成" && clear && source_openwrt_setting
}

Ip_source_setting() {
  clear
  m=$(echo $openwrt_ip | sed 's/[0-9.]//g')
  n=$(echo $openwrt_ip | sed 's/[0-9]//g' | wc -c)
  n1=$(echo $openwrt_ip | cut -d'.' -f1)
  n2=$(echo $openwrt_ip | cut -d'.' -f2)
  n3=$(echo $openwrt_ip | cut -d'.' -f3)
  n4=$(echo $openwrt_ip | cut -d'.' -f4)
  q=$(echo $openwrt_ip | sed 's/[q]//g')
  printf "
#############################################################
# Openwrt Compile Script for CentOS/RedHat 6+ Debian 7+ #
# Ubuntu 12+ Upgrade Software versions for version "$version"#
# For more information please visit https://guyezi.com  #
#############################################################
"
  echo "-------------------------------------"
  echo "|********** 正在修改网关IP **********|"
  echo "|********* 退出请输入【 q 】  *********|"
  echo "-------------------------------------"
  echo ""
  if [[ $(grep -o "192.168.1.1" package/base-files/files/bin/config_generate | wc -l) == "1" ]]; then
    while :; do
      read -p "请输入修改网关的IP地址:" openwrt_ip
      if [ -z $m ] && [ $n -eq 4 ] && [ -n $n1 ] && [ -n $n2 ] && [ -n $n3 ] && [ -n $n4 ] && [ -eq $q ]; then
        if [ $q =~ 'q' ]; then
          source_openwrt_setting
        else
          if [ $n1 -ge 0 ] && [ $n1 -le 255 ] && [ $n2 -ge 0 ] && [ $n2 -le 255 ] && [ $n3 -ge 0 ] && [ $n3 -le 255 ] && [ $n4 -ge 0 ] && [ $n4 -le 255 ]; then
            echo -e "${openwrt_ip} ip正确" && sed -i "s/192.168.1.1/${openwrt_ip}/g" $HOME/$OW/$file/lede/package/base-files/files/bin/config_generate && sed -i 's/192.168.1.1/${openwrt_ip}/g' $HOME/$OW/$file/lede/package/base-files/image-config.in
            cat $HOME/$OW/$file/lede/package/base-files/files/bin/config_generate | grep -n ${openwrt_ip} && echo "默认网关IP以改为 ${openwrt_ip}"
            Broadcast_source_setting
          else
            echo "你输入的ip错误，请重新输入"
          fi
        fi
        echo "你输入的ip错误，请重新输入"
      fi
    done
  fi
}

Broadcast_source_setting() {
  clear
  m=$(echo $broadcast_ip | sed 's/[0-9.]//g')
  n=$(echo $broadcast_ip | sed 's/[0-9]//g' | wc -c)
  n1=$(echo $broadcast_ip | cut -d'.' -f1)
  n2=$(echo $broadcast_ip | cut -d'.' -f2)
  n3=$(echo $broadcast_ip | cut -d'.' -f3)
  n4=$(echo $broadcast_ip | cut -d'.' -f4)
  q=$(echo $broadcast_ip | sed 's/[q]//g')
  printf "
#############################################################
# Openwrt Compile Script for CentOS/RedHat 6+ Debian 7+ #
# Ubuntu 12+ Upgrade Software versions for version "$version"#
# For more information please visit https://guyezi.com  #
#############################################################
"
  echo "-----------------------------------------"
  echo "|**********正在修改广播[IP]地址**********|"
  echo "|**********  退出请输入【 q 】   **********|"
  echo "-----------------------------------------"
  echo ""
  if [[ $(grep -o "192.168.1.255" package/base-files/image-config.in | wc -l) == "1" ]]; then
    while :; do
      read -p "请输入修改广播的IP地址:" broadcast_ip
      if [ -z $m ] && [ $n -eq 4 ] && [ -n $n1 ] && [ -n $n2 ] && [ -n $n3 ] && [ -n $n4 ] && [ -eq $q ]; then
        if [ $q =~ 'q' ]; then
          Ip_source_setting
        else
          if [ $n1 -ge 0 ] && [ $n1 -le 255 ] && [ $n2 -ge 0 ] && [ $n2 -le 255 ] && [ $n3 -ge 0 ] && [ $n3 -le 255 ] && [ $n4 -ge 0 ] && [ $n4 -le 255 ]; then
            echo -e "${broadcast_ip} ip正确" && sed -i "s/192.168.1.1/${broadcast_ip}/g" $HOME/$OW/$file/lede/package/base-files/image-config.in
            cat $HOME/$OW/$file/lede/package/base-files/files/bin/config_generate | grep -n ${broadcast_ip} && echo "默认广播IP以改为 ${broadcast_ip}"
            source_openwrt_setting
          else
            echo "你输入的广播ip错误，请重新输入"
          fi
        fi
        echo "你输入的广播ip错误，请重新输入"
      fi
    done
  fi
}

repository_source_setting() {
  clear
  repository_def="downloads.openwrt.org"
  repository_add="mirrors.cloud.tencent.com/lede"
  if [[ $(grep -o $repository_def package/base-files/image-config.in | wc -l) == "1" ]]; then
    echo ""
  else
    echo -e "$repository_add" && sed -i "s/$repository_def/$repository_add/g" $HOME/$OW/$file/lede/package/base-files/image-config.in
  fi
  echo "修改repository完成" && clear && source_openwrt_setting
}
Time_source_setting() {
  clear
  TimeZone="set system.@system[-1].zonename='Asia/Shanghai'"
  if [[ $(grep -o "UTC" package/base-files/files/etc/init.d/system | wc -l) == "1" ]]; then
    echo "正在修改时区"
  else
    sed -i "/UTC'/a \\$TimeZone" $HOME/$OW/$file/lede/package/base-files/files/bin/config_generate
    cat $HOME/$OW/$file/lede/package/base-files/files/bin/config_generate | grep -n 'Asia/Shanghai'
    sed -i "s/timezone='UTC/timezone='CST-8/g" $HOME/$OW/$file/lede/package/base-files/files/bin/config_generate
    cat $HOME/$OW/$file/lede/package/base-files/files/bin/config_generate | grep -n "CST-8"
  fi
  echo "修改时区完成" && clear && source_openwrt_setting
}

#Passwd_source_setting(){
#  clear
#  echo -n ${root_passwd}｜md5sum && sed -i "s#root:#root:$1${root_passwd}#g"
#}
#rootfs_setting(){}
system_setting() {
  clear
  #root_passwd='$1$XxDu6KOc$GxuZ/R0J2syD0eoxCW.by0'
  sed -i "s/DISTRIB_DESCRIPTION.*/DISTRIB_DESCRIPTION='%D %V %C by Guyezi'/g" package/base-files/files/etc/openwrt_release
  rm -rf $HOME/$OW/$file/lede/package/base-files/files/etc/banner
  wget -P $HOME/$OW/$file/lede/package/base-files/files/etc/ https://www.guyezi.com/banner
  sed -i 's/root::0:0:99999:7:::/root:$1$XxDu6KOc$GxuZ/R0J2syD0eoxCW.by0:0:0:99999:7:::/g' $HOME/$OW/$file/lede/package/base-files/files/etc/shadow
  source_openwrt_setting
}

source_openwrt_setting() {
  clear
  printf "
#############################################################
# Openwrt Compile Script for CentOS/RedHat 6+ Debian 7+ #
# Ubuntu 12+ Upgrade Software versions for version "$version"#
# For more information please visit https://guyezi.com  #
#############################################################
"
  echo "---------------------------------"
  echo "|**********自定义优化一**********|"
  echo "---------------------------------"
  echo ""
  echo -e "  $green  1$white. 添加ucl & upx支持($yellow PS:添加upx是为了减少插件的体积$blue）"
  echo ""
  echo -e "  $green  2$white. 修改默认网关地址"
  echo ""
  echo -e "  $green  3$white. 添加默认访问密码"
  echo ""
  echo -e "  $green  4$white. 开启DHCP自动ip分配"
  echo ""
  echo -e "  $green  5$white. 修改时区"
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
  read -p "输入选择：" Source_openwrt_setting_select
  case $Source_openwrt_setting_select in
  1)
    echo "添加ucl upx" && Upx_source_setting
    source_openwrt_setting
    ;;
  2)
    echo "修改默认网关IP地址" && Ip_source_setting
    source_openwrt_setting
    ;;
  3)
    echo "添加默认访问密码"
    #Passwd_source_setting
    system_setting
    ;;
  4)
    echo "开启DHCP自动ip分配"
    source_openwrt_setting
    ;;
  5)
    echo "修改时区" && Time_source_setting
    source_openwrt_setting
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
    source_openwrt_setting
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
    clear && echo "请输入正确的数字 [1-7,U,D,E,0]" && Time
    source_openwrt_setting
    ;;
  esac
}

source_openwrt_setting1() {
  clear
  printf "
#############################################################
# Openwrt Compile Script for CentOS/RedHat 6+ Debian 7+ #
# Ubuntu 12+ Upgrade Software versions for version "$version"#
# For more information please visit https://guyezi.com  #
#############################################################
"
  echo "---------------------------------"
  echo "|**********自定义优化二**********|"
  echo "---------------------------------"
  echo ""
  echo -e "  $green  1$white. 修改ROOTFS空间容量($yellow PS:紧x86有效$blue）"
  echo ""
  echo -e "  $green  2$white. 修改默认网关地址"
  echo ""
  echo -e "  $green  3$white. 添加默认访问密码"
  echo ""
  echo -e "  $green  4$white. 开启DHCP自动ip分配"
  echo ""
  echo -e "  $green  5$white. 修改UTC+8时区"
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
  read -p "输入选择：" Source_openwrt_setting1_select
  case $Source_openwrt_setting1_select in
  1)
    echo "修改ROOTFS空间容量" && rootfs_setting
    source_openwrt_setting1
    ;;
  2)
    echo "修改默认网关地址" && Time_source_setting
    source_openwrt_setting
    ;;
  3)
    echo "添加默认访问密码"
    ;;
  4)
    echo "开启DHCP自动ip分配"
    ;;
  5)
    echo "修改" && Time_source_setting
    source_openwrt_setting
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
    source_openwrt_setting
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
    clear && echo "请输入正确的数字 [1-7,U,D,E,0]" && Time
    source_openwrt_setting
    ;;
  esac
}

###### 准备下载源码 ############
source_download_openwrt() {
  clear
  printf "
#############################################################
# Openwrt Compile Script for CentOS/RedHat 6+ Debian 7+ #
# Ubuntu 12+ Upgrade Software versions for version '$version'#
# For more information please visit https://guyezi.com  #
#############################################################
"

  clear
  echo ""
  echo "  准备下载openwrt代码"
  echo ""
  echo -e "  $green  1$white. Lean_lede-source"
  echo ""
  echo -e "  $green  2$white. Lienol19.07_source"
  echo ""
  echo -e "  $green  3$white. Lienol21.02_source"
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
  read -p "请输入你要下载的源代码:" Source_openwrt_select
  case "$Source_openwrt_select" in
  1)
    create_file
    git clone https://github.com/coolsnowwolf/lede.git lede
    to_file
    system_setting
    source_openwrt_setting
    ;;
  2)
    create_file
    git clone -b 19.07 https://github.com/Lienol/openwrt.git lede
    to_file
    system_setting
    source_openwrt_setting
    ;;
  3)
    create_file
    git clone -b 21.02 https://github.com/Lienol/openwrt.git lede
    to_file
    system_setting
    source_openwrt_setting
    ;;
  4)
    create_file
    git clone -b lede-17.01 $O_Sou_URL lede
    to_file
    system_setting
    source_openwrt_setting
    ;;
  5)
    create_file
    git clone -b openwrt-18.06 $O_Sou_URL lede
    to_file
    system_setting
    source_openwrt_setting
    ;;
  6)
    create_file
    git clone -b openwrt-19.07 $O_Sou_URL lede
    to_file
    system_setting
    source_openwrt_setting
    ;;
  7)
    create_file
    git clone -b openwrt-19.7.7 $O_Sou_URL lede
    to_file
    system_setting
    source_openwrt_setting
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
    clear && echo "请输入正确的数字（1-6，0）" && Time
    source_download_openwrt
    ;;
  esac
}
source_download_openwrt1() {
  clear
  printf "
#############################################################
# Openwrt Compile Script for CentOS/RedHat 6+ Debian 7+ #
# Ubuntu 12+ Upgrade Software versions for version '$version'#
# For more information please visit https://guyezi.com  #
#############################################################
"
  clear
  echo ""
  echo "  准备下载openwrt代码"
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
  read -p "请输入你要下载的源代码:" Download_source_openwrt_1
  case "$Download_source_openwrt_1" in
  1)
    create_file
    git clone -b openwrt-21.02 $O_Sou_URL lede
    to_file
    system_setting
    source_openwrt_setting
    ;;
  2)
    create_file
    git clone -b openwrt-21.02 $O_Sou_URL lede
    to_file
    system_setting
    source_openwrt_setting
    ;;
  3)
    create_file
    git clone -b openwrt-19.07.7 $O_Sou_URL lede
    to_file
    system_setting
    source_openwrt_setting
    ;;
  4)
    create_file
    git clone -b openwrt-21.02 $O_Sou_URL lede
    to_file
    system_setting
    source_openwrt_setting
    ;;
  U)
    source_download_openwrt
    ;;
    # D)
    # Opt_source_num_Setting
    # ;;
  E)
    echo "退出"
    exit
    ;;
  0)
    main_num
    ;;
  *)
    clear && echo "请输入正确的数字（1-6，0）" && Time
    source_download_openwrt1
    ;;
  esac
}

##主菜单
function menu() {
  clear
  printf "
#############################################################
# Openwrt Compile Script for CentOS/RedHat 6+ Debian 7+ #
# Ubuntu 12+ Upgrade Software versions for version "$version"#
# For more information please visit https://guyezi.com  #
#############################################################
"
  printf "
*************************************
*       菜单          *
*                 *
*     1.搭建编译环境      *
*     2.源码版本编译      *
*     3.SDK编译插件     *
*     4.检测本机网络      *
*     5.检测脚本更新      *
*           0.退出          *
*************************************
"
  read -p "请输入您的选择: " choice
  case $choice in
  1)
    if [[ -e $HOME/$OW/$SF/$OCS ]]; then
      echo "存在"
    else
      cd $HOME/$OW/$SF/
      git clone https://github.com/openwrtcompileshell/OpenwrtCompileScript.git
      cd
      rm -rf $(pwd)/$OCS
      cd $HOME/$OW/$SF/$OCS
      bash openwrt.sh install
    fi
    ;;
  2)
    source_download_openwrt
    ;;
  3)
    remove
    ;;
  4)
    self_test
    ;;
  5)
    update_script
    ;;
  0)
    exit 0
    ;;
  esac
}

function main() {
  while true; do
    menu
  done
}

main

make_firmware_or_plugin() {
  clear
  calculating_time_start
  echo "----------------------------------------"
  echo "请选择编译固件 OR 编译插件"
  echo " 1.编译固件"
  echo " 2.编译插件"
  echo " 3.回退到加载配置选项（可以重新选择你的配置）"
  echo "----------------------------------------"
  read -p "请输入你的决定：" mk_value
  case "$mk_value" in
  1)
    make_compile_firmware
    ;;
  2)
    make_Compile_plugin
    ;;
  3)
    source_config
    ;;
  *)
    clear && echo "Error请输入正确的数字 [1-2]" && Time
    clear && make_firmware_or_plugin
    ;;
  esac
}

make_compile_firmware() {
  clear
  echo "--------------------------------------------------------"
  echo -e "$green++编译固件是否要使用多线程编译++$white"
  echo ""
  echo "  首次编译不建议-j，具体用几线程看你电脑j有机会编译失败,"
  echo "不懂回车默认运行make V=s"
  echo ""
  echo -e "多线程例子：$yellow make -j$cpu_cores V=s $white(黄色字体这段完整的输进去)"
  echo -e "温馨提醒你的cpu核心数为：$green $cpu_cores $white"
  echo ""
  echo -e "$red!!!请不要在输入参数这行直接输数字，把命令敲全，不懂就直接回车!!!$white"
  echo "--------------------------------------------------------"
  read -p "请输入你的参数(回车默认：make V=s)：" mk_f
  if [[ -z "$mk_f" ]]; then
    clear && echo "开始执行编译" && Time
    dl_download
    make V=s
  else
    dl_download
    clear
    echo -e "你输入的命令是：$green$mk_f$white"
    echo "准备开始执行编译" && Time
    $mk_f
  fi

  if [[ $? -eq 0 ]]; then
    n1_builder
    if_wo
    calculating_time_end
  else
    echo -e "$red>> 固件编译失败，请查询上面报错代码$white"
    make_continue_to_compile
  fi
  #by：BoomLee  ITdesk
}

if_wo() {
  if [[ $? -eq 0 ]]; then
    #复制编译好的固件过去
    workspace_if=$(echo $HOME | grep workspace | wc -l)
    if [[ "$workspace_if" == "1" ]]; then
      da=$(date +%Y%m%d)
      HOME=$(echo "$THEIA_WORKSPACE_ROOT")
      source_type=$(cat $HOME/$OW/$SF/tmp/source_type)
      you_file=$(cat $HOME/$OW/$SF/tmp/you_file)

      if [[ -e $HOME/bin ]]; then
        echo ""
      else
        mkdir -p $HOME/bin
      fi

      cd && cd $HOME
      \cp -rf $HOME/$OW/$you_file/lede/bin/targets/ $HOME/bin/$da-$source_type
      echo -e "本次编译完成的固件已经copy到$green $HOME/bin/$da-$source_type $white"
    fi
  else
    echo -e "$red>> 固件编译失败，请查询上面报错代码$white"
    make_continue_to_compile
  fi
}

n1_builder() {
  n1_img="$HOME/$OW/$file/lede/bin/targets/armvirt/64/[$(date +%Y%m%d)]-openwrt-armvirt-64-default-rootfs.tar.gz"
  builder_patch="$HOME/$OW/$SF/n1/N1_builder"

  if [[ -e $n1_img ]]; then
    echo -e "$green >>检测到N1固件，自动制作N1的OpenWRT镜像$white" && Time
    if [[ -e $HOME/$OW/$SF/n1 ]]; then
      echo ""
    else
      mkdir $HOME/$OW/$SF/n1
      n1_builder
    fi

    if [ ! -d $builder_patch/tmp ]; then
      mkdir -p $builder_patch/tmp
    else
      rm -rf $builder_patch/tmp/*
    fi

    if [[ -e $builder_patch ]]; then
      cd $builder_patch
      source_update_git_pull
    else
      git clone https://github.com/ITdesk01/N1_and_beikeyun-OpenWRT-Image-Builder.git $builder_patch
      ln -s $builder_patch $HOME/$OW/$file/lede/N1_builder && clear
    fi

    if [[ -e $builder_patch/armbian.img ]]; then
      echo -e "$green >>armbian.img存在，复制固件$white" && clear

      if [[ -e $builder_patch/openwrt.img ]]; then
        rm -rf $builder_patch/openwrt.img
        cp $n1_img $builder_patch/openwrt-armvirt-64-default-rootfs.tar.gz
      else
        cp $n1_img $builder_patch/openwrt-armvirt-64-default-rootfs.tar.gz
      fi

      cd $builder_patch
      sudo bash mk_n1_opimg.sh
      if [[ $? -eq 0 ]]; then
        echo ""
        echo -e "$green >>N1镜像制作完成,你的固件在：$builder_patch/tmp$white"
      else
        echo "$red >>N1固件制作失败，重新执行代码 $white" && Time
        n1_builder
      fi

    else
      clear
      echo -e "$yellow >>检查到没有armbian.img,请将你的armbian镜像放到：$builder_patch $white"
      echo -e "$green >>存放完成以后，回车继续制作N1固件$white"
      read a
      n1_builder
    fi

  else
    echo ""
  fi
}

make_Compile_plugin() {
  clear
  echo "--------------------------------------------------------"
  echo "编译插件"
  echo ""
  echo -e "$yellow例子：make package/插件名字/compile V=99$white"
  echo ""
  echo "PS:Openwrt首次git clone仓库不要用此功能，绝对失败!!!"
  echo "--------------------------------------------------------"
  read -p "请输入你的参数：" mk_p
  clear
  echo -e "你输入的参数是：$green$mk_p$white"
  echo "准备开始执行编译" && Time
  $mk_p

  if [[ $? -eq 0 ]]; then
    echo ""
    echo ""
    echo "---------------------------------------------------------------------"
    echo ""
    echo -e "  潘多拉编译完成的插件在$yellow/Openwrt/文件名/lede/bin/packages/你的平台/base$white,如果还是找不到的话，看下有没有报错，善用搜索 "
    echo ""
    echo "回车可以继续编译插件，或者Ctrl + c终止操作"
    echo ""
    echo "---------------------------------------------------------------------"
    read a
    make_Continue_compiling_the_plugin
    calculating_time_end
  else
    echo -e "$red>> 固件编译失败，请查询上面报错代码$white"
    make_continue_to_compile
  fi
  #by：$BY
}

make_Continue_compiling_the_plugin() {
  clear
  echo "----------------------------------------"
  echo "是否需要继续编译插件"
  echo " 1.继续编译插件"
  echo " 2.不需要了"
  echo "----------------------------------------"
  read -p "请输入你的决定：" mk_value
  case "$mk_value" in
  1)
    make_Compile_plugin
    ;;
  2)
    exit
    ;;
  *)
    clear && echo "Error请输入正确的数字 [1-2]" && Time
    clear && make_Continue_compiling_the_plugin
    ;;
  esac
}

make_continue_to_compile() {
  echo "---------------------------------------------------------------------"
  echo -e "你的编译出错了是否要继续编译"
  echo ""
  echo -e "$green 1.是（回到编译固件 OR 编译插件界面，直接选择编译固件还是插件即可）$white"
  echo ""
  echo -e "$red 2.否 （直接退出脚本）$white"
  echo ""
  echo ""
  prompt
  echo "---------------------------------------------------------------------"
  read -p "请输入你的决定:" continue_to_compile
  case "$continue_to_compile" in
  1)
    cd $HOME/$OW/$file/lede
    make_firmware_or_plugin
    ;;
  2)
    exit
    ;;
  *)
    clear && echo "Error请输入正确的数字 [1-2]" && Time
    clear && make_continue_to_compile
    ;;
  esac
}

#单独的命令模块
make_j() {
  dl_download
  calculating_time_start
  make -j$(nproc) V=s
  calculating_time_end
  n1_builder
}

new_source_make() {
  system_install
}

clean_make() {
  clear && echo -e "$green>>执行make clean$white"
  make clean
  noclean_make
}

noclean_make() {
  clear && echo -e "$green>>不执行make clean$white"
  source_config && make menuconfig && make_j
}

update_clean_make() {
  clear
  echo -e "$green>>文件夹:$action1 执行make clean$white"
  make clean && rm -rf .config && rm -rf ./tmp/ && rm -rf ./feeds
  echo -e "$green>>文件夹:$action1 执行git pull$white"
  source_update_No_git_pull
  echo -e "$green>>文件夹:$action1 执行常用设置$white"
  source_download_ok
  echo -e "$green>>文件夹:$action1 执行make menuconfig $white"
  make menuconfig
  echo -e "$green>>文件夹:$action1 执行make download 和make -j $white"
  make_j

  if [[ $? -eq 0 ]]; then
    echo ""
  else
    echo -e "$red>>文件夹:$action1 编译失败了，请检查上面的报错，然后重新进行编译 $white"
    echo ""
    echo -e "$green 可以采用以下命令重新进行编译"
    echo -e "$green bash \$openwrt $action1 make_j "
  fi
}

update_clean_make_kernel() {
  update_clean_make
  make kernel_menuconfig
  make_j
}

update_script_rely() {
  update_script
  install
  if [[ $? -eq 0 ]]; then
    echo -e "$green >>依赖安装完成 $white" && Time
  else
    clear
    echo -e "$red 依赖没有更新或安装成功，重新执行代码 $white" && Time
    update_script_rely
  fi
}

actions_openwrt() {
  HOME=$(pwd)
  file=lean
  if [[ ! -d "$HOME/$OW/$SF/$OCS" ]]; then
    echo -e "开始创建主文件夹"
    mkdir -p $HOME/$OW/$SF/dl
    mkdir -p $HOME/$OW/$SF/My_config
    mkdir -p $HOME/$OW/$SF/tmp
  fi

  echo "开始创建编译文件夹"
  mkdir $HOME/$OW/$file
  git clone http://192.168.1.13:3000/guyezi/lede.git $HOME/$OW/$file/lede
  cd $HOME/$OW/$file/lede
  source_download_ok
  make_j
}

file_help() {
  echo "---------------------------------------------------------------------"
  echo ""
  echo -e "$green用法: bash \$openwrt [文件夹] [命令] $white"
  echo -e "$green文件夹目录结构：$HOME/$OW/你的文件夹/lede $white"
  echo ""
  echo -e "$yellow可用命令：$white"
  echo -e "$green   make_j $white            执行make download 和make -j V=s "
  echo -e "$green   new_source_make $white   新建一个文件夹下载你需要的源码并进行编译 "
  echo -e "$green   clean_make $white        执行make clean清理一下源码然后再进行编译"
  echo -e "$green   noclean_make $white      不执行make clean清理一下源码然后再进行编译"
  echo -e "$green   update_clean_make $white 执行make clean 并同步最新的源码 再进行编译"
  echo -e "$green   update_clean_make_kernel $white 编译完成以后执行make kernel_menuconfig($red危险操作$white)"
  echo -e "$green   update_script $white     将脚本同步到最新"
  echo -e "$green   update_script_rely $white将脚本和源码依赖同步到最新"
  echo -e "$green   help $white 查看帮助"
  echo ""
  echo -e "$yellow例子： $white "
  echo -e "$green   bash \$openwrt help $white  查看帮助  "
  echo -e "$green   bash \$openwrt new_source_make $white  新建一个文件夹下载你需要的源码并进行编译  "
  echo -e "$green   bash \$openwrt update_script $white  将脚本同步到最新  "
  echo -e "$green   bash \$openwrt 你的文件夹  clean_make $white   清理编译文件，再重新编译  "
  echo -e "$green   bash \$openwrt 你的文件夹  update_clean_make $white 同步最新的源码清理编译文件再编译  "
  echo -e "$green   bash \$openwrt 你的文件夹  update_script_rely update_clean_make $white 脚本，源码依赖，源码同步最新，清理编译文件再编译  "
  echo ""
  echo "---------------------------------------------------------------------"

}

action1_if() {
  if [[ -e $HOME/$OW/$action1 ]]; then
    action2_if
  else
    echo ""
    echo -e "$red>>文件夹不存在，使用方法参考以下！！！$white"
    file_help
  fi
}

action2_if() {
  if [[ -z $action2 ]]; then
    echo ""
    echo -e "$red>>命令参数不能为空！$white"
    file_help
  else
    file=$action1
    cd $HOME/$OW/$file/lede
    rm -rf $HOME/$OW/$SF/tmp/*
    case "$action2" in
    make_j | new_source_make | clean_make | noclean_make | update_clean_make | update_clean_make_kernel | update_script_rely | n1_builder)
      $action2
      action3_if
      ;;
    *)
      echo ""
      echo -e "$red 命令不存在，使用方法参考以下！！！$white"
      file_help
      ;;
    esac
  fi
}

action3_if() {
  if [[ -z $action3 ]]; then
    echo ""
  else
    file=$action1
    cd $HOME/$OW/$file/lede
    rm -rf $HOME/$OW/$SF/tmp/*
    case "$action3" in
    make_j | new_source_make | clean_make | noclean_make | update_clean_make | update_clean_make_kernel | update_script_rely | n1_builder)
      $action3
      ;;
    *)
      echo ""
      echo -e "$red 命令不存在，使用方法参考以下！！！$white"
      file_help
      ;;
    esac
  fi
}

#copy  by:Toyo  modify:ITdesk
action1="$1"
action2="$2"
action3="$3"
if [[ -z $action1 ]]; then
  description_if
else
  case "$action1" in
  help)
    file_help
    ;;
  update_script)
    update_script
    ;;
  new_source_make)
    new_source_make
    ;;
  actions_openwrt)
    actions_openwrt
    ;;
  *)
    action1_if
    ;;
  esac
fi
