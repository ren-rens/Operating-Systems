# 1. Първите 12 реда
```
cat /etc/passwd | head -n 12
```

# 2. Първите 26 символа
```
cat /etc/passwd | head -c 26
```
ИЛИ
```
head -c 26 /etc/passwd
```

# 3. Всички редове, освен последните 4
```
cat /etc/passwd | head -n -4
```

# 4. Последните 17 реда
```
cat /etc/passwd | tail -n 17
```

# 5. 151-я ред (или друг произволен, ако нямате достатъчно редове)
```
cat /etc/passwd | head -n 151 | tail -n +151
```

# 6. Последните 4 символа от 13-ти ред (символът за нов ред не е част от реда)
```
cat /etc/passwd | head -n 13 | tail -n 1 | tail -c 4
```
