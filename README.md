music-theory
============

A ruby library to work with music theory concepts

Add this line to your application's Gemfile:

```ruby
gem 'music-theory'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install music-theory


## Usage

```ruby
Note.Gs + Interval.perfect(5)
 => D#

Note.Gs(5) - Interval.perfect(5)
 => C#5

Note.Gs(5) - Interval.augmented(6)
 => Bb4

Note.Gs - Interval.augmented(6)
 => Bb

Note.F.sharp.sharp - Interval.diminished(2)
 => E###

Note.F.sharp.sharp + Interval.diminished(2)
 => G
```
