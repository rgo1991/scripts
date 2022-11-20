#! python3
import time
import sys

indent = 0
indentIncreasing = True

try:
    while True:
        print(' ' * indent, end='')
        print('********')
        time.sleep(0.01)

        if indentIncreasing:
            indent = indent + 1
        else:
            indent = indent - 1

        if indent == 20:
                indentIncreasing = False
        if indent == 0:
                indentIncreasing = True

except KeyboardInterrupt:
    print('Goodbye')
    sys.exit()
