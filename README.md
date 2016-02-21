# Dining Philosophers

An implementation of the [Dining Philosophers problem](http://www.wikiwand.com/en/Dining_philosophers_problem) to teach myself [Pony](http://www.ponylang.org/).

In Pony 0.2.1, it works for a few seconds and then segfaults (or sometimes `bus error`s). No idea why. I also managed to make the compiler segfault once!

To compile:

```
$ ponyc
Building . -> /Users/chris/code/dining-philosophers-pony
Building builtin -> /usr/local/Cellar/ponyc/0.2.1/packages/builtin
Building time -> /usr/local/Cellar/ponyc/0.2.1/packages/time
Building collections -> /usr/local/Cellar/ponyc/0.2.1/packages/collections
Building ponytest -> /usr/local/Cellar/ponyc/0.2.1/packages/ponytest
Generating
Optimising
Writing ./dining-philosophers-pony.o
Linking ./dining-philosophers-pony
```

Sample output:

```
$ ./dining-philosophers-pony
Hume starts to think
Descartes starts to think
Locke starts to think
Russell starts to think
Wittgenstein starts to think
Hume starts eating
Hume puts down his cutlery and starts to think
Descartes starts eating
Locke starts eating
Locke puts down his cutlery and starts to think
Descartes puts down his cutlery and starts to think
Wittgenstein starts eating
Hume starts eating
...
...
Descartes starts eating
Locke starts eating
Locke puts down his cutlery and starts to think
Descartes puts down his cutlery and starts to think
Hume starts eating
Russell starts eating
Hume puts down his cutlery and starts to think
Russell puts down his cutlery and starts to think
Wittgenstein starts eating
Locke starts eating
Wittgenstein puts down his cutlery and starts to think
zsh: segmentation fault  ./dining-philosophers-pony
```
