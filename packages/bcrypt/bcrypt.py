# a simple script to encrypt bcrypt text
import getpass
import bcrypt

to_encrypt = getpass.getpass("to encrypt: ")
hashed_password = bcrypt.hashpw(to_encrypt.encode("utf-8"), bcrypt.gensalt())
print(hashed_password.decode())
