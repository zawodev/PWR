import sys
import data_processing_functions as dpf

# --------------- tester ---------------

mydict = {}
counter = 0

def func(log_entry: dpf.LogEntry):
    global mydict
    global counter
    if log_entry.response_code not in mydict:
        mydict[log_entry.response_code] = 1
    else:
        mydict[log_entry.response_code] += 1
    counter += 1

    if log_entry.response_code == "":
        print(log_entry.original_log)


if __name__ == "__main__":
    counter2 = 0
    for line in sys.stdin:
        parsed_line = dpf.parse_line(line)
        func(parsed_line)
    for key in sorted(mydict.keys()):
        print(f"{key} {mydict[key]}")
        counter2 += mydict[key]
    print(counter)
    print(counter2)



# --------------- tester ---------------
'''
line = 'zeus.polsl.gliwice.pl - - [28/Jul/1995:03:42:28 -0400] "GET /images/MOSAIC-logosmall.gif HTTP/1.0" 200 363'
parts = line.split(" ")
cmd = line[line.find('"') + 1:line.rfind('"')]
path = "".join(cmd.split(" ")[1:-1])
fwe = path.split("/")[-1]

host_domain=parts[0].split(".")[-1] if "." in parts[0] else ""
date=(parts[3] + " " + parts[4])[1:-1]
file_extension=fwe.split(".")[1] if "." in fwe else ""
response_code=parts[-2]
bytes_sent=parts[-1]

print(path)
print(date)
print(host_domain)
print(file_extension)
print(bytes_sent)
print(response_code)

from datetime import datetime

realdate = datetime.strptime(date, "%d/%b/%Y:%H:%M:%S %z")
if realdate.weekday() == 4:
    print("yes")
else: 
    print("no")
'''