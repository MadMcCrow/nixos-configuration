
[script("sh")]
update :
    root=$(git rev-parse --show-toplevel)
    npins -d "$root/packages/_npins" update