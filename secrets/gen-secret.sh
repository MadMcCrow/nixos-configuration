#!sh
TYPE="-t ed25519"
STORE="/persist/secrets"
KEY=$1

if [ -z "$1" ]
then
    echo "no valid name "
    exit
fi

echo "---- Generating key for $1 ----"
echo -e "\n" | ssh-keygen -C $KEY -f ./$KEY  -q
echo -e "\n---- move private key to $STORE ----"
echo "mv ./$KEY $STORE/$KEY"
sudo mv ./$KEY $STORE/$KEY -f
echo "---- Done ----"
