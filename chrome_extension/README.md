# Chrome Extension

Chrome extension helps user safely login into their banks in their browser and use app to import their accounts and transactions.
It currently supports 3 banks

- TD
- RBC
- Walmart Master Card

## Development 

- Install `nodejs 18.16.0`
- Run `npm run build_td` to build td content script (We use esbuild for using ES6 modules, rbc and walmart are not ES6 module scripts)
- Follow this [link](https://developer.chrome.com/docs/extensions/get-started/tutorial/hello-world#load-unpacked) to load the extension in chrome for development


