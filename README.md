# MIDI Communications MacOS Layer

**Realtime MIDI IO with Ruby for OSX.**

Access the [Apple Core MIDI framework API](https://developer.apple.com/library/mac/#documentation/MusicAudio/Reference/CACoreMIDIRef/MIDIServices/) with Ruby.

This library is part of a suite of Ruby libraries for MIDI:

| Function | Library |
| --- | --- |
| MIDI Events representation | [MIDI Events](https://github.com/javier-sy/midi-events) |
| MIDI Data parsing | [MIDI Parser](https://github.com/javier-sy/midi-parser) |
| MIDI communication with Instruments and Control Surfaces | [MIDI Communications](https://github.com/javier-sy/midi-communications) |
| Low level MIDI interface to MacOS | [MIDI Communications MacOS Layer](https://github.com/javier-sy/midi-communications-macos) |
| Low level MIDI interface to Linux | **TO DO** (by now [MIDI Communications](https://github.com/javier-sy/midi-communications) uses [alsa-rawmidi](http://github.com/arirusso/alsa-rawmidi)) | 
| Low level MIDI interface to JRuby | **TO DO** (by now [MIDI Communications](https://github.com/javier-sy/midi-communications) uses [midi-jruby](http://github.com/arirusso/midi-jruby))| 
| Low level MIDI interface to Windows | **TO DO** (by now [MIDI Communications](https://github.com/javier-sy/midi-communications) uses [midi-winm](http://github.com/arirusso/midi-winmm)) | 

This library is based on [Ari Russo's](http://github.com/arirusso) library [ffi-coremidi](https://github.com/arirusso/ffi-coremidi).

## Features

* Simplified API
* Input and output on multiple devices concurrently
* Generalized handling of different MIDI Message types (including SysEx)
* Timestamped input events
* Patch MIDI via software to other programs using IAC
* No events history and no buffers optimization

## Requirements

* [ffi](http://github.com/ffi/ffi)

## Installation

If you're using Bundler, add this line to your application's Gemfile:

`gem "midi-communications-macos"`

Otherwise

`gem install midi-communications-macos`

## Documentation

(**TO DO**) [rdoc](http://rubydoc.info/github/javier-sy/midi-communications-macos)

## Differences between [MIDI Communications MacOS Layer](https://github.com/javier-sy/midi-communications-macos) library and [ffi-coremidi](https://github.com/arirusso/ffi-coremidi) library

[MIDI Communications MacOS Layer](https://github.com/javier-sy/midi-communications-macos) is mostly a clone of [ffi-coremidi](https://github.com/arirusso/ffi-coremidi) with some modifications:
* Added locking behaviour when waiting midi events
* Removed buffering and process history information logging (to reduce CPU usage in some scenarios)
* Improved MIDI devices name detection
* Source updated to Ruby 2.7 code conventions (method keyword parameters instead of options = {}, hash keys as 'key:' instead of ':key =>', etc.)
* Updated dependencies versions
* Renamed module to MIDICommunicationsMacOS instead of CoreMIDI
* Renamed gem to midi-communications-macos instead of ffi-coremidi
* TODO: update tests to use rspec instead of rake
* TODO: migrate to (or confirm it's working ok on) Ruby 3.0 and Ruby 3.1

## Then, why does exist this library if it is mostly a clone of another library?

The author has been developing since 2016 a Ruby project called
[Musa DSL](https://github.com/javier-sy/musa-dsl) that needs a way
of representing MIDI Events and a way of communicating with
MIDI Instruments and MIDI Control Surfaces.

[Ari Russo](https://github.com/arirusso) has done a great job creating
several interdependent Ruby libraries that allow
MIDI Events representation ([MIDI Message](https://github.com/arirusso/midi-message)
and [Nibbler](https://github.com/arirusso/nibbler))
and communication with MIDI Instruments and MIDI Control Surfaces
([unimidi](https://github.com/arirusso/unimidi),
[ffi-coremidi](https://github.com/arirusso/ffi-coremidi) and others)
that, **with some modifications**, I've been using in MusaDSL.

After thinking about the best approach to publish MusaDSL
I've decided to publish my own renamed version of the modified dependencies because:

* The original libraries have features
  (buffering, very detailed logging and processing history information, not locking behaviour when waiting input midi messages)
  that are not needed in MusaDSL and, in fact,
  can degrade the performance on some use cases in MusaDSL.
* The requirements for **Musa DSL** users probably will evolve in time, so it will be easier to maintain an independent source code base.
* Some differences on the approach of the modifications vs the original library doesn't allow to merge the modifications on the original libraries.
* Then the renaming of the libraries is needed to avoid confusing existent users of the original libraries.
* Due to some of the interdependencies of Ari Russo libraries,
  the modification and renaming on some of the low level libraries (ffi-coremidi, etc.)
  forces to modify and rename unimidi library.

All in all I have decided to publish a suite of libraries optimized for MusaDSL use case that also can be used by other people in their projects.

| Function | Library | Based on Ari Russo's| Difference |
| --- | --- | --- | --- |
| MIDI Events representation | [MIDI Events](https://github.com/javier-sy/midi-events) | [MIDI Message](https://github.com/arirusso/midi-message) | removed parsing, small improvements |
| MIDI Data parsing | [MIDI Parser](https://github.com/javier-sy/midi-parser) | [Nibbler](https://github.com/arirusso/nibbler) | removed process history information, minor optimizations |
| MIDI communication with Instruments and Control Surfaces | [MIDI Communications](https://github.com/javier-sy/midi-communications) | [unimidi](https://github.com/arirusso/unimidi) | use of [MIDI Communications MacOS Layer](https://github.com/javier-sy/midi-communications-macos, removed process history information, removed buffering, removed command line script)
| Low level MIDI interface to MacOS | [MIDI Communications MacOS Layer](https://github.com/javier-sy/midi-communications-macos) | [ffi-coremidi](https://github.com/arirusso/ffi-coremidi) | removed buffering and process history information, locking behaviour when waiting midi events, improved midi devices name detection, minor optimizations |
| Low level MIDI interface to Linux | **TO DO** | | |
| Low level MIDI interface to JRuby | **TO DO** | | |
| Low level MIDI interface to Windows | **TO DO** | | |

## Author

* [Javier Sánchez Yeste](https://github.com/javier-sy)

## Acknowledgements

Thanks to [Ari Russo](http://github.com/arirusso) for his ruby library [ffi-coremidi](https://github.com/arirusso/ffi-coremidi) licensed under Apache License 2.0.

As explained by **Ari Russo** regarding his library **ffi-coremidi**:
* **ffi-coremidi** began with some coremidi/ffi binding code for MIDI output by [Colin Harris](http://github.com/aberant) contained in [his fork of MIDIator](http://github.com/aberant/midiator) and a [blog post](http://aberant.tumblr.com/post/694878119/sending-midi-sysex-with-core-midi-and-ruby-ffi).
* [MIDIator](http://github.com/bleything/midiator) is (c)2008 by Ben Bleything and Topher Cyll and released under the MIT license (see LICENSE.midiator and LICENSE.prp)
* Also thank you to [Jeremy Voorhis](http://github.com/jvoorhis) for some useful debugging.

### License

[MIDI Communicatios MacOS Layer](https://github.com/javier-sy/midi-communications-macos) Copyright (c) 2021 [Javier Sánchez Yeste](https://yeste.studio), licensed under LGPL 3.0 License

[ffi-coremidi](https://github.com/arirusso/ffi-coremidi) Copyright (c) 2011-2017 [Ari Russo](http://arirusso.com), licensed under Apache License 2.0 (see the file LICENSE.ffi-coremidi)
