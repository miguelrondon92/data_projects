import re
import pandas as pd

#looking for foo + 3 chars following foo

x = "7355468904568490684520684950680596849056840956049584905864059684171890128130945269068459068409680495689045809684516464311272"

patternUSA = re.findall("1..........", x)
patternMEX = re.findall("52.............." , x)

phone_numbers = patternUSA + patternMEX

pn = ', '.join(map(str, phone_numbers))


print(pn)

#An ID - foo
#        foo8562947

