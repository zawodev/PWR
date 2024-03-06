import pyautogui
import time

time.sleep(1)

pyautogui.press('win')
time.sleep(1)
pyautogui.write('notatnik')
time.sleep(1)
pyautogui.press('enter')
time.sleep(1)
pyautogui.write('Hello world')
pyautogui.moveTo(100, 100, duration=1)
