# Step 1
Create permission.txt file in home directory
```
touch permission.txt
```
# Step 2
For permission.txt give the rights:
* user: read
* group: write, exec
* other: read, exec

This could be done either with bits or letters.

## Bits
* read: 4
* write: 2
* exec: 1

```
chmod 435 permission.txt
```
## Letters
* read: r
* write: w
* exec: x

```
chmod u=r permission.txt
chmod g=wx permission.txt
chmod o=rx permission.txt
```
