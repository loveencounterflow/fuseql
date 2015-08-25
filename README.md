

- [fuseql](#fuseql)
		- [on OS X:](#on-os-x)
		- [on Linux:](#on-linux)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# fuseql
a FUSE virtual filesystem backed by an SQLite database



```bash
npm install -g npm@3.0-latest
```

```bash
npm install -g node-gyp-install
node-gyp-install
sudo apt-get install pkg-config
# sudo apt-get install fuse
sudo apt-get install libfuse-dev
npm install -g hyperfs
```


https://github.com/bcle/fuse4js

```bash
npm install -g --unsafe-perm fuse4js
```

```bash
fusermount -u /tmp/fuse4json/
```


### on OS X:

https://github.com/osxfuse/osxfuse/issues/171

### on Linux:

```bash
sudo pico /etc/fuse.conf
```


to uncomment the last line and set the `user_allow_other` option:

```bash
sudo cat /etc/fuse.conf
```

```
# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#
#mount_max = 1000

# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
#
#user_allow_other
```