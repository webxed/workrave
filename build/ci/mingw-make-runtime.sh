#!/bin/bash

RUNTIMEDIR="./"
ALL_LINGUAS="nl de eo pl da es zh_TW ru fr pt_BR"

if [ "x$1" != "x" ]; then
    if [ -e $1 ]; then
        ALL_LINGUAS=$(cat $1/po/LINGUAS |grep -v '^#')
        echo $ALL_LINGUAS
    fi
fi


. `dirname $0`/mingw-env

mkdir -p $RUNTIMEDIR/runtime-base
mkdir -p $RUNTIMEDIR/runtime-gtk
mkdir -p $RUNTIMEDIR/runtime-wimp

## Helper

function copy_dir()
{
    sourcedir=$1;
    source=$2
    dest=$3;

    prefix=`dirname $source`
    mkdir -p $TARGETDIR/$dest/$prefix
    cp -a $CROSSROOT/$sourcedir/$source $TARGETDIR/$dest/$prefix
}

## Base runtime

TARGETDIR=$RUNTIMEDIR/runtime-base 

find $TARGETDIR -name "*.dll" -print | xargs $STRIP

for lang in $ALL_LINGUAS; do
    mkdir -p $TARGETDIR/lib/locale/$lang/LC_MESSAGES/
    cp -aL /usr/share/locale/$lang/LC_MESSAGES/iso_639.mo $TARGETDIR/lib/locale/$lang/LC_MESSAGES/
    cp -aL /usr/share/locale/$lang/LC_MESSAGES/iso_3166.mo $TARGETDIR/lib/locale/$lang/LC_MESSAGES/
done

cp -a $SYSROOT/lib/libwinpthread-1.dll $TARGETDIR/lib

## Dbus runtime

TARGETDIR=$RUNTIMEDIR/runtime-dbus

copy_dir  bin    dbus*.exe                                  bin
copy_dir  lib    libdbus-1.dll                              lib
copy_dir  etc    dbus-1                                     etc

## Gtk runtime

if [ -d $CROSSROOT/lib/gtk-2.0/2.4.0 ]; then
    GTKVER=2.4.0
elif [ -d $CROSSROOT/lib/gtk-2.0/2.10.0 ]; then
    GTKVER=2.10.0
fi

if [ -d $CROSSROOT/lib/pango/1.4.0 ]; then
    PANVER=1.4.0
elif [ -d $CROSSROOT/lib/pango/1.5.0 ]; then
    PANVER=1.5.0
fi

TARGETDIR=$RUNTIMEDIR/runtime-gtk

copy_dir  etc    gtk-2.0                                    etc
copy_dir  etc    pango                                      etc

copy_dir  bin    zlib1.dll                                  lib
copy_dir  bin    iconv.dll                                  lib
copy_dir  bin    libexpat-1.dll                             lib
copy_dir  bin    libpng*.dll                                lib
copy_dir  bin    libfontconfig-1.dll                        lib
copy_dir  bin    libatk-1.0-0.dll                           lib
copy_dir  bin    libgdk-win32-2.0-0.dll                     lib
copy_dir  bin    libgdk_pixbuf-2.0-0.dll                    lib
copy_dir  bin    libglib-2.0-0.dll                          lib
copy_dir  bin    libgio-2.0-0.dll                           lib
copy_dir  bin    libgmodule-2.0-0.dll                       lib
copy_dir  bin    libgobject-2.0-0.dll                       lib
copy_dir  bin    libgthread-2.0-0.dll                       lib
copy_dir  bin    libgtk-win32-2.0-0.dll                     lib
copy_dir  bin    libpango-1.0-0.dll                         lib
copy_dir  bin    libpangoft2-1.0-0.dll                      lib
copy_dir  bin    libpangowin32-1.0-0.dll                    lib
copy_dir  bin    libpangocairo-1.0-0.dll                    lib
copy_dir  bin    libcairo-2.dll                             lib

if [[ $DOCKER_IMAGE = 'mingw-gtk2' ]] ; then
    copy_dir  bin    freetype6.dll                          lib
    copy_dir  bin    libjpeg-7.dll                          lib
    copy_dir  bin    libtiff-3.dll                          lib
    copy_dir  bin    intl.dll                               lib

else
    copy_dir  bin    libwinpthread-1.dll                    lib
    copy_dir  bin    libfreetype-6.dll                      lib
    copy_dir  bin    libjpeg-62.dll                         lib
    copy_dir  bin    libtiff-5.dll                          lib
    copy_dir  bin    libintl-8.dll                          lib
    copy_dir  bin    libatkmm-1.6-1.dll                     lib
    copy_dir  bin    libcairomm-1.0-1.dll                   lib
    copy_dir  bin    libgdkmm-2.4-1.dll                     lib
    copy_dir  bin    libgiomm-2.4-1.dll                     lib
    copy_dir  bin    libglibmm-2.4-1.dll                    lib
    copy_dir  bin    libgtkmm-2.4-1.dll                     lib
    copy_dir  bin    libpangomm-1.4-1.dll                   lib
    copy_dir  bin    libsigc-2.0-0.dll                      lib
    copy_dir  bin    libstdc++-6.dll                        lib
    copy_dir  bin    libgcc_s_dw2-1.dll                     lib
    copy_dir  bin    libssp-0.dll                           lib
    copy_dir  bin    libpcre-1.dll                          lib
    copy_dir  bin    libffi-6.dll                           lib
    copy_dir  bin    libharfbuzz-0.dll                      lib
    copy_dir  bin    libfribidi-0.dll                       lib
    copy_dir  bin    libpixman-1-0.dll                      lib
    copy_dir  bin    libbz2-1.dll                           lib
fi

for lang in $ALL_LINGUAS; do
    copy_dir share locale/$lang lib
done

msgunfmt $TARGETDIR/lib/locale/nl/LC_MESSAGES/gtk20.mo | sed '/Pre_vious"/!b;n;cmsgstr \"_Vorige\"' | msgfmt -o $TARGETDIR/lib/locale/nl/LC_MESSAGES/gtk20-new.mo  -
mv $TARGETDIR/lib/locale/nl/LC_MESSAGES/gtk20-new.mo $TARGETDIR/lib/locale/nl/LC_MESSAGES/gtk20.mo

TARGETDIR=$RUNTIMEDIR/runtime-wimp

if [ -f $CROSSROOT/lib/gtk-2.0/$GTKVER/engines/libwimp.dll ]; then
    copy_dir  lib    gtk-2.0/$GTKVER/engines/libwimp.dll        lib
    copy_dir  share  themes/*   share
fi
cp -a $TARGETDIR/share/themes/MS-Windows/gtk-2.0/gtkrc $TARGETDIR/share/themes/Raleigh/gtk-2.0/

find $RUNTIMEDIR -name "*.dll" -not -name "iconv.dll" -not -name "intl.dll" -not -name "zlib1.dll" -print | xargs $STRIP
