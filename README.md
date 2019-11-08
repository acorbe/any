# any
```
any <command> -flags.. file-keyword 

=>  <command> -flags.. filename-matching-keyword
```

In case `file-keyword` allows for more than one matching, a selection menu is prompted.

When the file/folder name includes a known keyword but bash autocompletion cannot help, any saves the pain.

&copy; Alessandro Corbetta 2019.

## Example
![demo-video](/docs/any-video-4.gif)

### cd keyword expansion
```bash
$ ls   
   workplace workfloor workaround
   
$ any cd around
    expanded to: cd workaround
$ workaround/ _
```

### generic command expansion
```bash
$ any cat around
$ any emacs -nw around
```

### complex folder pattern expansion (separated by `/`)
```bash
$ any cat around/demo => cat workaround/my-demo
```


## Installation 
### Via script (for systems with `.bashrc`)
+ `git clone git@github.com:acorbe/any.git`
+ `cd any`
+ `./install.sh`

### Explicit 
+ `git clone git@github.com:acorbe/any.git`
+ Add `source <path-to>/any/any-bash.sh` into your `~/.bashrc` (for standard linux)  or `~/.bash_profile` (for macos). 
+ (optional) `export ANY_ALIAS_CD=true`

## Aliases
+ `any cd` is aliased to `ad` by setting `ANY_ALIAS_CD=true` in your `.bashrc`
