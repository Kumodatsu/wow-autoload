# AutoLoad
A World of Warcraft addon that allows you to automatically run small scripts on
startup.

**IMPORTANT**: Do not add scripts if you don't know what they do.
Do not add scripts you get from people you don't trust.
As per the included license, I am not liable for anything bad happening as a
result of using this addon.
Only use it if you know what you're doing.

Currently, to make sure you do know what you're doing, the addon provides no
friendly interface.
You must directly call Lua functions with the in-game `/run` command to make use
of its functionality.
If you do not know what this means, I recommend not using this addon.

## How to add scripts
Run the following command in game to add a startup script:

    /run AutoRun.AddStartupScript(name, description, dependencies, source)

Here `name` is a name for the script, `description` is a description for the
script, `dependencies` is a table of names of addons that must be loaded before
the script is run, and `source` is the source code for the script.
For example, the following command:

    /run AutoRun.AddStartupScript("A script", "A script that does something", {"A", "B"}, [[print "Peekaboo"]])

will add a startup script that prints "Peekaboo" to the chat window after the
addons `A` and `B` have been loaded.
Scripts added this way will only take effect the next time you log in, and every
login afterwards until you remove the script again.

## How to remove scripts
Run the following command in game to remove a startup script:

    /run AutoRun.RemoveStartupScript(name)

Here `name` is the name for the script that you gave it when adding it using
`AddStartupScript`.
