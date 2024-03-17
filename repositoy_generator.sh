#! /bin/sh
SRC="src/"
DPKG="public_html/chonos/"

getLatest(){
    PACKAGE=$1
    GITNAME=$2
    LATEST_INFORMATION="https://api.github.com/repos/chon-group/$2/releases/latest"
    echo "Searching for $LATEST_INFORMATION"
    curl -s $LATEST_INFORMATION > /tmp/$PACKAGE.latest

    TAG_NAME=$(cat /tmp/$PACKAGE.latest | grep "tag_name" | head -n 1 | awk -F'["]' '{print $4}')
    
    LATEST_RELEASE_URL="https://github.com/chon-group/$GITNAME/archive/refs/tags/$TAG_NAME.tar.gz"
    FILENAME=$(echo "$LATEST_RELEASE_URL" | rev | cut -d "/" -f 1 | rev)
    GITREPO=$(echo $LATEST_RELEASE_URL | cut -d "/" -f 5)

    if [ ! -f $SRC$GITREPO/$FILENAME ]; then
        mkdir -p $SRC$GITREPO
        wget -P $SRC$GITREPO $LATEST_RELEASE_URL
    else
        rm -rf $SRC$GITREPO$TAG_NAME
    fi
    tar -xzf $SRC$GITREPO/$FILENAME -C $SRC$GITREPO

    VERSION=`egrep "Version:" $SRC$GITREPO/$GITREPO-$TAG_NAME/DEBIAN/control | cut -d ":" -f 2 | xargs`
    mkdir -p $DPKG
    rm $SRC$GITREPO/$GITREPO-$TAG_NAME/*.md 2> /dev/null
    rm $SRC$GITREPO/$GITREPO-$TAG_NAME/LICENSE 2> /dev/null
    dpkg-deb -b $SRC$GITREPO/$GITREPO-$TAG_NAME/ $DPKG$PACKAGE-$VERSION.deb
}


#getLatest DEBIAN-PACKAGE-NAME   GITHUB-REPO-NAME
getLatest "chonos-ddnsmng" "dpkg-chonos-ddnsmng"
getLatest "chonos-log" "dpkg-chonos-log"
getLatest "chonos-task" "dpkg-chonos-task"
getLatest "javino" "dpkg-javino"
getLatest "chonos-embeddedmas" "dpkg-chonos-embeddedmas"
getLatest "chonos-firmwaremng" "dpkg-chonos-firmwaremng"
getLatest "chonos-sysconfig" "dpkg-chonos-sysconfig"
getLatest "chonide" "dpkg-chonide"
getLatest "jason-cli" "dpkg-jason"
getLatest "jacamo-cli" "dpkg-jacamo"
getLatest "chonos-serial-port-emulator" "dpkg-virtualport-driver"
getLatest "chonos-network" "dpkg-chonos-network"
getLatest "chonos" "dpkg-chonos"
getLatest "chonos-neighbors" "dpkg-chonos-neighbors"
getLatest "chonos-cert" "dpkg-chonos-cert"
getLatest "contextnetserver-latest" "contextNetServer"
getLatest "chonos-simulide" "dpkg-simulide"

mkdir -p public_html/dists/chonos/main/binary-all
cd public_html

dpkg-scanpackages chonos/ > dists/chonos/main/binary-all/Release
cat dists/chonos/main/binary-all/Release | gzip -9c > dists/chonos/main/binary-all/Packages.gz

cd ../