## Before we start


Clap is the new library for implementing _command line applications_ in Pharo.
The project is hosted at [https://github.com/cdlm/clap-st](https://github.com/cdlm/clap-st).

In this book, all examples assume that Pharo runs under a unix-like operating system \(macOS or Linux\).


### Command line applications


A command line application consists of a single command or of several related commands designed to be used either interactively from a shell, or programmatically in shell scripts.
Clap supports applications with rich command line syntax, supporting positional parameters, flags or options, and even nested subcommands like `git`; it also tries to follow well-established conventions like short and long alternative syntaxes for flags.

The example below shows two different uses of the standard `seq` shell command, which generates numeric sequences:
```language=shell
> seq 3
1
2
3
> seq -s : 5 12
5:6:7:8:9:10:11:12
```


!!note In this book, code blocks show either the recording of a shell session, as above, or pieces of Pharo code, which you will recognize from the syntax. In shell sessions, lines starting with `>` represent the command prompt followed by a command entered at that point; subsequent lines, up to the next prompt, show the output of that command.


### Install Pharo and Clap from the command line


To get a working setup, the easiest is to obtain both the Pharo virtual machine and image via the [command line method](https://pharo.org/download#standalone):
```language=shell
> curl https://get.pharo.org/64/80+vm | bash
```


The virtual machine comes with two launcher scripts.
To open an image with its graphical user interface active, use `pharo-ui`:
```language=shell
> ./pharo-ui Pharo.image
```


While the image is open, let's load an up-to-date version of Clap in it; open a workspace and evaluate the following incantation:
```
Metacello new baseline: 'Clap';
  repository: 'github://cdlm/clap-st/src';
  ignoreImage;
  load.
```

If all went well, save and quit the image.

The other launcher script `pharo` runs the image _headless_, which is what we will use to try Clap commands from the shell.
To run Clap commands, follow the image name with the `clap` keyword, then the command itself.
Clap comes with the traditional _"hello world"_ as an example, if you want to try it:
```language=shell
> ./pharo Pharo.image clap hello
hello, world.
> ./pharo Pharo.image clap hello "pharo and clap"
hello, pharo and clap.
```



### Define a shell alias for convenience


From this point on, we will use a `clap` shortcut which _looks_ like an actual shell command.
For now, let's define it as a shell alias, like so:
```language=shell
> alias clap='./pharo Pharo.image clap'
> clap hello
hello, world.
```


!!note This alias is just a quick and dirty way to set up a shell session and to follow along this tutorial. It's very brittle because it relies on the image and virtual machine being installed in your shell's current working directory, and you will have to define it again in new shell sessions. See Section *@deploying@* for a proper deployment approach.


## Clap by Example


Through simple examples, this chapter shows how to specify the syntax and behavior of Clap commands.


### Declaring a command


Clap relies on a simple convention for registering commands: any class-side unary method with the `<commandline>` pragma is a factory method that returns the specification of a unique command.

As a first example, let's build a command that enumerates the months in the year.
First, we create a new package called `Clap-BookletExamples`.
Then we start with a new empty class:
```
Object subclass: #ClapBookletMonthsCommand
  instanceVariableNames: ''
  classVariableNames: ''
  package: 'Clap-BookletExamples'
```


Then, on the class-side, we add a unary method with the `<commandline>` pragma, and which returns the specification of a command named `months`:
```
ClapBookletMonthsCommand class >> commandSpecification
  <commandline>
  ^ ClapCommand id: #months
```


!!note Before trying commands, save the image. This is necessary because every command line invocation spawns a separate virtual machine, which will load the image as it is on disk.

After saving the image, switch to a terminal window and try either the explicit or the short version:
```language=shell
> pharo Pharo.image clap months
> clap months
```


Of course, since we have not given any behavior to the command yet, you should not see any output.
However, Clap takes care of terminating the execution with an exit status of zero, indicating success.

To print this success output:
```language=shell
> echo "exit status was $?"
exit status was 0
```


If you try a command or parameters that do not exist, mistype the name, or forget to save the image after declaring the command, the exit status should be nonzero, indicating that the command failed, and you should get an error message:
```language=shell
> clap oops wrong command
Unrecognized arguments: oops, wrong, command
> echo "exit status was $?"
exit status was 1
```


!!note Clap is case-sensitive when matching the names of commands and other named parameters.


### Giving behavior to a command


As a start, let's have our `months` command print the month numbers one to twelve.
We configure the command's behavior by setting its _meaning_ block, as follows:
```
commandSpecification
  <commandline>
  ^ (ClapCommand id: #months)
    meaning: [ :commandMatch | | out |
      out := commandMatch context stdout.
      (1 to: 12)
        do: [ :each | out << each asString ]
        separatedBy: [ out space ].
      out newLine ]
```


When Clap recognizes a command, it evaluates that command's `#meaning:` block, passing it a _match_ object which describes the command invocation.
The match also provides access to contextual resources like the standard output stream.
```language=shell
> clap months
1 2 3 4 5 6 7 8 9 10 11 12
```



### Trying a command from the workspace


For development convenience, we can run commands directly from the Pharo workspace.
To try that, send the `#activateWith:` message to our `months` command, passing the array of words that would be typed to invoke it:
```
ctx := ClapBookletMonthsCommand commandSpecification
  activateWith: #('months').
```


!!note Always pass an array of _strings_ to `#activateWith:`, starting with the name of the command itself.

Because it's a convenience method, `activateWith:` runs the command in a special debug context, which it then returns, so that it can be inspected.
For instance, we can obtain the command's output as a string:
```
ctx stdio stdout contents utf8Decoded
```



### Specifying parameters


Let's say we want to only enumerate between two given months:
```language=shell
> clap months 5 10
5 6 7 8 9 10
```


Or if you are in the Pharo workspace, you can print from the playground the following lines:
```
ctx := ClapBookletMonthsCommand commandSpecification
  activateWith: #('months' '5' '10').
ctx stdio stdout contents utf8Decoded
```


We modify the command specification as follows:
```
commandSpecification
  <commandline>
  ^ (ClapCommand id: #months)
    add: (ClapPositional id: #start);
    add: (ClapPositional id: #end);
    meaning: [ :commandMatch | | out start end |
      out := commandMatch context stdout.
      start := (commandMatch at: #start) word asNumber.
      end := (commandMatch at: #end) word asNumber.
      (start to: end)
        do: [ :each | out << each asString ]
        separatedBy: [ out space ].
      out newLine ]
```


First, we extend the command specification with two new parameters.
We model the start and end month as positionals, each with it its own unique identifier, and add them to the command.

Second, we update the command's behavior.
The match for the whole command  contains a smaller match for each positional; we look those up by their identifiers, and interpret the corresponding command line words as numbers.


### Positionals, flags, and commands


Compound parameter specifications, like our second version of the `months` command, are composed of various kinds of parameters nested together using the `#add:` message.
To strike a balance between following established conventions and keeping a simple and coherent model, Clap provides three kinds of parameters, each with specific nesting, matching, and semantic properties:

- _Positionals_ are recognized in order, relative to their sibling positionals, and do not have child parameters of their own; they convey meaning through the form of the word they match, once parsed into some adequate domain value, like a number or an URL.


- _Flags_ are parameters identified by keywords which usually start with dashes to distinguish them from other parameters; they are also know as _options_ in the jargon. They convey meaning through their presence, absence, number of occurrences, and order in the command line. A flag can have child positionals, resulting in a named parameter.


- _Commands_ are identified by keywords. They can have positionals and flags as children parameters, but also other commands. Sibling commands are exclusive, and a subcommand takes precedence over its parent command, which helps with structuring applications into multiple subcommands.


!!note TODO example here

Clap starts running application code with the meaning block of the innermost subcommand invoked.
The application receives a match tree associating each word of the command line with the matched parameter; the nesting of matches therefore mirrors the nesting of specifications.

The application then determines its course by navigating and querying the match tree; to this end, all parameters have a mandatory _identifier_, which is unique among sibling parameters.

Besides their identifier, Clap parameters also have a _name_ and a _description string_ which are how the user knows them; for convenience, if no name is given, Clap derives it from the identifier.
Name and description also appear in generated documentation and help messages.


### Positional parameters


Positionals are for passing values from an open-ended set, like numbers, URLs, file paths, application-specific identifiers, arbitrary strings… any information that the user would literally write on the command line.

Positionals are the simplest form of parameters; successive sibling positionals are recognized in order, each matching a word from the command line.
When writing the command line, the user must remember the correct sequence between successive arguments, and must ensure that each positional value is considered as one word by the shell: for instance, if the argument contains spaces or results from expanding shell variables, they have to pay attention to the shell's word-splitting rules and use quotes appropriately.
The application is then responsible for parsing the word matched by the positional into a proper domain value.

In our `months` command, we used positionals for the start and end month.
The order in which we add them to their parent command determines the matching order, so the first argument will always be `start` and the second one `end`.
At this point, both arguments are just two strings, so the application parses them into numbers before starting the enumeration.


### Handling missing arguments


By adding parameters, we have made the command quite brittle: what if the user omits one or both arguments, expecting the command to work like the initial version?
Well, it is the responsibility of the application to handle missing arguments in a robust manner.
Failing that, Clap fails:
```language=shell
> clap months 3
MessageNotUnderstood: ClapImplicit>>word
```


Here's why: when either positional is omitted, the `#at:` query returns an _implicit match_ \(see the [Null Object pattern](https://en.wikipedia.org/wiki/Null_object_pattern)\).
Sending `#word` was thus the mistake here, because this is only valid when the parameter _explicitly matched_ a word from the command line.
```
start := (commandMatch at: #start) word asNumber.
end := (commandMatch at: #end) word asNumber.
```


Instead, we could use a query like `#at:ifPresent:ifAbsent:` which has a fallback when no explicit match is found.
```
start := commandMatch at: #start
  ifPresent: [ :m | m word asNumber ]
  ifAbsent: [ 1 ].
end := commandMatch at: #end
  ifPresent: [ :m | m word asNumber ]
  ifAbsent: [ 12 ].
```


```language=shell
> clap months 10
10 11 12
> clap months
1 2 3 4 5 6 7 8 9 10 11 12
```


Or in the Pharo workspace :
```
ctx := ClapBookletMonthsCommand commandSpecification
  activateWith: #('months' '10').
ctx stdio stdout contents utf8Decoded
```


This approach does work, but the command's meaning block is becoming tedious to read, because it has to bother with details that are really the responsibility of the parameters themselves.

A better approach is to give each parameter its own _meaning_; then the command code does not have to care and can just ask parameter matches for their `#value`.
When asking for the value of an explicit match, the meaning block of the parameter will be used.
But if the user left the argument out, then an _implicit meaning_, given by a different block, should be used:
```
commandSpecification
  <commandline>
  ^ (ClapCommand id: #months)
    add: ((ClapPositional id: #start)
      meaning: [ :m | m word asNumber ];
      implicitMeaning: [ 1 ]);
    add: ((ClapPositional id: #end)
      meaning: [ :m | m word asNumber ];
      implicitMeaning: [ 12 ]);
    meaning: [ :commandMatch | | out start end |
      out := commandMatch context stdout.
      start := (commandMatch at: #start) value.
      end := (commandMatch at: #end) value.
      (start to: end)
        do: [ :each | out << each asString ]
        separatedBy: [ out space ].
      out newLine ]
```


!!note There is another way our command could fail: if the user types something that cannot be properly parsed into a number, then `#asNumber` will fail. We have left error handling out of examples for now, but in a future version Clap could provide facilities for argument validation and related error reporting.


### Positionals with multiple occurrences


As you might have guessed, the `months` command we are using as a running example is inspired from the unix `seq` command for generating number sequences; indeed, they behave the same with both bounds specified.
However, when they're only given one bound, `months` treats it as the number to count _from_, while `seq` counts _up to_ it starting from one.
To make matters worse, `seq` also accepts three arguments, in which case the middle one is an increment, much like the `#to:by:do:` iteration method.

Clap recognizes positional in order, which means that subsequent positionals have lower and lower precedence.
In contrast, precedence in `seq` does not match order: it needs an upper bound most \(its third positional\), possibly preceded by a lower bound \(first positional\), and then maybe with an increment in between \(second positional\).
This means in practice that the first argument to `seq` changes meaning depending on how many other arguments follow.

If we want to reproduce the way `seq` handles positionals, we have to take a different approach.
We can treat the arguments as _multiple occurrences_ of a single positional, which we can access as a collection and analyse using arbitrary logic:
```
seqSpecification
  <commandline>
  ^ (ClapCommand id: #'months-seq')
    add: ((ClapPositional id: #bound)
      multiple: true;
      meaning: [ :m | m word asNumber ]);
    meaning: [ :commandMatch | | out bounds start step end |
      out := commandMatch context stdout.
      bounds := (commandMatch occurrencesOf: #bound) collect: #value.
      end := bounds size >= 1
        ifTrue: [ bounds last ] ifFalse: [ 12 ].
      start := bounds size >= 2
        ifTrue: [ bounds first ] ifFalse: [ 1 ].
      step := bounds size >= 3
        ifTrue: [ bounds second ] ifFalse: [ 1 ].
      (start to: end by: step)
        do: [ :each | out << each asString ]
        separatedBy: [ out space ].
      out newLine ]
```


Note that we've declared this version of the command as a new method and with a different identifier.
This leaves `months` unchanged, but adds a new `months-seq` which you can try for comparison:
```language=shell
> clap months-seq 3
1 2 3
> clap months-seq 3 7
3 4 5 6 7
> clap months-seq 3 2 7
3 5 7
```



### Flags and options


from SD to CDLM: more here please


#### default boolean value


tu peux toujours faire `aFlagMatch isExplicit` pour savoir si il était présent explicitement

mais aFlagMatch value fait la même chose si tu ne lui as pas donné de meaning


### Commands and subcommands


Reoops!
How do I write a command then :\(

How we access parent command from subcommand
args context parent probably?

the example is

```
myCommand
	— baseDirectory
	— months
	— renter

et je veux dump qui fait un dump donc comme sous commande?

	— dump
```



	comment dump peut acceder a —basedirectory


quittance —baseDirectory /tmp -dump

\]\]\]


