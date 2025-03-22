echo "Moving to chrome extension"

cd ~/code_lab/sweaty_wallet/chrome_extension

echo "Building extension"

npm run build

echo "Moving to root project directory"

cd ~/code_lab/sweaty_wallet

echo "Deleting existing extension"

rm -rf /mnt/c/Users/hp/Downloads/chrome_extension

echo "Copying Extension"

cp -r chrome_extension /mnt/c/Users/hp/Downloads/
