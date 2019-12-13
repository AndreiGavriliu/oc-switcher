# oc-switcher
The following script helps manage multiple OpenShift `oc` client versions. It creates a symlink of the `oc` client of your choice to a location within `$PATH` location. 

# usage
```
$ ./oc-switcher.sh
usage: ./oc-switcher.sh <new_version>
Currently running /my/oc/clients/openshift-oc-client-v3.10.0

Found the following oc-client versions in /my/oc/clients:
=> v4.2.11
=> v4.1.4
=> v4.1.0
=> v3.9.0
=> v3.7.1
=> v3.11.0
=> v3.10.0
```

```
$ ./oc-switcher.sh v3.10.0
Adding version v3.10.0
... done
```
