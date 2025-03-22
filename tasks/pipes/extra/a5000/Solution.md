# First
Изведете реда от /etc/passwd, на който има информация за вашия потребител.
```
cat /etc/passwd | grep "$(cat /etc/passwd | cut -d ':' -f 1 | whoami)"
```
OR
```
cat /etc/passwd | grep "$(whoami)"
```

# Second
Изведедете този ред и двата реда преди него.
```
cat /etc/passwd | grep -B 2 "$(whoami)"
```

# Third
Изведете този ред, двата преди него, и трите след него.
```
cat /etc/passwd | grep -B 2 -A 3 "$(whoami)"
```

# Fourth
Изведете *само* реда, който се намира 2 реда преди реда, съдържащ информация за вашия потребител.
```
cat /etc/passwd | grep -B 2 "$(whoami)" | head -n 1
```
