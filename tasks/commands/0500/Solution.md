# First step
Create the practice_test directory
```
mkdir practice_test
```
# Second step
Create the test1 directory in practice_test.
Could be done either like this:
```
mkdir practice_test/test1
```
OR:
```
cd practice_test
mkdir test1
```
# Can step 1 and 2 be done in one step?
```
mkdir -p practice_test/test1
```
# Third step
Create the empty file in test1 that is called test.txt:
```
cd practice_test/test1
touch test.txt
```
Or:
```
touch practice_test/test1/test.txt
```
# Fourth step
Move the test.txt file in practice_test directory:
```
mv practice_test/test1/test.txt practice_test/test.txt
```
