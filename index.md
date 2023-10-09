## Before we start
1
2
3
> seq -s : 5 12
5:6:7:8:9:10:11:12
  repository: 'github://cdlm/clap-st/src';
  ignoreImage;
  load.
hello, world.
> ./pharo Pharo.image clap hello "pharo and clap"
hello, pharo and clap.
> clap hello
hello, world.
  instanceVariableNames: ''
  classVariableNames: ''
  package: 'Clap-BookletExamples'
  <commandline>
  ^ ClapCommand id: #months
> clap months
exit status was 0
Unrecognized arguments: oops, wrong, command
> echo "exit status was $?"
exit status was 1
  <commandline>
  ^ (ClapCommand id: #months)
    meaning: [ :commandMatch | | out |
      out := commandMatch context stdout.
      (1 to: 12)
        do: [ :each | out << each asString ]
        separatedBy: [ out space ].
      out newLine ]
1 2 3 4 5 6 7 8 9 10 11 12
  activateWith: #('months').
5 6 7 8 9 10
  activateWith: #('months' '5' '10').
ctx stdio stdout contents utf8Decoded
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
MessageNotUnderstood: ClapImplicit>>word
end := (commandMatch at: #end) word asNumber.
  ifPresent: [ :m | m word asNumber ]
  ifAbsent: [ 1 ].
end := commandMatch at: #end
  ifPresent: [ :m | m word asNumber ]
  ifAbsent: [ 12 ].
10 11 12
> clap months
1 2 3 4 5 6 7 8 9 10 11 12
  activateWith: #('months' '10').
ctx stdio stdout contents utf8Decoded
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
1 2 3
> clap months-seq 3 7
3 4 5 6 7
> clap months-seq 3 2 7
3 5 7
	— baseDirectory
	— months
	— renter

et je veux dump qui fait un dump donc comme sous commande?

	— dump
			args exitSuccess
				]
			args exitFailure
				]
			args exitFailure:
				]
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
Print the result of a Pharo expression

Usage: evaluate [--help] [--save] [--keepAlive] [<EXPR>]

Parameters:
    <EXPR>      The expression to evaluate, joining successive arguments with spaces (if omitted, read the expression from stdin)

Options:
    --help      Prints this documentation
    --save      Save the image after evaluation
    --keepAlive
                Keep image running
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
  atName: 'help'
  ifFound: [ :help | help value; exitSuccess ].
Hello, help
			args
				atName: 'help'
				ifFound: [ :help |
					help
						value;
						exitSuccess ].
			(self with: args) sayHello ]
	^ self new
		setArguments: arguments;
		yourself