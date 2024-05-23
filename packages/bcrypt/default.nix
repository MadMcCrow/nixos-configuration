{ python3Packages, writers, ... }:
writers.writePython3Bin "bcrypt" { libraries = [ python3Packages.bcrypt ]; }
(builtins.readFile ./bcrypt.py)
