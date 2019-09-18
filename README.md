# any
`any <command> -flags keyword` expands to `<command> -flags filename-matching-keyword` if the matching is unique, otherwise provides a selection.

When the file/folder name includes a known keyword but bash autocompletion cannot help, any saves the pain.

## Example
```
$ ls   
   aa
   workforce
   workplace
   workfloor
   workaround
   workout
   bb

$ any cd around
workaround $ _

# similarly

$ any cat around
$ any emacs -nw around

```

## Installation
+ `git clone git@github.com:acorbe/any.git`
+ Add `source <path-to>/any/any-bash.sh` into your `~/.bashrc` (for standard linux)  or `~/.bash_profile` (for macos). 