### Quick recap on parameters and matches


An essential premise is that Clap receives command lines as _arrays of strings_; any command line gets processed and split into _words_ by a shell, whether it was interactively entered at a command prompt, or it was passed to the `system()` POSIX function, but is not structured further. This is why we have to interpret concrete arguments into domain values.

Given a parameter match, the `#word` message returns its concrete representation as a string.
Clap assumes that the command line is UTF-8, but also provides lower-level accessors for other encodings or raw access to the byte representation.

Conversely, `#value` interprets the match into a domain value, according to the parameter's _meaning_.
Positionals, flags, and commands all have a meaning specified by a block passed to the `#meaning:` message.
The meaning is often a simple conversion, but is limited to that; one parameter can depend on others, in fact, for commands, it defines their complete behavior.

Parameter matches form a tree.
We can navigate up to the `#parent` of any match, or directly to the invocation `#context` which is the root of the match tree.
Navigating down requires querying for a child match by identifier, either using branching queries like `#at:ifPresent:`, or collective queries like `#occurrencesOf:`.
These queries all return _explicit_ matches, which represents a span of one or several words of the command line.

The short query `#at:` always answers a meaningful object, unless we're asking for an invalid parameter.
When the requested parameter has no occurrence in the command line, `#at:` returns an _implicit_ match.
The message `#implicitMeaning:` of parameter specifications provides an alternate to the `#meaning:` block for this situation, guaranteeing that the normal meaning block will always be passed explicit match objects.


