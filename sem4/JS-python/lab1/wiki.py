import wikipedia

page = input("enter the page on wikipedia: ")
print(wikipedia.page(page).summary)
print(wikipedia.page(page).url)

