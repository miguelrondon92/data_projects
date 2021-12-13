from sys import argv, exit
import csv
import re
# an array called match
match = []

filename, datafile, sequence = argv

# if length of argv != 3, user error.
if len(argv) != 3:
    print("Usage: python dna.py data.csv sequence.txt")
    sys.exit(1)

#open DNA sequence that is being looked at.
with open(sequence, "r") as sequence:
    for seq in sequence:
        seq = seq

# open data_file that contains the Short Tandem Repeats(STR) that we are looking for.
with open(datafile, "r") as datafile:
    # read through data_file
    reader = csv.reader(datafile)
    #make reader into a list and call it key.
    key =list(reader)
    #make a duplicate list for reference.

#iterate through the first dataset in key to get headerfile, hand it the value "i"
for i in key[0]:
    
    # if i is in the seq
    if i in seq:
        #this formula reads regular expression and function inside 
        #regular expression to get consecutive i's in a list.(VERY POWERFUL FUNCTION)
        STR_list = re.findall(rf'(?:{i})+', seq)
        #stores the largest list. 
        STR_max = max(STR_list)
        #counts the amount of time i is in largest list 
        STR_count = STR_max.count(i)
        #appends count to the STR_count which will be used later to compare with match. 
        match.append(f'{STR_count}')
        
        
#iterate through key with j. 
for j in key:
    #pop off the first element of j
    name = j.pop(0)
    #if the new "j" is the same as match, print name 
    if (match == j):
        print(name)
        exit(0)
print("no match")
exit(0)

