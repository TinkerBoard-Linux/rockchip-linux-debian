import asyncio
from pyppeteer import launch

async def main():
  browser = await launch(executablePath='/usr/bin/chromium', headless=False)
  # launch browser
  # headless=True: do not display the browser window
  # headless=False: display the browser window
  page = await browser.newPage() # create the new page
  await page.goto('https://tinker-board.asus.com/tw/download-list.html?product=tinker-board-3n')

  await asyncio.sleep(5) # Wait for the page to load

  content = await page.content()
  with open("/home/linaro/.server_list.txt", "w") as f:
    f.write(content)
  await browser.close()

asyncio.get_event_loop().run_until_complete(main())
