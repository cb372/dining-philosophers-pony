// An implementation of the Dining Philosophers problem in Pony.
//
// Loosely based on Viktor Klang's Akka implementation:
// http://klangism.tumblr.com/post/968180337/dining-hakkers

use "time"
use "collections"

primitive Available
primitive Taken
type ForkState is (Available | Taken)
    

actor Fork
  let name: String
  let out: StdStream
  var state: ForkState = Available
  var takenBy: (None val | Philosopher tag) = None
  
  new create(out': StdStream, number: I8) =>
    out = out'
    name = "Fork " + number.string()
    
  be take(philosopher: Philosopher tag) =>
    match state
    | Available => 
      //out.print(name + ": Somebody wants me and I am available")
      state = Taken
      takenBy = philosopher
      philosopher.receiveFork(this)
    | Taken =>
      //out.print(name + ": Somebody wants me but I am already taken")
      philosopher.deniedFork(this)
    end
  
  be put(philosopher: Philosopher tag) =>
    match state
    | Taken =>
      if takenBy is philosopher then
        state = Available
        takenBy = None
      else
        out.print(name + ": That's weird, the wrong person tried to put me down")
      end
    end


primitive Start
primitive Thinking
primitive WaitingForFirstFork
primitive WaitingForSecondFork
primitive DeniedFirstFork
primitive Eating
type PhilosopherState is (Start | Thinking | WaitingForFirstFork | WaitingForSecondFork | DeniedFirstFork | Eating)
   

actor Philosopher
  let out: StdStream
  let name: String
  let left: Fork
  let right: Fork
  var state: PhilosopherState = Start
  var holdingFork: (None val | Fork tag) = None

  let timers: Timers = Timers
  let two_seconds: U64 = 2000000000
  let half_a_second: U64 = 500000000
  
  new create(out': StdStream, name': String, left': Fork, right': Fork) =>
    out = out'
    name = name'
    left = left'
    right = right'
    
  be eat() =>
    match state
    | Thinking =>
      state = WaitingForFirstFork
      left.take(this)
      right.take(this)
    end

  be think() =>
    match state
    | Start =>
      // think for a few seconds, then decide to eat
      out.print(name + " starts to think")
      state = Thinking
      timers(Timer(Eat(this), two_seconds))
    | Eating =>
      // put down my forks, think for a few seconds, then decide to eat again
      out.print(name + " puts down his cutlery and starts to think")
      state = Thinking
      left.put(this)
      right.put(this)
      timers(Timer(Eat(this), two_seconds))
    end

  be receiveFork(fork: Fork) =>
    match state
    | WaitingForFirstFork =>
      // I've received my first fork. Start waiting for the other one.
      //out.print(name + " received his first fork")
      holdingFork = fork
      state = WaitingForSecondFork
    | WaitingForSecondFork =>
      // I've now received both forks, so I can start eating.
      // Eat for a few seconds and then start thinking.
      out.print(name + " starts eating")
      holdingFork = None
      state = Eating
      timers(Timer(Think(this), two_seconds))
    | DeniedFirstFork =>
      // I failed to pick up my first fork, but I picked up the second one.
      // Put it back down and try again.
      //out.print(name + " puts down a fork, because he didn't get the other one")
      state = Thinking
      fork.put(this)
      timers(Timer(Eat(this), half_a_second))
    end
  
  be deniedFork(fork: Fork) =>
    match state
    | WaitingForFirstFork =>
      //out.print(name + " was denied a fork. Will wait for the result of the other fork.")
      state = DeniedFirstFork
    | WaitingForSecondFork =>
      //out.print(name + " was denied his second fork, so he puts down his first one")
      match holdingFork
      | let f: Fork => f.put(this)
      end
      holdingFork = None
      state = Thinking
      timers(Timer(Eat(this), half_a_second))
    | DeniedFirstFork =>
      //out.print(name + " was denied both forks")
      state = Thinking
      timers(Timer(Eat(this), half_a_second))
    end


// TODO Could reduce repetition by using an interface here?
// Also looks like the latest version of Pony supports lambdas?
class Eat is TimerNotify
  let p: Philosopher
  
  new iso create(philosopher: Philosopher) =>
    p = philosopher

  fun ref apply(timer: Timer, count: U64): Bool =>
    p.eat()
    false // do not reschedule


class Think is TimerNotify
  let p: Philosopher
  
  new iso create(philosopher: Philosopher) =>
    p = philosopher

  fun ref apply(timer: Timer, count: U64): Bool =>
    p.think()
    false // do not reschedule


actor Main
  new create(env: Env) =>
    let fork1 = Fork.create(env.out, 1)
    let fork2 = Fork.create(env.out, 2)
    let fork3 = Fork.create(env.out, 3)
    let fork4 = Fork.create(env.out, 4)
    let fork5 = Fork.create(env.out, 5)

    let philosophers = Array[Philosopher](5)
    philosophers.push(Philosopher.create(env.out, "Descartes", fork1, fork2))
    philosophers.push(Philosopher.create(env.out, "Hume", fork2, fork3))
    philosophers.push(Philosopher.create(env.out, "Locke", fork3, fork4))
    philosophers.push(Philosopher.create(env.out, "Russell", fork4, fork5))
    philosophers.push(Philosopher.create(env.out, "Wittgenstein", fork5, fork1))
    
    for p in philosophers.values() do
      p.think()
    end
