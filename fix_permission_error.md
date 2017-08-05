**Fix permission errors**  
run script by another script with sudo or chmod the file
```sh
# '-a' append '-G' group root with user osmc
usermod -a -G root osmc
chmod g+rw /dev/gpiomem
```