### Exit status


```
meaning: [ :args |
			args exitSuccess
				]
```


Usually we do not have to do it since when the block is fully executed an exitSuccess is raised

```
meaning: [ :args |
			args exitFailure
				]
```


status one

```
meaning: [ :args |
			args exitFailure:
				]
```


status one


### Get help for free


flag help et command help


#### Help flag


Passing `--help` to a command that supports it describes the command and its parameters:
```
> clap hello --help
Provides greetings

Usage: hello [--help] [--whisper] [--shout] [--language] [<who>]

Parameters:
    <who>       Recipient of the greetings

Options:
    --help      Prints this documentation
    --whisper   Greet discretely
    --shout     Greet loudly
    --language
                Select language of greeting
```

```
> clap eval --help
Print the result of a Pharo expression

Usage: evaluate [--help] [--save] [--keepAlive] [<EXPR>]

Parameters:
    <EXPR>      The expression to evaluate, joining successive arguments with spaces (if omitted, read the expression from stdin)

Options:
    --help      Prints this documentation
    --save      Save the image after evaluation
    --keepAlive
                Keep image running
```


Pay attention: by convention, `--help` takes precedence over other arguments.
However, in Clap, flags do not automatically trigger behavior.
This makes it necessary to check for it as one of the first things the command does.
```
hello
  "The usual Hello-World example, demonstrating a Clap command with a couple options."

  <commandline>
  ^ (ClapCommand withName: 'hello')
    description: 'Provides greetings';
    add: ClapFlag forHelp;
    " other parameters... "
    meaning: [ :args |
      args
        at: #helpFlag
        ifFound: [ :help | help value; exitSuccess ].
      (self with: args) sayHello ]
```



