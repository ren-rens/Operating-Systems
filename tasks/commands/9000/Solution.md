# Step 1
Create the archive c_start.tar.
```
tar -cvf c_start.tar my_etc $(find my_etc -type f -name \c*) \;
```
Using the command tar we create an archive with the flags. 

# Step 2
Delete directory my_etc.
```
rm -rf my_etc
```

# Step 3
Delete the archive.
```
rm -f c_start.tar
```
