#! /bin/sh
SRC="src/"
DPKG="public_html/chonos/"

getLatest(){
    PACKAGE=$1
    LATEST_RELEASE_URL=$2
    FILENAME=$(echo "$LATEST_RELEASE_URL" | rev | cut -d "/" -f 1 | rev)
    GITREPO=$(echo $LATEST_RELEASE_URL | cut -d "/" -f 5)
    RELEASE=`echo $FILENAME | cut -d "." -f 1`

    if [ ! -d $SRC ]; then
        mkdir $SRC
    elif [ -d $SRC$GITREPO-$RELEASE ]; then
        rm -rf $SRC$GITREPO-$RELEASE
    fi

    if [ ! -f $SRC$FILENAME ]; then
        wget -P $SRC $LATEST_RELEASE_URL
    else
        local_modified_date=$(date -d "$(date -r $SRC$FILENAME '+%Y-%m-%d %H:%M:%S')" +%s)
        remote_release_date=$(date -d "$(curl -s https://api.github.com/repos/chon-group/$GITREPO/releases/latest | grep "published_at" | head -n 1 | awk -F': ' '{print $2}' | tr -d '",')" +%s)
        if [ "$remote_release_date" -gt "$local_modified_date" ]; then
            rm $SRC$FILENAME
            wget -P $SRC $LATEST_RELEASE_URL
        fi
    fi
    tar -xzf $SRC$FILENAME -C $SRC
   
    VERSION=`egrep "Version:" $SRC/$GITREPO-$RELEASE/DEBIAN/control | cut -d ":" -f 2 | xargs`
    mkdir -p $DPKG$PACKAGE
    rm $SRC$GITREPO-$RELEASE/*.md 2> /dev/null
    rm $SRC$GITREPO-$RELEASE/LICENCE 2> /dev/null
    dpkg-deb -b $SRC$GITREPO-$RELEASE/ $DPKG$PACKAGE/$PACKAGE-$VERSION.deb
}


getLatest "chonos-ddnsmng"              "https://github.com/chon-group/dpkg-chonos-ddnsmng/archive/refs/tags/ddnsmng-latest.tar.gz"
getLatest "chonos-log"                  "https://github.com/chon-group/dpkg-chonos-log/archive/refs/tags/log-latest.tar.gz"
getLatest "chonos-task"                 "https://github.com/chon-group/dpkg-chonos-task/archive/refs/tags/task-latest.tar.gz"
getLatest "javino"                      "https://github.com/chon-group/dpkg-javino/archive/refs/tags/javino-latest.tar.gz"
getLatest "chonos-embeddedmas"          "https://github.com/chon-group/dpkg-chonos-embeddedmas/archive/refs/tags/embeddedmas-latest.tar.gz"
getLatest "chonos-firmwaremng"          "https://github.com/chon-group/dpkg-chonos-firmwaremng/archive/refs/tags/firmwaremng-latest.tar.gz"
getLatest "chonos-sysconfig"            "https://github.com/chon-group/dpkg-chonos-sysconfig/archive/refs/tags/sysconfig-latest.tar.gz"
getLatest "chonide"                     "https://github.com/chon-group/dpkg-chonide/archive/refs/tags/chonide-latest.tar.gz"
getLatest "jason-cli"                   "https://github.com/chon-group/dpkg-jason/archive/refs/tags/jasoncli-latest.tar.gz"
getLatest "jacamo-cli"                  "https://github.com/chon-group/dpkg-jacamo/archive/refs/tags/jacamocli-latest.tar.gz"
getLatest "chonos-serial-port-emulator" "https://github.com/chon-group/dpkg-virtualport-driver/archive/refs/tags/dpkg-virtualport-driver-latest.tar.gz"
getLatest "chonos-network"              "https://github.com/chon-group/dpkg-chonos-network/archive/refs/tags/network-latest.tar.gz"
getLatest "chonos"                      "https://github.com/chon-group/dkpg-chonos/archive/refs/tags/chonos-latest.tar.gz"
getLatest "chonos-neighbors"            "https://github.com/chon-group/dpkg-chonos-neighbors/archive/refs/tags/neighbors-latest.tar.gz"
getLatest "chonos-cert"                 "https://github.com/chon-group/dpkg-chonos-cert/archive/refs/tags/cert-latest.tar.gz"
getLatest "contextnetserver-latest"     "https://github.com/chon-group/contextNetServer/archive/refs/tags/contextnetserver-latest.tar.gz"
getLatest "chonos-simulide"             "https://github.com/chon-group/dpkg-simulide/archive/refs/tags/simulide-latest.zip"

mkdir -p public_html/dists/chonos/main/binary-i386

cd public_html

dpkg-scanpackages chonos/ /dev/null | gzip -9c > dists/chonos/main/binary-i386/Packages.gz
dpkg-scanpackages chonos/ /dev/null > dists/chonos/main/binary-i386/Release

mkdir -p dists/chonos/main/binary-all
cp dists/chonos/main/binary-i386/* dists/chonos/main/binary-all/

mkdir -p dists/chonos/main/binary-amd64
cp dists/chonos/main/binary-i386/* dists/chonos/main/binary-amd64/

mkdir -p dists/chonos/main/binary-arm64
cp dists/chonos/main/binary-i386/* dists/chonos/main/binary-arm64/

mkdir -p dists/chonos/main/binary-armhf
cp dists/chonos/main/binary-i386/* dists/chonos/main/binary-armhf/

apt-ftparchive release . > Release