#### Help command


Clap also provides a `help` command.
Without an argument, it works like the `--help` flag and documents its parent command:
```
> clap help
Entry point for commands implemented with Clap

Usage: clap [--help]

Options:
    --help      Prints this documentation

Commands:
    help        Prints command documentation
    evaluate    Print the result of a Pharo expression
    hello       Provides greetings
    version     Displays version information, in various formats
    bettermonths
```


With an argument it documents the corresponding sibling command:
```
> clap help hello
Provides greetings

Usage: hello [--help] [--whisper] [--shout] [--language] [<who>]

Parameters:
    <who>       Recipient of the greetings

Options:
    --help      Prints this documentation
    --whisper   Greet discretely
    --shout     Greet loudly
    --language
                Select language of greeting
```



## Patterns of command definition



### Command vs. flag


flag: you have to manage it explicitly
- add flag `add: ClapFlag forHelp;`
- in meaning:


```
args
  atName: 'help'
  ifFound: [ :help | help value; exitSuccess ].
```


command:
Potential Conflict with positional

```
> clap hello help
Hello, help
```



### Patterns to express meaning


```
meaning: [ :args |
			args
				atName: 'help'
				ifFound: [ :help |
					help
						value;
						exitSuccess ].
			(self with: args) sayHello ]
```



