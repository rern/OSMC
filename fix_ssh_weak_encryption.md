SSH Weak Encryption
---

for applications that not support strong encryptions
```sh
# server support list
sudo sshd -T | grep ciphers

# client support list
ssh -Q cipher

# disable unsupport encryptions
sed -i -e '/^KexAlgorithms/ s/^/#/
' -e '/^Ciphers/ s/^/#/
' -e '/^MACs/ s/^/#/
' /tmp/mount/etc/ssh/sshd_config
```
