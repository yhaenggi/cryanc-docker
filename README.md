These images have been built and tested on docker amd64, arm32v7 and arm64v8. This is a multi platform image.

## Usage ##

    docker run -d -p 8080:8080/tcp yhaenggi/cryanc:2.2

## Build ##

If you want to build the images yourself, you'll have to adapt the registry file, copy qemu and enable binfmt.

    cp /usr/bin/qemu-{x86_64,arm,aarch64} .

In case you want other arches, just add them in the ARCHES files and copy the corresponding qemu user static binary. If you want support for another archtitecture, open an issue.

On some distros, you have to manually enable binfmt support:

    sudo service binfmt-support restart

You can verify if it worked with this (should show enabled):

    update-binfmts --display|grep -E "arm|aarch"

## Tags ##
   * 2.2