```
with: arguments
	^ self new
		setArguments: arguments;
		yourself
```




Control the border between the shell world \(strings\) and Pharo objects.
Two choices:
- convert in the meaning block from string to objects
- pass all the arguments to the domain with a specific API



## Clap Explained


Clap is a framework for adding rich command line interfaces to Pharo code; it sits at the frontier of the image, between application code and the shell environment.
There are two main families of objects in Clap:
- _Specifications_ describe the syntax and behavior of commands that the image understands.
- _Activations_ represent command invocations and their arguments, their domain-level meaning, and which words they map to.


Before we start with the details, let's recap the general workflow with Clap:
1. On the shell side, the user invokes a command, either directly in the terminal or from a shell script; for convenience, that command would usually be an alias or a small wrapper around the correct Pharo virtual machine and image.
1. On the image side, Clap receives the command with its arguments as an array of words, and creates an activation context, matching the arguments with known commands specifications.
1. A successful match has meaning defined by application code, which queries the context for domain-level meaning or raw syntax of command parameters, and for external resources like input/output streams.
1. When the application code runs to completion, Clap cleanly exits the image. Alternatively, the application can tell the context to terminate early, with a deliberate exit status, or if it fails to handle an exception, Clap catches it and gracefully reports the error.



### Specifications


%  extending with custom parameter kinds


### Activations


![Main specification classes](figures/parameters/Specifications.pdf width=70&label=specificationClasses)
![Main activation classes](figures/parameters/Activations.pdf width=70&label=activationClasses)
![Context and tree of matches](figures/parameters/tree.pdf width=70&label=matchTree)


### Deploying Clap commands

@deploying

A single Pharo image can host several Clap commands; in fact the base image includes commands for automating development tasks like loading code or running tests.
Loading additional commands into an image is as simple as loading the corresponding packages; Clap discovers declared commands automatically.

However, either when loading commands in an image, installing them on your own system, or packaging them for other users to install, you will have to consider a few gotchas:
- Commands installed in a common image must all have distinct names.
- The wrapper script for a command must know which image to run and with which VM; if one or the other are known by relative path, then the working directory matters.
- Commands can modify their host image, inducing side-effects between successive runs or between commands hosted in a common image.

We do not have generic answers to those questions but we are interested in your feedback.
