
import random

one = "one"
two = "two"
three = "three"
four = "four"
five = "five"
six = "six"
seven = "seven"

team = [one, two, three, four, five, six, seven]
monday = { "oncall" : "" , "chats1" : "" , "chats2":"", "chats3":"" , "emails1":"" , "emails2":"" , "wrapup":"" }
tuesday =  { "oncall" : "" , "chats1" : "" , "chats2":"", "chats3":"" , "emails1":"" , "emails2":"" , "wrapup":"" }
wednesday = { "oncall" : "" , "chats1" : "" , "chats2":"", "chats3":"" , "emails1":"" , "emails2":"" , "wrapup":"" }
thursday = { "oncall" : "" , "chats1" : "" , "chats2":"", "chats3":"" , "emails1":"" , "emails2":"" , "wrapup":"" }
friday = { "oncall" : "" , "chats1" : "" , "chats2":"", "chats3":"" , "emails1":"" , "emails2":"" , "wrapup":"" }
weekdays = [ monday, tuesday, wednesday, thursday, friday ]

oncall_list = []
weekends_on = []
for t in team:
	weekends_on.append(t)
def monday_rota():
	random.shuffle(team)
	for k,v in monday.items():
		for r in range(7):
			if team[r] in monday.values():
				pass
			else:
				monday.update({k:team[r]})
#	print("weekens_on" + weekends_on[0])
#	print("monday oncall:" + monday["oncall"] + "monday wrapup:" + monday["wrapup"])
#	monday.update({"oncall":monday["wrapup"]})
#	print("monday oncall after change" + monday["oncall"])
	if monday["oncall"] == weekends_on[0]:
		monday.update({"oncall":monday["wrapup"]})
		monday.pop('wrapup', None)
		print("change made")
	oncall_list.append(monday["oncall"])
	print(monday)


def tuesday_rota():
	random.shuffle(team)
	for k,v in tuesday.items():
		for l in range(7):
			if team[l] in tuesday.values():
				 pass
			else:
				tuesday.update({k:team[l]})
	oncall_list.append(tuesday["oncall"])
	print(tuesday)

def wednesday_rota():
	random.shuffle(team)
	for k,v in wednesday.items():
		for m in range(7):
			if team[m] in wednesday.values():
				pass
			else:
				wednesday.update({k:team[m]})
	oncall_list.append(wednesday["oncall"])
	print(wednesday)


monday_rota()
tuesday_rota()
wednesday_rota()
print(oncall_list)
