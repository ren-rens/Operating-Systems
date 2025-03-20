# Всички които не започват с s
```
cat /etc/passwd | grep -E "^[^s].*"
```

# Започват с s и имат числа след това
```
cat /etc/passwd | grep -E -v "^[^s0-9]{5}.*"
```
-v inverts
